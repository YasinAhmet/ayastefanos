---
tags: [game-design]
---
# GD 07 · Gündem

Gündem, masadaki uzun soluklu devlet işidir: oyuncu aynı anda yalnız birini yürütür, her ay biraz ilerler, süresi dolunca etkileri bir kerede uygulanır. Gündemler bir ağaç oluşturur: `önce` ile bağlanan gündem öncekiler bitmeden açılmaz, `dışlar` ile birbirine bağlanan gündemlerden biri başlayınca ya da bitince diğeri kilitlenir. Tarihî modda `tarihî` işaretli gündemler sırayla kendiliğinden yürür; Fantezi modunda oyuncu seçer. Geri: [[GD 00 Rehber]] · [[GD 02 Sistemler]].

Biçim: `### Gündem · Ad` · alan satırı `` `gündem: g_id` · `devir: YYYY-YYYY` · `süre: 18ay` `` (isteğe bağlı: `önce: g_a, g_b` · `dışlar: g_c` · `tarihî` · `bayrak: AL`) · isteğe bağlı `` `koşul: …` `` satırı · açıklama paragrafı · `> Kaynak:` satırı · `` `etki: …` `` satırı (normal etki sözdizimi; `şans`/`kademe` yok). `dışlar` karşılıklı yazılır; derleyici simetriyi ve `önce` döngülerini denetler.

## Abdülhamid devri

