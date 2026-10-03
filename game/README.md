# game/ · Ayastefanos Utancı metin ve görsel prototipi

Suzerain tarzı olay akışı, Paradox tarzı bir harita masasında: Godot 4.7 (GDScript). Zaman çizgisi yarı doğrusaldır: büyük düğümler (1876, 1877–78, 1908, 1914) her oyunda gelir, aralarındaki hikâye iplikleri (Reji, Mısır, Ayastefanos ve Berlin, Doğu Rumeli, Girit) oyuncunun kararlarıyla ayrılır ve açık bir sonuçla kapanır. Harita illerin kimde olduğunu gösterir; harplerde her cephenin dengesi, onu değiştiren olaylar ve kendi sonucu vardır. Masadaki hükümet kaynaktan yazılıdır: 1908–1913 arası sadrazam, Dahiliye, Maliye, Harbiye ve Bahriye nazırları ay hassasiyetinde (Said, Kâmil, Tevfik, Hüseyin Hilmi, İbrahim Hakkı, Said Paşa, Gazi Ahmed Muhtar, Kâmil, Mahmud Şevket, Said Halim) İhsan Güneş'in kabine tablolarına ve Akşin'e dayanır; üst köşedeki kart ve Payitaht penceresi o ayın sadrazamını ve padişahı gösterir, Talat 1909–1917 arası Dahiliye Nazırı olarak yer alır, 1917'den sadrazamdır. Tablo `Lore/Game Design/GD 02 Sistemler.md`'deki `## Kabineler`dedir. Menüde üç açılır kutu vardır: oyun türü (Tarihî varsayılan, ya da Fantezi), tempo (Hızlı varsayılan, ya da Ayrıntılı) ve başlangıç yılı (1873 varsayılan; 1876, 1908, 1913, 1914, 1918; 1873'ten sonrası için oyun o yılın Ocak ayına kadar tarihteki seçimlerle oynanmış sayılır). Hızlı tempoda yalnız hayati ve önemli olaylar (GD 01 sıralamasının S ve A katmanı, zincirler ve alternatif dallar) masaya gelir; ötekiler tarihteki seçenekle kendiliğinden geçer ve yıllar çabuk akar. Ayrıntılı tempoda her olay gelir. Fantezi: bütün seçenekler ve alternatif tarih açıktır. Tarihî modda her olayda tek seçenek görünür: tarihte olan. Seçimin dayanağı olayın altında yazılıdır (kasadaki kitaplar, Wikipedia ya da varsayım).

Masada evrak solda kart listesidir; tıklanan yer, il, cephe, devlet ya da kişi sol altta küçük bir panelde açılır. İl paneli ildeki toplulukların tahminî nüfusunu, güçlerini ve durumlarını gösterir; nüfus olaylarla (muhacirler, tehcir, kıtlık) ve toprak kayıplarıyla değişir. Önemli kişiler (Enver, Talat, Cemal, Mustafa Kemal, Midhat, Gazi Osman ve Ahmed Muhtar paşalar, Goltz, Liman…) haritada o ay bulundukları yerde küçük madalyonlarla durur. Haritada yazılar çakışmaz: daha önemli işaret yer kaplar, kişiler yana kayar, yer adları ve il adları sığmazsa gizlenir.

İstanbul haritada sarı bir başkent yıldızıdır; Babıâli, Yıldız, Galata gibi yerler yıldızın panelinde listelenir. Hükümdarın portresi sağ üstteki karttadır. Kişilerin portreleri döneme göre değişebilir (`görseller:`). Nüfus panelinde `†` ile işaretli kayıplar (ölüler) ayrıca sayılır; devlet panelinde ve son ekranında "Kayıplar" kartı vardır. Rakamlar Wikipedia'daki en yüksek tahminlerdir ve tartışmalıdır (GD 05).

Menüdeki "Kaynakçaları göster" kapalıyken kaynak satırları ve Tarihî moddaki dayanaklar tümüyle gizlenir (ayar `user://settings.cfg`'de). Açıkken her kaynağın başında türünü gösteren bir ikon vardır: kitap (kasadaki kitap, sayfa bağlantılı), W (Wikipedia, ⚠ kasadan değil), soru işareti (tahmin ya da varsayım). Son ekranı, ayardan bağımsız olarak, oyunda tarihten ayrılan her kararı "Tarihte: …" satırıyla listeler.

Sol alttaki panel seçilen her şeyin açıklamasını gösterir: il ve yerlerin 1873–1919 geçmişi (GD 05), devletlerin bir iki paragraflık tarihi, kişilerin özgeçmişi (GD 02); uzun metin "devamı ▾" ile açılır. Olay metinlerindeki mavi kelimeler **wiki** bağlantılarıdır: tıklanınca sağda bir panel açılır. Panelde maddenin Türkçe özeti (GD 06 Sözlük), kitaplardan alıntılar, bağlanan maddeler, geri ve ileri düğmeleri ve bütün maddelerin aranabilir listesi vardır.

**Sonlar koşulludur** (GD 03, yol × sonuç matrisi). Oyun sonunda ya da bir yolun son olayı `☠ karar` dediğinde sekiz satırlık bir tablo yukarıdan aşağı denenir; koşulu tutan ilk satır sondur. Yollar ve sonları:
- **Abdülhamid:** Yıldız'ın Zaferi, Yıldız'da Mütareke ya da Payitahtta Rus Çizmesi.
- **İttihat, Alman ittifakıyla:** Kafkas Zaferi ya da Mondros'tan Samsun'a (tarihî).
- **İttihat ya da Ahrar, harbe girmeden ya da İtilaf'ın yanında:** Tarafsız İmparatorluk, İtilaf'la Bir Barış.
- **Ahrar yolu:** Babıâli basılmaz ya da Balkan Harbi hiç çıkmaz; bu yolda tarafsız kalınıp Edirne tutulursa Ahrar'ın Barışı.

Cephelerin `sınır` listesi varsa denge bozguna düşünce düşman sıradaki ili kendiliğinden işgal eder, zaferde geri alınır (Kars bir sonraki harpte düşebilir).

Debug menüsü (üst çubukta "Debug" ya da F10) seçilen bir yıla atlar: oyun o yıla kadar tarihî seçimlerle gelir, sonra seçilen modda (Fantezi ya da Tarihî) sürer. Debug için otomatik oynatma da vardır: menüde "Otomatik: Tarihî / Fantezi" ya da masada "Otomatik" (F9). Çubukta oynat/duraklat/durdur, adım başına 0,05–2 saniye hız, politika (Tarihî, Rastgele, Alternatif öncelikli) ve "Olayları göster" (mektup açılır, seçilir, kapanır) bulunur.

## Rework: şans, güç ve gündem

Oyunun sözleşmesi `game/REWORK.md`'dedir: bayrak kapıyı açar, güç sonucu belirler.

**Şans ve kademe.** Bir seçenek `şans:` (başarı ya da başarısız) ya da `kademe:` (ezici, zafer, çıkmaz, yenilgi, bozgun) taşıyabilir; ifade kaynakları, bayrakları ve tarihi okur. Olay penceresinde seçeneğin altında önizleme satırı vardır: görünür kaynaklar kesin, gizli kaynaklar ▲/▼, dallar için dağılım ("Başarı %62", "zafer %35 · çıkmaz %30…"), dünya ve il değişiklikleri, `▶` zincir ("bir evrak açar") ve "İleride N evrakı etkiler" (derleyicinin ters dizini). Seçilen dal Defter'e, geçmişe ve son ekranındaki yol haritasına rozet olarak yazılır.

**Tetik olaylar.** `tür: tetik` olaylar bir tarihte kesin gelmez: pencere açıkken ve koşul tutarken her ay ortalama süreye (`ortalama: 18ay`) göre zar atılır. Zorunlu davranırlar. Tarihî modda alternatif tetikler hiç gelmez, tarihî olanlar kendi ayında gelir.

**Tohumlu RNG.** Bütün zarlar oyunun kendi üreticisinden (`rng`) çıkar; tohum kayda yazılır, aynı tohum aynı oyunu verir. **Tarihî mod deterministiktir**: zar atılmaz, `(tarihî)` dal seçilir, cepheler hedef il almaz.

**Cephe modeli.** Harp başında cepheye ulusal havuzdan tümen ayrılır (havuz = Harbiye × 0,6). Her ay etkin güç (ikmal kapasitesini aşan tümen dörtte bir sayılır), moral, mevsim, duruş (taarruz, savunma, geri), komutan ve arazi düşmanın gücüyle kıyaslanır; denge kayar, zayiat ve moral buna göre değişir. Taarruzda denge zafere varınca sıradaki **hedef il** alınır ve ikmal her ele geçen ille zorlaşır (aşırı uzanma); yenilgide önce alınan iller geri gider. Harbiye Nezareti paneli (cephe işaretine tıklayınca, Tarihî modda yalnız okunur) şunları gösterir: etkin güç ve oran, ikmal kapasitesi, aşırı uzanma uyarısı, duruş düğmeleri, komutan seçimi (GD 02'deki `komutan:` puanları), tümen havuzu ve sevkiyat (2 ay sonra varır), hedef iller ve beklenen kayma ile zayiat. Uzayan harp **harp yorgunluğu** (gizli kaynak) biriktirir; moral her ay yorgunluğun elliye bölümü kadar düşer, barışta yıllık kuralla azalır.

**Antlaşmalar cepheyi okur.** Barış ve mütareke olayları koşul ve ifadelerinde cephenin dengesini, işgal edilen ya da alınan illeri ve harp yorgunluğunu okur; sonuç masada ne kazanıldıysa ona bağlıdır.

**Devlet ilişkileri, hizipler, saflar.** Her büyük devlet için gizli bir ilişki kaynağı vardır (`iliski_ru`, `iliski_in`, `iliski_fr`, `iliski_av`, `iliski_it`, `iliski_bu`, `iliski_yu`; Almanya için `alman_nufuzu`): 0 düşmanlık, 50 soğuk tarafsızlık, 100 dostluk. Yıllık kurallar ilişkiyi kaydırır, elçilik kararları (yaklaşma, imtiyaz, borç, askerî heyet) bedelle değiştirir, harpler ilişkiye ve Harbiye'ye bağlı `şans:` ile önlenebilir ya da erken çıkabilir. Hizipler `ordu_sadakati`, `ulema`, `muhalefet` (ve `hakimiyet`, `jon_turk`) eşiklerinde tetik olaylarla darbe ve isyan getirir. Büyük Harp'te saflar dünya anahtarlarındadır (`saf_bu`, `saf_it`, `saf_yu`, `saf_ro`: tarafsız, ittifak ya da itilaf) ve cephelerin düşman gücünü ve açılışını belirler. İlişki ve hizip kaynakları gizlidir: arayüzde sayı yerine ▲/▼ görünür.

**Gündem ağacı** (GD 07). Üst çubuktaki "Gündem" düğmesi (Payitaht'ın yanında) devirlere göre sütunlu bir pencere açar: her kart bitti, yürüyor (ilerleme çubuğu), açık ya da kilitli (nedeniyle) görünür ve süre ile etki önizlemesi taşır. Aynı anda tek gündem yürür; başkasını başlatmak ilerlemeyi siler; süre dolunca etkiler bir kerede uygulanır. `önce:` ön koşulu, `dışlar:` karşılıklı dışlamayı kurar. Tarihî modda tarihî gündemler sırayla kendiliğinden yürür; Fantezi'de oyuncu seçer.

**Bileşik sonlar ve yol haritası.** Son tablosu (GD 03) sonu seçer; ondan bağımsız olarak `son: *` taşıyan kartlar (`ax_` ile başlayan eksenler: Rejim, Toprak, Harp, Topluluklar, Maliye) her sonda koşuluna göre eklenir, sonun kendi kartlarının ardından. Son ekranında ayrıca "Yol haritası" vardır: büyük düğümler ve tarihten ayrılan kararlar sırayla, seçilen dal rozetiyle; "yakın kaçırılanlar" kapanan kapıları ve eksik kalan değerleri gösterir.

## Kaynak tek yerde

Bütün olaylar, kişiler, devletler, sonlar ve kurallar `Lore/Game Design/GD *.md` dosyalarındadır (Obsidian'da okunur, elle düzenlenir). Oyun onları doğrudan okumaz; önce derlenir:

```bash
py game/tools/build_events.py --check
```

Bu komut:
- olayları, koşulları ve etkileri ayrıştırır;
- bayrakları (okunup hiç konmayan hata, konup hiç okunmayan uyarı), bağlantıları (`[[Kitap#p. N]]` gerçek bir sayfaya gitmeli), alıntıları (kitabın o sayfasında geçmeli) ve görselleri denetler;
- dünya durumu anahtarlarını (GD 04), illeri, yerleri, cepheleri, nüfus tablolarını ve kişilerin harita takvimini (GD 05) okur; alternatif olmayan her olayda tam bir `(tarihî)` seçenek arar ve dayanaklarını (kasa / wiki / varsayım) sayar; kayıtta olmayan bir anahtarı, ili ya da devleti hata sayar; hiçbir olayın tepki vermediği sonuçları, Tarihî modda seçeneksiz kalacak olayları ve yalnız alternatif tarihe açılan işaretsiz seçenekleri uyarı sayar;
- kaç seçeneğin yalnız sayı değiştirdiğini raporlar;
- `game/data/events.json`'u yazar;
- kullanılan görselleri küçültüp `game/assets/images/`'a kopyalar, lisanslarını `CREDITS.md`'ye yazar.

`game/data/events.json` elle düzenlenmez.

İl haritası ayrıca üretilir (yalnız GD 05'in `## İller` tablosu değişince gerekir):

```bash
python3 game/tools/build_map.py
```

Natural Earth'ün kamu malı 1:10m idari sınırlarını (ilk çalıştırmada `game/tools/.cache/`'e indirilir, commit edilmez) 1878–1914 vilayetlerine birleştirir; `game/data/map/provinces.json` (Godot) ve `provinces.svg` (her il bir `<path id>`) yazar. `shapely` gerekir.

## Dosyalar

| Yol | Ne yapar |
|---|---|
| `scenes/main.tscn` + `scripts/main.gd` | Kök sahne: oyun durumunu tutar, ekranları değiştirir (menü → masa → son) |
| `scripts/game_state.gd` | Bütün kurallar: kaynaklar, bayraklar, dünya durumu, illerin sahibi ve tutanı, tarih, olayların açılması (gecikmeli zincir, yuva), kararlar, cepheler (denge defteri, aylık seyir, sonuç), mod (Tarihî modda tek seçenek), nüfus (👥 etkileri, toprak kaybında göç, topluluk durumu), kişilerin yeri, yıl dönümü (kurallar + gazete), kayıt |
| `scripts/autoplay.gd` | Oyuncu yerine seçim: Tarihî, Rastgele, Alternatif öncelikli politikaları; masadaki otomatik oynatma ve `sim.gd` kullanır |
| `scripts/logic.gd` | Koşul değerlendirme, metin varyantları, maliyet etiketleri, tarih metni, görsel yükleme |
| `scripts/ui/map_view.gd` | Harita: iller tutanın renginde (sahip başkaysa taralı), kaydırma ve yakınlaştırma, haritaya iğnelenen işaretler, öncelikli çakışma geçişi (işaretler ve il adları üst üste binmez) |
| `scripts/ui/desk.gd` | Masa: ince üst çubuk, solda evrak kartları, haritada mühürler, yerler, Babıâli'de hükümdar madalyonu, kişi madalyonları, cephe işaretleri, sol altta yer / il ve nüfus / devlet / cephe / kişi paneli, zaman kendiliğinden ilerler (buton yok), otomatik oynatma çubuğu |
| `scripts/ui/event_panel.gd` | Olay mektubu (580 px): metin, görsel, nazır görüşleri, seçenekler (kilitli olanlar nedeniyle), sonuç, kaynakça; kararlar da burada açılır |
| `scripts/ui/panels.gd` | Payitaht (hükümdar + üç nazır), Gündem penceresi, devlet dosyası, Defter (iplikler ve toprak defteri), kaynakça/sözlük, yıl sonu gazetesi |
| `scripts/ui/ui_kit.gd` | Ortak görünüm: Viktorya atlası paleti, paneller, mühürler, madalyon |
| `scripts/ui/ending_screen.gd` | Son ekranı ve son kartları |
| `tests/sim.gd` | Başsız oynanış testi ve güç testleri (`-- nopower` onları atlar, `-- quick` rastgele oyunları atlar) |
| `tests/logic_test.gd` | `Logic` birim testi: ifade, koşul, dal önizleme olasılıkları |
| `tests/engine_test.gd` | Motor testi: tohumlu RNG, şans/kademe dalları, tetikler, değer defteri, cephe, gündem, kayıt ve yükleme |
| `tests/ui_smoke.gd` | Her ekranı (Gündem ve Harbiye paneli dahil) bir kez açar |
| `REWORK.md` | Rework sözleşmesi: expr, şans/kademe, RNG, tetik, cephe modeli, devlet ilişkileri, hizipler, Gündem şemaları |
| `Lore/Game Design/GD 07 Gündem.md` | Gündem ağacı (kaynak) |
| `tools/build_events.py` | Derleyici ve denetleyici: `--check` üretir ve denetler, `--selftest` ifade ve dal ayrıştırmasını sınar (Godot bu klasörü görmez: `.gdignore`) |
| `tools/build_map.py` | İl haritasını Natural Earth'ten üretir |
| `tools/fetch_portraits.py` | Kişilerin dönem portrelerini Wikimedia Commons'tan kasaya indirir, lisanslarını yazar |
| `data/map/provinces.json`, `provinces.svg` | Üretilmiş il haritası |

## Test

```bash
godot --headless --path . -s res://game/tests/sim.gd
```

Yedi hazır strateji kendi sonuna ulaşmalı: Hamidiye sıkı yönetimi → Payitahtta Rus Çizmesi, ordusunu koruyan Abdülhamid → Yıldız'ın Zaferi, ihtiyatlı İttihat → Kafkas Zaferi, Enver'i tutan Talat → Tarafsız İmparatorluk, İtilaf'a yanaşan Talat → İtilaf'la Bir Barış, Balkan Harbi'ni önleyen yol → Ahrar'ın Barışı. Rastgele oyunlar en az altı farklı sona ulaşmalı. Tarihî modun tek yolu Son 3'e varmalı ve her olayda yalnız bir seçenek göstermeli; bu yolda 1919'daki nüfus (Ermenilerin 1873'e oranı) ve kişilerin birkaç tarihteki yeri yazdırılır (1912'de Enver Derne'de olmalı). Fantezi modunda 400 rastgele oyunun hepsi bir sonla bitmeli ve en az altı farklı son görülmeli. Test ayrıca ipliklerin ve cephelerin nasıl kapandığını, 1900'de kaç farklı dünya oluştuğunu ve hiçbir oyunda görülmeyen olayları listeler.

Sim ayrıca güç testlerini çalıştırır (cephe modeli, havuz, ikmal, aşırı uzanma, gündem ve tohum tekrarı); `-- nopower` onları atlar, `-- quick` yalnız stratejileri oynar (rastgele 400 oyun yok).

```bash
godot --headless --path . -s res://game/tests/sim.gd -- quick  # hızlı: stratejiler ve güç testleri
godot --headless --path . -s res://game/tests/logic_test.gd    # ifade, koşul, dal olasılıkları
godot --headless --path . -s res://game/tests/engine_test.gd   # tohumlu RNG, dallar, tetik, defter, kayıt
python3 game/tools/build_events.py --selftest                  # derleyicinin ifade/dal ayrıştırması
godot --headless --path . -s res://game/tests/ui_smoke.gd      # her ekranı bir kez açar
xvfb-run -s "-screen 0 1600x900x24" godot --path . --resolution 1600x900 -s res://game/tests/screenshots.gd -- <klasör>
```
