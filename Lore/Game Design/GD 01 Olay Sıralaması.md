---
tags: [game-design]
---
# GD 01 · Olay Sıralaması

Kasadaki kitaplara göre 1873–1919 arasının en önemli 195 olayı, en önemliden en önemsize. Geri: [[GD 00 Rehber]] · Sonlar: [[GD 03 Sonlar ve Yollar]].

## Nasıl sıralandı

**Puan = 2 × oyun ağırlığı + kasa ağırlığı** (en yüksek 9). Eşit puanda, olayı anan sayfa sayısı fazla olan öne geçer.

- **Oyun ağırlığı:** 3 = bir yol ayrımı ya da son değiştirir · 2 = bir kaynağı ya da kaldıracı oynatır · 1 = atmosfer.
- **Kasa ağırlığı:** olayı anan sayfa sayısı 100 ve üstü ise 3, 25–99 ise 2, 25'in altında ise 1. Sayılar ya olayın kendi notunun başındaki sayılardır ("Found in N sources on M pages") ya da `py tools/mentions.py --terms …` ile, olaya özgü terimlerle sayılmıştır (ör. Ayastefanos Antlaşması için notun kendi sayısı, Hamidiye alayları için "Hamidiye Alay" ve benzerleri).
- **Uyarı:** `mentions.py` kelime başından eşleştirir; genel terimler sayıyı şişirir ("Reji" "rejim"i de sayar). Terimler tek tek denetlendi ama sayılar kaba bir ölçüdür: sıralamanın iskeleti oyun ağırlığıdır.
- **Katman:** S (1–15) · A (16–45) · B (46–85) · C (86+). Dağılım: S 15, A 30, B 40, C 110.
- **Olay kimlikleri (id):** yıl dosyalarında o olay için tasarlanan olaylar. Bir sıra birden çok olaya ayrılabilir (ör. Sarıkamış: karar, zafer, felaket). Yıl dosyaları bunlara ek olarak zincir, bütçe ve **Alternatif tarih** olayları içerir.
- **Kaynak sütunu:** her olay için bir sayfa bağlantısı ve yazarın tarafı. Ayrıntılı kaynaklar yıl dosyalarındadır.

Sıralamaya katılmıyorsan puanı değiştirmen yeter: tablo elle düzenlenebilir, oyun bu dosyayı okumaz.

## Sıralama

