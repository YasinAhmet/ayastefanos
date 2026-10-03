# Rework sözleşmesi (orchestrator → işçi ajanlar)

Bu belge, "bayrak kapıyı açar, güç sonucu belirler" reworkünün **ortak sözleşmesidir**. Her işçi ajan yalnız kendi görevine düşen bölümü uygular, ama şemayı ve adları buradan **aynen** alır. Bir şey burada tanımlı değilse uydurmak yerine raporda sorun.

Genel kurallar:
- İçerik `Lore/Game Design/GD *.md`'dedir; `game/data/events.json` elle düzenlenmez, `python3 game/tools/build_events.py --check` ile üretilir ve **0 error** vermelidir.
- Testler: `godot --headless --path . -s res://game/tests/sim.gd` (uzun; `-- quick` varsa onu kullan), `godot --headless --path . -s res://game/tests/ui_smoke.gd`.
- Kodun dili: GDScript 4 (Godot 4.7), tab girintisi, mevcut yorum yoğunluğu ve adlandırma. Python: mevcut stil.
- Oyun metni Türkçe. Vault kuralları (`Lore/Rules.md`): tarihî iddia kasadaki kitaba sayfa bağlantısıyla dayanır; yeni alternatif içerik `alternatif` etiketi taşır ve kaynak satırı `> Kaynak: Alternatif tarih. …` diye başlar. Mekanik sayılar tasarımdır.
- **Tarihî mod deterministiktir**: zar atılmaz, dallarda `(tarihî)` işaretli dal seçilir, tetik olaylar yalnız tarihî olanlar (alternatif değilse) tarihlerinde gelir, cepheler hedef il almaz.
- Ajanlar commit atmaz; orchestrator inceler ve commit eder.

---

## 1. Sayısal ifade (expr)

GD sözdizimi: sayılar (`12`, `0.6`), kaynak adları ya da id'leri (`Harbiye`, `dogu_hazirligi`, derleyicinin `resolve()`'u ile), bayraklar `⚑ad` (0 ya da 1), `+ - * /`, parantez, `min(a,b)`, `max(a,b)`, `ay` (1–12), `yıl`.

JSON AST (derleyici üretir, `Logic.eval_expr(node, state) -> float` değerlendirir):

```
{"n": 3.5}                          sayı
{"v": "harbiye"}                    kaynak değeri (state.value_of)
{"f": "goltz_serbest"}              bayrak → 1.0 / 0.0
{"k": "ay"} | {"k": "yil"}          tarih
{"op": "+"|"-"|"*"|"/", "a": X, "b": X}   (/ sıfıra bölmede 0)
{"op": "neg", "a": X}
{"fn": "min"|"max", "args": [X, X]}
```

Derleyici fonksiyonu: `parse_expr(where, text, resolve) -> (ast, flags_read_list)`; bilinmeyen ad error.

## 2. Olasılıklı ve kademeli seçenekler

Seçenek satırında özel bir backtick alanı ve altında girintili dal satırları:

```
1. **Taarruz emri ver.** `şans: 30 + (Harbiye-50)*1.2 + ⚑goltz_serbest*10` `Para -5` — ortak sonuç metni (isteğe bağlı)
   - başarı: `kafkas_93 +10 · +⚑x` — başarı metni
   - başarısız (tarihî): `Harbiye -8` — başarısızlık metni
```

```
1. **Saldırıyı Ocak'ta başlat.** `kademe: Harbiye*0.6 + dogu_hazirligi*0.4 - 50 ± 15` `Para -5` — ortak metin
   - ≥25 ezici: `…` — metin
   - ≥8 zafer: `…` — metin
   - ≥-8 çıkmaz: `…` — metin
   - ≥-25 yenilgi: `…` — metin
   - bozgun (tarihî): `…` — metin
```

Kurallar: `şans` iki dal ister (`başarı`, `başarısız`); `kademe` en az iki dal, sonuncusu eşiksiz, eşikler azalan. `± N` yazılmazsa yayılım 10. Seçenek `(tarihî)` ise dallarından tam biri `(tarihî)` olmalı (error). Ortak etkiler (aynı satırdaki diğer backtick alanları) her durumda uygulanır. Dalların etkileri normal etki sözdizimidir (bayrak, ▶, ≡, 🗺, 👥, ☠ dahil).

