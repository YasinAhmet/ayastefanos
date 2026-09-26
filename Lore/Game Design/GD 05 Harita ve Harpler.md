---
tags: [game-design]
---
# GD 05 · Harita ve Harpler

Masadaki harita, illerin kimde olduğunu gösterir. Her il iki katmanlıdır: **Sahip** (hukuken kimin toprağı) ve **Tutan** (fiilen kimin elinde). İl, tutanın rengine boyanır; sahip başka biriyse sahibin rengiyle taranır (Mısır 1882'den sonra: sahip Osmanlı, tutan İngiltere). Geri: [[GD 00 Rehber]] · [[GD 04 Dünya Durumu ve İplikler]].

> [!info] Sınırlar sadeleştirilmiştir
> İl sınırları Natural Earth'ün kamu malı idari sınırlarından birleştirilerek çizilir (`tools/map/build_map.py`); 1878–1914 vilayet sınırlarının kaba bir yaklaşığıdır, kaynak değildir (⚠ Not from vault sources).

Etkiler: `🗺 kars RU` ili devreder (sahip ve tutan Rusya; ASCII `map:kars RU`) · `🗺 misir ~IN` yalnız tutanı değiştirir (işgal; ASCII `map:misir ~IN`). Koşullar: `il:kars = RU` (tutan), `sahip:misir = OS` (sahip).

## İller

Başlangıç 1873'tür.

| id | Ad | Sahip | Tutan | Bölge |
|---|---|---|---|---|
| istanbul | İstanbul | OS | OS | Payitaht |
| edirne | Edirne (Kırkkilise) | OS | OS | Rumeli |
| tekfurdagi | Tekfurdağı | OS | OS | Rumeli |
| gumulcine | Batı Trakya (Gümülcine, Pirin) | OS | OS | Rumeli |
| dogu_rumeli | Doğu Rumeli (Filibe) | OS | OS | Rumeli |
| tuna | Tuna (Rusçuk, Sofya) | OS | OS | Rumeli |
| selanik | Selanik | OS | OS | Rumeli |
| serez | Serez ve Drama | OS | OS | Rumeli |
| manastir | Manastır | OS | OS | Rumeli |
| kesriye | Kesriye ve Florina | OS | OS | Rumeli |
| kosova | Kosova (Priştine, Yeni Pazar) | OS | OS | Rumeli |
| uskup | Üsküp | OS | OS | Rumeli |
| iskodra | İşkodra | OS | OS | Rumeli |
| yanya | Yanya | OS | OS | Rumeli |
| ergiri | Ergiri ve Görice | OS | OS | Rumeli |
| teselya | Teselya | OS | OS | Rumeli |
| bosna | Bosna-Hersek | OS | OS | Rumeli |
| nis | Niş | OS | OS | Rumeli |
| dobruca | Dobruca | OS | OS | Rumeli |
| girit | Girit | OS | OS | Adalar |
| ege_adalari | Ege adaları (Midilli, Sakız, Limni) | OS | OS | Adalar |
| oniki_ada | Rodos ve On İki Ada | OS | OS | Adalar |
| kibris | Kıbrıs | OS | OS | Adalar |
| hudavendigar | Hüdavendigâr (Bursa) | OS | OS | Anadolu |
| aydin | Aydın (İzmir) | OS | OS | Anadolu |
| konya | Konya | OS | OS | Anadolu |
| ankara | Ankara | OS | OS | Anadolu |
| kastamonu | Kastamonu | OS | OS | Anadolu |
| adana | Adana | OS | OS | Anadolu |
| sivas | Sivas | OS | OS | Anadolu |
| trabzon | Trabzon | OS | OS | Anadolu |
| erzurum | Erzurum | OS | OS | Doğu |
| kars | Kars ve Ardahan | OS | OS | Doğu |
| batum | Batum | OS | OS | Doğu |
| van | Van | OS | OS | Doğu |
| bitlis | Bitlis | OS | OS | Doğu |
| diyarbakir | Diyarbakır | OS | OS | Doğu |
| mamuretulaziz | Mamuretülaziz (Harput) | OS | OS | Doğu |
| halep | Halep | OS | OS | Arabistan |
| suriye | Suriye (Şam) | OS | OS | Arabistan |
| beyrut | Beyrut ve Lübnan | OS | OS | Arabistan |
| kudus | Kudüs | OS | OS | Arabistan |
| musul | Musul | OS | OS | Irak |
| bagdat | Bağdat | OS | OS | Irak |
| basra | Basra | OS | OS | Irak |
| hicaz | Hicaz | OS | OS | Arabistan |
| yemen | Yemen | OS | OS | Arabistan |
| necd | Necd (Riyad) | AR | AR | Arabistan |
| sammar | Cebel-i Şammar (Hâil) | OS | RS | Arabistan |
| lahsa | el-Ahsa | OS | OS | Arabistan |
| kuveyt | Kuveyt | OS | OS | Arabistan |
| umman | Umman ve Körfez şeyhlikleri | IN | IN | Arabistan |
| trablusgarp | Trablusgarp ve Bingazi | OS | OS | Afrika |
| tunus | Tunus | OS | OS | Afrika |
| misir | Mısır ve Sudan | OS | MI | Afrika |
| cezayir | Cezayir | FR | FR | Afrika |
| aden | Aden | IN | IN | Arabistan |
| sirbistan | Sırbistan | OS | SR | Komşular |
| karadag | Karadağ | SR | SR | Komşular |
| romanya | Romanya | OS | RO | Komşular |
| yunanistan | Yunanistan | YU | YU | Komşular |
| avusturya | Avusturya-Macaristan | AV | AV | Komşular |
| italya | İtalya | IT | IT | Komşular |
| almanya | Almanya | AL | AL | Komşular |
| fransa | Fransa | FR | FR | Komşular |
| rusya | Rusya | RU | RU | Komşular |
| kafkasya | Kafkasya (Tiflis, Revan) | RU | RU | Komşular |
| iran | İran | IR | IR | Komşular |

## Yerler

Haritadaki işaretler. Tıklanınca sol altta o yerin paneli açılır: açıklama, orada bekleyen evrak, açık kararlar, ilgili iplikler, geçmiş olaylar. `konum` boylam,enlemdir. Olaylar `yer:` alanıyla bir yere bağlanır; alanı olmayan olay kendi devletinin yerine düşer (`bayrak`). İstanbul'daki yerler haritada tek bir sarı başkent yıldızında toplanır; yıldıza tıklanınca listelenir. Hükümdarın portresi haritada değil, ekranın sağ üstündeki kartta durur.

### Yer · Babıâli
`yer: babiali` · `il: istanbul` · `konum: 28.976,41.011` · `simge: payitaht` · `bayrak: OS`
Sadrazamın ve nazırların makamı; buradan Payitaht açılır.
> Kaynak: [[Sublime Porte]]

### Yer · Yıldız Sarayı
`yer: yildiz` · `il: istanbul` · `konum: 29.010,41.049` · `simge: saray`
Abdülhamid'in sarayı; jurnallerin gittiği yer.
> Kaynak: [[Yıldız Sarayı]]

### Yer · Dolmabahçe Sarayı
`yer: dolmabahce` · `il: istanbul` · `konum: 29.000,41.039` · `simge: saray`
Boğaz kıyısındaki saray.
> Kaynak: [[Dolmabahçe Sarayı]]

### Yer · Ayastefanos
`yer: ayastefanos` · `il: istanbul` · `konum: 28.820,40.963` · `simge: antlasma`
Yeşilköy: 1878'de Rus karargâhının kurulduğu ve ön barışın imzalandığı sahil kasabası.
> Kaynak: [[Yeşilköy (Ayastefanos)]]

### Yer · Haliç
`yer: halic` · `il: istanbul` · `konum: 28.955,41.040` · `simge: donanma`
Donanmanın demir yeri.
> Kaynak: [[Ottoman Navy]]

### Yer · Galata
`yer: galata` · `il: istanbul` · `konum: 28.974,41.025` · `simge: banka`
Osmanlı Bankası, Düyun-u Umumiye ve Reji'nin semti.
> Kaynak: [[Beyoğlu and Galata]] · [[Ottoman Bank]] · [[Düyun-u Umumiye]] · [[Tobacco Régie]]

### Yer · Harbiye Mektebi
`yer: harbiye_mektebi` · `il: istanbul` · `konum: 28.987,41.046` · `simge: ordu`
Subayların yetiştiği mektep.
> Kaynak: [[Ottoman War Academy]]

### Yer · Edirne
`yer: edirne` · `il: edirne` · `konum: 26.556,41.677` · `simge: sehir`
> Kaynak: [[Edirne]]

### Yer · Filibe
`yer: filibe` · `il: dogu_rumeli` · `konum: 24.750,42.150` · `simge: sehir`
Doğu Rumeli'nin merkezi.
> Kaynak: [[Bulgaristan]]

### Yer · Plevne
`yer: plevne` · `il: tuna` · `konum: 24.617,43.417` · `simge: kale`
> Kaynak: [[Siege of Plevne (1877)]]

### Yer · Selanik
`yer: selanik` · `il: selanik` · `konum: 22.944,40.640` · `simge: sehir`
> Kaynak: [[Selanik]]

### Yer · Girit
`yer: girit` · `il: girit` · `konum: 24.020,35.510` · `simge: ada`
> Kaynak: [[Girit]]

### Yer · Kıbrıs
`yer: kibris` · `il: kibris` · `konum: 33.360,35.170` · `simge: ada`
> Kaynak: [[Kıbrıs]]

### Yer · Çanakkale
`yer: canakkale` · `il: hudavendigar` · `konum: 26.400,40.150` · `simge: kale`
> Kaynak: [[Çanakkale and Gelibolu]]

### Yer · Kars
`yer: kars` · `il: kars` · `konum: 43.090,40.600` · `simge: kale`
> Kaynak: [[Kars]]

### Yer · Batum
`yer: batum` · `il: batum` · `konum: 41.640,41.640` · `simge: liman`
> Kaynak: [[Batum]]

### Yer · Erzurum
`yer: erzurum` · `il: erzurum` · `konum: 41.270,39.900` · `simge: kale`
> Kaynak: [[Erzurum]]

### Yer · Sarıkamış
`yer: sarikamis` · `il: kars` · `konum: 42.590,40.330` · `simge: ordu`
> Kaynak: [[Sarıkamış]]

### Yer · Van
`yer: van` · `il: van` · `konum: 43.380,38.500` · `simge: sehir`
> Kaynak: [[Van]]

### Yer · Şam
`yer: sam` · `il: suriye` · `konum: 36.290,33.510` · `simge: sehir`
> Kaynak: [[Şam]]

### Yer · Bağdat
`yer: bagdat` · `il: bagdat` · `konum: 44.360,33.310` · `simge: sehir`
> Kaynak: [[Bağdat]]

### Yer · Mekke
`yer: mekke` · `il: hicaz` · `konum: 39.830,21.420` · `simge: kutsal`
> Kaynak: [[Mekke]]

### Yer · Kahire
`yer: kahire` · `il: misir` · `konum: 31.240,30.040` · `simge: sehir`
Hıdivin payitahtı.
> Kaynak: [[Mısır]] · [[British occupation of Egypt (1882)]]

### Yer · Süveyş Kanalı
`yer: suveys` · `il: misir` · `konum: 32.300,30.600` · `simge: liman`
> Kaynak: [[Süveyş Kanalı]]

### Yer · Trablusgarp
`yer: trablus` · `il: trablusgarp` · `konum: 13.190,32.890` · `simge: liman`
> Kaynak: [[Trablusgarp]]

### Yer · Tunus
`yer: tunus` · `il: tunus` · `konum: 10.180,36.800` · `simge: liman`
> Kaynak: [[Tunus]]

## Harpler ve cepheler

Harp açıkken her cephenin ortasında haritada bir işaret durur. Tıklanınca sağdaki panel güç dengesini (0 düşmanın, 100 bizim), kimin üstün olduğunu, dengeyi hangi olayların ne kadar değiştirdiğini ve cephenin sonucunu gösterir.

- **Denge:** cephenin `değer`i bir gizli kaynaktır (bkz. [[GD 02 Sistemler#Kaynaklar]]). Olayların seçenekleri onu değiştirir (`kafkas +8`); her değişiklik, onu yapan olayın adıyla cephe defterine yazılır.
- **Kendi seyri:** karara bağlanmamış bir cephe her ay bir puan, `güç` değerlerinin ortalaması `karşı`dan 10'dan fazla yüksekse bizden yana, düşükse düşmandan yana kayar. Bu kayma da defterde "Cephenin kendi seyri" diye yıllık toplanır.
- **Sonuç:** her cephe kendi olaylarıyla karara bağlanır (`sonuç`). Sonuç olaylarının tarihî sürümü koşulsuzdur; alternatif sürüm, denge yeterince yüksekse aynı yuvada öne geçer (ör. `bagdat_tutuldu`, `irak >= 60`). İlk cevaplanan sonuç olayı cephenin sonucudur. Sonuç olayları illerin sahibini değiştirir (`🗺`).
- **Sınır:** `sınır` alanı olan cephede denge `yenilgi` eşiğine düşünce düşman, listede sıradaki elimizdeki ili işgal eder (en çok altı ayda bir); denge `zafer` eşiğini aşınca bu cephede işgal edilmiş son ilimiz geri alınır. İkisi de Toprak defterine "Cephenin kendi seyri" diye yazılır. Böylece 1877'de tutulan Kars bir sonraki harpte kendiliğinden düşebilir.
- `koşul` harbin açık olduğu durumdur; `başlangıç` işaretin haritaya çıktığı ay; `iller` cephenin çekiştiği iller (haritada vurgulanır); `zafer` / `yenilgi` panelde "üstün" sayılan eşiklerdir.

> [!info] Sayılar tasarımdır
> Cephe dengesi, kayma ve eşikler oyun dengesidir; kaynak gösterilen, sonuç olaylarının kendisidir.

### Cephe · Tuna ve Balkan
`cephe: tuna_93` · `harp: 93 Harbi` · `değer: tuna_93` · `düşman: RU` · `konum: 25.40,43.30` · `iller: tuna, dogu_rumeli` · `güç: harbiye` · `karşı: 50` · `başlangıç: 1877-06` · `zafer: 65` · `yenilgi: 30` · `sonuç: balkan_tutuldu, plevne_dustu, edirne_mutareke`
`koşul: ⚑harp_93 & ⚑harpte & yıl <= 1878`
Ruslar Tuna'yı geçip Balkanlar'a yürüyor; Plevne yolun ortasında.
> Kaynak: [[Russo-Turkish War of 1877-1878]] · [[Siege of Plevne (1877)]]

### Cephe · Kafkas ('93)
`cephe: kafkas_93` · `harp: 93 Harbi` · `değer: kafkas_93` · `düşman: RU` · `konum: 42.70,40.50` · `iller: kars, erzurum` · `sınır: kars, batum, erzurum` · `güç: harbiye` · `karşı: 50` · `başlangıç: 1877-05` · `zafer: 60` · `yenilgi: 30` · `sonuç: kars_tutuldu, kars_1877`
`koşul: ⚑harp_93 & ⚑harpte & yıl <= 1878`
Gazi Ahmed Muhtar Paşa Kars ile Erzurum arasında Rus kollarını karşılıyor.
> Kaynak: [[Gazi Ahmed Muhtar Paşa]] · [[Kars]]

### Cephe · Trablusgarp
`cephe: trablus` · `harp: Trablusgarp Harbi` · `değer: trablus` · `düşman: IT` · `konum: 17.50,31.20` · `iller: trablusgarp` · `güç: harbiye` · `karşı: 40` · `başlangıç: 1911-10` · `zafer: 65` · `yenilgi: 30` · `sonuç: trablus_tutuldu, usi, hamid_1912_usi`
`koşul: ⚑trablus_harbi`
İtalyanlar kıyıda; çölde gönüllü subaylar ve aşiretler.
> Kaynak: [[Italo-Turkish War (1911-1912)]] · [[Trablusgarp]]

### Cephe · Trakya
`cephe: trakya` · `harp: Balkan Harbi` · `değer: trakya` · `düşman: BU` · `konum: 27.30,41.55` · `iller: edirne, tekfurdagi` · `güç: harbiye` · `karşı: 50` · `başlangıç: 1912-10` · `zafer: 60` · `yenilgi: 30` · `sonuç: edirne_tutuldu, edirne_dustu, hamid_1913_londra`
`koşul: ⚑balkan_harbi_on`
Kırkkilise, Lüleburgaz, Çatalca; ve kuşatılmış Edirne.
> Kaynak: [[Edirne]]

### Cephe · Kafkas
`cephe: kafkas` · `harp: Büyük Harp` · `değer: kafkas` · `düşman: RU` · `konum: 42.40,40.20` · `iller: kars, batum, erzurum` · `sınır: kars, batum, erzurum, trabzon` · `güç: harbiye, dogu_hazirligi` · `karşı: 45` · `başlangıç: 1914-11` · `zafer: 65` · `yenilgi: 30` · `sonuç: sarikamis_zafer, kafkas_bahar_zafer, sarikamis_felaket, kafkas_cikmaz, hamid_erzurum_dustu`
`koşul: ⚑harpte & (⚑yol_ittihat | ⚑yol_hamid) & !⚑mondros`
Sarıkamış'ın karlı dağları; Erzurum'un ardında beş yüz kilometrelik bir ikmal yolu.
> Kaynak: [[Sarıkamış Operation (1914-1915)]]

### Cephe · Çanakkale
`cephe: canakkale` · `harp: Büyük Harp` · `değer: canakkale` · `düşman: IN` · `konum: 26.30,40.15` · `iller: edirne, hudavendigar` · `güç: harbiye, bahriye` · `karşı: 45` · `başlangıç: 1915-02` · `zafer: 65` · `yenilgi: 30` · `sonuç: gelibolu_tahliye`
`koşul: ⚑harpte & ⚑yol_ittihat & !⚑mondros`
Boğaz'ın tabyaları, sonra Gelibolu'nun siperleri.
> Kaynak: [[Çanakkale and Gelibolu]]

### Cephe · Irak
`cephe: irak` · `harp: Büyük Harp` · `değer: irak` · `düşman: IN` · `konum: 46.20,31.60` · `iller: basra, bagdat` · `güç: harbiye` · `karşı: 40` · `başlangıç: 1914-11` · `zafer: 65` · `yenilgi: 30` · `sonuç: bagdat_tutuldu, bagdat_dustu`
`koşul: ⚑harpte & ⚑yol_ittihat & !⚑mondros`
Basra'dan Dicle boyunca Bağdat'a.
> Kaynak: [[Bağdat]] · [[Basra]]

### Cephe · Filistin ve Süveyş
`cephe: filistin` · `harp: Büyük Harp` · `değer: filistin` · `düşman: IN` · `konum: 33.60,30.90` · `iller: kudus, misir` · `güç: harbiye` · `karşı: 45` · `başlangıç: 1915-01` · `zafer: 65` · `yenilgi: 30` · `sonuç: kudus_tutuldu, kudus_dustu`
`koşul: ⚑harpte & ⚑yol_ittihat & !⚑mondros`
Sina çölü, Süveyş Kanalı, sonra Gazze ve Kudüs.
> Kaynak: [[Süveyş Kanalı]] · [[Kudüs]]

### Cephe · Hicaz
`cephe: hicaz` · `harp: Büyük Harp` · `değer: hicaz` · `düşman: AR` · `konum: 39.60,24.50` · `iller: hicaz` · `güç: harbiye` · `karşı: 45` · `başlangıç: 1916-06` · `zafer: 65` · `yenilgi: 30` · `sonuç: arap_isyani_onlendi, medine_mudafaa`
`koşul: ⚑harpte & ⚑yol_ittihat & ⚑arap_isyani & !⚑mondros`
Şerif Hüseyin'in isyanı; Medine'de Fahreddin Paşa.
> Kaynak: [[Hicaz]] · [[Medine]]

## Nüfus

Her ilde hangi toplulukların, kaç bin kişiyle yaşadığı. Sol alttaki il panelinde gösterilir; olaylar değiştirir.

- **Etki:** `👥 ermeni -80% @Doğu` bir grubu yüzdeyle azaltır ya da artırır; `👥 turk +150 @Anadolu` bin kişi ekler ya da çıkarır. Eklenen sayı hedef illere nüfuslarıyla orantılı dağıtılır. Hedef bir il (`@van`), bir bölge (`@Doğu`, yukarıdaki Bölge sütunu) ya da `@imparatorluk` (o an Osmanlı'nın olan bütün iller) olabilir; `@` yazılmazsa imparatorluk demektir. ASCII: `pop:ermeni -80% @dogu`.
- **Kendiliğinden göç:** bir il başka bir devlete devredilince (`🗺 kars RU`), aşağıdaki grup tablosunun Göç sütunundaki oranda nüfus ilden ayrılır ve Anadolu ile Payitaht'a yerleşir (1878 ve 1912–13 muhacirleri).
- **Güç:** grubun bir kaynağı varsa (Ermeniler, Araplar, Kürtler) panelde o kaynağın değeri gösterilir.
- **Durum:** başlangıca göre oran ve bayraklardan türetilir. Oran %5'in altındaysa "yok edildi", %35'in altındaysa "sürüldü", %85'in altındaysa "azalıyor", %115'in üstündeyse "muhacirle artıyor". Aksi hâlde "Ayaklanma" koşulu tutuyorsa "ayaklandı", "Baskı" koşulu tutuyorsa "baskı altında", değilse "yerleşik".

> [!info] Sayılar tahminîdir
> Rakamlar binlik ve yuvarlaktır; 1873 için tahmin edilmiştir. Toplamlar, Osmanlı'nın 1881/82–1893 sayımının yayımlanmış özetlerinden türetilmiştir (⚠ Not from vault sources · Wikipedia: *Demographics of the Ottoman Empire*, https://en.wikipedia.org/wiki/Demographics_of_the_Ottoman_Empire ; *Ottoman census of 1881–82*). İl içindeki dağılım varsayımdır.
> Rumeli'nin Müslüman nüfusu 1906 sayımına yaklaştırılmıştır (⚠ Wikipedia: *Demographics of the Ottoman Empire*).
> **Ölüler (`†`):** `👥 turk -300 @tuna †` gibi işaretli azalmalar göç değil ölümdür; Kayıplar kartına yazılır. Rakam olarak Wikipedia'daki tahminlerin **en yükseği** alınır (kullanıcının isteği; hepsi ⚠ Not from vault sources ve tartışmalıdır): 1877–78'de 400.000 Müslüman sivil; 1912–13 Balkan Harbi'nde 1.500.000'e kadar Müslüman sivil (Arnavutlar 270.000'e kadar); 1914–18'de Rus işgalindeki doğu vilayetlerinde 600.000'e kadar Türk ve Kürt (Rummel), 1918 baharında Erzurum'da 25.000, Kars'ta 20.000; 1894–96 Hamidiye olaylarında 300.000'e kadar Ermeni; 1915 tehcirinde 1.500.000'e kadar Ermeni; 1915–18 Suriye kıtlığında 500.000'e kadar. Oyunun nüfus tablosu bu rakamları taşıyamadığı yerde (bir ilde grup tükendiğinde) kayıp tablodaki nüfusla sınırlı kalır.
> Ermeni sayısı en tartışmalı rakamdır. Patrikhane 1882 için 2.660.000, 1912 için 2.100.000 der; resmî sayımlar çok daha düşüktür ([[Osmanlı İmparatorluğu Tarihi (Robert Mantran)#p. 672|Mantran, p. 672]] · *Fransız kaynağı*). Yalman, dokuz doğu vilayetinin (Erzurum, Van, Bitlis, Harput, Diyarbakır, Sivas, Halep, Adana, Trabzon) nüfusunu 6 milyon, bunun 913.875'ini (%15) Ermeni verir ([[Birinci Dünya Savaşı'nda Türkiye (Ahmet Emin Yalman)#p. 266|Yalman, p. 266]] · *Türk kaynağı*). Gürün, Patrikhane'nin 1880–1882 rakamlarını karşılaştırır ([[The Armenian File (Kâmuran Gürün)#p. 123|Gürün, p. 123]] · *Türk kaynağı*). Oyun bu dokuz ilde Yalman'ın toplamına yakın durur.

### Nüfus grupları

| id | Ad | Güç | Göç | Baskı | Ayaklanma |
|---|---|---|---|---|---|
| turk | Türk ve Müslüman | - | 35 | - | - |
| kurt | Kürt | Kürtler | 10 | - | - |
| arap | Arap | Araplar | 0 | ⚑yol_ittihat & ⚑harpte & Araplar < 30 | ⚑arap_isyani |
| arnavut | Arnavut | - | 10 | - | - |
| bosnak | Boşnak | - | 20 | - | - |
| rum | Rum | - | 0 | - | - |
| ermeni | Ermeni | Ermeniler | 0 | ⚑hamidiye_kuruldu & !⚑yol_ittihat | - |
| bulgar | Bulgar | - | 0 | - | - |
| sirp | Sırp | - | 0 | - | - |
| yahudi | Yahudi | - | 0 | - | - |
| diger | Diğer (Çerkes, Tatar, Süryani, Ulah, Kıpti…) | - | 20 | - | - |

### Nüfus tablosu

Bin kişi, 1873. Boş hücre sıfırdır. Komşu devletlerin illeri tutulmaz.

| il | turk | kurt | arap | arnavut | bosnak | rum | ermeni | bulgar | sirp | yahudi | diger |
|---|---|---|---|---|---|---|---|---|---|---|---|
| istanbul | 380 |  |  |  |  | 150 | 150 | 5 |  | 45 | 130 |
| edirne | 450 |  |  |  |  | 150 | 12 | 250 |  | 13 | 15 |
| tekfurdagi | 180 |  |  |  |  | 110 | 8 | 40 |  | 2 | 5 |
| gumulcine | 320 |  |  |  |  | 40 |  | 140 |  |  | 10 |
| dogu_rumeli | 200 |  |  |  |  | 50 |  | 600 |  |  | 30 |
| tuna | 700 |  |  |  |  | 20 |  | 1100 |  | 15 | 150 |
| selanik | 300 |  |  | 10 |  | 180 |  | 120 |  | 75 | 30 |
| serez | 250 |  |  | 10 |  | 120 |  | 100 |  | 5 | 20 |
| manastir | 150 |  |  | 250 |  | 30 |  | 180 |  |  | 40 |
| kesriye | 90 |  |  | 20 |  | 70 |  | 70 |  |  | 20 |
| kosova | 60 |  |  | 400 | 30 |  |  |  | 170 |  |  |
| uskup | 120 |  |  | 150 |  |  |  | 100 | 30 |  |  |
| iskodra |  |  |  | 250 |  |  |  |  | 20 |  | 10 |
| yanya |  |  |  | 100 |  | 220 |  |  |  | 5 | 30 |
| ergiri |  |  |  | 220 |  | 30 |  |  |  |  | 10 |
| teselya | 40 |  |  |  |  | 300 |  |  |  |  | 20 |
| bosna |  |  |  |  | 500 |  |  |  | 500 | 5 | 200 |
| nis | 60 |  |  | 40 |  |  |  |  | 180 |  |  |
| dobruca | 60 |  |  |  |  | 10 |  | 40 |  |  | 80 |
| girit | 80 |  |  |  |  | 200 |  |  |  |  |  |
| ege_adalari | 20 |  |  |  |  | 200 |  |  |  |  |  |
| oniki_ada | 10 |  |  |  |  | 120 |  |  |  | 3 |  |
| kibris | 45 |  |  |  |  | 140 |  |  |  |  |  |
| hudavendigar | 1200 |  |  |  |  | 80 | 60 |  |  |  | 30 |
| aydin | 1100 |  |  |  |  | 250 | 15 |  |  | 25 | 30 |
| konya | 900 |  |  |  |  | 60 | 15 |  |  |  |  |
| ankara | 800 |  |  |  |  | 40 | 80 |  |  |  |  |
| kastamonu | 900 |  |  |  |  | 20 |  |  |  |  |  |
| adana | 250 |  | 30 |  |  |  | 80 |  |  |  | 30 |
| sivas | 800 |  |  |  |  | 60 | 150 |  |  |  |  |
| trabzon | 850 |  |  |  |  | 150 | 50 |  |  |  |  |
| erzurum | 350 | 100 |  |  |  |  | 130 |  |  |  | 10 |
| kars | 60 | 20 |  |  |  |  | 30 |  |  |  | 20 |
| batum | 80 |  |  |  |  |  |  |  |  |  | 20 |
| van | 30 | 180 |  |  |  |  | 130 |  |  |  | 20 |
| bitlis | 30 | 220 |  |  |  |  | 130 |  |  |  |  |
| diyarbakir | 70 | 250 |  |  |  |  | 70 |  |  |  | 50 |
| mamuretulaziz | 250 | 100 |  |  |  |  | 90 |  |  |  |  |
| halep | 250 |  | 450 |  |  |  | 50 |  |  |  | 60 |
| suriye |  |  | 600 |  |  |  |  |  |  | 10 | 70 |
| beyrut |  |  | 500 |  |  |  |  |  |  |  | 60 |
| kudus |  |  | 230 |  |  |  |  |  |  | 25 |  |
| musul | 20 | 180 | 150 |  |  |  |  |  |  |  | 50 |
| bagdat |  | 20 | 700 |  |  |  |  |  |  | 50 |  |
| basra |  |  | 450 |  |  |  |  |  |  |  |  |
| hicaz |  |  | 400 |  |  |  |  |  |  |  |  |
| yemen |  |  | 1500 |  |  |  |  |  |  |  |  |
| lahsa |  |  | 100 |  |  |  |  |  |  |  |  |
| kuveyt |  |  | 30 |  |  |  |  |  |  |  |  |
| trablusgarp |  |  | 800 |  |  |  |  |  |  | 20 |  |
| tunus |  |  | 1100 |  |  |  |  |  |  | 30 | 20 |
| misir |  |  | 5500 |  |  |  |  |  |  |  | 700 |

## Kişiler haritada

Önemli kişiler haritada küçük madalyonlarla, o ay bulundukları yerde görünür; tıklanınca kişi kartı açılır. O sırada tahtta ya da kabinenin başında görünen kişi burada ayrıca gösterilmez. Yer bir `yer` kimliği (Yerler bölümü) ya da `Ad @ boylam,enlem`dir. Koşullu satırlar oyuncunun seçimlerini izler: gönüllüler Trablus'a gitmediyse Enver ile Mustafa Kemal orada görünmez; Abdülhamid yolunda (1908 ihtilali bastırıldıysa) İttihatçılar haritadan çekilir.

> [!info] Dayanak
> Tarihler kasadaki kişi notlarından ve kitaplardan; notlarda olmayan tarihler Wikipedia'dan (⚠ Not from vault sources) ya da yaklaşık.

| Kişi | Başlangıç | Bitiş | Yer | Koşul | Dayanak |
|---|---|---|---|---|---|
| midhat | 1873-01 | 1877-01 | babiali | - | [[Midhat Paşa]] |
| midhat | 1878-11 | 1880-07 | sam | - | [[Midhat Paşa]] (Suriye valisi) |
| midhat | 1880-08 | 1881-04 | İzmir @ 27.14,38.42 | - | [[Midhat Paşa]] (Aydın valisi) |
| midhat | 1881-05 | 1881-06 | yildiz | - | [[Midhat Paşa]] (Yıldız muhakemesi) |
| midhat | 1881-07 | 1884-04 | Taif @ 40.42,21.27 | - | [[Midhat Paşa]] |
| hobart | 1873-01 | 1886-05 | halic | - | [[Hobart Paşa]] |
| osman_pasa | 1876-07 | 1877-06 | Vidin @ 22.88,43.99 | - | [[Gazi Osman Paşa]] |
| osman_pasa | 1877-07 | 1877-12 | plevne | ⚑harp_93 | [[Gazi Osman Paşa]] · [[Siege of Plevne (1877)]] |
| osman_pasa | 1878-04 | 1900-04 | yildiz | - | [[Gazi Osman Paşa]] (Mabeyn müşiri) |
| ahmed_muhtar | 1877-04 | 1877-10 | kars | ⚑harp_93 | [[Gazi Ahmed Muhtar Paşa]] |
| ahmed_muhtar | 1877-11 | 1878-03 | erzurum | ⚑harp_93 | [[Gazi Ahmed Muhtar Paşa]] |
| ahmed_muhtar | 1885-10 | 1908-08 | kahire | - | [[Gazi Ahmed Muhtar Paşa]] (fevkalade komiser) |
| ahmed_muhtar | 1912-07 | 1912-10 | babiali | ⚑yol_ittihat | [[Gazi Ahmed Muhtar Paşa]] (sadrazam) |
| goltz | 1883-06 | 1895-10 | harbiye_mektebi | - | [[Colmar von der Goltz]] |
| goltz | 1915-12 | 1916-04 | bagdat | ⚑yol_ittihat & ⚑harpte | [[Colmar von der Goltz]] · ölümü `goltz_olum` olayında |
| talat | 1898-01 | 1908-07 | selanik | - | [[Talat Paşa]] (Selanik posta idaresi, Cemiyet'in merkezi) |
| talat | 1908-08 | 1918-10 | babiali | ⚑yol_ittihat | [[Talat Paşa]] |
| enver | 1906-09 | 1908-07 | selanik | - | [[Enver Paşa]] (Üçüncü Ordu kurmayı) |
| enver | 1908-08 | 1909-02 | selanik | ⚑yol_ittihat | [[Enver Paşa]] |
| enver | 1909-03 | 1911-09 | Berlin @ 13.40,52.52 | ⚑yol_ittihat | [[Enver Paşa]] (ataşemiliter) |
| enver | 1911-10 | 1912-10 | Derne @ 22.64,32.77 | ⚑gonullu_trablus | [[Enver (Murat Bardakçı)#p. 113\|Bardakçı, *Enver*, p. 113]] |
| enver | 1912-11 | 1914-11 | babiali | ⚑yol_ittihat | [[Enver Paşa]] (Babıâli Baskını, Harbiye Nezareti) |
| enver | 1914-12 | 1915-01 | sarikamis | ⚑yol_ittihat & ⚑harpte | [[Sarıkamış Operation (1914-1915)]] |
| enver | 1915-02 | 1918-10 | babiali | ⚑yol_ittihat | [[Enver Paşa]] |
| cemal | 1909-08 | 1911-08 | Adana @ 35.32,37.00 | ⚑yol_ittihat | [[Cemal Paşa]] (Adana valisi) ⚠ Wikipedia: *Djemal Pasha* |
| cemal | 1911-09 | 1912-07 | bagdat | ⚑yol_ittihat | [[Cemal Paşa]] (Bağdat valisi) ⚠ Wikipedia: *Djemal Pasha* |
| cemal | 1913-01 | 1914-11 | babiali | ⚑yol_ittihat | [[Cemal Paşa]] |
| cemal | 1914-12 | 1917-12 | sam | ⚑yol_ittihat & ⚑harpte | [[Cemal Paşa Hatıralar (Cemal Paşa)#p. 234\|Cemal Paşa, p. 234]] |
| cemal | 1918-01 | 1918-10 | babiali | ⚑yol_ittihat | [[Cemal Paşa]] |
| niyazi | 1908-06 | 1908-12 | Resne @ 21.00,41.07 | ⚑yol_ittihat | [[Resneli Niyazi]] |
| mustafa_kemal | 1905-02 | 1907-09 | sam | - | [[Atatürk Hakkında Hatıralar ve Belgeler (Afet İnan)#p. 86\|İnan, p. 86]] |
| mustafa_kemal | 1907-10 | 1911-09 | selanik | - | [[Enver (Murat Bardakçı)#p. 16\|Bardakçı, *Enver*, p. 16]] |
| mustafa_kemal | 1911-10 | 1912-10 | Tobruk @ 23.96,32.08 | ⚑gonullu_trablus | [[Enver (Murat Bardakçı)#p. 115\|Bardakçı, *Enver*, p. 115]] · [[Cemal Paşa Hatıralar (Cemal Paşa)#p. 84\|Cemal Paşa, p. 84]] |
| mustafa_kemal | 1912-11 | 1913-09 | Bolayır @ 26.77,40.51 | ⚑yol_ittihat | ⚠ Wikipedia: *Mustafa Kemal Atatürk* |
| mustafa_kemal | 1913-10 | 1915-01 | Sofya @ 23.32,42.70 | ⚑yol_ittihat | [[Enver (Murat Bardakçı)#p. 77\|Bardakçı, *Enver*, p. 77]] · [[Zabit ve Kumandan ile Hasbihal (Mustafa Kemal)#p. 10\|Kemal, p. 10]] |
| mustafa_kemal | 1915-02 | 1915-12 | canakkale | ⚑yol_ittihat & ⚑harpte | [[Çanakkale'yi Almanlar mı Kazandı (Video transcript)#loc. 12\|Video, loc. 12]] |
| mustafa_kemal | 1916-03 | 1917-06 | Muş @ 41.49,38.74 | ⚑yol_ittihat & ⚑harpte | ⚠ Wikipedia: *Mustafa Kemal Atatürk* (16. Kolordu; Bitlis ve Muş) |
| mustafa_kemal | 1917-07 | 1917-10 | Halep @ 37.16,36.20 | ⚑yol_ittihat & ⚑harpte | [[Cemal Paşa Hatıralar (Cemal Paşa)#p. 234\|Cemal Paşa, p. 234]] (7. Ordu, istifa) |
| mustafa_kemal | 1917-11 | 1918-07 | harbiye_mektebi | ⚑yol_ittihat | ⚠ Wikipedia: *Mustafa Kemal Atatürk* |
| mustafa_kemal | 1918-08 | 1918-10 | Nablus @ 35.26,32.22 | ⚑yol_ittihat & ⚑harpte | ⚠ Wikipedia: *Mustafa Kemal Atatürk* (7. Ordu) |
| mustafa_kemal | 1918-11 | 1919-04 | harbiye_mektebi | - | [[Mustafa Kemal Atatürk]] (Bekirağa ziyareti) |
| mustafa_kemal | 1919-05 | 1919-12 | Samsun @ 36.33,41.29 | - | [[100. Yılında Jön Türk Devrimi (Sina Akşin)#p. 450\|Akşin, p. 450]] |
| liman | 1913-12 | 1915-02 | harbiye_mektebi | ⚑yol_ittihat | [[Liman von Sanders]] |
| liman | 1915-03 | 1916-01 | canakkale | ⚑yol_ittihat & ⚑harpte | [[Liman von Sanders]] (5. Ordu) |
| liman | 1916-02 | 1918-02 | harbiye_mektebi | ⚑yol_ittihat | [[Liman von Sanders]] |
| liman | 1918-03 | 1918-10 | Nasıra @ 35.30,32.70 | ⚑yol_ittihat & ⚑harpte | [[Liman von Sanders]] (Yıldırım Ordular Grubu) |
| fahreddin | 1916-06 | 1919-01 | Medine @ 39.61,24.47 | ⚑yol_ittihat & ⚑arap_isyani | [[Fahreddin Paşa]] |
