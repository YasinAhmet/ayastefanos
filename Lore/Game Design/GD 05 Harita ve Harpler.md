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
| edirne | Edirne | OS | OS | Rumeli |
| dogu_rumeli | Doğu Rumeli (Filibe) | OS | OS | Rumeli |
| tuna | Tuna (Rusçuk, Sofya) | OS | OS | Rumeli |
| selanik | Selanik | OS | OS | Rumeli |
| manastir | Manastır | OS | OS | Rumeli |
| kosova | Kosova (Üsküp) | OS | OS | Rumeli |
| iskodra | İşkodra | OS | OS | Rumeli |
| yanya | Yanya | OS | OS | Rumeli |
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
| necd | Necd | AR | AR | Arabistan |
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

Haritadaki işaretler. Tıklanınca sağda o yerin paneli açılır: açıklama, orada bekleyen evrak, açık kararlar, ilgili iplikler, geçmiş olaylar. `konum` boylam,enlemdir. Olaylar `yer:` alanıyla bir yere bağlanır; alanı olmayan olay kendi devletinin yerine düşer (`bayrak`). İstanbul'daki yerler haritada Payitaht'ın çevresinde bir halka olarak gösterilir.

### Yer · Babıâli
`yer: babiali` · `il: istanbul` · `konum: 28.976,41.011` · `simge: payitaht` · `bayrak: OS`
Sadrazamın ve nazırların makamı. Hükümdarın portresi burada durur; tıklanınca Payitaht açılır.
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