JSON (seçeneğin `effects` listesine tek bir etki olarak eklenir, ortak etkilerden sonra):

```
{"t":"roll", "chance": EXPR,
 "branches":[{"label":"başarı","min":null,"effects":[...],"text":TEXT,"hist":false},
             {"label":"başarısız","min":null,"effects":[...],"text":TEXT,"hist":true}]}
{"t":"tier", "expr": EXPR, "spread": 15,
 "branches":[{"label":"ezici","min":25,"effects":[...],"text":TEXT,"hist":false}, …, {"label":"bozgun","min":null,…}]}
```

`TEXT`, derleyicinin `compile_text` çıktısıdır (outcome ile aynı biçim).

Motor: `şans` → p = clamp(eval, 5, 95)/100, `rng.randf() < p` ise branches[0]. `kademe` → x = eval + rng.randf_range(-spread, spread); `min` değeri `x >= min` olan ilk dal, yoksa son dal. Tarihî modda zar yok: `hist` dalı. Seçilen dal `history` kaydına `"branch": label` ve `"branch_text"` olarak yazılır; `choose()` dönüşünde `outcome`, dal metni eklenmiş haliyle döner ve ayrıca `"branch"` anahtarı taşır.

Önizleme: `Logic.branch_odds(effect, state) -> Array[{label, p}]` (p 0..1). `şans`: [p, 1-p]. `kademe`: x ± spread'in düzgün dağılımında her dal aralığının payı (analitik).

## 3. RNG

`GameState`: `var rng := RandomNumberGenerator.new()`, `var rng_seed := 0`. `new_game(..., seed := 0)`: seed 0 ise `randi()` ile üretilir; `rng.seed = rng_seed`. Kayıt `SAVE_VERSION = 3`: `rng_seed` ve `rng.state` saklanır, eski kayıtlar seed 0 ile yüklenir. Bütün oyun zarları `gs.rng` üzerinden atılır (globale `randf()` yok). Yardımcılar: `func chance(p: float) -> bool`, `func roll_range(a, b) -> float`; ikisi de `historical()` ise deterministik (chance → p >= 0.5, roll_range → orta nokta) döner.

## 4. Tetik olaylar (MTTH)

GD: `tür: tetik` (alternatifse `tür: tetik · alternatif`), tarih başlığı **en erken** tarihtir, `bitiş: YYYY-MM` isteğe bağlı, `ortalama: 18ay` (ya da `2yıl`) zorunlu, `koşul:` zorunlu. Derleyici: `KINDS`'a `tetik`; JSON'da `"kind":"tetik"`, `"mtth": ay_sayısı`.

Motor: her ay (`advance` döngüsünde, `_front_tick` yanında) `_trigger_tick()`: cevaplanmamış, kuyrukta olmayan, penceresi açık ve koşulu tutan her tetik olay için `chance(1 - pow(0.5, 1.0/mtth))` tutarsa olay `queued`'a girer (o ay açılır). Tarihî modda: alternatif tetikler hiç gelmez; alternatif olmayan tetik, tarihindeki ayda gelir (zar yok). Tetik olaylar zorunlu davranır (zamanı durdurur).

## 5. Ters dizin ve değer defteri

Derleyici `events.json`'a `"reverse"` yazar: `{"flag:ad": [event_id,…], "world:anahtar": [...], "res:id": [...]}`. Bir anahtarı **okuyan** (koşul, metin varyantı, option cond, expr, son koşulu) olayların id'leri; sonlar `"end:son_id"` olarak listelenir.

Motor: `value_log: Dictionary` (kaynak id → `[{y, m, d, by}]`), `_add()` her değişimi `_acting` (yoksa "Yıllık kural" / "Cephenin kendi seyri") ile yazar; aynı ay aynı `by` birleştirilir. Kayda girer.

