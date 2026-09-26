# game/ · Ayastefanos Utancı metin ve görsel prototipi

Suzerain tarzı olay akışı, Paradox tarzı bir harita masasında: Godot 4.7 (GDScript). Zaman çizgisi yarı doğrusaldır: büyük düğümler (1876, 1877–78, 1908, 1914) her oyunda gelir, aralarındaki hikâye iplikleri (Reji, Mısır, Ayastefanos ve Berlin, Doğu Rumeli, Girit) oyuncunun kararlarıyla ayrılır ve açık bir sonuçla kapanır. Harita illerin kimde olduğunu gösterir; harplerde her cephenin dengesi, onu değiştiren olaylar ve kendi sonucu vardır. Menüden Fantezi (bütün seçenekler ve alternatif tarih açık) ya da Tarihî oyun seçilir. Tarihî modda her olayda tek seçenek görünür: tarihte olan. Seçimin dayanağı olayın altında yazılıdır (kasadaki kitaplar, Wikipedia ya da varsayım).

Masada evrak solda kart listesidir; tıklanan yer, il, cephe, devlet ya da kişi sol altta küçük bir panelde açılır. İl paneli ildeki toplulukların tahminî nüfusunu, güçlerini ve durumlarını gösterir; nüfus olaylarla (muhacirler, tehcir, kıtlık) ve toprak kayıplarıyla değişir. Önemli kişiler (Enver, Talat, Cemal, Mustafa Kemal, Midhat, Gazi Osman ve Ahmed Muhtar paşalar, Goltz, Liman…) haritada o ay bulundukları yerde küçük madalyonlarla durur. Haritada yazılar çakışmaz: daha önemli işaret yer kaplar, kişiler yana kayar, yer adları ve il adları sığmazsa gizlenir.

Debug için otomatik oynatma vardır: menüde "Otomatik: Tarihî / Fantezi" ya da masada "Otomatik" (F9). Çubukta oynat/duraklat/durdur, adım başına 0,05–2 saniye hız, politika (Tarihî, Rastgele, Alternatif öncelikli) ve "Olayları göster" (mektup açılır, seçilir, kapanır) bulunur.

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
| `scripts/ui/desk.gd` | Masa: ince üst çubuk, solda evrak kartları, haritada mühürler, yerler, Babıâli'de hükümdar madalyonu, kişi madalyonları, cephe işaretleri, sol altta yer / il ve nüfus / devlet / cephe / kişi paneli, "Zamanı ilerlet", otomatik oynatma çubuğu |
| `scripts/ui/event_panel.gd` | Olay mektubu (580 px): metin, görsel, nazır görüşleri, seçenekler (kilitli olanlar nedeniyle), sonuç, kaynakça; kararlar da burada açılır |
| `scripts/ui/panels.gd` | Payitaht (hükümdar + üç nazır), devlet dosyası, Defter (iplikler ve toprak defteri), kaynakça/sözlük, yıl sonu gazetesi |
| `scripts/ui/ui_kit.gd` | Ortak görünüm: Viktorya atlası paleti, paneller, mühürler, madalyon |
| `scripts/ui/ending_screen.gd` | Son ekranı ve son kartları |
| `tests/sim.gd` | Başsız oynanış testi |
| `tools/build_events.py` | Derleyici ve denetleyici (Godot bu klasörü görmez: `.gdignore`) |
| `tools/build_map.py` | İl haritasını Natural Earth'ten üretir |
| `data/map/provinces.json`, `provinces.svg` | Üretilmiş il haritası |

## Test

```bash
godot --headless --path . -s res://game/tests/sim.gd
```

İki hazır strateji kendi sonuna ulaşmalı (Hamidiye sıkı yönetimi → Son 1, ihtiyatlı İttihat → Son 2). Tarihî modun tek yolu Son 3'e varmalı ve her olayda yalnız bir seçenek göstermeli; bu yolda 1919'daki nüfus (Ermenilerin 1873'e oranı) ve kişilerin birkaç tarihteki yeri yazdırılır (1912'de Enver Derne'de olmalı). Fantezi modunda 400 rastgele oyunun hepsi bir sonla bitmeli. Test ayrıca ipliklerin ve cephelerin nasıl kapandığını, 1900'de kaç farklı dünya oluştuğunu ve hiçbir oyunda görülmeyen olayları listeler.

```bash
godot --headless --path . -s res://game/tests/ui_smoke.gd      # her ekranı bir kez açar
xvfb-run -s "-screen 0 1600x900x24" godot --path . --resolution 1600x900 -s res://game/tests/screenshots.gd -- <klasör>
```
