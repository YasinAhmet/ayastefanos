---
tags: [game-design]
---
# GD 02 · Sistemler

Oyunun kuralları: kaynaklar, gizli değerler, Payitaht, devletler, olay yazımı, yıllık kurallar ve gazete. Geri: [[GD 00 Rehber]] · Sonlar: [[GD 03 Sonlar ve Yollar]].

> [!info] Sayılar tasarımdır
> Kasadaki kitaplarda maliyet, bütçe ya da güç rakamı yok denecek kadar azdır (Hamidiye alaylarının maliyeti, Şerif'e verilen tahsisat, donanmanın bakım gideri hiçbir kitapta yok). Bu yüzden aşağıdaki bütün sayılar **oyun dengesi** içindir, kaynak değildir. Kaynak gösterilen şey olayın kendisidir, sayısı değil.

## Kaynaklar

Görünür olanlar masada, çubuk olarak durur (0–100). Gizli olanları oyuncu sayı olarak görmez; nazırların sözlerinden, gazete manşetlerinden ve açılan ya da kapanan seçeneklerden sezer (Suzerain'deki gibi).

| id | Ad | Başlangıç | Görünür | Açıklama |
|---|---|---|---|---|
| para | Para | 25 | evet | Hazine. Her şeyi o satın alır. Her yıl gelir gelir; 1875 iflasından sonra borç yükü, 1881'den sonra Düyun-u Umumiye payı düşer. Sıfıra inerse dış borç olayı çıkar. |
| harbiye | Harbiye | 45 | evet | Kara ordusu. Abdülhamid yolunda bakılmazsa her yıl çürür. |
| bahriye | Bahriye | 70 | evet | Donanma. Abdülaziz'in zırhlılarıyla yüksek başlar; Haliç'e kapatılırsa hızla çürür. |
| ermeniler | Ermeniler | 25 | evet | Ermeni milli hareketinin gücü (komiteler, cemaatin siyasi ağırlığı, Avrupa'daki sesi). Yükseldikçe doğuda olaylar sertleşir. Tehcir edilirse neredeyse sıfıra iner. |
| araplar | Araplar | 40 | evet | Arap vilayetlerinde özerklik ve isyan gücü (Şerif, aşiretler, cemiyetler). 1916 isyanının çıkıp çıkmamasını belirler. |
| kurtler | Kürtler | 35 | evet | Kürt aşiretlerinin gücü. Doğuda yetki onlara bırakılırsa yükselir; ucuzdur ama bedeli başka yerden ödenir. |
| hakimiyet | Hâkimiyet | 45 | hayır | Sarayın (sonra Cemiyet'in) devlet üzerindeki denetimi. 1908 yol ayrımını belirler. |
| jon_turk | Jön Türk ruhu | 10 | hayır | Subaylar ve mektepliler arasında meşrutiyet ateşi. Ordu modernleştikçe yükselir: güçlü ordu ile güvenli taht birbirini iter. |
| alman_nufuzu | Alman nüfuzu | 5 | hayır | Berlin'in etkisi. Demiryolu yardımını ve askerî heyetin işe yarayıp yaramayacağını belirler. |
| dogu_hazirligi | Doğu hazırlığı | 10 | hayır | Doğu cephesinin kışa, ikmale ve salgına hazırlığı (yol, demiryolu, depo, kaput, hastane). Sarıkamış'ı belirler. |
| avrupa_baskisi | Avrupa baskısı | 35 | hayır | Büyük devletlerin baskısı: ıslahat talepleri, müdahale, barış şartları. |
| enver_iliskisi | Enver'le ilişki | 50 | hayır | İttihat yolunda Talat'ın Enver'i ne kadar durdurabileceği. İhtiyat onu harcar. |
| cokus | Çöküş | 0 | hayır | Abdülhamid yolunda harp başlayınca işleyen sayaç. 100'e varınca Rus ordusu Payitahttadır. |
| kafkas | Kafkas cephesi | 50 | hayır | Cephe dengesi: 0 düşmanın, 100 bizim. Harp yıllarında haritada cephe işaretinde görünür; her ay ordunun gücüne göre bir puan kayar. Bkz. [[GD 05 Harita ve Harpler#Harpler ve cepheler]]. |
| canakkale | Çanakkale cephesi | 50 | hayır | Cephe durumu. |
| irak | Irak cephesi | 50 | hayır | Cephe durumu. |
| filistin | Filistin cephesi | 50 | hayır | Cephe durumu. |
| hicaz | Hicaz cephesi | 50 | hayır | Cephe durumu. |
| tuna_93 | Tuna ve Balkan cephesi ('93) | 50 | hayır | 93 Harbi'nin Rumeli cephesi (bkz. [[GD 05 Harita ve Harpler#Harpler ve cepheler]]). |
| kafkas_93 | Kafkas cephesi ('93) | 50 | hayır | 93 Harbi'nin doğu cephesi. |
| trablus | Trablusgarp cephesi | 50 | hayır | 1911–12 İtalya harbi. |
| trakya | Trakya cephesi | 50 | hayır | 1912–13 Balkan Harbi. |

**Denge ölçüsü (yazarlar için):** küçük etki ±3–5 · orta ±8–12 · büyük ±15–25. Yıllık gelir +10'dur; bir yılda iki büyük harcama yapan oyuncu ertesi yıl darda kalmalıdır. Her seçenek bir şey verir, bir şey alır: bedava seçenek ancak bir emirle çözülen durumlarda olur (ör. depodaki kaputların dağıtılması).

## Payitaht

Masadaki Payitaht düğmesi hükümdarı ve üç nazırı gösterir. Bir nazırın sözü, bağlı olduğu kaynağın düzeyi kadar ağır basar (Harbiye 20'nin altındaysa Harbiye Nazırı'nın uyarısı "kimse dinlemiyor" diye soluk görünür). Kişiler:

### Kişi · Sultan Abdülaziz
`kişi: abdulaziz` · `unvan: Sultan Abdülaziz (1861–1876)` · `görsel: Abdulaziz (Sultan of the Ottoman Empire).jpg` · `rol: hükümdar`
Oyunun ilk hükümdarı. Dolmabahçe'de oturur; donanması tonilatoda Avrupa'nın ikincisidir, hazinesi borçla döner. Kötü yönetimden, özellikle mali iflastan sorumlu tutulur ve 30 Mayıs 1876'da tahttan indirilir.
> Kaynak: [[Abdülaziz]] · [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 25|Akşin, *Kısa Türkiye Tarihi*, loc. 25]] · [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 26|Akşin, loc. 26]] · *Türk kaynağı*

### Kişi · Sultan II. Abdülhamid
`kişi: abdulhamid` · `unvan: Sultan II. Abdülhamid (1876–1909)` · `görsel: Abdülhamid II of Turkey.jpg` · `rol: hükümdar`
13 Şubat 1878'den sonra imparatorluğu Yıldız Sarayı'ndan mutlak bir otoriteyle yönetir. Şehzadeliğinde harçlığını iyi kullanmış, sultanken de servetini Galatalı sarraf Agop Zarifi eliyle yurt dışında işletmiştir. Ürkek, "saçma sapan korkulara kapılan" biri olarak betimlenir; sarayda sade yaşar.
> Kaynak: [[Abdülhamid II]] · [[Enver (Murat Bardakçı)#p. 62|Bardakçı, *Enver*, p. 62]] · *Türk kaynağı* · [[Osmanlı İmparatorluğu Tarihi (Robert Mantran)#p. 654|Mantran, *Osmanlı İmparatorluğu Tarihi*, p. 654]] · *Fransız kaynağı*

### Kişi · Talat
`kişi: talat` · `unvan: Talat Bey, Dahiliye Nazırı (1917'den Sadrazam Talat Paşa)` · `rol: hükümdar`
Edirneli posta memuru, İttihat ve Terakki'nin sivil lideri. İttihatçı hareketin "başlıca güçlü adamı"dır, ama iktidarı öteki güçlü adamlarla paylaşmak zorundadır; Enver kendi isteğini bütün ülkeye kabul ettirebilir. İttihat yollarında oyuncu onun masasındadır.
> Kaynak: [[Talat Paşa]] · [[Osmanlı İmparatorluğu Tarihi (Robert Mantran)#p. 766|Mantran, p. 766]] · *Fransız kaynağı* · [[Birinci Dünya Savaşı'nda Türkiye (Ahmet Emin Yalman)#p. 98|Yalman, *Birinci Dünya Savaşı'nda Türkiye*, p. 98]] · *Türk kaynağı*

### Kişi · Sultan Vahdettin
`kişi: vahdettin` · `unvan: Sultan VI. Mehmed Vahdettin (1918–1922)` · `görsel: 1909 10 Resimli Kitab Vahdettin.jpg` · `rol: hükümdar`
Son Osmanlı padişahı. Mütareke yıllarında Damat Ferid onun adına davranır. Tarihî yolda Talat kaçtıktan sonra masa onundur: işgalin, divanıharplerin ve Anadolu'dan gelen seslerin önünde.
> Kaynak: [[Mehmed VI Vahdettin]] · [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 101|Akşin, loc. 101]] · *Türk kaynağı*

### Kişi · Maliye Nazırı
`kişi: maliye_nazir` · `unvan: Maliye Nazırı` · `rol: maliye`
Abdülaziz ve Abdülhamid devrinin maliye nazırlarının adı kasada geçmez; oyunda adsız bir nazır olarak durur. Maaş günü altı yüz bin lirayı bulmak onun işidir: Osmanlı Bankası'na, Reji'ye, Düyun-u Umumiye'ye yalvararak avans koparır.
> Kaynak: [[Enver (Murat Bardakçı)#p. 66|Bardakçı, *Enver*, p. 66]] · *Türk kaynağı*

### Kişi · Serasker Hüseyin Avni Paşa
`kişi: huseyin_avni` · `unvan: Serasker Hüseyin Avni Paşa` · `görsel: Huseyin avni pasha.jpg` · `rol: harbiye`
Abdülaziz'in seraskeri; padişahın tahttan indirilip hayatının sona ermesinden "birinci derece sorumlu" tutulur. 15 Haziran 1876'da Çerkes Hasan tarafından öldürülür.
> Kaynak: [[Hüseyin Avni Paşa]] · [[Enver (Murat Bardakçı)#p. 61|Bardakçı, *Enver*, p. 61]] · *Türk kaynağı*

### Kişi · Hobart Paşa
`kişi: hobart` · `unvan: Hobart Paşa, donanma müşaviri` · `görsel: Augustus Charles Hobart-Hampden - Project Gutenberg eText 16296.jpg` · `rol: bahriye`
Amerikan İç Savaşı'nın abluka yarıcısı İngiliz denizci; Girit isyanı sırasında Osmanlı Bahriyesi'ne girer. Kasada bu yıllar için bir Bahriye Nazırı adı geçmediğinden oyunda donanmanın sesi odur.
> Kaynak: [[Hobart Paşa]] · [[Hobart Paşa'nın Anıları (Augustus C. Hobart-Hampden)#p. 14|Hobart-Hampden, *Hobart Paşa'nın Anıları*, p. 14]] · *İngiliz kaynağı*

### Kişi · Serasker Rıza Paşa
`kişi: riza_pasa` · `unvan: Serasker Rıza Paşa` · `rol: harbiye`
Abdülhamid devrinin seraskeri; kasada yalnızca adıyla geçer. Oyunda sarayın sadık, orduyu yerinde saydıran seraskeridir.
> Kaynak: [[Enver (Murat Bardakçı)#p. 600|Bardakçı, *Enver*, p. 600]] · *Türk kaynağı*

### Kişi · Bahriye Nazırı Hasan Hüsnü Paşa
`kişi: hasan_husnu` · `unvan: Bahriye Nazırı Hasan Hüsnü Paşa` · `rol: bahriye`
Abdülhamid devrinin Bahriye Nazırı. Donanma onun zamanında Haliç'te bekler.
> Kaynak: [[Sultanın Paşaları (Olivier Bouquet)#p. 498|Bouquet, *Sultanın Paşaları*, p. 498]] · *Fransız kaynağı*

### Kişi · Cavid Bey
`kişi: cavid` · `unvan: Maliye Nazırı Cavid Bey` · `görsel: Djavid Bey.png` · `rol: maliye`
Selanikli iktisatçı, İttihatçıların maliye nazırı ve iç çevrenin en savaş karşıtı sesi. 1 Ağustos 1914'te Alman ittifakını okuyup bir taslak sanmıştır.
> Kaynak: [[Cavid Bey]] · [[Türkiye'de Hükümetler (İhsan Güneş)#p. 88|Güneş, *Türkiye'de Hükümetler*, p. 88]] · [[Birinci Dünya Savaşı'nda Türkiye (Ahmet Emin Yalman)#p. 96|Yalman, p. 96]] · *Türk kaynağı*

### Kişi · Mahmud Şevket Paşa
`kişi: mahmud_sevket` · `unvan: Harbiye Nazırı Mahmud Şevket Paşa` · `rol: harbiye`
Alman terbiyeli asker, Hareket Ordusu'nun komutanı; 1910'dan Harbiye Nazırı, 1913'te sadrazam. 11 Haziran 1913'te öldürülür.
> Kaynak: [[Mahmud Şevket Paşa]] · [[Türkiye'de Hükümetler (İhsan Güneş)#p. 99|Güneş, p. 99]] · *Türk kaynağı*

### Kişi · Ahmed İzzet Paşa
`kişi: ahmed_izzet` · `unvan: Harbiye Nazırı Ahmed İzzet Paşa` · `görsel: Ahmet İzzet Paşa.jpg` · `rol: harbiye`
Alman terbiyeli kurmay; Mahmud Şevket'in öldürülmesinden sonra Said Halim Paşa kabinesinde Harbiye Nazırı (Haziran 1913), Aralık 1913'te yerini Enver'e bırakır. Ekim 1918'de mütareke kabinesinin sadrazamıdır.
> Kaynak: [[Ahmed İzzet Paşa]] · [[Türkiye'de Hükümetler (İhsan Güneş)#p. 127|Güneş, *Türkiye'de Hükümetler*, p. 127]] · *Türk kaynağı*

### Kişi · Bahriye Nazırı
`kişi: bahriye_nazir` · `unvan: Bahriye Nazırı` · `rol: bahriye`
1909–1913 arasında Bahriye Nezareti kabineden kabineye el değiştirir; oyunda adsız bir nazırdır.
> Kaynak: [[Türkiye'de Hükümetler (İhsan Güneş)#p. 114|Güneş, p. 114]] · *Türk kaynağı*

### Kişi · Enver Paşa
`kişi: enver` · `unvan: Harbiye Nazırı Enver Paşa` · `görsel: Enver Pasha 1911.jpg` · `rol: harbiye`
1908'in kahraman subayı, Ocak 1914'ten Harbiye Nazırı. "Sadece Enver Paşa, kendi isteğini tüm ülkeye kabul ettirdi." Talat onu ancak ilişkileri yettiği kadar durdurabilir.
> Kaynak: [[Enver Paşa]] · [[Türkiye'de Hükümetler (İhsan Güneş)#p. 127|Güneş, p. 127]] · [[Birinci Dünya Savaşı'nda Türkiye (Ahmet Emin Yalman)#p. 98|Yalman, p. 98]] · *Türk kaynağı*

### Kişi · Cemal Paşa
`kişi: cemal` · `unvan: Bahriye Nazırı Cemal Paşa` · `görsel: Djemal Pasha2.png` · `rol: bahriye`
Üçlünün üçüncüsü; 1914'ten Bahriye Nazırı, sonra Suriye'de 4. Ordu komutanı.
> Kaynak: [[Cemal Paşa]] · [[Türkiye'de Hükümetler (İhsan Güneş)#p. 127|Güneş, p. 127]] · *Türk kaynağı*

### Kişi · Rauf Bey
`kişi: rauf` · `unvan: Bahriye Nazırı Rauf Bey` · `görsel: Hüseyin Rauf Orbay.jpg` · `rol: bahriye`
İzzet Paşa kabinesinin Bahriye Nazırı; 30 Ekim 1918'de Mondros'ta mütarekeyi imzalar.
> Kaynak: [[Türkiye'de Hükümetler (İhsan Güneş)#p. 178|Güneş, p. 178]] · [[Şahbaba (Murat Bardakçı)#p. 116|Bardakçı, *Şahbaba*, p. 116]] · *Türk kaynağı*

## Kabineler

Masadaki koltukların kimde olduğu. Satırlar yukarıdan aşağı denenir; tarihi ve koşulu tutan ilk satır geçerlidir.

| Başlangıç | Bitiş | Koşul | Hükümdar | Maliye | Harbiye | Bahriye |
|---|---|---|---|---|---|---|
| 1873-01 | 1876-05 | - | abdulaziz | maliye_nazir | huseyin_avni | hobart |
| 1876-06 | 1909-12 | !⚑yol_ittihat | abdulhamid | maliye_nazir | riza_pasa | hasan_husnu |
| 1910-01 | 1917-12 | ⚑yol_hamid | abdulhamid | maliye_nazir | riza_pasa | hasan_husnu |
| 1908-07 | 1909-04 | ⚑yol_ittihat | abdulhamid | maliye_nazir | riza_pasa | bahriye_nazir |
| 1909-05 | 1909-12 | ⚑yol_ittihat | talat | cavid | mahmud_sevket | bahriye_nazir |
| 1910-01 | 1913-06 | ⚑yol_ittihat | talat | cavid | mahmud_sevket | bahriye_nazir |
| 1913-07 | 1913-12 | ⚑yol_ittihat | talat | cavid | ahmed_izzet | bahriye_nazir |
| 1914-01 | 1918-09 | ⚑yol_ittihat | talat | cavid | enver | cemal |
| 1918-10 | 1919-12 | ⚑yol_ittihat & ⚑talat_gitti | vahdettin | maliye_nazir | ahmed_izzet | rauf |
| 1918-10 | 1919-12 | ⚑yol_ittihat | talat | cavid | enver | cemal |

Mütareke sonrası Harbiye koltuğu kasadaki uzun listeden sadeleştirilecek: bkz. [[GD 99 Açık Sorular]].)

## Devletler

Masada her devletin bayraklı yuvarlak bir düğmesi vardır; olay düğmeleri de ilgili devletin bayrağıyla çıkar. `konum` haritadaki yeri (boylam,enlem; o devletin olayları başka bir `yer` verilmemişse burada görünür), `bayrak` şimdilik harf kısaltmasıdır. Payitaht bloğundaki `görsel` masadaki haritanın arka planıdır (şimdilik 1900 tarihli bir Wikimedia haritası; gerçek harita 2.5D masayla gelecek).

### Devlet · Payitaht
`devlet: OS` · `ad: Devlet-i Aliyye` · `konum: 28.976,41.011` · `görsel: Map-of-Ottoman-Empire-1900.png`
İstanbul, Babıâli, saray. Payitaht düğmesi hükümdarı ve nazırları açar.

### Devlet · Rusya
`devlet: RU` · `ad: Rusya İmparatorluğu` · `konum: 33.50,46.60`
Karadeniz'in ve Boğazlar'ın öbür ucundaki asıl tehdit. İki yüzyıllık savaşların karşı tarafı.

### Devlet · İngiltere
`devlet: IN` · `ad: Büyük Britanya` · `konum: 14.50,35.90`
Kıbrıs'ı alan, Mısır'a yerleşen, Hindistan yolunu kollayan deniz gücü.

### Devlet · Fransa
`devlet: FR` · `ad: Fransa` · `konum: 8.60,36.50`
Tunus'u alan, Suriye ve Lübnan'da gözü olan alacaklı.

### Devlet · Almanya
`devlet: AL` · `ad: Alman İmparatorluğu` · `konum: 13.40,51.50`
Önce danışman, sonra demiryolu sahibi, en sonunda müttefik.

### Devlet · Avusturya-Macaristan
`devlet: AV` · `ad: Avusturya-Macaristan` · `konum: 16.37,48.21`
Bosna-Hersek'i önce işgal, sonra ilhak eden komşu.

### Devlet · İtalya
`devlet: IT` · `ad: İtalya` · `konum: 12.50,41.90`
1911'de Trablusgarp'a çıkan genç devlet.

### Devlet · Yunanistan
`devlet: YU` · `ad: Yunanistan` · `konum: 23.73,37.98`
Girit'i ve adaları isteyen komşu; 1919'da İzmir'e çıkar.

### Devlet · Bulgaristan
`devlet: BU` · `ad: Bulgaristan` · `konum: 23.32,42.70`
Ayastefanos'un doğurduğu prenslik, Balkan Harbi'nin Çatalca'ya dayanan ordusu, sonra Büyük Harp'te müttefik.

### Devlet · Sırbistan ve Karadağ
`devlet: SR` · `ad: Sırbistan ve Karadağ` · `konum: 20.46,44.82`
1876'da savaş açan, 1912'de Balkan ittifakına giren komşular.

### Devlet · Romanya
`devlet: RO` · `ad: Romanya` · `konum: 26.10,44.43`
1878'e kadar kâğıt üstünde Osmanlı'ya bağlı prenslik; Ayastefanos ve Berlin'le bağımsız, Dobruca'yı alır.
> Kaynak: [[Osmanlı İmparatorluğu Tarihi (Robert Mantran)#p. 644|Mantran, *Osmanlı İmparatorluğu Tarihi*, p. 644]] · *Fransız kaynağı*

### Devlet · Arnavutluk
`devlet: AB` · `ad: Arnavutluk` · `konum: 19.82,41.33`
Balkan Harbi'nin sonunda Londra'da bağımsızlığı tanınan prenslik.
> Kaynak: [[Arnavutluk]]

### Devlet · Mısır
`devlet: MI` · `ad: Mısır Hıdivliği` · `konum: 31.24,30.04`
Kâğıt üstünde Osmanlı, 1882'den sonra fiilen İngiliz.

### Devlet · İran
`devlet: IR` · `ad: İran` · `konum: 51.40,35.70`
Doğudaki komşu ve rakip.

### Devlet · Ermeniler
`devlet: ER` · `ad: Ermeni cemaati ve komiteler` · `konum: 42.60,39.20`
Bir devlet değil, bir güç. Doğu vilayetleri, Hınçak ve Taşnak komiteleri, Avrupa'daki temsilcileri.

### Devlet · Araplar
`devlet: AR` · `ad: Arap vilayetleri ve Hicaz` · `konum: 41.00,25.50`
Bir devlet değil, bir güç. Suriye, Irak, Hicaz; Mekke Şerifi ve aşiretler.

### Devlet · Kürtler
`devlet: KU` · `ad: Kürt aşiretleri` · `konum: 42.20,37.70`
Bir devlet değil, bir güç. Doğu vilayetlerinin aşiret reisleri; Hamidiye alayları.

## Olay yazım kuralları

Oyun her şeyi bu klasördeki dosyalardan okur. `py game/tools/build_events.py --check` bu kurallara uymayan her satırı gösterir.

1. **Başlık:** `### YYYY[-AA[-GG]] · Başlık`. Tarih, olayın en erken çıkabileceği andır.
2. **Alanlar** (başlığın hemen altındaki satır, ters tırnaklı `anahtar: değer` parçaları ` · ` ile ayrılır):
   - `id:` benzersiz, küçük harf, Türkçe karakter yok (`plevne`, `ayastefanos_imza`).
   - `tür:` `zorunlu` · `isteğe bağlı` · `geçici` · `ara` · `kural` · `manşet` · `epilog`. Ek olarak `zincir` (yalnız `▶` ile açılır) ve `alternatif` (Alternatif tarih; oyunda öyle etiketlenir).
   - `bayrak:` devlet kısaltması (varsayılan `OS`). · `görsel:` `Attachments/Images` içindeki dosya adı. · `sıra:` [[GD 01 Olay Sıralaması]]'ndaki sıra. · `bitiş:` olayın en geç açık kalacağı tarih (`geçici` ve `kural` için). · `son:` (yalnız `epilog`) hangi sonun kartı olduğu.
   - `koşul:` ayrı satırda: `` `koşul: ⚑harp_93 & Harbiye >= 30` ``.
3. **Metin:** alanlardan sonra gelen düz paragraflar. `[[Not adı]]` bağlantıları oyunda tıklanabilir sözlük (codex) kelimesine dönüşür; açıklama o notun Summary bölümünden gelir.
4. **Görüşler:** `💬 Maliye: "…"`, `💬 Harbiye: "…"`, `💬 Bahriye: "…"` (o anki nazırın adıyla gösterilir) ya da `💬 Liman von Sanders: "…"` gibi adlı bir kişi.
5. **Kaynak:** `> Kaynak:` ile başlayan satırlar; her iddia bir sayfa bağlantısı ve tarafıyla (*Türk kaynağı*, *Alman kaynağı*…). `> “…”` satırları kaynaktan kısa alıntıdır; derleyici alıntının o sayfada gerçekten geçtiğini denetler. Video dökümleri *video dökümü (ikincil)* diye işaretlenir.
6. **Seçenekler:** `1. **Seçenek metni.** [koşul: …] (ipucu: …) `etkiler` — sonuç metni`
   - `[koşul: …]` tutmazsa seçenek görünür ama kilitlidir; kilit nedeni koşuldan yazılır ("Bahriye ≥ 40 gerekir"). Gizli değerlere bağlı koşulda neden "Yeterli nüfuzunuz yok" diye gösterilir.
   - `(ipucu: …)` fare üstüne gelince görünen açıklama.
   - Etkiler: `Para -10` · `hakimiyet +5` · `+⚑bayrak` · `-⚑bayrak` · `▶ olay_id` · `👤 kişi_id` · `☠ son_id`. ASCII karşılıkları: `+f:bayrak` · `-f:bayrak` · `>olay_id` · `@kişi_id` · `end:son_id`.
   - Seçeneği olmayan olay tek bir "Devam" düğmesiyle gelir.
7. **Koşul dili:** `⚑x` (ya da `f:x`) bayrak var · `!` değil · `&` ve · `|` veya · parantez · karşılaştırma `>= <= > < = !=` · sol tarafta bir kaynak/gizli değer ya da `yıl`, `ay`; toplama/çıkarma yapılabilir (`hakimiyet - jon_turk >= 20`). Kaynak adları Türkçe (`Para`, `Kürtler`) ya da id (`para`, `kurtler`) yazılabilir.

## Zaman akışı

- Masada o tarihte açık olan olayların düğmeleri durur. **Zamanı ilerlet** düğmesi, bir sonraki olayın tarihine atlar; o yıl başka olay yoksa yıl dönümüne geçer.
- `zorunlu` olay cevaplanmadan zaman ilerlemez. `isteğe bağlı` olay yıl sonuna kadar açık kalır. `geçici` olay yalnız kendi ayında (ya da `bitiş`e kadar) açıktır.
- `▶` ile sıraya konan olay koşulu tutuyorsa hemen (tarihi gelmemişse tarihinde) açılır; tutmuyorsa düşer. Böylece aynı `▶` iki olaya birden işaret edebilir, hangisinin koşulu tutarsa o çıkar (ör. Sarıkamış'ın sonucu).
- **Yıl dönümü:** önce `kural` olayları sırayla uygulanır, sonra yılın gazetesi çıkar (o yıl verilen kararların başlıkları + koşulu tutan `manşet` satırları). Olay olmayan yıllar atlanır ama kuralları yine işler.
- Oyun `☠` ile biter; son ekranı o sonun `epilog` kartlarından koşulu tutanları sırayla gösterir.

## Yıllık kurallar

Oyuncunun görmediği, her yıl dönümünde işleyen kurallar.

### 1873 · Yıllık gelir
`id: k_gelir` · `tür: kural`
1. **Uygula.** `Para +10`

### 1875 · İflasın yükü
`id: k_iflas` · `tür: kural`
`koşul: ⚑iflas_1875 & !⚑duyun_umumiye`
1. **Uygula.** `Para -6 · avrupa_baskisi +2`

### 1881 · Düyun-u Umumiye payı
`id: k_duyun` · `tür: kural`
`koşul: ⚑duyun_umumiye`
1. **Uygula.** `Para -4`

### 1873 · Hazine boşaldı
`id: k_dis_borc` · `tür: kural`
`koşul: Para <= 0`
1. **Uygula.** `▶ dis_borc`

### 1879 · Ordunun çürümesi
`id: k_harbiye_curume` · `tür: kural`
`koşul: !⚑yol_ittihat`
1. **Uygula.** `Harbiye -1`

### 1883 · Goltz'un talimleri
`id: k_goltz` · `tür: kural`
`koşul: ⚑goltz_serbest & !⚑yol_ittihat`
1. **Uygula.** `Harbiye +1 · jon_turk +2`

### 1878 · Donanma Haliç'te
`id: k_halic` · `tür: kural`
`koşul: ⚑donanma_halicte`
1. **Uygula.** `Bahriye -4`

### 1873 · Donanmanın bakımı
`id: k_bahriye_bakim` · `tür: kural`
`koşul: !⚑donanma_halicte`
1. **Uygula.** `Bahriye -1 · Para -1`

### 1878 · Jurnal ağı
`id: k_jurnal` · `tür: kural`
`koşul: ⚑jurnal_ag & !⚑yol_ittihat`
1. **Uygula.** `hakimiyet +3 · jon_turk +1 · Harbiye -1 · Para -1`

### 1891 · Hamidiye alayları
`id: k_hamidiye` · `tür: kural`
`koşul: ⚑hamidiye_kuruldu & !⚑hamidiye_lagv`
1. **Uygula.** `Kürtler +2 · Ermeniler +1 · avrupa_baskisi +1`

### 1891 · Doğuda jandarma
`id: k_dogu_jandarma` · `tür: kural`
`koşul: ⚑dogu_jandarma`
1. **Uygula.** `Para -3 · Ermeniler -1 · dogu_hazirligi +1`

### 1909 · Meşrutiyet ordusu
`id: k_ittihat_ordu` · `tür: kural` · `bitiş: 1914`
`koşul: ⚑yol_ittihat`
1. **Uygula.** `Harbiye +1`

### 1914 · Harp ekonomisi
`id: k_harp` · `tür: kural`
`koşul: ⚑harpte`
1. **Uygula.** `Para -6`

### 1915 · Payitahta doğru (Harbiye çökük)
`id: k_cokus_agir` · `tür: kural`
`koşul: ⚑yol_hamid & ⚑harpte & Harbiye < 30`
1. **Uygula.** `cokus +20`

### 1915 · Payitahta doğru
`id: k_cokus` · `tür: kural`
`koşul: ⚑yol_hamid & ⚑harpte & Harbiye >= 30`
1. **Uygula.** `cokus +12`

### 1915 · Denizden gelen tehlike
`id: k_cokus_deniz` · `tür: kural`
`koşul: ⚑yol_hamid & ⚑harpte & Bahriye < 30`
1. **Uygula.** `cokus +5`

### 1884 · Milli Tütün İdaresi
`id: k_reji_milli` · `tür: kural`
`koşul: reji = milli`
1. **Uygula.** `Para +3 · avrupa_baskisi +1`

### 1882 · Mısır'da Osmanlı taburları
`id: k_misir_osmanli` · `tür: kural`
`koşul: misir = osmanli | misir = ortak`
1. **Uygula.** `Para -2 · Araplar -1 · avrupa_baskisi +1`

### 1916 · Suriye'nin öfkesi
`id: k_suriye` · `tür: kural`
`koşul: ⚑suriye_idamlari`
1. **Uygula.** `Araplar +3`

## Sistem olayları

### 1873 · Galata bankerleri
`id: dis_borc` · `tür: zorunlu · zincir` · `bayrak: OS`
Hazine boş. Maaş günü geldi; altı yüz bin lirayı bulmak Maliye Nazırı'na düşüyor. Avans alınacak kapılar belli: Osmanlı Bankası{eğer reji = fransiz | reji = ortak: , Tütün Rejisi}{eğer reji = milli: , Milli Tütün İdaresi'nin kasası}{eğer ⚑duyun_umumiye: , Düyun-u Umumiye}. Nazır kapı kapı dolaşıp "yalvar yakar" olacak.

[eğer: reji = milli] Tütünün kârı artık Galata'ya değil hazineye akıyor; Maliye Nazırı bu kez önce kendi kasasına bakıyor.

[eğer: misir = ingiliz] Mısır'ın vergisi yıllardır Kahire'deki İngiliz kasasında; oradan bir kuruş gelmeyecek.
💬 Maliye: "Efendimiz, faizi ağır ama başka kapı yok."
💬 Harbiye: "Askerin maaşı bir ay daha gecikirse kışlalarda ses çıkar."
> Kaynak: [[Enver (Murat Bardakçı)#p. 66|Bardakçı, *Enver*, p. 66]] · *Türk kaynağı* · [[Düyun-u Umumiye]]
1. **Avansı al.** `Para +20 · avrupa_baskisi +5` — Para bulundu; faizi de, alacaklıların sözü de büyüdü.
2. **Milli Tütün İdaresi'nin kasasından borç al.** [koşul: reji = milli] (ipucu: Tekel devletin elindeyse) `Para +14 · avrupa_baskisi -1` — Tütünün kârı maaşlara yetti; bu kez Galata'ya gidilmedi.
3. **Maaşları geciktir.** `Para +10 · Harbiye -5 · jon_turk +3` — Hazine nefes aldı; kışlalarda homurtu başladı.
4. **Berlin'den iste.** [koşul: alman_nufuzu >= 20] `Para +15 · alman_nufuzu +5` — Alman bankaları yardım etti; karşılığını da isteyecekler.

## Gazete manşetleri

Yıl dönümü gazetesinde (Abdülhamid devrinde *Takvim-i Vekâyi*, İttihat devrinde *Tanin*) görünen, gizli değerleri sezdiren satırlar. Bkz. [[Ottoman press]].

### 1878 · Sükûnet-i tamme
`id: m_hakimiyet` · `tür: manşet`
`koşul: hakimiyet >= 70 & !⚑yol_ittihat`
Vilayetlerden her gün aynı telgraf geliyor: "asayiş berkemal". Yıldız'a günde binlerce jurnal ulaşıyor.
> Kaynak: [[Birinci Dünya Savaşı'nda Türkiye (Ahmet Emin Yalman)#p. 56|Yalman, p. 56]] · *Türk kaynağı* · [[Mahşerin İki Gemisi - Part II (Video transcript)#loc. 10|Video, *Mahşerin İki Gemisi - Part II*, loc. 10]] · *video dökümü (ikincil)*

### 1878 · Mekteplerde fısıltı
`id: m_jon_turk` · `tür: manşet`
`koşul: jon_turk >= 50 & !⚑yol_ittihat`
Harbiye ve Tıbbiye koğuşlarında el altından *Vatan*'ın sayfaları dolaşıyor.

### 1878 · Haliç'te pas
`id: m_halic` · `tür: manşet`
`koşul: ⚑donanma_halicte & Bahriye <= 35`
Haliç'te demirli zırhlıların kazanlarını yıllardır kimse yakmadı.
> Kaynak: [[Enver (Murat Bardakçı)#p. 69|Bardakçı, *Enver*, p. 69]] · *Türk kaynağı*

### 1873 · Maaşlar gecikti
`id: m_para` · `tür: manşet`
`koşul: Para <= 10`
Memurlar yine maaş bekliyor; Galata'da sarraflar faizi artırdı.

### 1873 · Hasta Adam
`id: m_avrupa` · `tür: manşet`
`koşul: avrupa_baskisi >= 60`
Avrupa gazeteleri yine "Hasta Adam"ın mirasını paylaşıyor.

### 1880 · Berlin'in sesi
`id: m_alman` · `tür: manşet`
`koşul: alman_nufuzu >= 40`
Babıâli'de Alman elçisinin sözü her geçen yıl daha çok dinleniyor.

### 1880 · Doğudan haberler
`id: m_ermeni` · `tür: manşet`
`koşul: Ermeniler >= 60`
Doğu vilayetlerinden gelen raporlarda komitelerin adı her ay daha sık geçiyor.

### 1880 · Mekke'den mektuplar
`id: m_arap` · `tür: manşet`
`koşul: Araplar >= 60`
Mekke'den ve Şam'dan gelen mektupların dili soğudu.

### 1891 · Aşiretlerin kanunu
`id: m_kurt` · `tür: manşet`
`koşul: Kürtler >= 60`
Doğuda bazı aşiret reisleri vergiyi de, hükmü de kendileri koyuyor.

### 1910 · Erzurum yolunda
`id: m_dogu` · `tür: manşet`
`koşul: dogu_hazirligi >= 45 & ⚑yol_ittihat`
Erzurum yolunda amele taburları çalışıyor; depolar doluyor.

### 1885 · Kolcuların türküsü
`id: m_reji` · `tür: manşet`
`koşul: reji = fransiz | reji = ortak`
Reji kolcularının vurduğu bir kaçakçı için Anadolu'da yine bir türkü yakıldı.
> Kaynak: [[Mahşerin İki Gemisi - Part II (Video transcript)#loc. 8|Video, *Mahşerin İki Gemisi - Part II*, loc. 8]] · *video dökümü (ikincil)*

### 1885 · Tütün hazineye
`id: m_reji_milli` · `tür: manşet`
`koşul: reji = milli`
Milli Tütün İdaresi'nin Galata'daki depolarında bu yılın mahsulü tartıldı; kârı hazineye yazıldı.

### 1883 · Kahire'de iki bayrak
`id: m_misir` · `tür: manşet`
`koşul: misir = ortak | misir = osmanli`
Kahire'den gelen mektuplarda hıdivin sarayındaki Osmanlı taburlarından söz ediliyor.

### 1914 · Sansür
`id: m_cokus` · `tür: manşet`
`koşul: ⚑harpte & cokus >= 50`
Cepheden gelen haberler artık sansürden bile geçmiyor; köylerde yalnız dualar okunuyor.

## Suzerain'den alınanlar

| Suzerain'de | Burada |
|---|---|
| Her bölümün başındaki gazete | Yıl dönümü gazetesi: *Takvim-i Vekâyi* / *Tanin* |
| Yıllık bütçe ekranı | Her yıl bir `Bütçe` olayı (Maliye Nazırı): Harbiye, Bahriye, doğu, Arabistan, demiryolu, hafiye payları |
| Kabine toplantısında bakanların çatışan görüşleri | `💬` satırları; nazırın sözü kaynağının gücüyle ağırlaşır |
| Kilitli seçenekler ve nedeni | `[koşul: …]` tutmayan seçenek gri görünür, nedeni yazar |
| "Bu karar hatırlanacak" | Bayrak koyan seçeneklerde küçük bir bildirim |
| Codex / ansiklopedi | Metindeki `[[Not]]` kelimeleri tıklanır; kasadaki notun özeti açılır. Her olayın kaynak listesi bir düğmeyle açılır (Kaynakça) |
| Zirveler ve çok adımlı görüşmeler | Berlin 1878, 1914 ıslahat görüşmeleri, Mondros: `zincir` olaylarla |
| Savaş haritası ve ordu kartları | Harp yıllarında cephe kartları (Kafkas, Çanakkale, Irak, Filistin, Hicaz, Galiçya) |
| Sonda alan alan epilog | Son ekranında Ordu, Donanma, Maliye, Ermeniler, Araplar, Kürtler, Almanya kartları |
| Önsözde geçmiş seçimi | Abdülaziz önsözü (1873–1876): seçimler Abdülhamid'in başlangıç değerlerini belirler |