## 6. Cephe modeli (Faz 3)

### GD 05 cephe alanları

Mevcut alanlar kalır. `karşı:` **kaldırılır**, yerine:

| alan | tür | anlam |
|---|---|---|
| `kuvvet: 12` | int | harp başında cepheye ayrılan tümen (havuzdan, yetmezse ne varsa) |
| `düşman_güç: EXPR` | expr | düşmanın etkin tümen gücü (ör. `16 - ⚑rus_ihtilali*9`) |
| `ikmal: EXPR` | expr | ikmal kapasitesi, tümen cinsinden (ör. `8 + ⚑dogu_hatti_1*3 + dogu_hazirligi/10`) |
| `arazi: dağ` | dağ / ova / çöl / kale / deniz | mevsim ve savunma çarpanı |
| `hedef: kars, batum, ardahan` | il listesi | taarruzda sırayla alınacak düşman/kayıp iller (isteğe bağlı) |

### Durum

`GameState.fstate[fid] = {"div": float, "stance": "savunma", "commander": "", "morale": 70.0, "depth": 0, "taken": [], "losses": 0.0, "incoming": [{"div": n, "at": month_key}]}`; harp ilk görünür olduğunda oluşturulur. Kayda girer.

Ulusal havuz: `army_total() = roundi(value_of("harbiye") * 0.6)`; `army_reserve() = army_total() - Σ div (aktif cepheler) - Σ incoming`. Negatifse yeni tahsis yapılamaz (mevcutlar erimez).

### Aylık hesap (`_front_tick`, aktif her cephe)

```
nitelik   q = 0.4 + harbiye/75 (+ komutanın "nitelik" puanı/100)
kapasite  cap = max(1, eval(ikmal) - 2*depth  (+ komutanın "ikmal"/10))
etkin     eff = div if div <= cap else cap + (div-cap)*0.25
moral     m = 0.5 + morale/200
mevsim    dağ: Ara–Mar 0.6 · çöl: Haz–Ağu 0.75 · diğer 1.0   (yalnız taarruz ve geri çekilmede; savunmada 1.0)
duruş     taarruz 1.3 · savunma 1.0 · geri 0.8
komutan   1 + (taarruz|savunma puanı duruşa göre)/100
bizim     ours = eff * q * m * mevsim * duruş * komutan
düşman    enemy = max(1, eval(düşman_güç)) * (arazi=="kale" ve depth>0 ise 1.2) * (savunma duruşunda arazi dağ/kale ise 0.85)
oran      r = ours / enemy
kayma     d = clamp(roundi(14*ln(r)) + noise, -6, 6); noise = roundi(roll_range(-1.5, 1.5))
          taarruz: d>0 ise d = roundi(d*1.5)+1 · savunma: d = roundi(d*0.6) · geri: d = min(d, 0) - 1
zayiat    L = div*0.01 * clamp(1/r, 0.3, 3) * duruşK(taarruz 2.0, savunma 0.7, geri 0.5)
          * (1.8 eğer mevsim<1) * exp(0.45*depth) * (1 + max(0, div-cap)*0.08) * (1 + komutanın "aşırı"/100 eğer taarruz)
moral     d>0: +2 · d<0: -3 · L > div*0.03: -4 ; clamp 10..100
```

`div -= L`, `fstate.losses += L`, ölüler: `_record_death("turk", L*10, <cephenin ilk ili>)` (bin kişi). Cephe değeri `_add(value, d)`.

Tarihî modda: noise 0, cephe hedef almaz (sınır kaybı mevcut davranışıyla sürer).

### Toprak (iki yönlü `_front_border`)

En çok `BORDER_EVERY = 4` ayda bir:
- değer `>= zafer` ve duruş `taarruz` ve `depth < hedef.size()` → sıradaki hedef ili `_set_province(il, "OS", false)`, `depth += 1`, `taken.append`, değer 55'e çekilir (sonraki il yeniden kazanılmalı).
- değer `<= yenilgi` → önce `taken`'dan son il düşmana geri (depth -= 1), o yoksa mevcut davranış (sınır listesinden bir il düşer).
- değer `>= zafer` ve duruş taarruz değil → mevcut davranış (düşmanın aldığı ilk geri alınır).