### Gündem · Harbiye'de ıslahat
`gündem: g_harbiye_islahat` · `devir: 1878-1895` · `süre: 12ay` · `tarihî` · `bayrak: OS`
Harbiye Mektebi'nin teorik derslerle yetinen müfredatı elden geçirilir; kurmay hizmeti ve tatbikat programa girer. Reform masraflıdır ama ordunun asıl eksiği olan eğitimli subay açığını kapatmaya başlar.
> Kaynak: [[100. Yılında Jön Türk Devrimi (Sina Akşin)#p. 661|Akşin, *100. Yılında Jön Türk Devrimi*, p. 661]] · *Türk kaynağı*
`etki: Harbiye +6 · para -4`

### Gündem · Alman usulü ordu
`gündem: g_alman_ordu` · `devir: 1880-1908` · `süre: 18ay` · `önce: g_harbiye_islahat` · `dışlar: g_ingiliz_bahriye, g_redif_milis` · `tarihî` · `bayrak: AL`
`koşul: !⚑goltz_serbest`
Prusyalı Goltz'un Harbiye'de açtığı yol genişletilir: Alman müşavirler talim ve kurmaylık eğitimini üstlenir. Ordu güçlenir, ama genç subaylar Avrupa fikirleriyle de tanışır ve Berlin'in nüfuzu artar.
> Kaynak: [[Colmar von der Goltz]] · [[100. Yılında Jön Türk Devrimi (Sina Akşin)#p. 661|Akşin, *100. Yılında Jön Türk Devrimi*, p. 661]] · *Türk kaynağı*
`etki: Harbiye +6 · alman_nufuzu +6 · jon_turk +3`

### Gündem · İngiliz usulü donanma
`gündem: g_ingiliz_bahriye` · `devir: 1880-1908` · `süre: 24ay` · `önce: g_harbiye_islahat` · `dışlar: g_alman_ordu, g_redif_milis` · `bayrak: IN`
Donanmanın bakımı ve eğitimi İngiliz müşavirlere bırakılır. Haliç'te çürüyen gemiler yeniden denize çıkabilir hâle gelir; karşılığında Londra'ya borçlanılır ve ordunun reformu geri plana düşer.
> Kaynak: Alternatif tarih. [[Ottoman Navy]] · [[Enver (Murat Bardakçı)#p. 69|Bardakçı, *Enver*, p. 69]] · *Türk kaynağı*
`etki: Bahriye +8 · para -5 · avrupa_baskisi +4`

## Abdülhamid devri (devamı)

### Gündem · Redif ve milis ordusu
`gündem: g_redif_milis` · `devir: 1880-1905` · `süre: 18ay` · `önce: g_harbiye_islahat` · `dışlar: g_alman_ordu, g_ingiliz_bahriye` · `bayrak: OS`
Maaşlı müşavirler yerine redif taburları ve mahalli milis örgütlenir; ordu ucuz ve kalabalık olur, ama talim ve silah birliği yoktur. Subaylar bu yolu Avrupa'dan geri kalmak sayar.
> Kaynak: Alternatif tarih. [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 34|Akşin, *Kısa Türkiye Tarihi*, loc. 34]] · *Türk kaynağı*
`etki: Harbiye +4 · para -3 · ordu_sadakati +4 · jon_turk -2`

### Gündem · Merkeziyetçi idare
`gündem: g_merkeziyet` · `devir: 1878-1908` · `süre: 12ay` · `dışlar: g_adem_merkeziyet` · `tarihî` · `bayrak: OS`
Vilayetler Yıldız'a telgrafla bağlanır; valiler ve mutasarrıflar doğrudan saraydan atanır. Denetim sıkılaşır, ama uzak vilayetlerde sarayın adamı olmayan kimse söz sahibi olamaz.
> Kaynak: [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 35|Akşin, *Kısa Türkiye Tarihi*, loc. 35]] · *Türk kaynağı* · [[Osmanlı İmparatorluğu Tarihi (Robert Mantran)#p. 638|Mantran, *Osmanlı İmparatorluğu Tarihi*, p. 638]] · *Fransız kaynağı*
`etki: hakimiyet +5 · araplar -3 · muhalefet +3`

### Gündem · Adem-i merkeziyet ve özel teşebbüs
`gündem: g_adem_merkeziyet` · `devir: 1902-1908` · `süre: 18ay` · `dışlar: g_merkeziyet` · `bayrak: OS`
[[Prens Sabahaddin]]'in Paris'te savunduğu yol: vilayetlere geniş yetki ve yerel girişim. Sarayın telgraf ağı gevşer; Arap ve Rum vilayetleri rahatlar, Yıldız ise denetimi bırakır.
> Kaynak: Alternatif tarih. [[Prens Sabahaddin]] · [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 36|Akşin, *Kısa Türkiye Tarihi*, loc. 36]] · *Türk kaynağı*
`etki: hakimiyet -6 · araplar -6 · muhalefet +4 · avrupa_baskisi -3`

### Gündem · Düyun-u Umumiye ile uzlaşma
`gündem: g_duyun_uzlasma` · `devir: 1881-1900` · `süre: 12ay` · `dışlar: g_borc_tahsilat` · `tarihî` · `bayrak: OS`
Muharrem Kararnamesi'nin ardından borç idaresi gelirleri doğrudan tahsil eder; hazine pazarlığa oturmaktan kaçmaz. Faizler düşer, bankerler yatışır, ama maliye kendi gelirleri üzerinde söz sahibi olmaktan çıkar.
> Kaynak: [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 28|Akşin, *Kısa Türkiye Tarihi*, loc. 28]] · *Türk kaynağı* · [[Düyun-u Umumiye]]
`etki: para +4 · iliski_fr +5 · avrupa_baskisi -4`

### Gündem · Gelirleri kendi eline alma
`gündem: g_borc_tahsilat` · `devir: 1880-1900` · `süre: 12ay` · `dışlar: g_duyun_uzlasma` · `bayrak: OS`
Hazine, borç idaresinin payına direnir ve vergiyi kendi memurlarıyla toplamaya çalışır. Kısa vadede para girer, ama alacaklı devletlerin diplomatik baskısı artar.
> Kaynak: Alternatif tarih. [[Düyun-u Umumiye]] · [[Osmanlı İmparatorluğu Tarihi (Robert Mantran)#p. 642|Mantran, *Osmanlı İmparatorluğu Tarihi*, p. 642]] · *Fransız kaynağı*
`etki: para +6 · iliski_fr -6 · avrupa_baskisi +6`

### Gündem · Hicaz hattında garnizon ve iaşe
`gündem: g_hicaz_demiryolu` · `devir: 1900-1908` · `süre: 12ay` · `tarihî` · `bayrak: OS`
Hat yalnız tren değil, Şam–Medine arasında kale, kuyu ve iaşe ağıdır. Garnizonlar demiryoluna dayanır; aşiretlere verilen tahsisat ise ancak hat işlediği sürece sürer.
> Kaynak: [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 54|Akşin, *Kısa Türkiye Tarihi*, loc. 54]] · *Türk kaynağı* · [[Hejaz Railway]]
`etki: Harbiye +2 · araplar -3 · para -4`

### Gündem · Bağdat hattı ve Alman sermayesi
`gündem: g_bagdat_demiryolu` · `devir: 1888-1908` · `süre: 24ay` · `tarihî` · `bayrak: OS`
Anadolu'dan Bağdat'a uzanan hat Alman bankalarıyla yapılır. Irak vilayetleri bağlanır, ama Londra'nın şüphesi artar ve Berlin'in iktisadi nüfuzu yerleşir.
> Kaynak: [[Osmanlı İmparatorluğu Tarihi (Robert Mantran)#p. 644|Mantran, *Osmanlı İmparatorluğu Tarihi*, p. 644]] · *Fransız kaynağı* · [[Baghdad Railway]]
`etki: para -4 · alman_nufuzu +6 · iliski_in -3 · dogu_hazirligi +2`

### Gündem · Mektepler ve idadiler
`gündem: g_mektepler` · `devir: 1880-1905` · `süre: 18ay` · `tarihî` · `bayrak: OS`
Memleketin dört bir yanında rüşdiye, idadi ve mülkiye mektepleri açılır; gençlere devlet memuru olacağı vaat edilir. Okuyan gençler padişaha minnettar olduğu kadar meşrutiyet fikriyle de tanışır.
> Kaynak: [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 34|Akşin, *Kısa Türkiye Tarihi*, loc. 34]] · *Türk kaynağı* · [[Osmanlı İmparatorluğu Tarihi (Robert Mantran)#p. 636|Mantran, *Osmanlı İmparatorluğu Tarihi*, p. 636]] · *Fransız kaynağı*
`etki: para -4 · jon_turk +4 · hakimiyet +2`

## Meşrutiyet devri

### Gündem · Cavid'in istikraz müzakereleri
`gündem: g_cavid_istikraz` · `devir: 1909-1914` · `süre: 12ay` · `dışlar: g_milli_iktisat` · `tarihî` · `bayrak: OS`
[[Cavid Bey]] Paris ve Berlin bankalarıyla borç ve vergi düzenini pazarlıkla çözmeye çalışır. Faizler yumuşar, ama siyasi şartlar da masaya gelir.
> Kaynak: [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 77|Akşin, *Kısa Türkiye Tarihi*, loc. 77]] · *Türk kaynağı* · [[Cavid Bey]]
`etki: para +6 · avrupa_baskisi +4 · iliski_fr +3`

### Gündem · Milli iktisat
`gündem: g_milli_iktisat` · `devir: 1909-1914` · `süre: 18ay` · `dışlar: g_cavid_istikraz` · `bayrak: OS`
Yabancı sermayeye karşı yerli tüccar ve şirketler himaye edilir; kapitülasyonlara itirazlar sertleşir. İç piyasa canlanır, dış kredi ise daralır.
> Kaynak: Alternatif tarih. [[Capitulations]] · [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 78|Akşin, *Kısa Türkiye Tarihi*, loc. 78]] · *Türk kaynağı*
`etki: para +2 · muhalefet -3 · iliski_fr -4 · avrupa_baskisi +5`

### Gündem · Alman askerî heyeti
`gündem: g_alman_heyeti` · `devir: 1912-1914` · `süre: 12ay` · `dışlar: g_milis_seferberlik` · `tarihî` · `bayrak: OS`
[[Liman von Sanders]]'in başkanlığında bir Alman heyeti ordu eğitimini üstlenir. Talim düzelir, ama Petersburg bunu Boğazlar üzerinde bir tehdit sayar.
> Kaynak: [[Türkiye'de Beş Yıl (Liman von Sanders)#p. 21|Sanders, *Türkiye'de Beş Yıl*, p. 21]] · *Alman kaynağı* · [[Liman von Sanders]]
`etki: Harbiye +6 · alman_nufuzu +6 · iliski_ru -5`

### Gündem · Redif ve gönüllü seferberliği
`gündem: g_milis_seferberlik` · `devir: 1911-1914` · `süre: 12ay` · `dışlar: g_alman_heyeti` · `bayrak: OS`
Balkan hezimetinden sonra redif ve gönüllü kuvvetler örgütlenir. Mevcut kuvvet çabuk artar, ancak komuta ve silah ayrılığı sürer.
> Kaynak: Alternatif tarih. [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 77|Akşin, *Kısa Türkiye Tarihi*, loc. 77]] · *Türk kaynağı* · [[Balkan Wars (1912-1913)|Balkan Harbi]]
`etki: Harbiye +4 · ordu_sadakati +3 · para -4`

### Gündem · İngiltere'yle ittifak arayışı
`gündem: g_ingiliz_ittifak` · `devir: 1909-1914` · `süre: 12ay` · `dışlar: g_alman_ittifak, g_rus_anlasma, g_silahli_tarafsizlik` · `bayrak: OS`
Londra'ya bir ittifak ya da garanti teklifi götürülür. İngiltere ilgisiz kalsa da hattın açık tutulması Kıbrıs ve Mısır'ın yarattığı soğukluğu bir parça giderir.
> Kaynak: Alternatif tarih. [[Enver (Murat Bardakçı)#p. 66|Bardakçı, *Enver*, p. 66]] · *Türk kaynağı*
`etki: iliski_in +8 · iliski_ru -3 · alman_nufuzu -4`

### Gündem · Almanya'yla ittifak
`gündem: g_alman_ittifak` · `devir: 1912-1914` · `süre: 6ay` · `dışlar: g_ingiliz_ittifak, g_rus_anlasma, g_silahli_tarafsizlik` · `tarihî` · `bayrak: OS`
Berlin'e ittifak teklifi götürülür; Enver ve çevresi Alman ordusunun gücüne güvenir. Askerî yardım yakınlaşır, ama harp çıkarsa taraf seçmiş sayılırsınız.
> Kaynak: [[Enver (Murat Bardakçı)#p. 69|Bardakçı, *Enver*, p. 69]] · *Türk kaynağı* · [[Birinci Dünya Savaşı'nda Türkiye (Ahmet Emin Yalman)#p. 56|Yalman, *Birinci Dünya Savaşı'nda Türkiye*, p. 56]] · *Türk kaynağı*
`etki: alman_nufuzu +6 · Harbiye +3 · iliski_ru -5 · iliski_in -4`

### Gündem · Rusya'yla anlaşma
`gündem: g_rus_anlasma` · `devir: 1910-1914` · `süre: 12ay` · `dışlar: g_ingiliz_ittifak, g_alman_ittifak, g_silahli_tarafsizlik` · `bayrak: OS`
Boğazlar ve Doğu Anadolu üzerinde Petersburg'la pazarlık yapılır. Rusya dostluk görünümü verir; Londra ve Berlin ise bunun karşılığını sorar.
> Kaynak: Alternatif tarih. [[Birinci Dünya Savaşı'nda Türkiye (Ahmet Emin Yalman)#p. 62|Yalman, *Birinci Dünya Savaşı'nda Türkiye*, p. 62]] · *Türk kaynağı*
`etki: iliski_ru +10 · alman_nufuzu -4 · avrupa_baskisi -3`

### Gündem · Silahlı tarafsızlık
`gündem: g_silahli_tarafsizlik` · `devir: 1912-1914` · `süre: 6ay` · `dışlar: g_ingiliz_ittifak, g_alman_ittifak, g_rus_anlasma` · `bayrak: OS`
Hiçbir bloka girmeyen, ama seferberliğe hazır bir devlet kurulur. Kimse güvenmez, kimse de zorlamaz; ordu ve hazine tamamen hazır tutulmalıdır.
> Kaynak: Alternatif tarih. [[Birinci Dünya Savaşı'nda Türkiye (Ahmet Emin Yalman)#p. 85|Yalman, *Birinci Dünya Savaşı'nda Türkiye*, p. 85]] · *Türk kaynağı*
`etki: Harbiye +3 · para -4 · avrupa_baskisi -4`

### Gündem · Muhacirlerin iskânı
`gündem: g_iskan_muhacir` · `devir: 1909-1914` · `süre: 18ay` · `tarihî` · `bayrak: OS`
Balkan ve Kafkas muhacirleri Anadolu'ya yerleştirilir; arazi, tohum ve barınak sağlanır. Kısa vadede hazine yorulur, ama Anadolu'nun nüfus dengesi değişir.
> Kaynak: [[Osmanlı İmparatorluğu Tarihi (Robert Mantran)#p. 695|Mantran, *Osmanlı İmparatorluğu Tarihi*, p. 695]] · *Fransız kaynağı* · [[Refugees (muhacir)]]
`etki: para -5 · muhalefet -2 · Harbiye +2`

### Gündem · Doğu hattı etüdü
`gündem: g_dogu_hatti_etut` · `devir: 1910-1914` · `süre: 12ay` · `bayrak: OS`
`koşul: !⚑dogu_hatti_1`
Sivas'tan Erzurum'a gidecek hattın güzergâhı, istasyonları ve depoları önceden incelenir. Henüz ray döşenmez, ama harp çıkarsa kışa ve ikmale hazırlık bundan başlar.
> Kaynak: Alternatif tarih. [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 76|Akşin, *Kısa Türkiye Tarihi*, loc. 76]] · *Türk kaynağı* · [[Osmanlı İmparatorluğu Tarihi (Robert Mantran)#p. 696|Mantran, *Osmanlı İmparatorluğu Tarihi*, p. 696]] · *Fransız kaynağı*
`etki: para -3 · dogu_hazirligi +5`

## Harp devri

### Gündem · Kapitülasyonların kaldırılması
`gündem: g_kapitulasyon` · `devir: 1914-1915` · `süre: 6ay` · `tarihî` · `bayrak: OS`
Eylül 1914'te kapitülasyonlar tek taraflı kaldırılır. Gümrük ve adli ayrıcalıklar gider; devletlerin tepkisi sertleşir ama hazine gelir kazanır.
> Kaynak: [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 78|Akşin, *Kısa Türkiye Tarihi*, loc. 78]] · *Türk kaynağı* · [[Capitulations]]
`etki: para +5 · avrupa_baskisi +4 · iliski_fr -3`

### Gündem · Alman harp yardımı
`gündem: g_alman_harp_yardimi` · `devir: 1914-1916` · `süre: 8ay` · `dışlar: g_ayri_baris, g_rus_ayri_baris` · `tarihî` · `bayrak: OS`
Alman silah, cephane ve altın sevkiyatı hattan hatta taşınır. Ordu ayakta kalır, ama Berlin'in sözü genel kurmayın içine kadar girer.
> Kaynak: [[Türkiye'de Beş Yıl (Liman von Sanders)#p. 64|Sanders, *Türkiye'de Beş Yıl*, p. 64]] · *Alman kaynağı* · [[Birinci Dünya Savaşı'nda Türkiye (Ahmet Emin Yalman)#p. 98|Yalman, *Birinci Dünya Savaşı'nda Türkiye*, p. 98]] · *Türk kaynağı*
`etki: Harbiye +5 · para +4 · alman_nufuzu +6`

### Gündem · Ayrı barış arayışı
`gündem: g_ayri_baris` · `devir: 1915-1917` · `süre: 12ay` · `dışlar: g_alman_harp_yardimi, g_rus_ayri_baris` · `bayrak: OS`
İtilaf'la gizli temaslar yapılır; barış şartları sorulur. Berlin haberi alırsa güven sarsılır, ama Harp yorgunluğu bir nebze durur.
> Kaynak: Alternatif tarih. [[Birinci Dünya Savaşı'nda Türkiye (Ahmet Emin Yalman)#p. 98|Yalman, *Birinci Dünya Savaşı'nda Türkiye*, p. 98]] · *Türk kaynağı*
`etki: harp_yorgunlugu -6 · iliski_in +5 · alman_nufuzu -6`

### Gündem · Rusya'yla ayrı barış
`gündem: g_rus_ayri_baris` · `devir: 1917-1918` · `süre: 6ay` · `dışlar: g_alman_harp_yardimi, g_ayri_baris` · `bayrak: OS`
Rus devriminden sonra Doğu cephesinde ateşkes ve ayrı barış yoklanır. Cephe rahatlar; Rusya'dan alınan toprak vaatleri Berlin'le sürtüşme yaratır.
> Kaynak: Alternatif tarih. [[Birinci Dünya Savaşı'nda Türkiye (Ahmet Emin Yalman)#p. 85|Yalman, *Birinci Dünya Savaşı'nda Türkiye*, p. 85]] · *Türk kaynağı*
`etki: harp_yorgunlugu -5 · iliski_ru +8 · dogu_hazirligi +3`

### Gündem · Seferberlik ve ikmal teşkilatı
`gündem: g_seferberlik_ikmal` · `devir: 1914-1916` · `süre: 6ay` · `tarihî` · `bayrak: OS`
Hayvan, tahıl ve nakil araçları askere tahsis edilir; ikmal teşkilatı genişletilir. Cepheler beslenir, köy ve kasabalarda kıtlık başlar.
> Kaynak: [[Birinci Dünya Savaşı'nda Türkiye (Ahmet Emin Yalman)#p. 56|Yalman, *Birinci Dünya Savaşı'nda Türkiye*, p. 56]] · *Türk kaynağı* · [[Türkiye'de Beş Yıl (Liman von Sanders)#p. 64|Sanders, *Türkiye'de Beş Yıl*, p. 64]] · *Alman kaynağı*
`etki: Harbiye +4 · para -5 · dogu_hazirligi +3`

### Gündem · Almanya'dan harp istikrazı
`gündem: g_harp_istikrazi` · `devir: 1914-1917` · `süre: 6ay` · `dışlar: g_harp_milli_iktisat` · `tarihî` · `bayrak: OS`
Alman bankalarından altın ve avans alınır; borç ödemeleri harp sonrasına bırakılır. Hazine rahatlar, ama borcun ucu Berlin'in elinde kalır.
> Kaynak: [[Birinci Dünya Savaşı'nda Türkiye (Ahmet Emin Yalman)#p. 62|Yalman, *Birinci Dünya Savaşı'nda Türkiye*, p. 62]] · *Türk kaynağı*
`etki: para +8 · alman_nufuzu +4 · iliski_in -2`

### Gündem · Harp ekonomisinde milli iktisat
`gündem: g_harp_milli_iktisat` · `devir: 1915-1918` · `süre: 12ay` · `dışlar: g_harp_istikrazi` · `bayrak: OS`
Yerli şirketler himaye edilir; ihtiyaç maddelerine fiyat tavanı konur. Borç artmaz, ama ticaret daralır ve karaborsa yayılır.
> Kaynak: Alternatif tarih. [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 78|Akşin, *Kısa Türkiye Tarihi*, loc. 78]] · *Türk kaynağı*
`etki: para +3 · muhalefet +3 · ordu_sadakati -2`

### Gündem · Darülfünun ıslahatı
`gündem: g_darulfunun` · `devir: 1915-1918` · `süre: 12ay` · `tarihî` · `bayrak: OS`
İstanbul Darülfünunu'nda Alman ve yerli hocalarla müfredat yenilenir. Harbin ortasında yapılan bu reform, gençler arasında Cemiyet'e yakınlığı artırır.
> Kaynak: [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 78|Akşin, *Kısa Türkiye Tarihi*, loc. 78]] · *Türk kaynağı*
`etki: para -3 · jon_turk +3 · ulema -3`

### Gündem · Hicaz hattının korunması
`gündem: g_hicaz_takviye` · `devir: 1914-1916` · `süre: 8ay` · `tarihî` · `bayrak: OS`
Hat boyunca karakollar ve ikmal depoları takviye edilir. Şerif'in adamlarının raylara el atması güçleşir, ama harcama ve asker ihtiyacı büyür.
> Kaynak: [[Hejaz Railway]] · [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 54|Akşin, *Kısa Türkiye Tarihi*, loc. 54]] · *Türk kaynağı*
`etki: Harbiye -2 · araplar -3 · para -4`

### Gündem · Bağdat hattı Toros tünelleri
`gündem: g_bagdat_toros` · `devir: 1914-1917` · `süre: 12ay` · `tarihî` · `bayrak: OS`
Amanos ve Toros tünellerinin açılması Irak ve Filistin cephelerine ikmal yolunu kısaltır. İşçi ve malzeme sıkıntısı büyüktür, hat harp boyunca tamamlanamaz.
> Kaynak: [[Türkiye'de Beş Yıl (Liman von Sanders)#p. 154|Sanders, *Türkiye'de Beş Yıl*, p. 154]] · *Alman kaynağı* · [[Baghdad Railway]]
`etki: para -6 · alman_nufuzu +4 · dogu_hazirligi +3`