| # | Katman | Tarih | Olay | Not | Kitap/sayfa | Oyundaki rolü | Olay kimlikleri | Yıl | Kaynak |
|---|---|---|---|---|---|---|---|---|---|
| 1 | S | 1912-10 | Balkan Harbi: Kırkkilise, Lüleburgaz, Çatalca | [[Balkan Wars (1912-1913)]] | 47/584 | yol ayrımı / son | `balkan_harbi`, `luleburgaz`, `catalca` | [[GD 1912]] | [[Balkan Savaşı Günlüğü (Gustav von Hochwächter)#p. 6]] · *Alman kaynağı* |
| 2 | S | 1908-07-23 | Meşrutiyet'in yeniden ilanı | [[Young Turk Revolution (1908)]] | 35/382 | yol ayrımı / son | `ihtilal_1908`, `ihtilal_bastirildi` | [[GD 1908]] | [[Türkiye'de Hükümetler (İhsan Güneş)#p. 38]] · *Türk kaynağı* |
| 3 | S | 1914-08-02 | Osmanlı–Alman ittifakı ve seferberlik | [[German military mission (1913)]] | 42/332 | yol ayrımı / son | `ittifak_1914`, `seferberlik` | [[GD 1914]] | [[Türkiye'de Beş Yıl (Liman von Sanders)#p. 333]] · *Alman kaynağı* |
| 4 | S | 1919-09-04 | Sivas Kongresi | [[Sivas Congress (1919)]] | 15/289 | yol ayrımı / son | `sivas_kongresi` | [[GD 1919]] | [[Sivas Kongresi (Mahmut Goloğlu)#loc. 65]] · *Türk kaynağı* |
| 5 | S | 1919-01 | Paris Barış Konferansı | [[Paris Peace Conference (1919)]] | 25/241 | yol ayrımı / son | `paris_konferansi` | [[GD 1919]] | [[Arap İsyanı 1916-1918 (David Murphy)#p. 80]] · *İrlandalı kaynağı* |
| 6 | S | 1915-04-24 | Ermeni tehciri | [[Armenian deportation (1915)]] | 28/236 | yol ayrımı / son | `tehcir_karar` | [[GD 1915]] | [[Talât Paşa'nın Evrak-ı Metrukesi (Murat Bardakçı)#p. 13]] · *Türk kaynağı* |
| 7 | S | 1914-11 | Kış kıyafeti: depodaki kaputlar ve çizmeler dağıtılmamış (Ocak 1915'te ortaya çıkar) | [[Military uniforms and equipment]] | 41/230 | yol ayrımı / son | `kislik_techizat`, `depo_kaputlar` | [[GD 1914]] | [[Hafız Hakkı Paşa'nın Sarıkamış Günlüğü (Hafız Hakkı Paşa)#p. 107]] · *Türk kaynağı* |
| 8 | S | 1876-12-23 | Kanun-ı Esasi ilan edilir | [[First Constitutional Era (1876-1878)]] | 26/214 | yol ayrımı / son | `kanun_esasi` | [[GD 1876]] | [[Türkiye'de Hükümetler (İhsan Güneş)#p. 36]] · *Türk kaynağı* |
| 9 | S | 1876-05-30 | Abdülaziz tahttan indirilir | [[Abdülaziz]] | 30/208 | yol ayrımı / son | `abdulaziz_hal` | [[GD 1876]] | [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 26]] · *Türk kaynağı* |
| 10 | S | 1909-04 | 31 Mart Vakası, Hareket Ordusu ve Abdülhamid'in hal'i | [[31 March Incident (1909)]] | 36/203 | yol ayrımı / son | `31_mart`, `hareket_ordusu`, `abdulhamid_hal` | [[GD 1909]] | [[Osmanlı İmparatorluğu Tarihi (Robert Mantran)#p. 735]] · *Fransız kaynağı* |
| 11 | S | 1913-06-11 | Mahmud Şevket Paşa öldürülür | [[Mahmud Şevket Paşa]] | 31/191 | yol ayrımı / son | `mahmud_sevket_suikast` | [[GD 1913]] | [[Son Osmanlılar (Murat Bardakçı)#p. 74]] · *Türk kaynağı* |
| 12 | S | 1919-07-23 | Erzurum Kongresi | [[Erzurum Congress (1919)]] | 12/174 | yol ayrımı / son | `erzurum_kongresi` | [[GD 1919]] | [[Son Meşrutiyet (Sina Akşin)#loc. 48]] · *Türk kaynağı* |
| 13 | S | 1908-11 | Şerif Hüseyin Mekke emirliğine atanır | [[Şerif Hüseyin]] | 16/170 | yol ayrımı / son | `serif_atama` | [[GD 1908]] | [[Irak Kralı I. Faysal (Ali A. Allawi)#p. 70]] · *Iraklı kaynağı* |
| 14 | S | 1915-03-18 | Çanakkale deniz zaferi | [[Gallipoli Campaign (1915)]] | 30/168 | yol ayrımı / son | `bogaz_18mart` | [[GD 1915]] | [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 77]] · *Türk kaynağı* |
| 15 | S | 1877-07 | Plevne müdafaası (Gazi Osman Paşa) | [[Siege of Plevne (1877)]] | 20/167 | yol ayrımı / son | `plevne` | [[GD 1877]] | [[Zabit ve Kumandan ile Hasbihal (Mustafa Kemal)#p. 95]] · *Türk kaynağı* |
| 16 | A | 1918-10-30 | Mondros Mütarekesi | [[Armistice of Mudros (1918)]] | 27/160 | yol ayrımı / son | `mondros` | [[GD 1918]] | [[Cumhuriyete Doğru (Mahmut Goloğlu)#loc. 220]] · *Türk kaynağı* |
| 17 | A | 1918-12-16 | Divan-ı Harp ve Tahkik-i Fecayi | [[Unionist trials (1919-1920)]] | 22/150 | yol ayrımı / son | `divani_harp` | [[GD 1918]] | [[Kim Hain, Kim Kahraman (Video transcript)#loc. 6]] · *video dökümü (ikincil)* |
| 18 | A | 1899 | Bağdat Demiryolu imtiyazı Almanya'ya | [[Baghdad Railway]] | 33/140 | yol ayrımı / son | `bagdat_imtiyaz` | [[GD 1899]] | [[Balkan Savaşları (Troçki) (Leon Trotsky)#loc. 375]] · *Rus kaynağı* |
| 19 | A | 1914-12-18 | Sarıkamış harekâtı | [[Sarıkamış Operation (1914-1915)]] | 22/140 | yol ayrımı / son | `sarikamis_karar`, `sarikamis_zafer`, `sarikamis_felaket` | [[GD 1914]] | [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 76]] · *Türk kaynağı* |
| 20 | A | 1914-08-11 | Goeben ve Breslau Boğaz'a girer | [[Goeben and Breslau (1914)]] | 24/131 | yol ayrımı / son | `goeben` | [[GD 1914]] | [[Birinci Dünya Savaşı'nda Türkiye (Ahmet Emin Yalman)#p. 99]] · *Türk kaynağı* |
| 21 | A | 1875-10-06 | Mali iflas: faiz ödemeleri yarıya indirilir | [[Mahmud Nedim Paşa]] | 39/121 | yol ayrımı / son | `iflas_1875` | [[GD 1875]] | [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 25]] · *Türk kaynağı* |
| 22 | A | 1889 | Tıbbiye'de İttihad-ı Osmani kurulur | [[Committee of Union and Progress]] | 34/114 | yol ayrımı / son | `tibbiye_cemiyet` | [[GD 1889]] | [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 30]] · *Türk kaynağı* |
| 23 | A | 1908-10-05 | Bulgaristan'ın istiklali ve Bosna-Hersek'in ilhakı | [[Bulgaristan]] | 29/112 | yol ayrımı / son | `bosna_bulgar_1908` | [[GD 1908]] | [[100. Yılında Jön Türk Devrimi (Sina Akşin)#p. 343]] · *Türk kaynağı* |
| 24 | A | 1918-11-13 | İtilaf donanması İstanbul'a gelir | [[Boğazlar]] | 30/107 | yol ayrımı / son | `isgal_istanbul` | [[GD 1918]] | [[Enver (Murat Bardakçı)#p. 641]] · *Türk kaynağı* |
| 25 | A | 1915-04-25 | Gelibolu çıkarması | [[Çanakkale and Gelibolu]] | 22/100 | yol ayrımı / son | `gelibolu_cikarma` | [[GD 1915]] | [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 77]] · *Türk kaynağı* |
| 26 | A | 1878-06 | Berlin Kongresi | [[Congress of Berlin (1878)]] | 21/98 | yol ayrımı / son | `berlin_kongresi`, `berlin_ermeni_maddesi` | [[GD 1878]] | [[Osmanlı'da Değişim ve Anayasal Rejim Sorunu (İlber Ortaylı)#p. 255]] · *Türk kaynağı* |
| 27 | A | 1898 | Kaiser II. Wilhelm'in resmî ziyareti | [[Kaiser Wilhelm II]] | 29/97 | yol ayrımı / son | `kaiser_1898` | [[GD 1898]] | [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 32]] · *Türk kaynağı* |
| 28 | A | 1877-04-24 | Rusya harp ilan eder: 93 Harbi | [[Russo-Turkish War of 1877-1878]] | 28/95 | yol ayrımı / son | `harp_93` | [[GD 1877]] | [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 27]] · *Türk kaynağı* |
| 29 | A | 1900 | Hicaz Demiryolu İslam dünyasının bağışlarıyla başlar | [[Hejaz Railway]] | 19/90 | yol ayrımı / son | `hicaz_demiryolu` | [[GD 1900]] | [[Birinci Dünya Savaşı'nda Türkiye (Ahmet Emin Yalman)#p. 62]] · *Türk kaynağı* |
| 30 | A | 1910-07 | Cavid Bey Londra'da Bağdat hattını görüşür | [[Cavid Bey]] | 24/89 | yol ayrımı / son | `cavid_londra` | [[GD 1910]] | [[Osmanlı Arap Coğrafyası ve Avrupa Emperyalizmi (Ali Akyıldız)#p. 111]] · *Türk kaynağı* |
| 31 | A | 1881-12 | Muharrem Kararnamesi: Düyun-u Umumiye kurulur | [[Düyun-u Umumiye]] | 25/88 | yol ayrımı / son | `muharrem_kararnamesi` | [[GD 1881]] | [[Balkan Harbi'nde Ulaştırma (Bülent Durgun)#p. 37]] · *Türk kaynağı* |
| 32 | A | 1916-06 | Şerif Hüseyin'in isyanı | [[Arab Revolt (1916-1918)]] | 7/86 | yol ayrımı / son | `arap_isyani`, `arap_isyani_onlendi` | [[GD 1916]] | [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 78]] · *Türk kaynağı* |
| 33 | A | 1883 | Colmar von der Goltz İstanbul'a gelir | [[Colmar von der Goltz]] | 20/78 | yol ayrımı / son | `goltz_heyeti` | [[GD 1883]] | [[100. Yılında Jön Türk Devrimi (Sina Akşin)#p. 661]] · *Türk kaynağı* |
| 34 | A | 1913-12 | Liman von Sanders heyeti | [[German military mission (1913)]] | 9/75 | yol ayrımı / son | `liman_heyeti` | [[GD 1913]] | [[Arap İsyanı 1916-1918 (David Murphy)#p. 8]] · *İrlandalı kaynağı* |
| 35 | A | 1918-09-19 | Nablus (Megiddo) taarruzu Filistin cephesini çökertir | [[Palestine and Sinai Front]] | 16/75 | yol ayrımı / son | `megiddo` | [[GD 1918]] | [[Osmanlı Piyadesi 1914-1918 (David Nicolle)#p. 12]] · *İngiliz kaynağı* |
| 36 | A | 1916-05 | Sykes–Picot görüşmeleri | [[Sykes-Picot Agreement (1916)]] | 8/73 | yol ayrımı / son | `sykes_picot` | [[GD 1916]] | [[Osmanlı İmparatorluğu Tarihi (Robert Mantran)#p. 778]] · *Fransız kaynağı* |
| 37 | A | 1915-03-04 | Rusya Boğazları ve İstanbul'u ister | [[Boğazlar]] | 21/69 | yol ayrımı / son | `rus_bogaz_talebi` | [[GD 1915]] | [[Irak Kralı I. Faysal (Ali A. Allawi)#p. 159]] · *Iraklı kaynağı* |
| 38 | A | 1917-03 | Rus İhtilali | [[Russian Revolution (1917)]] | 24/67 | yol ayrımı / son | `rus_ihtilali` | [[GD 1917]] | [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 79]] · *Türk kaynağı* |
| 39 | A | 1878-02-13 | Meclis tatil edilir: Yıldız'dan mutlak idare başlar | [[Abdülhamid II]] | 26/66 | yol ayrımı / son | `meclis_tatil` | [[GD 1878]] | [[Enver (Murat Bardakçı)#p. 62]] · *Türk kaynağı* |
| 40 | A | 1915-08-10 | Anafartalar: Mustafa Kemal'in karşı taarruzu | [[Gallipoli Campaign (1915)]] | 14/62 | yol ayrımı / son | `anafartalar` | [[GD 1915]] | [[Türkiye'de Beş Yıl (Liman von Sanders)#p. 127]] · *Alman kaynağı* |
| 41 | A | 1876-08-31 | V. Murad indirilir, II. Abdülhamid tahta çıkar | [[Murad V]] | 13/58 | yol ayrımı / son | `murad_v_ara`, `abdulhamid_culus` | [[GD 1876]] | [[Enver (Murat Bardakçı)#p. 61]] · *Türk kaynağı* |
| 42 | A | 1915-02 | Birinci Kanal Harekâtı | [[Suez Canal Campaign (1915)]] | 10/56 | yol ayrımı / son | `suveys_1` | [[GD 1915]] | [[Arap İsyanı 1916-1918 (David Murphy)#p. 21]] · *İrlandalı kaynağı* |
| 43 | A | 1914-11 | Köprüköy muharebesi ve Hasan İzzet Paşa'nın uyarısı | [[Caucasus Front]] | 11/55 | yol ayrımı / son | `koprukoy`, `hasan_izzet_uyari` | [[GD 1914]] | [[Hafız Hakkı Paşa'nın Sarıkamış Günlüğü (Hafız Hakkı Paşa)#p. 27]] · *Türk kaynağı* |
| 44 | A | 1914-10-29 | Souchon'un filosu Rus limanlarını bombalar | [[Wilhelm Souchon]] | 11/53 | yol ayrımı / son | `karadeniz_baskini` | [[GD 1914]] | [[Kılıç Ali'nin Anıları (Kılıç Ali)#p. 21]] · *Türk kaynağı* |
| 45 | A | 1911-10 | İtalya Trablusgarp'a saldırır | [[Italo-Turkish War (1911-1912)]] | 18/52 | yol ayrımı / son | `trablus_1911`, `trablus_gonulluler` | [[GD 1911]] | [[100. Yılında Jön Türk Devrimi (Sina Akşin)#p. 220]] · *Türk kaynağı* |
| 46 | B | 1896-08 | Taşnakların Osmanlı Bankası baskını | [[Ottoman Bank]] | 17/51 | yol ayrımı / son | `osmanli_bankasi_baskini` | [[GD 1896]] | [[Osmanlı İmparatorluğu Tarihi (Robert Mantran)#p. 696]] · *Fransız kaynağı* |
| 47 | B | 1918-10-08 | Talat Paşa kabinesi istifa eder | [[Talat Paşa]] | 8/51 | yol ayrımı / son | `talat_istifa` | [[GD 1918]] | [[İttihad ve Terakki Yargılamaları I (Erol Şadi Erdinç)#p. 11]] · *Türk kaynağı* |
| 48 | B | 1888 | Anadolu Demiryolu imtiyazı Alman grubuna | [[Baghdad Railway]] | 15/48 | yol ayrımı / son | `anadolu_demiryolu` | [[GD 1888]] | [[Osmanlı İmparatorluğu Tarihi (Robert Mantran)#p. 667]] · *Fransız kaynağı* |
| 49 | B | 1894 | Sason olayları | [[Hamidian massacres and Armenian uprisings (1894-1896)]] | 16/45 | yol ayrımı / son | `sason` | [[GD 1894]] | [[Balkan Savaşları (Troçki) (Leon Trotsky)#loc. 220]] · *Rus kaynağı* |
| 50 | B | 1913-01-23 | Babıâli Baskını | [[Raid on the Sublime Porte (1913)]] | 13/43 | yol ayrımı / son | `babiali_baskini` | [[GD 1913]] | [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 55]] · *Türk kaynağı* |
| 51 | B | 1919-05-15 | Yunan ordusu İzmir'e çıkar | [[Occupation of İzmir (1919)]] | 10/42 | yol ayrımı / son | `izmir_isgali` | [[GD 1919]] | [[Osmanlı İmparatorluğu Tarihi (Robert Mantran)#p. 793]] · *Fransız kaynağı* |
| 52 | B | 1919-05-19 | Mustafa Kemal Samsun'a çıkar | [[Mustafa Kemal Atatürk]] | 15/42 | yol ayrımı / son | `samsun` | [[GD 1919]] | [[Kılıç Ali'nin Anıları (Kılıç Ali)#p. 34]] · *Türk kaynağı* |
| 53 | B | 1914-08 | İngiltere parası ödenmiş dretnotlara el koyar | [[Ottoman Navy]] | 17/41 | yol ayrımı / son | `dretnotlar` | [[GD 1914]] | [[Cemal Paşa Hatıralar (Cemal Paşa)#p. 116]] · *Türk kaynağı* |
| 54 | B | 1918-03-03 | Brest-Litovsk Antlaşması | [[Treaty of Brest-Litovsk (1918)]] | 13/40 | yol ayrımı / son | `brest_litovsk` | [[GD 1918]] | [[The Armenian File (Kâmuran Gürün)#p. 309]] · *Türk kaynağı* |
| 55 | B | 1908-07 | Resneli Niyazi dağa çıkar, Şemsi Paşa vurulur | [[Resneli Niyazi]] | 15/39 | yol ayrımı / son | `niyazi_daga`, `semsi_pasa` | [[GD 1908]] | [[Cumhuriyete Doğru (Mahmut Goloğlu)#loc. 219]] · *Türk kaynağı* |
| 56 | B | 1912-01-06 | Meclis altı dretnotluk donanma programını kabul eder | [[Ottoman Navy]] | 17/37 | yol ayrımı / son | `donanma_programi` | [[GD 1912]] | [[Balkan Harbi'nde Ulaştırma (Bülent Durgun)#p. 239]] · *Türk kaynağı* |
| 57 | B | 1914-02 | Vehip Paşa Hicaz'da; Emir Abdullah Kitchener'le görüşür | [[Hicaz]] | 7/32 | yol ayrımı / son | `vehip_hicaz` | [[GD 1914]] | [[Irak Kralı I. Faysal (Ali A. Allawi)#p. 94]] · *Iraklı kaynağı* |
| 58 | B | 1915 | Cemal Paşa'nın Aley divan-ı harbi ve Beyrut idamları | [[Cemal Paşa]] | 11/32 | yol ayrımı / son | `suriye_idamlari` | [[GD 1915]] | [[Cemal Paşa Hatıralar (Cemal Paşa)#p. 17]] · *Türk kaynağı* |
| 59 | B | 1914 | Doğuya ikmal: demiryolu Ulukışla'da biter, Erzincan'a 500 km yol | [[Erzurum]] | 13/31 | yol ayrımı / son | `dogu_ikmal` | [[GD 1914]] | [[Türkiye'de Beş Yıl (Liman von Sanders)#p. 154]] · *Alman kaynağı* |
| 60 | B | 1914-01 | Enver Harbiye Nazırı ve Erkân-ı Harbiye Reisi | [[Enver Paşa]] | 16/31 | yol ayrımı / son | `enver_harbiye` | [[GD 1914]] | [[Enver (Murat Bardakçı)#p. 457]] · *Türk kaynağı* |
| 61 | B | 1906-09 | Selanik'te Osmanlı Hürriyet Cemiyeti kurulur | [[Selanik]] | 9/30 | yol ayrımı / son | `hurriyet_cemiyeti` | [[GD 1906]] | [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 34]] · *Türk kaynağı* |
| 62 | B | 1882 | Urabi ayaklanması ve Mısır'ın İngiliz işgali | [[British occupation of Egypt (1882)]] | 5/28 | yol ayrımı / son | `urabi`, `misir_isgali` | [[GD 1882]] | [[Mahşerin İki Gemisi - Part II (Video transcript)#loc. 15]] · *video dökümü (ikincil)* |
| 63 | B | 1878-03-03 | Ayastefanos Antlaşması | [[Treaty of San Stefano (1878)]] | 14/27 | yol ayrımı / son | `ayastefanos_muzakere`, `ayastefanos_imza` | [[GD 1878]] | [[Mahşerin İki Gemisi - Part I (Video transcript)#loc. 20]] · *video dökümü (ikincil)* |
| 64 | B | 1903-04-29 | Makedonya isyanı ve Mürzsteg ıslahatı; Hüseyin Hilmi müfettiş | [[Makedonya]] | 11/26 | yol ayrımı / son | `makedonya_1903`, `murzsteg` | [[GD 1903]] | [[Enver (Murat Bardakçı)#p. 81]] · *Türk kaynağı* |
| 65 | B | 1919-03 | Damat Ferid sadrazam | [[Damat Ferit Paşa]] | 30/541 | kaynak ya da kaldıraç | `damat_ferid` | [[GD 1919]] | [[Osmanlı İmparatorluğu Tarihi (Robert Mantran)#p. 793]] · *Fransız kaynağı* |
| 66 | B | 1914-09-09 | Kapitülasyonlar kaldırılır | [[Capitulations]] | 37/296 | kaynak ya da kaldıraç | `kapitulasyon` | [[GD 1914]] | [[Türkiye'de Milli İktisat (Zafer Toprak)#p. 197]] · *Türk kaynağı* |
| 67 | B | 1874 | Zırhlı donanma: borçla alınan gemiler | [[Ottoman Navy]] | 44/273 | kaynak ya da kaldıraç | `zirhli_donanma` | [[GD 1874]] | [[Osmanlı İmparatorluğu Tarihi (Robert Mantran)#p. 600]] · *Fransız kaynağı* |
| 68 | B | 1911-11-21 | Hürriyet ve İtilaf Fırkası kurulur | [[Freedom and Accord Party]] | 22/231 | kaynak ya da kaldıraç | `hurriyet_itilaf` | [[GD 1911]] | [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 51]] · *Türk kaynağı* |
| 69 | B | 1891 | Saray hafiyeleri gizli cemiyetin peşinde | [[Informants and spies (jurnal system)]] | 38/166 | kaynak ya da kaldıraç | `hafiye_1891` | [[GD 1891]] | [[Türkiye'de Hükümetler (İhsan Güneş)#p. 37]] · *Türk kaynağı* |
| 70 | B | 1877-03-19 | İlk Meclis-i Mebusan açılır | [[Ottoman Parliament]] | 24/157 | kaynak ya da kaldıraç | `meclis_1877` | [[GD 1877]] | [[Enver (Murat Bardakçı)#p. 88]] · *Türk kaynağı* |
| 71 | B | 1908-12-17 | Meclis-i Mebusan yeniden açılır | [[Ottoman Parliament]] | 24/157 | kaynak ya da kaldıraç | `meclis_1908` | [[GD 1908]] | [[Türkiye'de Hükümetler (İhsan Güneş)#p. 39]] · *Türk kaynağı* |
| 72 | B | 1916-06 | Talat maliye vekili; tüketim kooperatifleri ve Milli İktisat | [[National economy (Milli İktisat)]] | 16/150 | kaynak ya da kaldıraç | `milli_iktisat` | [[GD 1916]] | [[Türkiye'de Milli İktisat (Zafer Toprak)#p. 342]] · *Türk kaynağı* |
| 73 | B | 1877-02 | Midhat Paşa azledilip sürülür | [[Midhat Paşa]] | 32/147 | kaynak ya da kaldıraç | `midhat_surgun` | [[GD 1877]] | [[Enver (Murat Bardakçı)#p. 61]] · *Türk kaynağı* |
| 74 | B | 1916 | Harbin ikinci yarısı: Romanya, Galiçya ve Makedonya'ya tümenler | [[Galician Front (1916-1917)]] | 23/141 | kaynak ya da kaldıraç | `avrupa_tumenleri` | [[GD 1916]] | [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 78]] · *Türk kaynağı* |
| 75 | B | 1916-06-04 | Falkenhayn Galiçya için kolordu ister | [[Galician Front (1916-1917)]] | 21/127 | kaynak ya da kaldıraç | `galicya` | [[GD 1916]] | [[Kumandanım Galiçya Ne Yana Düşer (M. Şevki Yazman)#p. 16]] · *Türk kaynağı* |
| 76 | B | 1878 | Rumeli'den muhacir seli | [[Refugees (muhacir)]] | 45/119 | kaynak ya da kaldıraç | `muhacir_1878` | [[GD 1878]] | [[Osmanlı İmparatorluğu Tarihi (Robert Mantran)#p. 675]] · *Fransız kaynağı* |
| 77 | B | 1899-01-23 | Kuveyt Şeyhi Mübarek ile İngiltere'nin gizli anlaşması | [[Hindistan]] | 14/114 | kaynak ya da kaldıraç | `kuveyt_1899` | [[GD 1899]] | [[Osmanlı Arap Coğrafyası ve Avrupa Emperyalizmi (Ali Akyıldız)#p. 258]] · *Türk kaynağı* |
| 78 | B | 1915-06-13 | İlk kâğıt para | [[National economy (Milli İktisat)]] | 18/114 | kaynak ya da kaldıraç | `kagit_para` | [[GD 1915]] | [[Birinci Dünya Savaşı'nda Türkiye (Ahmet Emin Yalman)#p. 205]] · *Türk kaynağı* |
| 79 | B | 1917 | Yıldırım Ordular Grubu kurulur | [[Yıldırım Army Group]] | 28/105 | kaynak ya da kaldıraç | `yildirim` | [[GD 1917]] | [[Osmanlı Piyadesi 1914-1918 (David Nicolle)#p. 11]] · *İngiliz kaynağı* |
| 80 | B | 1892 | Cemaleddin Afgani sarayın misafiri: İttihad-ı İslam | [[Pan-Islamism]] | 19/103 | kaynak ya da kaldıraç | `afgani` | [[GD 1892]] | [[Osmanlı İmparatorluğu Tarihi (Robert Mantran)#p. 664]] · *Fransız kaynağı* |
| 81 | B | 1918-11-01 | Talat, Enver ve Cemal bir Alman gemisiyle kaçar | [[Enver Paşa]] | 15/24 | yol ayrımı / son | `ucluler_kacti` | [[GD 1918]] | [[Osmanlı İmparatorluğu Tarihi (Robert Mantran)#p. 791]] · *Fransız kaynağı* |
| 82 | B | 1908-03 | Rumeli'de maaş için asker ayaklanmaları | [[Rumeli]] | 12/22 | yol ayrımı / son | `asker_maas_1908` | [[GD 1908]] | [[100. Yılında Jön Türk Devrimi (Sina Akşin)#p. 440]] · *Türk kaynağı* |
| 83 | B | 1891 | Hamidiye Alayları kurulur | [[Hamidiye Regiments]] | 9/19 | yol ayrımı / son | `hamidiye_alaylari` | [[GD 1891]] | [[Osmanlı İmparatorluğu Tarihi (Robert Mantran)#p. 696]] · *Fransız kaynağı* |
| 84 | B | 1878-05-20 | Çırağan Baskını: Murad'ı geri getirme teşebbüsü | [[Murad V]] | 9/18 | yol ayrımı / son | `ciragan_baskini` | [[GD 1878]] | [[Enver (Murat Bardakçı)#p. 72]] · *Türk kaynağı* |
| 85 | B | 1914-02-08 | Doğu vilayetleri ıslahat anlaşması (müfettişler) | [[Van]] | 10/18 | yol ayrımı / son | `islahat_1914` | [[GD 1914]] | [[Birinci Dünya Savaşı'nda Türkiye (Ahmet Emin Yalman)#p. 262]] · *Türk kaynağı* |
| 86 | C | 1913-07 | Edirne geri alınır | [[Edirne]] | 8/15 | yol ayrımı / son | `edirne_geri` | [[GD 1913]] | [[Enver (Murat Bardakçı)#p. 104]] · *Türk kaynağı* |
| 87 | C | 1915-12-07 | Kut kuşatması ve Townshend'in teslimi (29 Nisan 1916) | [[Siege of Kut (1916)]] | 6/15 | yol ayrımı / son | `kut_kusatma`, `kut_zafer` | [[GD 1915]] | [[Osmanlı Piyadesi 1914-1918 (David Nicolle)#p. 10]] · *İngiliz kaynağı* |
| 88 | C | 1909-04 | Adana olayları | [[Adana events (1909)]] | 5/14 | yol ayrımı / son | `adana_1909` | [[GD 1909]] | [[100. Yılında Jön Türk Devrimi (Sina Akşin)#p. 631]] · *Türk kaynağı* |
| 89 | C | 1915-04-20 | Van isyanı | [[Van]] | 1/10 | yol ayrımı / son | `van_1915` | [[GD 1915]] | [[The Armenian File (Kâmuran Gürün)#p. 275]] · *Türk kaynağı* |
| 90 | C | 1919-06-22 | Amasya Genelgesi | [[Amasya Circular (1919)]] | 4/10 | yol ayrımı / son | `amasya` | [[GD 1919]] | [[Sivas Kongresi (Mahmut Goloğlu)#loc. 6]] · *Türk kaynağı* |
| 91 | C | 1913-03-26 | Aç kalan Edirne teslim olur | [[Edirne]] | 6/9 | yol ayrımı / son | `edirne_dustu` | [[GD 1913]] | [[Irak Kralı I. Faysal (Ali A. Allawi)#p. 86]] · *Iraklı kaynağı* |
| 92 | C | 1917-03-11 | İngilizler Bağdat'ı alır | [[Bağdat]] | 5/9 | yol ayrımı / son | `bagdat_dustu` | [[GD 1917]] | [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 80]] · *Türk kaynağı* |
| 93 | C | 1897-04 | Yunan Harbi ve Dömeke zaferi | [[Greco-Turkish War of 1897]] | 6/8 | yol ayrımı / son | `yunan_harbi_1897` | [[GD 1897]] | [[Balkan Savaşı Günlüğü (Gustav von Hochwächter)#p. 26]] · *Alman kaynağı* |
| 94 | C | 1902 | Alınan tüfekler depolarda bekletilir | [[Military uniforms and equipment]] | 4/6 | yol ayrımı / son | `silah_depo` | [[GD 1902]] | [[Balkan Harbi'nde Ulaştırma (Bülent Durgun)#p. 76]] · *Türk kaynağı* |
| 95 | C | 1916-02-16 | Erzurum, Bitlis ve Trabzon Ruslara düşer | [[Erzurum]] | 5/6 | yol ayrımı / son | `erzurum_1916`, `trabzon_1916` | [[GD 1916]] | [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 78]] · *Türk kaynağı* |
| 96 | C | 1878-01-31 | Edirne mütarekesi, Ruslar Yeşilköy'e kadar gelir | [[Yeşilköy (Ayastefanos)]] | 2/5 | yol ayrımı / son | `edirne_mutareke` | [[GD 1878]] | [[The Armenian File (Kâmuran Gürün)#p. 145]] · *Türk kaynağı* |
| 97 | C | 1897-03-19 | Donanmanın Haliç'ten 'utanç verici' çıkışı | [[Ottoman Navy]] | 4/5 | yol ayrımı / son | `donanma_1897` | [[GD 1897]] | [[Enver (Murat Bardakçı)#p. 69]] · *Türk kaynağı* |
| 98 | C | 1917-12-09 | Kudüs düşer | [[Kudüs]] | 3/5 | yol ayrımı / son | `kudus_dustu` | [[GD 1917]] | [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 80]] · *Türk kaynağı* |
| 99 | C | 1878-02 | Donanma Haliç'e kapatılır | [[Ottoman Navy]] | 3/3 | yol ayrımı / son | `donanma_halic` | [[GD 1878]] | [[Enver (Murat Bardakçı)#p. 69]] · *Türk kaynağı* |
| 100 | C | 1918-03-12 | Erzurum, Sarıkamış ve Kars geri alınır | [[Kars]] | 2/2 | yol ayrımı / son | `kafkas_geri_1918` | [[GD 1918]] | [[The Armenian File (Kâmuran Gürün)#p. 311]] · *Türk kaynağı* |
| 101 | C | 1895-10 | Üç sefirin ıslahat layihası, Babıâli ve Trabzon olayları, ıslahat fermanı | [[Hamidian massacres and Armenian uprisings (1894-1896)]] | 1/1 | yol ayrımı / son | `islahat_1895`, `trabzon_1895` | [[GD 1895]] | [[Cemal Paşa Hatıralar (Cemal Paşa)#p. 400]] · *Türk kaynağı* |
| 102 | C | 1914-06 | Taşnakların Erzurum kongresi | [[Armenian revolutionary committees]] | 0/0 | yol ayrımı / son | `tasnak_erzurum` | [[GD 1914]] | [[The Armenian File (Kâmuran Gürün)#p. 261]] · *Türk kaynağı* |
| 103 | C | 1915-04 | Çekirge ve Suriye kıtlığı | [[Famine and epidemics]] | 30/97 | kaynak ya da kaldıraç | `suriye_kitlik` | [[GD 1915]] | [[Cemal Paşa Hatıralar (Cemal Paşa)#p. 341]] · *Türk kaynağı* |
| 104 | C | 1917-07-06 | Faysal'ın kuvvetleri Akabe'yi alır | [[Faysal]] | 12/96 | kaynak ya da kaldıraç | `akabe` | [[GD 1917]] | [[Osmanlı İmparatorluğu Tarihi (Robert Mantran)#p. 777]] · *Fransız kaynağı* |
| 105 | C | 1919-07-13 | Divan-ı Harp üçlüyü ve Nazım'ı idama mahkûm eder | [[Doktor Nazım]] | 29/96 | kaynak ya da kaldıraç | `ucluler_idam_karari` | [[GD 1919]] | [[The Armenian File (Kâmuran Gürün)#p. 318]] · *Türk kaynağı* |
| 106 | C | 1884 | Midhat Paşa Taif'te öldürülür | [[Midhat Paşa]] | 18/84 | kaynak ya da kaldıraç | `midhat_taif` | [[GD 1884]] | [[Sultanın Paşaları (Olivier Bouquet)#p. 66]] · *Fransız kaynağı* |
| 107 | C | 1914-11 | Cihad-ı Ekber ilanı | [[Pan-Islamism]] | 25/83 | kaynak ya da kaldıraç | `cihad` | [[GD 1914]] | [[Enver (Murat Bardakçı)#p. 154]] · *Türk kaynağı* |
| 108 | C | 1890 | Taşnaksutyun Tiflis'te kurulur | [[Armenian revolutionary committees]] | 20/82 | kaynak ya da kaldıraç | `tasnak_kurulus` | [[GD 1890]] | [[Osmanlı İmparatorluğu Tarihi (Robert Mantran)#p. 695]] · *Fransız kaynağı* |
| 109 | C | 1880-06-01 | Bismarck, Sultan'ın Alman müşavir talebini onaylar | [[Otto von Bismarck]] | 19/77 | kaynak ya da kaldıraç | `alman_danisman` | [[GD 1880]] | [[Mahşerin İki Gemisi - Part II (Video transcript)#loc. 14]] · *video dökümü (ikincil)* |
| 110 | C | 1917-03-26 | Gazze muharebeleri | [[Palestine and Sinai Front]] | 20/74 | kaynak ya da kaldıraç | `gazze` | [[GD 1917]] | [[İttihadçı'nın Sandığı (Murat Bardakçı)#p. 450]] · *Türk kaynağı* |
| 111 | C | 1908-06 | Reval görüşmesi ve Makedonya'da yeni müdahale korkusu | [[Selanik]] | 15/71 | kaynak ya da kaldıraç | `reval` | [[GD 1908]] | [[100. Yılında Jön Türk Devrimi (Sina Akşin)#p. 438]] · *Türk kaynağı* |
| 112 | C | 1885-09-18 | Doğu Rumeli Bulgaristan'a katılır | [[Bulgaristan]] | 13/66 | kaynak ya da kaldıraç | `dogu_rumeli` | [[GD 1885]] | [[Enver (Murat Bardakçı)#p. 64]] · *Türk kaynağı* |
| 113 | C | 1883 | Tütün Rejisi tekeli | [[Tobacco Régie]] | 23/65 | kaynak ya da kaldıraç | `reji` | [[GD 1883]] | [[Balkan Harbi'nde Ulaştırma (Bülent Durgun)#p. 37]] · *Türk kaynağı* |
| 114 | C | 1893-04 | Ermenilere genel af | [[Abdülhamid II]] | 17/56 | kaynak ya da kaldıraç | `ermeni_affi_1893` | [[GD 1893]] | [[The Armenian File (Kâmuran Gürün)#p. 199]] · *Türk kaynağı* |
| 115 | C | 1887 | Hınçak partisi Cenevre'de kurulur | [[Armenian revolutionary committees]] | 10/55 | kaynak ya da kaldıraç | `hincak` | [[GD 1887]] | [[Osmanlı İmparatorluğu Tarihi (Robert Mantran)#p. 695]] · *Fransız kaynağı* |
| 116 | C | 1916-09-23 | Hicaz'da Osmanlı garnizonları teslim; Fahreddin Paşa Medine'de | [[Fahreddin Paşa]] | 13/55 | kaynak ya da kaldıraç | `medine_mudafaa` | [[GD 1916]] | [[Irak Kralı I. Faysal (Ali A. Allawi)#p. 131]] · *Iraklı kaynağı* |
| 117 | C | 1881-05-12 | Tunus Fransız himayesine girer | [[Tunus]] | 14/54 | kaynak ya da kaldıraç | `tunus` | [[GD 1881]] | [[Bir Amerikan Diplomatının İstanbul Anıları (Samuel S. Cox)#p. 705]] · *Amerikan kaynağı* |
| 118 | C | 1893 | Yozgat ve Merzifon olayları (Hınçak) | [[Armenian revolutionary committees]] | 18/53 | kaynak ya da kaldıraç | `yozgat_1893` | [[GD 1893]] | [[Kim Hain, Kim Kahraman (Video transcript)#loc. 2]] · *video dökümü (ikincil)* |
| 119 | C | 1912-10 | Uşi Antlaşması: Trablusgarp İtalya'ya | [[Trablusgarp]] | 9/53 | kaynak ya da kaldıraç | `usi` | [[GD 1912]] | [[Osmanlı Arap Coğrafyası ve Avrupa Emperyalizmi (Ali Akyıldız)#p. 9]] · *Türk kaynağı* |
| 120 | C | 1915-02-12 | Tifüs: Hafız Hakkı Paşa ölür | [[Famine and epidemics]] | 17/53 | kaynak ya da kaldıraç | `tifus_1915` | [[GD 1915]] | [[Türkiye'de Beş Yıl (Liman von Sanders)#p. 81]] · *Alman kaynağı* |
| 121 | C | 1912-07 | Halaskâr Zabitan İttihat'ı iktidardan düşürür | [[Mahmud Şevket Paşa]] | 20/47 | kaynak ya da kaldıraç | `halaskar` | [[GD 1912]] | [[100. Yılında Jön Türk Devrimi (Sina Akşin)#p. 32]] · *Türk kaynağı* |
| 122 | C | 1898 | Salisbury Rusya'ya Osmanlı'nın paylaşılmasını önerir | [[Lord Salisbury]] | 13/44 | kaynak ya da kaldıraç | `salisbury_taksim` | [[GD 1898]] | [[Mahşerin İki Gemisi - Part II (Video transcript)#loc. 15]] · *video dökümü (ikincil)* |
| 123 | C | 1918-07 | V. Mehmed ölür, Vahdettin tahta çıkar | [[Mehmed VI Vahdettin]] | 15/41 | kaynak ya da kaldıraç | `vahdettin_culus` | [[GD 1918]] | [[Türkiye'de Hükümetler (İhsan Güneş)#p. 297]] · *Türk kaynağı* |
| 124 | C | 1913-05-30 | Londra Antlaşması | [[Londra]] | 14/40 | kaynak ya da kaldıraç | `londra_1913` | [[GD 1913]] | [[Balkan Savaşları (Troçki) (Leon Trotsky)#loc. 349]] · *Rus kaynağı* |
| 125 | C | 1892 | Anadolu Demiryolu Ankara'ya ulaşır | [[Baghdad Railway]] | 14/39 | kaynak ya da kaldıraç | `ankara_hatti` | [[GD 1892]] | [[Osmanlı İmparatorluğu Tarihi (Robert Mantran)#p. 667]] · *Fransız kaynağı* |
| 126 | C | 1890 | Musa Bey davası, Erzurum ve Kumkapı olayları | [[Hamidian massacres and Armenian uprisings (1894-1896)]] | 15/38 | kaynak ya da kaldıraç | `kumkapi_1890` | [[GD 1890]] | [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 31]] · *Türk kaynağı* |
| 127 | C | 1915-08-30 | McMahon'un Şerif Hüseyin'e cevabı | [[Henry McMahon]] | 7/37 | kaynak ya da kaldıraç | `mcmahon` | [[GD 1915]] | [[Irak Kralı I. Faysal (Ali A. Allawi)#p. 113]] · *Iraklı kaynağı* |
| 128 | C | 1916-08-06 | Mustafa Kemal Bitlis ve Muş'u geri alır | [[Caucasus Front]] | 15/31 | kaynak ya da kaldıraç | `mus_bitlis` | [[GD 1916]] | [[Atatürk Hakkında Hatıralar ve Belgeler (Afet İnan)#p. 30]] · *Türk kaynağı* |
| 129 | C | 1916-08-04 | İkinci Kanal Harekâtı Romani'de durur | [[Palestine and Sinai Front]] | 9/30 | kaynak ya da kaldıraç | `suveys_2` | [[GD 1916]] | [[Osmanlı Piyadesi 1914-1918 (David Nicolle)#p. 10]] · *İngiliz kaynağı* |
| 130 | C | 1907 | İkinci Jön Türk Kongresi (Paris) | [[Young Turks]] | 15/29 | kaynak ya da kaldıraç | `jon_turk_kongresi_1907` | [[GD 1907]] | [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 34]] · *Türk kaynağı* |
| 131 | C | 1875-07 | Hersek ayaklanması |  | 9/25 | kaynak ya da kaldıraç | `hersek_isyani` | [[GD 1875]] | [[Balkan Savaşları (Troçki) (Leon Trotsky)#loc. 374]] · *Rus kaynağı* |
| 132 | C | 1895 | Zeytun isyanı | [[Hamidian massacres and Armenian uprisings (1894-1896)]] | 10/25 | kaynak ya da kaldıraç | `zeytun` | [[GD 1895]] | [[Osmanlı İmparatorluğu Tarihi (Robert Mantran)#p. 696]] · *Fransız kaynağı* |
| 133 | C | 1905 | Yıldız suikastı (bombalı teşebbüs) | [[Yıldız assassination attempt (1905)]] | 13/25 | kaynak ya da kaldıraç | `yildiz_suikasti` | [[GD 1905]] | [[Avrupa ve Biz (İlber Ortaylı)#p. 147]] · *Türk kaynağı* |
| 134 | C | 1909-02-13 | Kâmil Paşa güvensizlik oyuyla düşer | [[Kamil Paşa]] | 34/208 | atmosfer | `kamil_dusus` | [[GD 1909]] | [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 38]] · *Türk kaynağı* |
| 135 | C | 1910 | Havran (Dürzi) isyanı | [[Lübnan]] | 20/106 | atmosfer | `havran` | [[GD 1910]] | [[Balkan Savaşı Günlüğü (Gustav von Hochwächter)#p. 88]] · *Alman kaynağı* |
| 136 | C | 1917-02-04 | Talat sadrazam olur | [[Talat Paşa]] | 12/24 | kaynak ya da kaldıraç | `talat_sadrazam` | [[GD 1917]] | [[Talât Paşa'nın Evrak-ı Metrukesi (Murat Bardakçı)#p. 87]] · *Türk kaynağı* |
| 137 | C | 1881-07-02 | Teselya ve Narda Yunanistan'a bırakılır | [[Yunanistan]] | 13/22 | kaynak ya da kaldıraç | `teselya` | [[GD 1881]] | [[Enver (Murat Bardakçı)#p. 64]] · *Türk kaynağı* |
| 138 | C | 1918-09-15 | Kafkas İslam Ordusu Bakü'yü alır | [[Bakü]] | 12/22 | kaynak ya da kaldıraç | `baku` | [[GD 1918]] | [[Enver (Murat Bardakçı)#p. 227]] · *Türk kaynağı* |
| 139 | C | 1919-04-10 | Boğazlıyan Kaymakamı Kemal Bey idam edilir | [[Boğazlıyan Kaymakamı Kemal Bey]] | 7/22 | kaynak ya da kaldıraç | `kemal_bey_idam` | [[GD 1919]] | [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 90]] · *Türk kaynağı* |
| 140 | C | 1877-06-27 | Ruslar Tuna'yı geçer | [[Tuna]] | 9/21 | kaynak ya da kaldıraç | `tuna_gecisi` | [[GD 1877]] | [[Mahşerin İki Gemisi - Part I (Video transcript)#loc. 18]] · *video dökümü (ikincil)* |
| 141 | C | 1906-10 | Mustafa Kemal Şam'da Vatan ve Hürriyet'i kurar | [[Mustafa Kemal Atatürk]] | 8/20 | kaynak ya da kaldıraç | `vatan_hurriyet` | [[GD 1906]] | [[Zabit ve Kumandan ile Hasbihal (Mustafa Kemal)#p. 12]] · *Türk kaynağı* |
| 142 | C | 1876-07-30 | Sırbistan ve Karadağ harp ilan eder | [[Sırbistan]] | 11/19 | kaynak ya da kaldıraç | `sirp_harbi` | [[GD 1876]] | [[Mahşerin İki Gemisi - Part I (Video transcript)#loc. 17]] · *video dökümü (ikincil)* |
| 143 | C | 1897 | Mizancı Murad affı kabul edip döner | [[Mizancı Murad]] | 5/19 | kaynak ya da kaldıraç | `mizanci_af` | [[GD 1897]] | [[Osmanlı İmparatorluğu Tarihi (Robert Mantran)#p. 706]] · *Fransız kaynağı* |
| 144 | C | 1909-08-07 | Yemen'de İmam Yahya'nın ültimatomu | [[Yemen]] | 6/18 | kaynak ya da kaldıraç | `yemen_1909` | [[GD 1909]] | [[100. Yılında Jön Türk Devrimi (Sina Akşin)#p. 218]] · *Türk kaynağı* |
| 145 | C | 1877-08 | Şıpka geçidi muharebeleri | [[Şıpka]] | 9/17 | kaynak ya da kaldıraç | `sipka` | [[GD 1877]] | [[Plevne'de Bir Avustralyalı (Charles S. Ryan)#p. 241]] · *Avustralyalı kaynağı* |
| 146 | C | 1896 | Girit isyanı | [[Girit]] | 6/17 | kaynak ya da kaldıraç | `girit_1896` | [[GD 1896]] | [[Balkan Savaşları (Troçki) (Leon Trotsky)#loc. 376]] · *Rus kaynağı* |
| 147 | C | 1909 | Arnavut isyanları (1909–1912) | [[Arnavutluk]] | 8/16 | kaynak ya da kaldıraç | `arnavut_isyani` | [[GD 1909]] | [[Balkan Savaşı Günlüğü (Gustav von Hochwächter)#p. 88]] · *Alman kaynağı* |
| 148 | C | 1913 | Aziz Ali el-Mısri el-Ahd cemiyetini kurar | [[Aziz Ali el-Mısri]] | 4/15 | kaynak ya da kaldıraç | `el_ahd` | [[GD 1913]] | [[Irak Kralı I. Faysal (Ali A. Allawi)#p. 82]] · *Iraklı kaynağı* |
| 149 | C | 1916-01 | İtilaf kuvvetleri Gelibolu'yu boşaltır | [[Çanakkale and Gelibolu]] | 9/15 | kaynak ya da kaldıraç | `gelibolu_tahliye` | [[GD 1916]] | [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 77]] · *Türk kaynağı* |
| 150 | C | 1876-12 | Tersane (İstanbul) Konferansı |  | 6/14 | kaynak ya da kaldıraç | `tersane_konferansi` | [[GD 1876]] | [[Hobart Paşa'nın Anıları (Augustus C. Hobart-Hampden)#p. 16]] · *İngiliz kaynağı* |
| 151 | C | 1907-08 | İngiliz–Rus itilafı | [[İran]] | 9/14 | kaynak ya da kaldıraç | `ingiliz_rus_itilafi` | [[GD 1907]] | [[Mahşerin İki Gemisi - Part II (Video transcript)#loc. 15]] · *video dökümü (ikincil)* |
| 152 | C | 1876-10-31 | Ignatiev'in Sırbistan ültimatomu | [[Nikolay Ignatiev]] | 2/13 | kaynak ya da kaldıraç | `ignatiev_ultimatom` | [[GD 1876]] | [[Osmanlı İmparatorluğu Tarihi (Robert Mantran)#p. 638]] · *Fransız kaynağı* |
| 153 | C | 1873-04 | Vatan yahut Silistre sahnelenir, Namık Kemal sürülür | [[Namık Kemal]] | 5/12 | kaynak ya da kaldıraç | `vatan_silistre` | [[GD 1873]] | [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 23]] · *Türk kaynağı* |
| 154 | C | 1877-11-18 | Kars düşer (Gazi Ahmed Muhtar'ın direnişine rağmen) | [[Gazi Ahmed Muhtar Paşa]] | 4/9 | kaynak ya da kaldıraç | `kars_1877` | [[GD 1877]] | [[Hobart Paşa'nın Anıları (Augustus C. Hobart-Hampden)#p. 228]] · *İngiliz kaynağı* |
| 155 | C | 1918-10-01 | Şam ve Halep düşer | [[Şam]] | 3/9 | kaynak ya da kaldıraç | `sam_halep` | [[GD 1918]] | [[Osmanlı Piyadesi 1914-1918 (David Nicolle)#p. 12]] · *İngiliz kaynağı* |
| 156 | C | 1914-11-22 | İngiliz-Hint kuvvetleri Basra'yı alır | [[Mesopotamian Front]] | 6/8 | kaynak ya da kaldıraç | `basra_1914` | [[GD 1914]] | [[Osmanlı Piyadesi 1914-1918 (David Nicolle)#p. 9]] · *İngiliz kaynağı* |
| 157 | C | 1876-04 | Bulgar ayaklanması ve 'Bulgar vahşeti' (Gladstone, Eylül 1876) | [[William Gladstone]] | 6/7 | kaynak ya da kaldıraç | `bulgar_isyani`, `gladstone_risale` | [[GD 1876]] | [[Neden Biz (Video transcript)#loc. 11]] · *video dökümü (ikincil)* |
| 158 | C | 1902-02-04 | Birinci Jön Türk Kongresi (Paris) bölünmeyle biter | [[Young Turks]] | 5/7 | kaynak ya da kaldıraç | `jon_turk_kongresi_1902` | [[GD 1902]] | [[Enver (Murat Bardakçı)#p. 86]] · *Türk kaynağı* |
| 159 | C | 1896 | Nelidov'un Boğaz'ı ele geçirme planı | [[Boğazlar]] | 4/6 | kaynak ya da kaldıraç | `nelidov_plani` | [[GD 1896]] | [[Mahşerin İki Gemisi - Part II (Video transcript)#loc. 17]] · *video dökümü (ikincil)* |
| 160 | C | 1903 | Bağdat Demiryolu Şirketi kurulur | [[Baghdad Railway]] | 4/6 | kaynak ya da kaldıraç | `bagdat_sirketi` | [[GD 1903]] | [[Türkiye'de Milli İktisat (Zafer Toprak)#p. 642]] · *Türk kaynağı* |
| 161 | C | 1908 | Hicaz Demiryolu Medine'ye ulaşır | [[Hejaz Railway]] | 5/6 | kaynak ya da kaldıraç | `hicaz_medine` | [[GD 1908]] | [[Osmanlı Ortadoğu'sunu Yeniden Düşünmek (Cem Emrence)#p. 120]] · *Türk kaynağı* |
| 162 | C | 1906 | Erzurum isyanı: vergi ve Hamidiye'ye karşı | [[Erzurum]] | 4/5 | kaynak ya da kaldıraç | `erzurum_1906` | [[GD 1906]] | [[Osmanlı İmparatorluğu Tarihi (Robert Mantran)#p. 712]] · *Fransız kaynağı* |
| 163 | C | 1877-12-10 | Plevne düşer | [[Gazi Osman Paşa]] | 3/4 | kaynak ya da kaldıraç | `plevne_dustu` | [[GD 1877]] | [[The Armenian File (Kâmuran Gürün)#p. 121]] · *Türk kaynağı* |
| 164 | C | 1918-12-21 | Fransız ve Ermeni Lejyonu Adana'ya girer | [[Adana]] | 2/3 | kaynak ya da kaldıraç | `adana_isgal` | [[GD 1918]] | [[Son Meşrutiyet (Sina Akşin)#loc. 254]] · *Türk kaynağı* |
| 165 | C | 1879 | İngiliz askerî konsolosları doğu vilayetlerinde | [[Kafkasya]] | 1/2 | kaynak ya da kaldıraç | `ingiliz_konsoloslar` | [[GD 1879]] | [[Osmanlı İmparatorluğu Tarihi (Robert Mantran)#p. 694]] · *Fransız kaynağı* |
| 166 | C | 1909-09-03 | İttihat ve Terakki ile Taşnaksutyun anlaşması | [[Ottoman press]] | 1/2 | kaynak ya da kaldıraç | `tasnak_anlasma` | [[GD 1909]] | [[The Armenian File (Kâmuran Gürün)#p. 260]] · *Türk kaynağı* |
| 167 | C | 1918-09-29 | Bulgaristan mütareke imzalar | [[Bulgaristan]] | 1/2 | kaynak ya da kaldıraç | `bulgar_mutareke` | [[GD 1918]] | [[Atatürk Hakkında Hatıralar ve Belgeler (Afet İnan)#p. 32]] · *Türk kaynağı* |
| 168 | C | 1919-01 | Medine garnizonu teslim olur | [[Medine]] | 1/2 | kaynak ya da kaldıraç | `medine_teslim` | [[GD 1919]] | [[Osmanlı Piyadesi 1914-1918 (David Nicolle)#p. 12]] · *İngiliz kaynağı* |
| 169 | C | 1878-06-04 | Kıbrıs İngiltere'ye bırakılır | [[Kıbrıs]] | 1/1 | kaynak ya da kaldıraç | `kibris` | [[GD 1878]] | [[Enver (Murat Bardakçı)#p. 63]] · *Türk kaynağı* |
| 170 | C | 1897-12-18 | Girit'e özerklik | [[Girit]] | 1/1 | kaynak ya da kaldıraç | `girit_ozerklik` | [[GD 1897]] | [[Enver (Murat Bardakçı)#p. 64]] · *Türk kaynağı* |
| 171 | C | 1914-11-14 | Ayastefanos'taki Rus abidesi yıkılır | [[Yeşilköy (Ayastefanos)]] | 1/1 | kaynak ya da kaldıraç | `abide_yikim` | [[GD 1914]] | [[Zabit ve Kumandan ile Hasbihal (Mustafa Kemal)#p. 118]] · *Türk kaynağı* |
| 172 | C | 1889 | Kaiser II. Wilhelm'in ilk ziyareti | [[Kaiser Wilhelm II]] | 0/0 | kaynak ya da kaldıraç | `kaiser_1889` | [[GD 1889]] | [[Arap İsyanı 1916-1918 (David Murphy)#p. 8]] · *İrlandalı kaynağı* |
| 173 | C | 1898 | Taşnak kongresi terörü başlıca silah olarak benimser | [[Armenian revolutionary committees]] | 0/0 | kaynak ya da kaldıraç | `tasnak_1898` | [[GD 1898]] | [[Balkan Savaşları (Troçki) (Leon Trotsky)#loc. 371]] · *Rus kaynağı* |
| 174 | C | 1900 | Darülfünun kurulur |  | 25/96 | atmosfer | `darulfunun` | [[GD 1900]] | [[Avrupa ve Biz (İlber Ortaylı)#p. 245]] · *Türk kaynağı* |
| 175 | C | 1916-04-06 | Goltz Paşa Bağdat'ta ölür | [[Colmar von der Goltz]] | 20/78 | atmosfer | `goltz_olum` | [[GD 1916]] | [[Türkiye'de Beş Yıl (Liman von Sanders)#p. 463]] · *Alman kaynağı* |
| 176 | C | 1911-07-03 | Türk Ocağı çalışmaya başlar | [[Türk Ocağı]] | 17/68 | atmosfer | `turk_ocagi` | [[GD 1911]] | [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 62]] · *Türk kaynağı* |
| 177 | C | 1918-12-04 | Wilson Prensipleri Cemiyeti | [[Halide Edib]] | 17/59 | atmosfer | `wilson_cemiyeti` | [[GD 1918]] | [[Son Meşrutiyet (Sina Akşin)#loc. 304]] · *Türk kaynağı* |
| 178 | C | 1890 | Kolera salgını | [[Famine and epidemics]] | 21/58 | atmosfer | `kolera_1890` | [[GD 1890]] | [[Osmanlı'da Değişim ve Anayasal Rejim Sorunu (İlber Ortaylı)#p. 157]] · *Türk kaynağı* |
| 179 | C | 1874 | İstanbul–Sofya demiryolu ve Dedeağaç kolu açılır | [[Sofya]] | 14/44 | atmosfer | `rumeli_demiryolu` | [[GD 1874]] | [[Değişen İstanbul (Zeynep Çelik)#p. 147]] · *Türk kaynağı* |
| 180 | C | 1901 | Servet-i Fünun kapatılır | [[Tevfik Fikret]] | 9/36 | atmosfer | `servet_i_funun` | [[GD 1901]] | [[Osmanlı İmparatorluğu Tarihi (Robert Mantran)#p. 897]] · *Fransız kaynağı* |
| 181 | C | 1878 | Prizren (Arnavut) Birliği | [[Arnavutluk]] | 7/19 | atmosfer | `prizren_birligi` | [[GD 1878]] | [[Osmanlı'da Milletler ve Diplomasi (İlber Ortaylı)#loc. 24]] · *Türk kaynağı* |
| 182 | C | 1880 | Beyrut'ta birleşik, özerk Suriye–Lübnan gösterileri | [[Lübnan]] | 3/19 | atmosfer | `beyrut_1880` | [[GD 1880]] | [[Osmanlı'da Değişim ve Anayasal Rejim Sorunu (İlber Ortaylı)#p. 203]] · *Türk kaynağı* |
| 183 | C | 1888 | İstanbul–Viyana demiryolu tamamlanır | [[Yeşilköy (Ayastefanos)]] | 7/18 | atmosfer | `viyana_hatti` | [[GD 1888]] | [[Değişen İstanbul (Zeynep Çelik)#p. 147]] · *Türk kaynağı* |
| 184 | C | 1886-01 | Gazi Ahmed Muhtar Paşa Mısır fevkalade komiseri | [[Gazi Ahmed Muhtar Paşa]] | 4/12 | atmosfer | `muhtar_misir` | [[GD 1886]] | [[Osmanlı Arap Coğrafyası ve Avrupa Emperyalizmi (Ali Akyıldız)#p. 439]] · *Türk kaynağı* |
| 185 | C | 1885 | Armenakan partisi Van'da kurulur | [[Armenian revolutionary committees]] | 2/10 | atmosfer | `armenakan` | [[GD 1885]] | [[Osmanlı İmparatorluğu Tarihi (Robert Mantran)#p. 695]] · *Fransız kaynağı* |
| 186 | C | 1916 | Veliaht Yusuf İzzeddin ölür, Vahdettin veliaht | [[Şehzade Yusuf İzzeddin]] | 5/8 | atmosfer | `yusuf_izzeddin` | [[GD 1916]] | [[Şahbaba (Murat Bardakçı)#p. 60]] · *Türk kaynağı* |
| 187 | C | 1892-12 | Van valisine suikast teşebbüsü | [[Van]] | 5/7 | atmosfer | `van_valisi_1892` | [[GD 1892]] | [[The Armenian File (Kâmuran Gürün)#p. 198]] · *Türk kaynağı* |
| 188 | C | 1873 | Hıdiv İsmail'e imtiyazları genişleten ferman | [[Mısır]] | 4/6 | atmosfer | `hidiv_ferman` | [[GD 1873]] | [[Osmanlı Arap Coğrafyası ve Avrupa Emperyalizmi (Ali Akyıldız)#p. 22]] · *Türk kaynağı* |
| 189 | C | 1879-04 | Hayreddin Paşa ve Hıdiv İsmail'in azli | [[Hayreddin Paşa]] | 1/5 | atmosfer | `hidiv_azli` | [[GD 1879]] | [[Osmanlı Arap Coğrafyası ve Avrupa Emperyalizmi (Ali Akyıldız)#p. 547]] · *Türk kaynağı* |
| 190 | C | 1904 | Yusuf Akçura, Üç Tarz-ı Siyaset | [[Yusuf Akçura]] | 3/5 | atmosfer | `uc_tarz` | [[GD 1904]] | [[İstanbul'da Ramazan (François Georgeon)#p. 165]] · *Fransız kaynağı* |
| 191 | C | 1915-04-26 | Londra Antlaşması: İtalya'ya Antalya vaadi | [[Mark Sykes]] | 3/4 | atmosfer | `londra_1915` | [[GD 1915]] | [[Trablusgarp Savaşı ve Türk-İtalyan İlişkileri (Timothy W. Childs)#p. 328]] · *Amerikan kaynağı* |
| 192 | C | 1901-04 | Boxer isyanında Çin'e halifelik heyeti | [[Caliphate]] | 3/3 | atmosfer | `cin_heyeti` | [[GD 1901]] | [[Osmanlı'da Değişim ve Anayasal Rejim Sorunu (İlber Ortaylı)#p. 309]] · *Türk kaynağı* |
| 193 | C | 1876-06-15 | Çerkes Hasan vakası: Hüseyin Avni öldürülür | [[Hüseyin Avni Paşa]] | 1/2 | atmosfer | `cerkes_hasan` | [[GD 1876]] | [[Enver (Murat Bardakçı)#p. 61]] · *Türk kaynağı* |
| 194 | C | 1904-08-29 | Eski padişah V. Murad ölür | [[Murad V]] | 2/2 | atmosfer | `murad_v_olum` | [[GD 1904]] | [[Son Osmanlılar (Murat Bardakçı)#p. 163]] · *Türk kaynağı* |
| 195 | C | 1906 | Büyük devletler Midilli ve Limni gümrüklerine el koyar | [[Makedonya]] | 1/1 | atmosfer | `midilli_1906` | [[GD 1906]] | [[Enver (Murat Bardakçı)#p. 81]] · *Türk kaynağı* |

## Yıllara göre

Olay olmayan yıl yoktur: 1873'ten 1919'a her yıl en az bir kasa olayı taşır. Sakin yıllar (1880'ler ve 1890'lar) az olayla, bütçe ve jurnal gibi yinelenen olaylarla doldurulur; harp ve kriz yılları çok olay taşır.

| Yıl | Sıralanan olay | Tasarlanan olay kimliği |
|---|---|---|
| 1873 | 2 | 2 |
| 1874 | 2 | 2 |
| 1875 | 2 | 2 |
| 1876 | 8 | 10 |
| 1877 | 8 | 8 |
| 1878 | 9 | 11 |
| 1879 | 2 | 2 |
| 1880 | 2 | 2 |
| 1881 | 3 | 3 |
| 1882 | 1 | 2 |
| 1883 | 2 | 2 |
| 1884 | 1 | 1 |
| 1885 | 2 | 2 |
| 1886 | 1 | 1 |
| 1887 | 1 | 1 |
| 1888 | 2 | 2 |
| 1889 | 2 | 2 |
| 1890 | 3 | 3 |
| 1891 | 2 | 2 |
| 1892 | 3 | 3 |
| 1893 | 2 | 2 |
| 1894 | 1 | 1 |
| 1895 | 2 | 3 |
| 1896 | 3 | 3 |
| 1897 | 4 | 4 |
| 1898 | 3 | 3 |
| 1899 | 2 | 2 |
| 1900 | 2 | 2 |
| 1901 | 2 | 2 |
| 1902 | 2 | 2 |
| 1903 | 2 | 3 |
| 1904 | 2 | 2 |
| 1905 | 1 | 1 |
| 1906 | 4 | 4 |
| 1907 | 2 | 2 |
| 1908 | 8 | 10 |
| 1909 | 6 | 8 |
| 1910 | 2 | 2 |
| 1911 | 3 | 4 |
| 1912 | 4 | 6 |
| 1913 | 7 | 7 |
| 1914 | 16 | 21 |
| 1915 | 14 | 15 |
| 1916 | 12 | 14 |
| 1917 | 7 | 7 |
| 1918 | 14 | 14 |
| 1919 | 10 | 10 |