### Oyuncu eylemleri (UI'nin çağırdığı API)

`set_stance(fid, s)`, `set_commander(fid, pid)` (bir kişi tek cephede), `transfer(fid, n)` (n>0: havuzdan, 2 ay sonra `incoming`→`div`; n<0: anında havuza), `commanders_for(fid) -> Array` (dönemi tutan ve hayatta olanlar), `front_report(fid) -> Dictionary` (`ours, enemy, ratio, cap, eff, expected_drift, expected_losses, morale, div, depth, next_target, overextended:bool`). UI bunları gösterir; `changed` sinyali yayınlanır.

### Komutanlar (GD 02)

Kişi bloğuna alan: `komutan: taarruz +20 · savunma +5 · ikmal -10 · aşırı +40 · nitelik 0` ve `komuta: 1911-1918` (yıl aralığı). JSON `persons[pid].commander = {"taarruz":20,"savunma":5,"ikmal":-10,"asiri":40,"nitelik":0,"from":1911,"to":1918}`.

### Harp yorgunluğu

Gizli kaynak `harp_yorgunlugu` (GD 02 tablosu, başlangıç 0). Ayda Σ L*1.5 kadar artar (yuvarlanır), barışta yıllık kural ile −15/yıl. Etkisi: moral her ay −yorgunluk/50. Barış olayları sonra yazılır (Faz 4).

## 7. Önizleme (UI)

`event_panel.gd`: seçenek düğmesinin altında küçük bir satır/ipucu:
- görünür kaynaklar kesin (`Logic.effect_chips`), gizli kaynaklar ▲/▼ adıyla;
- `roll`/`tier` için dağılım: "Başarı %62" ya da "ezici %10 · zafer %35 · çıkmaz %30 · yenilgi %20 · bozgun %5";
- dünya/il değişiklikleri ve `▶` zincir ("bir evrak açar");
- ters dizinden: "İleride N evrakı etkiler" (seçeneğin koyduğu bayrak ve dünya değerlerinin `reverse` listelerinin birleşimi, kendisi hariç).

## 8. Devlet ilişkileri (veri ile, motor değişmeden)

Her büyük devlet için GD 02 kaynak tablosunda **gizli** bir kaynak: `iliski_ru` (İlişki: Rusya), `iliski_in` (İngiltere), `iliski_fr` (Fransa), `iliski_av` (Avusturya-Macaristan), `iliski_it` (İtalya), `iliski_bu` (Bulgaristan), `iliski_yu` (Yunanistan). 0 düşmanlık, 50 soğuk tarafsızlık, 100 dostluk. Almanya için mevcut `alman_nufuzu` kullanılır. Başlangıçlar tasarım: RU 25, IN 55, FR 50, AV 40, IT 45, BU 30 (1878'den önce Bulgaristan yok, yine de değer tutulur), YU 30.

- **Kayma** yıllık kurallarla (`tür: kural`): ör. Rusya Balkan'da ilerledikçe −, Girit/Ermeni meselesi Avrupa ile ilişkileri bozar; ilişki değeri `avrupa_baskisi`'ni etkiler.
- **Elçilik kararları** (`tür: karar`, `yer:` mevcut landmark — Galata, Babıâli ya da devletin konumu): yaklaşma, imtiyaz, borç, askerî heyet. Bedel Para ya da başka bir ilişki.
- **Harpler koşula bağlanır**: tarihî harplerin başlangıç olaylarına alternatif bir "harbi önle" seçeneği `şans:` ile eklenir (ilişki, Harbiye ve avrupa_baskisi formülde); tarihî seçenek harbi başlatır. Ayrıca alternatif harp tetikleri (`tetik · alternatif`): ilişki çok düşük ve Harbiye zayıfsa erken harp; ilişki yüksekse ittifak teklifleri.
- **Büyük Harp safları**: dünya anahtarları (GD 04) `saf_bu`, `saf_it`, `saf_yu`, `saf_ro` (değerler `tarafsiz`, `ittifak`, `itilaf`; tarihî: BU ittifak 1915, IT itilaf 1915, YU itilaf 1917, RO itilaf 1916). 1914–1916'daki ilgili olaylar ilişki değerlerine göre `≡` koyar (şans ile). Cephe `düşman_güç` ifadeleri ve `koşul`ları bu değerleri okuyabilir (ör. Bulgaristan ittifakta değilse Trakya cephesi açılır).

## 9. Hizipler (veri ile)

GD 02'ye gizli kaynaklar: `ordu_sadakati` (ordunun hükümete bağlılığı, 60), `ulema` (ulema ve medrese tabanının gücü, 45), `muhalefet` (Ahrar/İtilaf ve Hürriyet; saray yolunda Jön Türk dışı muhalefet, 20). `hakimiyet` ve `jon_turk` kalır. Darbeler, karşı darbeler ve isyanlar bu değerlerin eşiklerinde **tetik** olaylarla gelir; sonuçları `şans`/`kademe` ile güce bağlıdır (ör. 31 Mart benzeri: `ulema >= 60 & ordu_sadakati <= 40`; Babıâli baskını benzeri: `jon_turk >= 70 & muhalefet >= 50`). Tarihî olaylar bu değerleri tarihî yönde kaydırır ki tarihî yol tutarlı kalsın.

## 10. Gündem ağacı (motor + derleyici + UI)

GD dosyası: `Lore/Game Design/GD 07 Gündem.md`. Blok:

```
### Gündem · Alman usulü ordu
`gündem: g_alman_ordu` · `devir: 1880-1908` · `süre: 18ay` · `önce: g_harbiye_islahat` · `dışlar: g_ingiliz_bahriye, g_milis` · `tarihî` · `bayrak: AL`
`koşul: !⚑yol_ittihat`
Bir paragraf açıklama.
> Kaynak: …
`etki: Harbiye +10 · alman_nufuzu +10 · jon_turk +5 · +⚑goltz_serbest`
```

Alanlar: `gündem` (id, `g_` önekli), `devir: YYYY-YYYY` (başlatılabileceği yıllar), `süre: Nay|Nyıl`, `önce` (hepsi bitmiş olmalı; isteğe bağlı), `dışlar` (biri bitmiş/başlamışsa bu kilitli; karşılıklı yazılmalı, derleyici simetriyi denetler), `tarihî` (tarihte izlenen yol; Tarihî mod bunları sırayla otomatik yürütür), `bayrak`, `koşul`, `etki` (normal etki sözdizimi; şans/kademe yok). Derleyici JSON: `"focuses": {id: {id, name, text, from, to, months, requires, excludes, hist, cond, effects, sources, nation}}`; bilinmeyen id error; `önce` döngüsü error.

Motor (`game_state.gd`): `focus_current := ""`, `focus_progress := 0`, `focus_done := {}` (id → month_key), kayda girer. `focus_state(id) -> "done"|"active"|"available"|"locked"` ve `focus_lock_reason(id)`. `start_focus(id)` (yalnız available; aktif varsa önce iptal — ilerleme kaybolur), `cancel_focus()`. `advance` içinde her ay aktif gündem `focus_progress += 1`; `>= months` olunca `_acting = name` ile etkiler uygulanır, `focus_done`, `history`'ye `{"id": id, "title": name, "option": "Gündem tamamlandı", "focus": true, …}` ve `year_log`'a kayıt. Tarihî modda: aktif yoksa `hist` olan ilk available gündem otomatik başlar; oyuncu başlatamaz. Fantezi'de oyuncu seçer; sim/autoplay rastgele seçer.

UI: üst çubukta "Gündem" düğmesi (Payitaht'ın yanında) → `panels.gd`'de pencere: devirlere göre sütunlar, her gündem kartı durumuna göre renkli (bitti/aktif + ilerleme çubuğu/açık/kilitli + neden), kartta açıklama, süre ve etki önizlemesi (`event_panel` önizleme mantığıyla aynı metin), "Başlat" düğmesi.
