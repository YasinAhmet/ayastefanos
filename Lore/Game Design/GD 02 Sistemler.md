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
| para | Para | 25 | evet | Hazine. Her şeyi o satın alır. Her yıl gelir gelir; 1875 iflasından sonra borç yükü, 1881'den sonra Düyun-u Umumiye payı düşer. Sıfıra inerse dış borç olayı çıkar. Hiçbir kaynak seçimle sıfıra ya da altına düşürülemez: böyle bir seçenek kilitlenir ("Kilitli: Para sıfıra düşer"). Zorunlu bir evrakın bütün seçenekleri kilitliyse oyun rastgele birini seçer ve hazine borca girer (Para en çok −50'ye iner). |
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
| cokus | Çöküş | 0 | hayır | Abdülhamid yolunda harp başlayınca işleyen sayaç. 100'e varınca Rus ordusu Payitahttadır. Harbiye 35'in üstündeyse ve Boğaz tutulduysa geriler. |
| kafkas | Kafkas cephesi | 50 | hayır | Cephe dengesi: 0 düşmanın, 100 bizim. Harp yıllarında haritada cephe işaretinde görünür; her ay cepheye ayrılan tümenlerin düşman gücüne oranıyla kayar (ikmal, arazi, duruş ve komutan etkiler; bkz. REWORK §6). Bkz. [[GD 05 Harita ve Harpler#Harpler ve cepheler]]. |
| canakkale | Çanakkale cephesi | 50 | hayır | Cephe durumu. |
| irak | Irak cephesi | 50 | hayır | Cephe durumu. |
| filistin | Filistin cephesi | 50 | hayır | Cephe durumu. |
| hicaz | Hicaz cephesi | 50 | hayır | Cephe durumu. |
| tuna_93 | Tuna ve Balkan cephesi ('93) | 50 | hayır | 93 Harbi'nin Rumeli cephesi (bkz. [[GD 05 Harita ve Harpler#Harpler ve cepheler]]). |
| kafkas_93 | Kafkas cephesi ('93) | 50 | hayır | 93 Harbi'nin doğu cephesi. |
| trablus | Trablusgarp cephesi | 50 | hayır | 1911–12 İtalya harbi. |
| trakya | Trakya cephesi | 50 | hayır | 1912–13 Balkan Harbi. |
| harp_yorgunlugu | Harp yorgunluğu | 0 | hayır | Harp süren her ay cephelerdeki kayıpla artar (REWORK §6); moral her ay yorgunluğun elliye bölümü kadar düşer. Barışta yıllık düşer. |
| iliski_ru | İlişki: Rusya | 25 | hayır | 0 düşmanlık, 50 soğuk tarafsızlık, 100 dostluk. '93 Harbi'nden sonra düşük başlar; Boğazlar, Balkanlar ve Ermeni meselesi onu aşağı çeker. Harbi diplomasiyle önleme şansını ve avrupa_baskisi'ni etkiler. |
| iliski_in | İlişki: İngiltere | 55 | hayır | Londra ile aranız. Kıbrıs, Mısır ve Ermeni meselesi onu oynatır; yüksekse Avrupa baskısı hafifler, düşükse Boğaz'da yalnız kalırsınız. |
| iliski_fr | İlişki: Fransa | 50 | hayır | Paris ile aranız. Düyun-u Umumiye ve borçlar onu yükseltir; Tunus, Ermeni meselesi ve Alman yakınlığı düşürür. |
| iliski_av | İlişki: Avusturya-Macaristan | 40 | hayır | Viyana ile aranız. Bosna, Sancak ve Berlin'e yakınlık onu belirler; yükselince Alman nüfuzunun yarattığı tedirginlik azalır. |
| iliski_it | İlişki: İtalya | 45 | hayır | Roma ile aranız. Trablusgarp'ın ve On İki Ada'nın kaderi buna bağlıdır; 1911 harbini önleme şansını belirler. |
| iliski_bu | İlişki: Bulgaristan | 30 | hayır | Sofya ile aranız (1878'den önce Bulgaristan yok, değer yine de tutulur). Doğu Rumeli ve Makedonya onu düşürür; Balkan ittifakını önleme şansını belirler. |
| iliski_yu | İlişki: Yunanistan | 30 | hayır | Atina ile aranız. Girit, Teselya ve Ege adaları onu belirler; 1897 harbini önleme şansını etkiler. |
| ordu_sadakati | Ordu sadakati | 60 | hayır | Ordunun hükümete (saraya, sonra Cemiyet'e) bağlılığı. Maaşlar gecikirse, jurnal ağı subayı küstürürse, Jön Türk ruhu yükselirse düşer. Düşükken subay darbeleri (tetik) gelir. |
| ulema | Ulema | 45 | hayır | Ulema ve medrese tabanının gücü. Meşrutiyet ve Batılılaşma ateşi arttıkça tepkisi büyür; 31 Mart benzeri isyanlar (tetik) yükseldikçe çıkar. |
| muhalefet | Muhalefet | 20 | hayır | Jön Türk dışı muhalefet: Ahrar ve İtilaf, Hürriyet. Saray baskısı sürdükçe yeraltında birikir; Cemiyet'in gevşek tuttuğu yerde sesini yükseltir. |

**Denge ölçüsü (yazarlar için):** küçük etki ±3–5 · orta ±8–12 · büyük ±15–25. Yıllık gelir +10'dur; bir yılda iki büyük harcama yapan oyuncu ertesi yıl darda kalmalıdır. Her seçenek bir şey verir, bir şey alır: bedava seçenek ancak bir emirle çözülen durumlarda olur (ör. depodaki kaputların dağıtılması).

## Payitaht

Masadaki Payitaht düğmesi hükümdarı ve üç nazırı gösterir. Bir nazırın sözü, bağlı olduğu kaynağın düzeyi kadar ağır basar (Harbiye 20'nin altındaysa Harbiye Nazırı'nın uyarısı "kimse dinlemiyor" diye soluk görünür). Kişiler:

### Kişi · Sultan Abdülaziz
`kişi: abdulaziz` · `unvan: Sultan Abdülaziz (1861–1876)` · `görsel: Abdulaziz (Sultan of the Ottoman Empire).jpg` · `rol: hükümdar`
1861'den 1876'ya tahtta oturan padişah. Modernleşmeye meraklıdır; 1867'de Avrupa'yı gezer, Paris Sergisi'ni görür. Onun devrinde güçlü bir donanma kurulur, ama saltanatının sonunda hazine iflas eder ve bunun sorumlusu sayılır. 30 Mayıs 1876'da Serasker Hüseyin Avni Paşa'nın darbesiyle tahttan indirilir, birkaç gün sonra ölü bulunur. Oyunun ilk yılı onun masasında başlar.
> Kaynak: [[Abdülaziz]] · [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 25|Akşin, *Kısa Türkiye Tarihi*, loc. 25]] · [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 26|Akşin, loc. 26]] · *Türk kaynağı*

### Kişi · Sultan II. Abdülhamid
`kişi: abdulhamid` · `unvan: Sultan II. Abdülhamid (1876–1909)` · `görsel: Abdülhamid II of Turkey.jpg` · `rol: hükümdar`
31 Ağustos 1876'da tahta çıkar; Kanun-ı Esasi'yi ilan eder, ama Rus ordusu İstanbul'un kapısına dayanınca 1878'de Meclis'i tatil eder. Otuz yıllık saltanatı iflasla açılır: 1881'de Düyun-u Umumiye kurulur. Atamaları kendi elinde toplar, hilafete dayanan bir İslamcı siyaset güder ve doğuda Hamidiye alaylarını kurar. Jön Türkler ve İttihat ve Terakki onu "istibdat" diye suçlar; 1908 ihtilali onu yeniden Meşrutiyet'e, 1909'daki 31 Mart'tan sonra da tahttan inmeye zorlar.
> Kaynak: [[Abdülhamid II]] · [[Enver (Murat Bardakçı)#p. 62|Bardakçı, *Enver*, p. 62]] · *Türk kaynağı* · [[Osmanlı İmparatorluğu Tarihi (Robert Mantran)#p. 654|Mantran, *Osmanlı İmparatorluğu Tarihi*, p. 654]] · *Fransız kaynağı*

### Kişi · Talat
`kişi: talat` · `unvan: Talat Bey, Dahiliye Nazırı (1917'den Sadrazam Talat Paşa)` · `görsel: Idman19140528TalatBey.jpg` · `görseller: 1917=Talat Pasha.jpg` · `rol: hükümdar`
Edirneli bir posta memurunun oğlu; Selanik posta idaresinde memurken 1906'da Osmanlı Hürriyet Cemiyeti'ni kurar ve İttihat ve Terakki'nin sivil lideri olur. 1908'den sonra Dahiliye Nazırı, 1917–1918'de sadrazamdır. Büyük Harp'te iktidar Talat, Enver ve Cemal üçlüsündedir; iç cepheyi, iaşeyi ve 1915 tehcirini yöneten Dahiliye odur. Mütarekeden sonra bir Alman gemisiyle kaçar; 15 Mart 1921'de Berlin'de bir Ermeni tarafından vurulur.
> Kaynak: [[Talat Paşa]] · [[Osmanlı İmparatorluğu Tarihi (Robert Mantran)#p. 766|Mantran, p. 766]] · *Fransız kaynağı* · [[Birinci Dünya Savaşı'nda Türkiye (Ahmet Emin Yalman)#p. 98|Yalman, *Birinci Dünya Savaşı'nda Türkiye*, p. 98]] · *Türk kaynağı*

### Kişi · Kâmil Paşa
`kişi: kamil` · `unvan: Sadrazam Kıbrıslı Kâmil Paşa` · `görsel: Mehmed Kamil Pasha.jpg` · `rol: hükümdar`
Kıbrıslı Mehmed Kâmil Paşa, Abdülhamid devrinin "İngilizci" diye tanınan eski vezirlerinden. 1908'den sonra İttihat ve Terakki onu sadarete getirir, 1909'da Meclis'te düşürür. 29 Ekim 1912'de Balkan bozgununun ortasında yeniden sadrazam olur; İngiltere'nin kendisi iktidardayken imparatorluğa saldırılmasına izin vermeyeceğinden emindir. Tarihte 23 Ocak 1913'te Babıâli Baskını'nda Enver'e istifasını yazdırır; aynı yıl Lefkoşa'da ölür. Oyunda Ahrar yolunda (Alternatif tarih) masada o oturur.
> Kaynak: [[Kamil Paşa]] · [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 38|Akşin, *Kısa Türkiye Tarihi*, loc. 38]] · [[Birinci Dünya Savaşı'nda Türkiye (Ahmet Emin Yalman)#p. 81|Yalman, *Birinci Dünya Savaşı'nda Türkiye*, p. 81]] · *Türk kaynağı* · [[Sultanın Paşaları (Olivier Bouquet)#p. 562|Bouquet, *Sultanın Paşaları*, p. 562]] · *Fransız kaynağı*

### Kişi · Sultan Vahdettin
`kişi: vahdettin` · `unvan: Sultan VI. Mehmed Vahdettin (1918–1922)` · `görsel: 1909 10 Resimli Kitab Vahdettin.jpg` · `rol: hükümdar`
Son Osmanlı padişahı (1918–1922). Veliahtken İttihatçılara düşmanlığıyla bilinir; 1917'de Almanya'ya resmî ziyarete giderken Mustafa Kemal yanındadır. Temmuz 1918'de, yenilgiden aylar önce tahta çıkar ve bir süre Talat kabinesini yerinde tutar. Mondros'tan sonra siyasetini İngiltere'ye bağlar; Anadolu hareketine karşı durur ve 1920'de Meclis'i dağıtır.
> Kaynak: [[Mehmed VI Vahdettin]] · [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 101|Akşin, loc. 101]] · *Türk kaynağı*

### Kişi · Maliye Nazırı
`kişi: maliye_nazir` · `unvan: Maliye Nazırı` · `rol: maliye`
Abdülhamid devrinde Maliye Nezareti'ni yöneten nazırlar sık değişir; kasada tek bir ad öne çıkmadığından oyunda adsız bir nazırdır. İflasın ve Düyun-u Umumiye'nin gölgesinde bütçeyi o toparlar.
> Kaynak: [[Enver (Murat Bardakçı)#p. 66|Bardakçı, *Enver*, p. 66]] · *Türk kaynağı*

### Kişi · Serasker Hüseyin Avni Paşa
`kişi: huseyin_avni` · `unvan: Serasker Hüseyin Avni Paşa` · `görsel: Huseyin avni pasha.jpg` · `rol: harbiye`
Abdülaziz'in seraskeri ve 30 Mayıs 1876 darbesinin mimarı. Mantran'a göre padişahı indirme fikri, olası bir intikamdan korunmak için onun kafasında doğar; Dolmabahçe'yi karadan askerle, denizden donanmayla kuşatır. "Meşrutiyet bize göre değil" diyerek bütün gücün hükümette toplanmasını ister. Birkaç hafta sonra Çerkes Hasan onu bir Meclis-i Vükelâ toplantısında öldürür.
> Kaynak: [[Hüseyin Avni Paşa]] · [[Enver (Murat Bardakçı)#p. 61|Bardakçı, *Enver*, p. 61]] · *Türk kaynağı*

### Kişi · Hobart Paşa
`kişi: hobart` · `unvan: Hobart Paşa, donanma müşaviri` · `görsel: Augustus Charles Hobart-Hampden - Project Gutenberg eText 16296.jpg` · `rol: bahriye`
Amerikan İç Savaşı'nda abluka yarıcılığı yapmış İngiliz deniz subayı; 1868'de Osmanlı hizmetine girer, Girit'te Ali Paşa'nın yanındadır ve donanmanın başına getirilir. İngiltere izinsiz hizmet ettiği için onu listeden siler. 1877 harbinde Karadeniz filosunu kumanda eder. Hatıratı kasanın kaynaklarındandır, ama bazı hikâyelerinin arşivde tutmadığı görülmüştür. Kasada bu yıllar için bir Bahriye Nazırı adı geçmediğinden oyunda donanmanın sesi odur.
> Kaynak: [[Hobart Paşa]] · [[Hobart Paşa'nın Anıları (Augustus C. Hobart-Hampden)#p. 14|Hobart-Hampden, *Hobart Paşa'nın Anıları*, p. 14]] · *İngiliz kaynağı*

### Kişi · Serasker Rıza Paşa
`kişi: riza_pasa` · `unvan: Serasker Rıza Paşa` · `rol: harbiye`
Abdülhamid devrinin seraskeri; kasada yalnızca adıyla geçer. Oyunda sarayın sadık, orduyu yerinde saydıran seraskeridir: ordunun hazırlığından çok padişahın güvenliğini düşünür.
> Kaynak: [[Enver (Murat Bardakçı)#p. 600|Bardakçı, *Enver*, p. 600]] · *Türk kaynağı*

### Kişi · Bahriye Nazırı Hasan Hüsnü Paşa
`kişi: hasan_husnu` · `unvan: Bahriye Nazırı Hasan Hüsnü Paşa` · `rol: bahriye`
Bozcaadalı Hasan Hüsnü Paşa, Abdülhamid devrinin Bahriye Nazırı. Donanma onun zamanında Haliç'te bekler; 1897 Yunan Harbi'nde gemilerin açık denize çıkamaması bu yılların simgesi olur. Oyunda donanmayı kıskançlıkla koruyan ama kullanmayan nazırdır.
> Kaynak: [[Sultanın Paşaları (Olivier Bouquet)#p. 498|Bouquet, *Sultanın Paşaları*, p. 498]] · *Fransız kaynağı*

### Kişi · Cavid Bey
`kişi: cavid` · `unvan: Maliye Nazırı Cavid Bey` · `görsel: Djavid Bey.png` · `rol: maliye`
Selanikli iktisatçı, İttihatçıların Maliye Nazırı ve iç çevrenin en savaş karşıtı sesi. 1910'da Londra'da Bağdat demiryolu teminatlarını pazarlık eder; harbin arifesinde İngiltere ile ittifaktan yanadır. 1 Ağustos 1914'te Alman ittifakının metnini okur ama onu bir taslak sanır; Goeben ve Breslau Karadeniz'e gönderildiği gün "memleket için felaket" dediği maceraya katılmayı reddettiğini söyler. Mütarekeden sonra Teceddüt Fırkası'nı yönetir; 1926'da İzmir suikastı davasında asılır.
> Kaynak: [[Cavid Bey]] · [[Türkiye'de Hükümetler (İhsan Güneş)#p. 88|Güneş, *Türkiye'de Hükümetler*, p. 88]] · [[Birinci Dünya Savaşı'nda Türkiye (Ahmet Emin Yalman)#p. 96|Yalman, p. 96]] · *Türk kaynağı*

### Kişi · Mahmud Şevket Paşa
`kişi: mahmud_sevket` · `unvan: Harbiye Nazırı Mahmud Şevket Paşa (1913'te Sadrazam)` · `görsel: Mahmud Shevket Pasha.png` · `rol: harbiye` · `komutan: nitelik +10 · taarruz +5` · `komuta: 1909-1913`
Alman terbiyeli bir kurmay; Goltz Paşa'nın yardımcısı olarak yetişir. Nisan 1909'da 31 Mart ayaklanmasını bastıran Hareket Ordusu'nun kumandanıdır; sonra üç ordunun müfettişi ve 1910'dan Harbiye Nazırı olur. Babıâli Baskını'ndan sonra sadrazam ve Harbiye Nazırı yapılır; orduyu Alman kumandasına verme fikri Liman von Sanders heyetini doğurur. 11 Haziran 1913'te Beyazıt'ta öldürülür.
> Kaynak: [[Mahmud Şevket Paşa]] · [[Türkiye'de Hükümetler (İhsan Güneş)#p. 99|Güneş, p. 99]] · *Türk kaynağı*

### Kişi · Ahmed İzzet Paşa
`kişi: ahmed_izzet` · `unvan: Harbiye Nazırı Ahmed İzzet Paşa` · `görsel: Ahmet İzzet Paşa.jpg` · `rol: harbiye` · `komutan: savunma +10 · ikmal +5` · `komuta: 1912-1918`
Alman terbiyeli bir general ve erkân-ı harbiye reisi. Balkan Harbi'nden sonra, Mahmud Şevket'in öldürülmesinin ardından Harbiye Nazırı olur; Aralık 1913'te koltuğu Enver'e bırakır. Ekim 1918'de sadrazamdır: kısa ömürlü kabinesi Mondros Mütarekesi'ni imzalar ve çekilir. İttihatçılar onu, çevresinde Cavid ile Fethi'nin çalışabileceği "ağırbaşlı bir kumandan" olarak görür.
> Kaynak: [[Ahmed İzzet Paşa]] · [[Türkiye'de Hükümetler (İhsan Güneş)#p. 127|Güneş, *Türkiye'de Hükümetler*, p. 127]] · *Türk kaynağı*

### Kişi · Bahriye Nazırı
`kişi: bahriye_nazir` · `unvan: Bahriye Nazırı` · `rol: bahriye`
Bahriye Nezareti 1909–1913 arasında kabineden kabineye ve vekâletle el değiştirir; Güneş'in tablosundan okunabilen nazırlar adlarıyla yazılıdır. Bu adsız koltuk yalnız tabloda boş ya da vekâletle doldurulmuş aylar için kalır (1908 sonbaharı, 1910 ortası–1911 sonu). Donanma programlarını ve bağış kampanyalarını Bahriye Nazırı savunur.
> Kaynak: [[Türkiye'de Hükümetler (İhsan Güneş)#p. 114|Güneş, p. 114]] · *Türk kaynağı*

### Kişi · Enver Paşa
`kişi: enver` · `unvan: Harbiye Nazırı Enver Paşa` · `görsel: Enver Pasha 1911.jpg` · `görseller: 1914=Der türkische Kriegsminister Enver Pascha.png` · `rol: harbiye` · `komutan: taarruz +25 · savunma 0 · ikmal -15 · aşırı +60` · `komuta: 1911-1918`
1908 ihtilalinin kahraman subayı; Makedonya'daki devrimciler arasında öne çıkar, 23 Temmuz 1908'de balkondan "Hasta adamı iyileştirdik!" diye bağırır. 1909–1911'de Berlin'de ataşemiliter, 1911–1912'de Trablusgarp'ta Bingazi–Derne cephesinin kumandanıdır. Babıâli Baskını'nın ve Edirne'nin geri alınmasının kahramanı olarak Ocak 1914'te Harbiye Nazırı olur. Yalman'a göre ülkeyi harbe tek başına sürükleyen odur; Sarıkamış harekâtı da onun planıdır. Mütarekeden sonra kaçar; 1922'de Orta Asya'da ölür.
> Kaynak: [[Enver Paşa]] · [[Türkiye'de Hükümetler (İhsan Güneş)#p. 127|Güneş, p. 127]] · [[Birinci Dünya Savaşı'nda Türkiye (Ahmet Emin Yalman)#p. 98|Yalman, p. 98]] · *Türk kaynağı*

### Kişi · Cemal Paşa
`kişi: cemal` · `unvan: Bahriye Nazırı Cemal Paşa` · `görsel: Djemal Pasha2.png` · `rol: bahriye` · `komutan: taarruz +5 · ikmal -5 · aşırı +20` · `komuta: 1914-1918`
"Büyük" Cemal Paşa, İttihat ve Terakki üçlüsünün üçüncüsü. Balkan Harbi'nde Konya ihtiyat tümenini kumanda eder, sonra İstanbul muhafızı ve Bahriye Nazırı olur; harbin arifesinde Fransa ile ittifaktan yanadır. 1914 sonundan itibaren 4. Ordu kumandanı olarak Suriye'yi yönetir, Süveyş harekâtını düzenler ve Şam'da Arap milliyetçilerini astırır. 1918'de Talat ve Enver'le kaçar; 25 Temmuz 1922'de Tiflis'te öldürülür. Hatıratı kasanın kaynaklarındandır.
> Kaynak: [[Cemal Paşa]] · [[Türkiye'de Hükümetler (İhsan Güneş)#p. 127|Güneş, p. 127]] · *Türk kaynağı*

### Kişi · Rauf Bey
`kişi: rauf` · `unvan: Bahriye Nazırı Rauf Bey` · `görsel: Hüseyin Rauf Orbay.jpg` · `rol: bahriye`
Hüseyin Rauf (Orbay), Balkan Harbi'nin "Hamidiye kahramanı" deniz subayı. 1914'te dretnot Sultan Osman'ı teslim almak için İngiltere'dedir ve İngilizler gemiye el koyunca eli boş döner; harbin son yıllarında Cemal'in en sert muhaliflerindendir. İzzet Paşa kabinesinin Bahriye Nazırı olarak 30 Ekim 1918'de Mondros'ta mütarekeyi imzalar. 1919'da Anadolu'da Mustafa Kemal'e katılır.
> Kaynak: [[Türkiye'de Hükümetler (İhsan Güneş)#p. 178|Güneş, p. 178]] · [[Şahbaba (Murat Bardakçı)#p. 116|Bardakçı, *Şahbaba*, p. 116]] · *Türk kaynağı*

### Kişi · Mustafa Kemal
`kişi: mustafa_kemal` · `unvan: Mustafa Kemal Bey (Paşa)` · `görsel: Ataturk, Ottoman War Academy, 1901.jpg` · `görseller: 1915=Mustafa Kemal, 1916.png · 1917=Mustafa Kemal 1917 (AtaturkYildirim, kırpılmış).jpg` · `rol: figür` · `komutan: taarruz +10 · savunma +25 · ikmal +10 · aşırı -20` · `komuta: 1911-1919`
Selanikli genç bir kurmay. 1905–1907'de Şam'da Vatan ve Hürriyet'i kurar, 1907 sonbaharında Selanik'te İttihat ve Terakki'ye girer ve Enver'le ilk anlaşmazlığını yaşar. Trablusgarp'ta Enver'in emrinde Derne'de, Balkan Harbi'nde Bolayır'da savaşır, 1913–1915'te Sofya'da ataşemiliterdir. Çanakkale'de Arıburnu ve Anafartalar'ın kumandanı olarak adını duyurur; 1916'da Bitlis ve Muş'u geri alır, 1917'de Cemal Paşa'yla çatışıp istifa eder. 19 Mayıs 1919'da Samsun'a çıkar.
> Kaynak: [[Mustafa Kemal Atatürk]] · [[Atatürk Hakkında Hatıralar ve Belgeler (Afet İnan)#p. 86|İnan, *Atatürk Hakkında Hatıralar ve Belgeler*, p. 86]] · [[Enver (Murat Bardakçı)#p. 115|Bardakçı, *Enver*, p. 115]] · *Türk kaynağı*

### Kişi · Resneli Niyazi
`kişi: niyazi` · `unvan: Kolağası Resneli Niyazi Bey` · `görsel: Ahmedniyazibey.jpg` · `rol: figür`
Resneli Kolağası Ahmed Niyazi, Arnavut bir subay. 3 Temmuz 1908'de 160 kişilik çetesiyle dağa çıkması 1908 ihtilalini başlatır; Enver de amcası Halil'le ardından gelir. Rumeli'nin bölüşüleceği söylentileri (Reval görüşmesi) onun gerekçelerindendir. İhtilalden sonra Enver'le birlikte "hürriyet kahramanı" diye anılır; halk bağışıyla alınan kruvazörlere ikisinin adı verilir.
> Kaynak: [[Resneli Niyazi]] · *Türk kaynağı*

### Kişi · Gazi Osman Paşa
`kişi: osman_pasa` · `unvan: Gazi Osman Paşa` · `görsel: Osman Pascha (Gazi Osman Paşa).jpg` · `rol: figür` · `komutan: savunma +35 · taarruz -5` · `komuta: 1877-1878`
Plevne'nin müdafii. 1877'de Vidin'den Plevne'ye yetişir ve beş ay boyunca, Bardakçı'nın deyişiyle "bir avuç askerle yüz binlerce kişilik bir Rus ordusunu durdurur"; İngiliz ve Amerikalı gözlemciler de onu över. Aralık 1877'de yaralı olarak teslim olur. Esaretten dönünce Abdülhamid onu yanında, Yıldız'da Mabeyn müşiri olarak tutar; hem şerefini kullanır hem de onun bir muhalefet odağı olmasını önler. Askerin tanıdığı "son kahraman" diye anılır.
> Kaynak: [[Gazi Osman Paşa]] · *Türk kaynağı*

### Kişi · Gazi Ahmed Muhtar Paşa
`kişi: ahmed_muhtar` · `unvan: Gazi Ahmed Muhtar Paşa` · `görsel: Ahmet muhtar.jpg` · `rol: figür` · `komutan: savunma +20 · taarruz +5` · `komuta: 1877-1878`
Mareşal ve sadrazam. '93 Harbi'nde Kafkas cephesinde birkaç zafer kazanır, ama Rusları durduramaz; Kars 18 Kasım 1877'de düşer. Sonra yirmi yılı aşkın bir süre Abdülhamid'in Mısır fevkalade komiseridir ve Sudan sınırında İngiliz tekliflerine direnir. 1912'de sadrazam olur; kabinesi Balkan bunalımının ortasında, 29 Ekim 1912'de istifaya zorlanır.
> Kaynak: [[Gazi Ahmed Muhtar Paşa]] · *Türk kaynağı*

### Kişi · Midhat Paşa
`kişi: midhat` · `unvan: Midhat Paşa` · `görsel: Nadar - Portrait of Midhat Pasha.jpg` · `rol: figür`
Büyük ıslahatçı vali ve "Kanun-ı Esasi'nin babası". Tuna ve Bağdat valiliklerinde memleket sandıklarını ve ilk vilayet gazetelerini kurar. Sadrazam olarak Abdülaziz'in ve V. Murad'ın tahttan indirilmesinde ve Meşrutiyet'in ilanında rol oynar. Abdülhamid onu beş ay sonra sürgüne gönderir; Suriye ve İzmir valiliklerinden sonra Yıldız'da yargılanır, idama mahkûm edilir, ceza sürgüne çevrilir. 1884'te Taif'te, söylentiye göre öldürülerek, ölür.
> Kaynak: [[Midhat Paşa]] · *Türk kaynağı*

### Kişi · Goltz Paşa
`kişi: goltz` · `unvan: Colmar von der Goltz Paşa` · `görsel: Colmar von der Goltz.jpg` · `rol: figür` · `komutan: nitelik +15 · savunma +10` · `komuta: 1914-1916`
Colmar von der Goltz, "Goltz Paşa". 1883'te İstanbul'a gelir ve Harbiye'de bir kuşak Osmanlı subayı yetiştirir; *Das Volk in Waffen* kitabı onların elinden düşmez. İttihatçılar onu eski rejimden daha çok kullanır; 1910 manevralarında Türk subaylarının eksiklerini açıkça eleştirir. Büyük Harp'te önce padişahın yaveri, sonra Irak'ta 6. Ordu'nun kumandanıdır; Liman von Sanders'le anlaşamaz. Nisan 1916'da Bağdat'ta tifüsten ölür.
> Kaynak: [[Colmar von der Goltz]] · *Alman kaynağı*

### Kişi · Liman von Sanders
`kişi: liman` · `unvan: Liman von Sanders Paşa` · `görsel: Bundesarchiv Bild 183-2007-0917-501, Otto Liman von Sanders.jpg` · `rol: figür` · `komutan: savunma +20 · taarruz +5 · nitelik +5` · `komuta: 1914-1918`
Otto Liman von Sanders, Aralık 1913'te gelen Alman askerî heyetinin başı. Rusya bir Alman'ın İstanbul'daki kolorduya kumanda etmesine itiraz edince mareşal yapılır ve Müfettiş-i Umumi unvanını alır. Çanakkale'de 5. Ordu'yla Boğaz müdafaasını, 1918'de Filistin'de Yıldırım Ordular Grubu'nu kumanda eder. Enver'le sık sık çatışır; hatıratı *Türkiye'de Beş Yıl* kasanın kaynaklarındandır.
> Kaynak: [[Liman von Sanders]] · *Alman kaynağı*

### Kişi · Fahreddin Paşa
`kişi: fahreddin` · `unvan: Fahreddin Paşa, Medine muhafızı` · `görsel: Ömer Fahreddin Paşa.jpg` · `rol: figür` · `komutan: savunma +30` · `komuta: 1916-1919`
Fahreddin (Fahri) Paşa, Medine'nin müdafii. Şerif Hüseyin'in isyanından sonra Cemal Paşa onu 15–16 taburla Medine'ye kumandan atar. Faysal ona "hükümetteki adamlara karşı" katılması için mektuplar gönderir; o reddeder. Demiryoluna yapılan baskınlar karşı taarruzunu durdurur, ama şehri mütarekeden sonra da bir süre tutar.
> Kaynak: [[Fahreddin Paşa]] · *Türk kaynağı*

### Kişi · V. Mehmed Reşad
`kişi: mehmed_resad` · `unvan: Sultan V. Mehmed Reşad (1909–1918)` · `görsel: Ahmet Resat.jpg` · `rol: hükümdar`
27 Nisan 1909'da Abdülhamid'in yerine tahta çıkar. Akşin onu meşrutiyet için uygun bir padişah bulur: siyasete pek karışmayan, iyi niyetli, babacan biri. Kaynaklar onu çoğunlukla bir imza ve simge olarak gösterir; oyunda masaya o değil, o günkü sadrazam oturur.
> Kaynak: [[Mehmed V Reşad]] · [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 43|Akşin, *Kısa Türkiye Tarihi*, loc. 43]] · *Türk kaynağı*

### Kişi · Küçük Said Paşa
`kişi: said_pasa` · `unvan: Sadrazam Küçük Said Paşa` · `görsel: 1909 05 10 Sait Pasa Ayastefanos Yat Kulubu Onunde.jpg` · `rol: sadrazam`
Abdülhamid'in eski vezirlerinden. Temmuz 1908'de Meşrutiyet'ten kısa süre önce sadrazamdır; ilk toplantıda Kanun-ı Esasi'nin yeniden yürürlüğe konmasını karara bağlar, ama Cemiyet ona sıcak bakmaz ve 3 Ağustos 1908'de çekilir. Hakkı Paşa'nın Trablusgarp ültimatomu üzerine çekilmesiyle 1 Ekim 1911'de yeniden sadrazam olur: Akşin'e göre "İngilizci" tanınan bu vezirin Mahmud Şevket'i dengeleyecek ağırlığı vardır. Mebusan 18 Ocak 1912'de dağıtılır, Talat ve Cavid hükümete girer, Nisan 1912'nin "sopalı seçim"i onun hükümeti altında yapılır; Temmuz 1912'de istifa etmek zorunda kalır.
> Kaynak: [[Küçük Said Paşa]] · [[Türkiye'de Hükümetler (İhsan Güneş)#p. 38|Güneş, *Türkiye'de Hükümetler*, p. 38]] · *Türk kaynağı* · [[Türkiye'de Hükümetler (İhsan Güneş)#p. 154|Güneş, *Türkiye'de Hükümetler*, p. 154]] · *Türk kaynağı* · [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 50|Akşin, *Kısa Türkiye Tarihi*, loc. 50]] · *Türk kaynağı* · [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 51|Akşin, *Kısa Türkiye Tarihi*, loc. 51]] · *Türk kaynağı*

### Kişi · Ahmed Tevfik Paşa
`kişi: tevfik_pasa` · `unvan: Sadrazam Ahmed Tevfik Paşa` · `görsel: Ahmed Tevfik Pasha.jpg` · `rol: sadrazam`
31 Mart ayaklanması sırasında, Hüseyin Hilmi Paşa'nın istifasının ardından 14 Nisan 1909'da sadrazam olur. Hükümetini hemen kurar ve programını Meclis'e sunar, ama Hareket Ordusu'nun gelişiyle bir aydan kısa sürede (6 Mayıs'a kadar) görevden uzaklaşır; Adana olayları onun zamanındadır.
> Kaynak: [[Tevfik Paşa]] · [[Türkiye'de Hükümetler (İhsan Güneş)#p. 44|Güneş, *Türkiye'de Hükümetler*, p. 44]] · *Türk kaynağı* · [[Türkiye'de Hükümetler (İhsan Güneş)#p. 45|Güneş, *Türkiye'de Hükümetler*, p. 45]] · *Türk kaynağı*

### Kişi · Hüseyin Hilmi Paşa
`kişi: huseyin_hilmi` · `unvan: Sadrazam Hüseyin Hilmi Paşa` · `rol: sadrazam`
Rumeli Müfettişi iken Kâmil Paşa'nın kabinesine 27 Kasım 1908'de Dahiliye Nazırı olarak girer. Kâmil'in 196 oyla düşmesinin ardından 13 Şubat 1909'da sadrazam olur ve hükümet programını Meclis'te okuyup güvenoyu isteme geleneğini başlatır. 31 Mart'ta istifa eder; 6 Mayıs 1909'da Hareket Ordusu'nun gölgesinde sadarete döner. Yıl sonunda Lynch (Fırat gemicilik) davasında Mahmud Şevket ve Bağdat mebuslarıyla tartışır; güvenoyuna rağmen çekilir (Ocak 1910).
> Kaynak: [[Hüseyin Hilmi Paşa]] · [[Türkiye'de Hükümetler (İhsan Güneş)#p. 43|Güneş, *Türkiye'de Hükümetler*, p. 43]] · *Türk kaynağı* · [[Türkiye'de Hükümetler (İhsan Güneş)#p. 44|Güneş, *Türkiye'de Hükümetler*, p. 44]] · *Türk kaynağı* · [[Türkiye'de Hükümetler (İhsan Güneş)#p. 45|Güneş, *Türkiye'de Hükümetler*, p. 45]] · *Türk kaynağı* · [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 48|Akşin, *Kısa Türkiye Tarihi*, loc. 48]] · *Türk kaynağı*

### Kişi · İbrahim Hakkı Paşa
`kişi: ibrahim_hakki` · `unvan: Sadrazam İbrahim Hakkı Paşa` · `rol: sadrazam`
12 Ocak 1910'da Hüseyin Hilmi'nin yerine sadrazam olur. Kabinesinde eskisine göre çok İttihatçı vardır (Talat Dahiliye, Cavid Maliye, İsmail Hakkı Maarif, Hayri Evkaf) ve Mahmud Şevket Harbiye Nazırı olarak hükümete girmiştir. Meclis'ten 178 kabul, 31 ret oyuyla güvenoyu alır (24 Ocak 1910); Lynch'in Fırat ayrıcalığını yenilemez. Akşin kabinedeki İttihatçı nazırların birer birer azaldığını yazar; Güneş'in tablosuna göre Şubat 1911'de Talat ve Cavid'in koltukları vekâletle doldurulur ve Dahiliye'yi Hakkı Paşa'nın kendisi tutar (tablo okunaksızdır, bkz. GD 99). Trablusgarp ültimatomundan sonra Ekim 1911'de çekilir.
> Kaynak: [[Türkiye'de Hükümetler (İhsan Güneş)#p. 99|Güneş, *Türkiye'de Hükümetler*, p. 99]] · *Türk kaynağı* · [[Türkiye'de Hükümetler (İhsan Güneş)#p. 154|Güneş, *Türkiye'de Hükümetler*, p. 154]] · *Türk kaynağı* · [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 48|Akşin, *Kısa Türkiye Tarihi*, loc. 48]] · *Türk kaynağı* · [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 50|Akşin, *Kısa Türkiye Tarihi*, loc. 50]] · *Türk kaynağı*

### Kişi · Prens Said Halim Paşa
`kişi: said_halim` · `unvan: Sadrazam Prens Said Halim Paşa` · `görsel: Großwezir Prinz Said Halim Pascha 1915 C. Pietzner.png` · `rol: sadrazam`
Kavalalı Mehmed Ali Paşa'nın torunu. Mahmud Şevket'in 11 Haziran 1913'te öldürülmesi üzerine sadrazam olur; kabinesi (onaylanışı 17 Haziran 1913) tümüyle İttihatçılardan kuruludur. Şubat 1917'de Talat'a bırakana kadar makamı korur.
> Kaynak: [[Said Halim Paşa]] · [[Türkiye'de Hükümetler (İhsan Güneş)#p. 160|Güneş, *Türkiye'de Hükümetler*, p. 160]] · *Türk kaynağı* · [[Türkiye'de Hükümetler (İhsan Güneş)#p. 127|Güneş, *Türkiye'de Hükümetler*, p. 127]] · *Türk kaynağı*

### Kişi · Recep Paşa
`kişi: recep_pasa` · `unvan: Harbiye Nazırı Recep Paşa` · `rol: harbiye`
Kâmil Paşa'nın kabinesinde 6 Ağustos 1908'den Şubat 1909'a kadar Harbiye Nazırı. Padişah Harbiye ve Bahriye'ye kendi adamlarını istemişti; Kâmil Paşa Kanun-ı Esasi'nin maddesinin yoruma açık olduğunu söyleyip kendi istediklerini atadı.
> Kaynak: [[Türkiye'de Hükümetler (İhsan Güneş)#p. 67|Güneş, *Türkiye'de Hükümetler*, p. 67]] · *Türk kaynağı* · [[Türkiye'de Hükümetler (İhsan Güneş)#p. 28|Güneş, *Türkiye'de Hükümetler*, p. 28]] · *Türk kaynağı* · [[Türkiye'de Hükümetler (İhsan Güneş)#p. 29|Güneş, *Türkiye'de Hükümetler*, p. 29]] · *Türk kaynağı*

### Kişi · Ali Rıza Paşa
`kişi: ali_riza_pasa` · `unvan: Harbiye Nazırı Ali Rıza Paşa` · `rol: harbiye`
Mısır fevkalade komiseri iken Hüseyin Hilmi'nin ilk kabinesinde (14 Şubat 1909) Harbiye Nazırı olur.
> Kaynak: [[Türkiye'de Hükümetler (İhsan Güneş)#p. 74|Güneş, *Türkiye'de Hükümetler*, p. 74]] · *Türk kaynağı*

### Kişi · Hüseyin Nazım Paşa
`kişi: nazim_pasa` · `unvan: Harbiye Nazırı Hüseyin Nazım Paşa` · `görsel: 1326 04 22 Serveti Funun Nazim Pasa Bagdat Valisi.jpg` · `rol: harbiye`
Yanya Valisi iken Mart 1909'da Harbiye Nazırı olur; Balkan Harbi'nde (22 Temmuz 1912'den 23 Ocak 1913'e, Muhtar ve Kâmil kabinelerinde) bu koltuktadır. Akşin onu yenilginin başlıca askerî sorumlusu sayar; 23 Ocak 1913'te Babıâli Baskını'nda vurulur.
> Kaynak: [[Nazım Paşa]] · [[Türkiye'de Hükümetler (İhsan Güneş)#p. 74|Güneş, *Türkiye'de Hükümetler*, p. 74]] · *Türk kaynağı* · [[Türkiye'de Hükümetler (İhsan Güneş)#p. 114|Güneş, *Türkiye'de Hükümetler*, p. 114]] · *Türk kaynağı* · [[Türkiye'de Hükümetler (İhsan Güneş)#p. 120|Güneş, *Türkiye'de Hükümetler*, p. 120]] · *Türk kaynağı*

### Kişi · Edhem Paşa
`kişi: edhem_pasa` · `unvan: Harbiye Nazırı Edhem Paşa` · `rol: harbiye`
Tevfik Paşa'nın kabinesinde 14 Nisan 1909'dan Hareket Ordusu'nun gelişine kadar Harbiye Nazırı (müir-i aynı).
> Kaynak: [[Türkiye'de Hükümetler (İhsan Güneş)#p. 83|Güneş, *Türkiye'de Hükümetler*, p. 83]] · *Türk kaynağı*

### Kişi · Salih Paşa
`kişi: salih_pasa` · `unvan: Harbiye Nazırı Salih Paşa` · `rol: harbiye`
II. Ordu komutanı iken 28 Nisan 1909'da Harbiye Nazırı olur ve Hüseyin Hilmi'nin ikinci kabinesinde, Mahmud Şevket'in girdiği Ocak 1910'a kadar kalır.
> Kaynak: [[Türkiye'de Hükümetler (İhsan Güneş)#p. 83|Güneş, *Türkiye'de Hükümetler*, p. 83]] · *Türk kaynağı* · [[Türkiye'de Hükümetler (İhsan Güneş)#p. 88|Güneş, *Türkiye'de Hükümetler*, p. 88]] · *Türk kaynağı*

### Kişi · Ziya Paşa
`kişi: ziya_pasa` · `unvan: Maliye Nazırı Ziya Paşa` · `rol: maliye`
Kâmil Paşa'nın (6 Ağustos 1908) ve Hüseyin Hilmi'nin ilk kabinesinin Maliye Nazırı; Temmuz 1912'de Gazi Ahmed Muhtar Paşa'nın kabinesinde, eski nazır olarak, bir kez daha bu koltuğa getirilir.
> Kaynak: [[Türkiye'de Hükümetler (İhsan Güneş)#p. 67|Güneş, *Türkiye'de Hükümetler*, p. 67]] · *Türk kaynağı* · [[Türkiye'de Hükümetler (İhsan Güneş)#p. 74|Güneş, *Türkiye'de Hükümetler*, p. 74]] · *Türk kaynağı* · [[Türkiye'de Hükümetler (İhsan Güneş)#p. 114|Güneş, *Türkiye'de Hükümetler*, p. 114]] · *Türk kaynağı*

### Kişi · Rıfat Bey
`kişi: rifat_bey` · `unvan: Maliye Nazırı Rıfat Bey` · `rol: maliye`
Mayıs–Haziran 1909'da Hüseyin Hilmi'nin ikinci kabinesinde, ve Divan-ı Muhasebat Reisi olarak Şubat 1913'ten Mart 1914'e kadar Mahmud Şevket ve Said Halim kabinelerinde Maliye Nazırı.
> Kaynak: [[Türkiye'de Hükümetler (İhsan Güneş)#p. 88|Güneş, *Türkiye'de Hükümetler*, p. 88]] · *Türk kaynağı* · [[Türkiye'de Hükümetler (İhsan Güneş)#p. 124|Güneş, *Türkiye'de Hükümetler*, p. 124]] · *Türk kaynağı* · [[Türkiye'de Hükümetler (İhsan Güneş)#p. 127|Güneş, *Türkiye'de Hükümetler*, p. 127]] · *Türk kaynağı*

### Kişi · Nail Bey
`kişi: nail_bey` · `unvan: Maliye Nazırı Nail Bey` · `rol: maliye`
Said Paşa'nın kabinesinde Ekim 1911'den Şubat 1912'ye kadar Maliye Nazırı; Cavid'in dönüşüyle yerini ona bırakır.
> Kaynak: [[Türkiye'de Hükümetler (İhsan Güneş)#p. 106|Güneş, *Türkiye'de Hükümetler*, p. 106]] · *Türk kaynağı*

### Kişi · Hüseyin Sabri Bey
`kişi: huseyin_sabri` · `unvan: Maliye Nazırı Hüseyin Sabri Bey` · `rol: maliye`
Eski Maliye Nazırı. 25 Ağustos 1912'de, Balkan Harbi'nin eşiğinde, Gazi Ahmed Muhtar'ın kabinesinde Maliye'ye getirilir.
> Kaynak: [[Türkiye'de Hükümetler (İhsan Güneş)#p. 114|Güneş, *Türkiye'de Hükümetler*, p. 114]] · *Türk kaynağı*

### Kişi · Abdurrahman Efendi
`kişi: abdurrahman_efendi` · `unvan: Maliye Nazırı Abdurrahman Efendi` · `rol: maliye`
Eski Dahiliye Nazırı. 30 Ekim 1912'de Kâmil Paşa'nın kabinesinde Maliye Nazırı olur; Said Halim hükümetinin programı, Ocak 1913'te Saray'da toplanan mecliste Maliye Nazırı'nın hazinenin harbe devam etmeye değil günlük ihtiyaca bile yetmediğini bildirdiğini anlatır.
> Kaynak: [[Türkiye'de Hükümetler (İhsan Güneş)#p. 120|Güneş, *Türkiye'de Hükümetler*, p. 120]] · *Türk kaynağı* · [[Türkiye'de Hükümetler (İhsan Güneş)#p. 128|Güneş, *Türkiye'de Hükümetler*, p. 128]] · *Türk kaynağı*

### Kişi · Halil Paşa
`kişi: halil_pasa` · `unvan: Bahriye Nazırı Halil Paşa` · `rol: bahriye`
Mirliva. 12 Ocak 1910'da İbrahim Hakkı Paşa'nın kabinesinde Bahriye Nazırı olur; 1910 ortasında koltuk vekâletle el değiştirir.
> Kaynak: [[Türkiye'de Hükümetler (İhsan Güneş)#p. 99|Güneş, *Türkiye'de Hükümetler*, p. 99]] · *Türk kaynağı*

### Kişi · Arif Hikmet Paşa
`kişi: arif_hikmet` · `unvan: Bahriye Nazırı Arif Hikmet Paşa` · `rol: bahriye`
Ferik ve âyan üyesi. 5 Mayıs 1909'da Hüseyin Hilmi'nin ikinci kabinesinde Bahriye Nazırı olur; Kâmil Paşa'nın ikinci kabinesinde (Ekim 1912) Adliye Nazırı'dır.
> Kaynak: [[Türkiye'de Hükümetler (İhsan Güneş)#p. 88|Güneş, *Türkiye'de Hükümetler*, p. 88]] · *Türk kaynağı* · [[Türkiye'de Hükümetler (İhsan Güneş)#p. 120|Güneş, *Türkiye'de Hükümetler*, p. 120]] · *Türk kaynağı*

### Kişi · Hurşid Paşa
`kişi: hurshid_pasa` · `unvan: Bahriye Nazırı Hurşid Paşa` · `rol: bahriye`
Seryaver. 4 Ekim 1911'de Said Paşa'nın kabinesinde Bahriye Nazırı olur; Trablusgarp Harbi'nin sürdüğü aylarda koltuktadır.
> Kaynak: [[Türkiye'de Hükümetler (İhsan Güneş)#p. 106|Güneş, *Türkiye'de Hükümetler*, p. 106]] · *Türk kaynağı*

### Kişi · Mahmud Muhtar Paşa
`kişi: mahmud_muhtar` · `unvan: Bahriye Nazırı Mahmud Muhtar Paşa` · `rol: bahriye`
22 Temmuz 1912'de Gazi Ahmed Muhtar Paşa'nın kabinesinde Bahriye Nazırı olur; Balkan Harbi'nin patlak verdiği Ekim 1912'de bu koltuktadır (kabine 29 Ekim'de düşer).
> Kaynak: [[Türkiye'de Hükümetler (İhsan Güneş)#p. 114|Güneş, *Türkiye'de Hükümetler*, p. 114]] · *Türk kaynağı*

### Kişi · Salih Paşa
`kişi: salih_bahriye` · `unvan: Bahriye Nazırı Salih Paşa` · `rol: bahriye`
Eski Nafıa Nazırı. 30 Ekim 1912'de Kâmil Paşa'nın kabinesinde Bahriye Nazırı olur; Ocak 1913'te Babıâli Baskını'yla birlikte görevi biter.
> Kaynak: [[Türkiye'de Hükümetler (İhsan Güneş)#p. 120|Güneş, *Türkiye'de Hükümetler*, p. 120]] · *Türk kaynağı*

### Kişi · Mahmud Paşa
`kişi: mahmud_pasa` · `unvan: Bahriye Nazırı Mahmud Paşa` · `rol: bahriye`
Mirliva. 24 Ocak 1913'te Mahmud Şevket Paşa'nın kabinesinde Bahriye Nazırı olur ve Said Halim'in kabinesinde de Mart 1914'te Cemal'in gelişine kadar kalır.
> Kaynak: [[Türkiye'de Hükümetler (İhsan Güneş)#p. 124|Güneş, *Türkiye'de Hükümetler*, p. 124]] · *Türk kaynağı* · [[Türkiye'de Hükümetler (İhsan Güneş)#p. 127|Güneş, *Türkiye'de Hükümetler*, p. 127]] · *Türk kaynağı*

### Kişi · Reşid Akif Paşa
`kişi: resid_akif` · `unvan: Dahiliye Nazırı Reşid Akif Paşa` · `rol: dahiliye`
6 Ağustos 1908'de Kâmil Paşa'nın kabinesinde Dahiliye Nazırı; 27 Kasım 1908'de koltuğu Hüseyin Hilmi Paşa'ya bırakır.
> Kaynak: [[Türkiye'de Hükümetler (İhsan Güneş)#p. 67|Güneş, *Türkiye'de Hükümetler*, p. 67]] · *Türk kaynağı*

### Kişi · Ferid Paşa
`kişi: ferid_pasa` · `unvan: Dahiliye Nazırı Ferid Paşa` · `rol: dahiliye`
Aydın vali vekili iken Mayıs 1909'da Hüseyin Hilmi'nin ikinci kabinesinde Dahiliye Nazırı olur; Talat'a Ağustos 1909'da yerini verir. Temmuz 1912'de Gazi Ahmed Muhtar'ın büyük kabinesinde bir kez daha Dahiliye'ye gelir.
> Kaynak: [[Türkiye'de Hükümetler (İhsan Güneş)#p. 83|Güneş, *Türkiye'de Hükümetler*, p. 83]] · *Türk kaynağı* · [[Türkiye'de Hükümetler (İhsan Güneş)#p. 88|Güneş, *Türkiye'de Hükümetler*, p. 88]] · *Türk kaynağı* · [[Türkiye'de Hükümetler (İhsan Güneş)#p. 114|Güneş, *Türkiye'de Hükümetler*, p. 114]] · *Türk kaynağı*

### Kişi · Celal Bey
`kişi: celal_bey` · `unvan: Dahiliye Nazırı Celal Bey` · `rol: dahiliye`
Edirne Valisi iken 4 Ekim 1911'de Said Paşa'nın kabinesinde Dahiliye Nazırı olur; 22 Ocak 1912'de yerini Hacı Adil Bey'e bırakır.
> Kaynak: [[Türkiye'de Hükümetler (İhsan Güneş)#p. 106|Güneş, *Türkiye'de Hükümetler*, p. 106]] · *Türk kaynağı*

### Kişi · Hacı Adil Bey
`kişi: haci_adil` · `unvan: Dahiliye Nazırı Hacı Adil Bey` · `rol: dahiliye`
Edirne Valisi iken 22 Ocak 1912'de Said Paşa'nın kabinesinde Dahiliye Nazırı olur; Nisan 1912'nin sopalı seçimleri onun nezareti sırasında yapılır. Mahmud Şevket'in kabinesinde (Ocak 1913) yeniden Dahiliye'dir.
> Kaynak: [[Türkiye'de Hükümetler (İhsan Güneş)#p. 106|Güneş, *Türkiye'de Hükümetler*, p. 106]] · *Türk kaynağı* · [[Türkiye'de Hükümetler (İhsan Güneş)#p. 124|Güneş, *Türkiye'de Hükümetler*, p. 124]] · *Türk kaynağı* · [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 51|Akşin, *Kısa Türkiye Tarihi*, loc. 51]] · *Türk kaynağı*

### Kişi · Reşid Bey
`kişi: resid_bey` · `unvan: Dahiliye Nazırı Reşid Bey` · `rol: dahiliye`
Aydın Valisi iken 30 Ekim 1912'de Kâmil Paşa'nın kabinesinde Dahiliye Nazırı olur; Balkan Harbi'nin en ağır haftalarında Dahiliye Nazırı'dır.
> Kaynak: [[Türkiye'de Hükümetler (İhsan Güneş)#p. 120|Güneş, *Türkiye'de Hükümetler*, p. 120]] · *Türk kaynağı*

## Kabineler

Masadaki koltukların kimde olduğu. Satırlar yukarıdan aşağı denenir; tarihi ve koşulu tutan ilk satır geçerlidir.

**Hükümdar** padişahtır (Abdülhamid, V. Mehmed Reşad, Vahdettin). **Sadrazam** doluysa masada o oturur (üst köşedeki kart); `-` ise masada, olayların atadığı kişi (persona) oturur. 1908–1913 satırları ay hassasiyetinde, İhsan Güneş'in *Türkiye'de Hükümetler* kitabındaki kabine tablolarına (Rumi tarihler Gregoryen'e çevrilmiştir; OCR'dan okunmuştur) ve Sina Akşin'in *Kısa Türkiye Tarihi*'ne dayanır:

- **Kâmil Paşa I** (6 Ağustos 1908 – 13 Şubat 1909; Said Paşa Temmuz 1908'de, Kâmil'den önce): [[Türkiye'de Hükümetler (İhsan Güneş)#p. 67|Güneş, p. 67]]
- **Hüseyin Hilmi I** (13 Şubat – 13 Nisan 1909): [[Türkiye'de Hükümetler (İhsan Güneş)#p. 74|Güneş, p. 74]]
- **Tevfik Paşa** (14 Nisan – 5 Mayıs 1909): [[Türkiye'de Hükümetler (İhsan Güneş)#p. 83|Güneş, p. 83]]
- **Hüseyin Hilmi II** (5 Mayıs 1909 – 12 Ocak 1910): [[Türkiye'de Hükümetler (İhsan Güneş)#p. 88|Güneş, p. 88]]
- **İbrahim Hakkı Paşa** (12 Ocak 1910 – 4 Ekim 1911): [[Türkiye'de Hükümetler (İhsan Güneş)#p. 99|Güneş, p. 99]]
- **Said Paşa II** (4 Ekim 1911 – 22 Temmuz 1912; Mebusan 18 Ocak 1912'de feshedilir, Nisan'da "sopalı seçim", Şubat 1912'de Talat Posta-Telgraf'a, Cavid Maliye'ye girer): [[Türkiye'de Hükümetler (İhsan Güneş)#p. 106|Güneş, p. 106]] · [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 51|Akşin, loc. 51]]
- **Gazi Ahmed Muhtar Paşa** (22 Temmuz – 29 Ekim 1912; "büyük kabine", İttihatçılar desteklemez): [[Türkiye'de Hükümetler (İhsan Güneş)#p. 114|Güneş, p. 114]]
- **Kâmil Paşa II** (30 Ekim 1912 – 23 Ocak 1913): [[Türkiye'de Hükümetler (İhsan Güneş)#p. 120|Güneş, p. 120]]
- **Mahmud Şevket Paşa** (24 Ocak – 11 Haziran 1913; hem sadrazam hem Harbiye): [[Türkiye'de Hükümetler (İhsan Güneş)#p. 124|Güneş, p. 124]]
- **Said Halim Paşa** (17 Haziran 1913'ten; Talat Dahiliye, Ahmed İzzet Harbiye, 3 Ocak 1914'ten Enver Harbiye): [[Türkiye'de Hükümetler (İhsan Güneş)#p. 127|Güneş, p. 127]]

| Başlangıç | Bitiş | Koşul | Hükümdar | Sadrazam | Dahiliye | Maliye | Harbiye | Bahriye |
|---|---|---|---|---|---|---|---|---|
| 1873-01 | 1876-05 | - | abdulaziz | - | - | maliye_nazir | huseyin_avni | hobart |
| 1876-06 | 1909-12 | !⚑yol_ittihat | abdulhamid | - | - | maliye_nazir | riza_pasa | hasan_husnu |
| 1910-01 | 1919-12 | ⚑yol_hamid | abdulhamid | - | - | maliye_nazir | riza_pasa | hasan_husnu |
| 1913-01 | 1919-12 | ⚑yol_ahrar | mehmed_resad | kamil | - | maliye_nazir | ahmed_izzet | bahriye_nazir |
| 1908-07 | 1908-07 | ⚑yol_ittihat | abdulhamid | said_pasa | - | maliye_nazir | riza_pasa | bahriye_nazir |
| 1908-08 | 1908-10 | ⚑yol_ittihat | abdulhamid | kamil | resid_akif | ziya_pasa | recep_pasa | bahriye_nazir |
| 1908-11 | 1909-01 | ⚑yol_ittihat | abdulhamid | kamil | huseyin_hilmi | ziya_pasa | recep_pasa | bahriye_nazir |
| 1909-02 | 1909-02 | ⚑yol_ittihat | abdulhamid | huseyin_hilmi | huseyin_hilmi | ziya_pasa | ali_riza_pasa | bahriye_nazir |
| 1909-03 | 1909-03 | ⚑yol_ittihat | abdulhamid | huseyin_hilmi | huseyin_hilmi | ziya_pasa | nazim_pasa | bahriye_nazir |
| 1909-04 | 1909-04 | ⚑yol_ittihat | abdulhamid | tevfik_pasa | - | maliye_nazir | edhem_pasa | bahriye_nazir |
| 1909-05 | 1909-06 | ⚑yol_ittihat | mehmed_resad | huseyin_hilmi | ferid_pasa | rifat_bey | salih_pasa | arif_hikmet |
| 1909-07 | 1909-07 | ⚑yol_ittihat | mehmed_resad | huseyin_hilmi | ferid_pasa | cavid | salih_pasa | arif_hikmet |
| 1909-08 | 1909-12 | ⚑yol_ittihat | mehmed_resad | huseyin_hilmi | talat | cavid | salih_pasa | arif_hikmet |
| 1910-01 | 1910-06 | ⚑yol_ittihat | mehmed_resad | ibrahim_hakki | talat | cavid | mahmud_sevket | halil_pasa |
| 1910-07 | 1911-01 | ⚑yol_ittihat | mehmed_resad | ibrahim_hakki | talat | cavid | mahmud_sevket | bahriye_nazir |
| 1911-02 | 1911-09 | ⚑yol_ittihat | mehmed_resad | ibrahim_hakki | ibrahim_hakki | maliye_nazir | mahmud_sevket | bahriye_nazir |
| 1911-10 | 1912-01 | ⚑yol_ittihat | mehmed_resad | said_pasa | celal_bey | nail_bey | mahmud_sevket | hurshid_pasa |
| 1912-02 | 1912-06 | ⚑yol_ittihat | mehmed_resad | said_pasa | haci_adil | cavid | mahmud_sevket | hurshid_pasa |
| 1912-07 | 1912-08 | ⚑yol_ittihat | mehmed_resad | ahmed_muhtar | ferid_pasa | ziya_pasa | nazim_pasa | mahmud_muhtar |
| 1912-09 | 1912-10 | ⚑yol_ittihat | mehmed_resad | ahmed_muhtar | ferid_pasa | huseyin_sabri | nazim_pasa | mahmud_muhtar |
| 1912-11 | 1913-01 | ⚑yol_ittihat | mehmed_resad | kamil | resid_bey | abdurrahman_efendi | nazim_pasa | salih_bahriye |
| 1913-02 | 1913-05 | ⚑yol_ittihat | mehmed_resad | mahmud_sevket | haci_adil | rifat_bey | mahmud_sevket | mahmud_pasa |
| 1913-06 | 1913-12 | ⚑yol_ittihat | mehmed_resad | said_halim | talat | rifat_bey | ahmed_izzet | mahmud_pasa |
| 1914-01 | 1914-02 | ⚑yol_ittihat | mehmed_resad | said_halim | talat | rifat_bey | enver | mahmud_pasa |
| 1914-03 | 1917-01 | ⚑yol_ittihat | mehmed_resad | said_halim | talat | cavid | enver | cemal |
| 1917-02 | 1918-06 | ⚑yol_ittihat | mehmed_resad | talat | talat | cavid | enver | cemal |
| 1918-07 | 1918-09 | ⚑yol_ittihat | vahdettin | talat | talat | cavid | enver | cemal |
| 1918-10 | 1919-12 | ⚑yol_ittihat & ⚑talat_gitti | vahdettin | - | - | maliye_nazir | ahmed_izzet | rauf |
| 1918-10 | 1919-12 | ⚑yol_ittihat | vahdettin | talat | talat | cavid | enver | cemal |

## Devletler

Masada her devletin bayraklı yuvarlak bir düğmesi vardır; olay düğmeleri de ilgili devletin bayrağıyla çıkar. `konum` haritadaki yeri (boylam,enlem; o devletin olayları başka bir `yer` verilmemişse burada görünür), `bayrak` şimdilik harf kısaltmasıdır. Payitaht bloğundaki `görsel` masadaki haritanın arka planıdır (şimdilik 1900 tarihli bir Wikimedia haritası; gerçek harita 2.5D masayla gelecek).

### Devlet · Payitaht
`devlet: OS` · `ad: Devlet-i Aliyye` · `konum: 28.976,41.011` · `görsel: Map-of-Ottoman-Empire-1900.png`
İstanbul, Babıâli ve saray: 1873'te Tuna'dan Basra'ya, Bosna'dan Yemen'e uzanan, ama 1875'te iflas etmiş bir imparatorluk. Abdülaziz'in devri iflasla, Abdülhamid'inki Düyun-u Umumiye ile açılır; 1878'de Balkanlar'ın büyük kısmı, 1882'de Mısır fiilen, 1912–13'te Rumeli kaybedilir.

Kaynaklar bu yılları bir yandan çözülme, bir yandan da merkezileşme ve modernleşme diye anlatır: Bouquet atamaların padişahın elinde toplandığını, Toprak ve Güran maliyenin çöküşünü, Akşin meşrutiyet mücadelesini yazar. Payitaht düğmesi hükümdarı ve nazırları açar.
> Kaynak: [[Ottoman Empire]] · [[Düyun-u Umumiye]] · [[Congress of Berlin (1878)]]

### Devlet · Rusya
`devlet: RU` · `ad: Rusya İmparatorluğu` · `konum: 33.50,46.60`
Karadeniz'in ve Boğazlar'ın öbür ucundaki asıl tehdit; iki yüzyıllık savaşların karşı tarafı. 1877–78'de ordusu Ayastefanos'a kadar geldi, Kars'ı, Ardahan'ı ve Batum'u aldı; Berlin Kongresi kazançlarının bir kısmını geri aldırdı.

İstanbul'daki sefiri İgnatiyev 1870'lerde Babıâli'yi yönlendirir (Mantran). 1914'te Kafkas cephesinde yeniden karşımızdadır; 1915'te İtilaf'tan İstanbul ve Boğazlar vaadi alır. 1917 ihtilaliyle çöker ve Brest-Litovsk'ta Kars, Ardahan ve Batum'u geri verir.
> Kaynak: [[Russian Empire]] · [[Russo-Turkish War of 1877-1878]] · [[Russian Revolution (1917)]] · [[Treaty of Brest-Litovsk (1918)]]

### Devlet · İngiltere
`devlet: IN` · `ad: Büyük Britanya` · `konum: 14.50,35.90`
Kıbrıs'ı alan, Mısır'a yerleşen, Hindistan yolunu kollayan deniz gücü. 1878'de Rusya'ya karşı imparatorluğun koruyucusu gibi görünür ve karşılığında Kıbrıs'ı alır; 1882'de Mısır'ı işgal eder.

Gladstone'un 'Bulgar vahşetleri' kampanyasından sonra kamuoyu Türklere döner; Salisbury bir paylaşım bile önerir. Büyük Harp'te Çanakkale'de, Irak'ta ve Filistin'de karşımızdadır; Şerif Hüseyin'i isyana destekler ve 1918'de İstanbul'u işgal eder.
> Kaynak: [[British occupation of Egypt (1882)]] · [[Lord Salisbury]] · [[William Gladstone]] · [[Gallipoli Campaign (1915)]]

### Devlet · Fransa
`devlet: FR` · `ad: Fransa` · `konum: 8.60,36.50`
1881'de Tunus'u alan, Suriye ve Lübnan'da gözü olan, imparatorluğun başlıca alacaklılarından biri. Osmanlı Bankası'nın ve Düyun-u Umumiye'nin arkasında Fransız sermayesi durur; Reji de Fransız ağırlıklı bir şirkettir.

Büyük Harp'te İtilaf'tadır; Sykes–Picot'da Suriye kıyısını, Kilikya'yı ve Musul'un kuzeyini kendine ayırır. Harpten sonra Adana ve Kilikya'ya asker çıkarır.
> Kaynak: [[Ottoman Bank]] · [[Tobacco Régie]] · [[Sykes-Picot Agreement (1916)]]

### Devlet · Almanya
`devlet: AL` · `ad: Alman İmparatorluğu` · `konum: 13.40,51.50`
Önce danışman, sonra demiryolu sahibi, en sonunda müttefik. Bismarck 1880'de padişahın Alman müşavir isteğini nüfuz kazanmak için kabul ettirir; Goltz Paşa bir kuşak subay yetiştirir. 1899'dan sonra Bağdat demiryolu imtiyazını alır.

1913'te Liman von Sanders'in askerî heyeti gelir; 2 Ağustos 1914'te gizli ittifak imzalanır ve Goeben ile Breslau Osmanlı'yı harbe sokar. Bardakçı'ya göre İttihat ve Terakki devletin kaderini Berlin'e bağladı.
> Kaynak: [[Otto von Bismarck]] · [[Colmar von der Goltz]] · [[German military mission (1913)]] · [[Goeben and Breslau (1914)]]

### Devlet · Avusturya-Macaristan
`devlet: AV` · `ad: Avusturya-Macaristan` · `konum: 16.37,48.21`
Bosna-Hersek'i 1878'de işgal, 1908'de ilhak eden komşu. Makedonya'da Rusya ile birlikte ıslahat denetimi kurar; Üsküp'e jandarma subayları gönderir (Bardakçı).

Büyük Harp'te Almanya'nın ve Osmanlı'nın müttefikidir; Galiçya'ya Osmanlı tümenleri gönderilir. 1918'de dağılır.
> Kaynak: [[Congress of Berlin (1878)]] · [[Galician Front (1916-1917)]]

### Devlet · İtalya
`devlet: IT` · `ad: İtalya` · `konum: 12.50,41.90`
1861'de birleşen genç krallık; Akdeniz'de sömürge arar. 1911'de Trablusgarp'a çıkar; 1912'de On İki Ada'yı alır ve Uşi'de Trablusgarp ile Bingazi'yi kendine bırakır.

1915'te İtilaf'a katılır ve Londra'da Antalya vaadini alır; harpten sonra Antalya ve Konya'ya asker çıkarır.
> Kaynak: [[Italo-Turkish War (1911-1912)]] · [[Trablusgarp]]

### Devlet · Yunanistan
`devlet: YU` · `ad: Yunanistan` · `konum: 23.73,37.98`
1830'da bağımsız olan krallık; Girit'i ve adaları ister. 1881'de Teselya'yı alır, 1897'de Dömeke'de yenilir, ama Girit özerk olur ve 1908'de Yunanistan'a katılır.

Balkan Harbi'nde Selanik'e ve Yanya'ya girer, Ege adalarını alır. 1919'da İzmir'e çıkar.
> Kaynak: [[Yunanistan]] · [[Greco-Turkish War of 1897]] · [[Girit]]

### Devlet · Bulgaristan
`devlet: BU` · `ad: Bulgaristan` · `konum: 23.32,42.70`
Ayastefanos'un doğurduğu, Berlin'in küçülttüğü prenslik. 1885'te Doğu Rumeli'yi katar, 1908'de bağımsızlığını ilan eder.

1912'de Balkan ittifakıyla Çatalca'ya dayanır ve Edirne'yi alır; İkinci Balkan Harbi'nde Edirne'yi geri verir ama Batı Trakya'yı tutar. 1915'te Almanya ve Osmanlı'nın müttefiki olur.
> Kaynak: [[Bulgaristan]] · [[Balkan Wars (1912-1913)]]

### Devlet · Sırbistan ve Karadağ
`devlet: SR` · `ad: Sırbistan ve Karadağ` · `konum: 20.46,44.82`
1876'da Osmanlı'ya harp açan Sırbistan ve Karadağ; Berlin'de ikisi de bağımsız olur ve Niş bölgesini alır. 1882'de Kral Milan'ın antlaşması Sırbistan'ı neredeyse Avusturya'nın bir vasalı yapar (Trotsky).

1912'de Balkan ittifakıyla Kosova'yı, Üsküp'ü ve Manastır'ı alırlar; Trotsky bu seferi Sırp ordusunun yanında izler.
> Kaynak: [[Sırbistan]] · [[Balkan Wars (1912-1913)]]

### Devlet · Romanya
`devlet: RO` · `ad: Romanya` · `konum: 26.10,44.43`
1878'e kadar kâğıt üstünde Osmanlı'ya bağlı Eflak ve Boğdan prenslikleri. '93 Harbi'nde Rusya'nın yanında savaşır; Ayastefanos ve Berlin'le bağımsız olur ve Dobruca'yı alır.

1913'te İkinci Balkan Harbi'nde Bulgaristan'a girer; 1916'da İtilaf'a katılır ve Osmanlı tümenleri Dobruca'da onunla savaşır.
> Kaynak: [[Osmanlı İmparatorluğu Tarihi (Robert Mantran)#p. 644|Mantran, *Osmanlı İmparatorluğu Tarihi*, p. 644]] · *Fransız kaynağı*

### Devlet · Arnavutluk
`devlet: AB` · `ad: Arnavutluk` · `konum: 19.82,41.33`
Balkan Harbi'nin sonunda Londra'da bağımsızlığı tanınan prenslik. Ondan önce Arnavutlar imparatorluğun sadık ve huzursuz tebaasıydı: 1878'de Prizren Birliği, 1910–1912'de kuzeyde isyanlar.

İşkodra'yı Karadağ, güneyini Yunanistan ister; büyük devletler 1913'te sınırlarını çizer.
> Kaynak: [[Arnavutluk]]

### Devlet · Cebel-i Şammar
`devlet: RS` · `ad: Cebel-i Şammar Emirliği (Reşidîler)` · `konum: 41.70,27.50`
Hâil merkezli, İstanbul'a bağlı Reşidî emirliği; Necd'de Suudlarla yarışır. 1902'den sonra Riyad'ı İbn Suud'a kaptırır.

Büyük Harp'te Osmanlı'nın yanında kalır: Cemal Paşa'ya göre Emir İbn Reşid 'seferin sonuna kadar Hilafet makamına kuvvetle bağlı' kaldı.
> Kaynak: [[Cemal Paşa Hatıralar (Cemal Paşa)#p. 200|Cemal Paşa, *Hatıralar*, p. 200]] · *Türk kaynağı*

### Devlet · Mısır
`devlet: MI` · `ad: Mısır Hıdivliği` · `konum: 31.24,30.04`
Kâğıt üstünde Osmanlı, 1882'den sonra fiilen İngiliz. Kavalalı Mehmed Ali Paşa'nın hanedanı özerk bir hıdivlik kurmuştur; İsmail Paşa unvanını Abdülaziz'e hediyelerle almıştır (Akyıldız).

1882'de Urabi hareketinden sonra İngiltere işgal eder; Ahmed Muhtar Paşa yirmi yılı aşkın Osmanlı fevkalade komiseri olarak Kahire'de oturur. 1914'te İngiltere hıdivi indirip himaye ilan eder.
> Kaynak: [[Mısır]] · [[British occupation of Egypt (1882)]]

### Devlet · İran
`devlet: IR` · `ad: İran` · `konum: 51.40,35.70`
Doğudaki komşu ve eski rakip. 1905'ten sonra meşrutiyet mücadelesi, 1907'de Rusya ve İngiltere'nin nüfuz bölgelerine bölünmesi. Büyük Harp'te tarafsızdır ama topraklarında Osmanlı, Rus ve İngiliz birlikleri savaşır.
> Kaynak: [[İran]]

### Devlet · Ermeniler
`devlet: ER` · `ad: Ermeni cemaati ve komiteler` · `konum: 42.60,39.20`
Bir devlet değil, bir güç: İstanbul'daki Patrikhane ve Ermeni cemaati, doğu vilayetlerinin Ermeni köyleri, Hınçak ve Taşnak komiteleri, Avrupa'daki temsilcileri. Berlin'in 61. maddesi Ermeni ıslahatını bir uluslararası mesele yapar.

1890'ların olayları, 1896 Osmanlı Bankası baskını, 1905 Yıldız bombası, 1909 Adana ve 1915 tehciri kaynaklarda tarafların birbirinden çok farklı anlattığı konulardır (Gürün, Türk tarafı; Mantran, Fransız tarafı).
> Kaynak: [[Armenian revolutionary committees]] · [[Hamidian massacres and Armenian uprisings (1894-1896)]] · [[Armenian deportation (1915)]]

### Devlet · Araplar
`devlet: AR` · `ad: Arap vilayetleri ve Hicaz` · `konum: 41.00,25.50`
Bir devlet değil, bir güç: Suriye, Irak, Hicaz ve Yemen'in şehirleri, Mekke Şerifi ve aşiretler. Abdülhamid'in İslamcı siyaseti Arap vilayetlerini İstanbul'a bağlamaya çalışır; 1908'den sonra İttihatçıların merkeziyetçiliğine tepki olarak Arap milliyetçiliği güçlenir (Murphy).

1916'da Şerif Hüseyin İngilizlerle anlaşarak isyan eder; Cemal Paşa Şam'da milliyetçileri astırır. 1918'de Faysal Şam'a girer.
> Kaynak: [[Arab Revolt (1916-1918)]] · [[Şerif Hüseyin]]

### Devlet · Kürtler
`devlet: KU` · `ad: Kürt aşiretleri` · `konum: 42.20,37.70`
Bir devlet değil, bir güç: doğu vilayetlerinin aşiret reisleri ve şeyhleri. Abdülhamid onların bir kısmını Hamidiye alaylarına alır; aşiretler kanuni dokunulmazlığı toprak kazanmak için kullanır (Emrence).

Büyük Harp'te Rus işgali doğudaki Kürt ahaliyi de göçe ve ölüme sürükler.
> Kaynak: [[Hamidiye Regiments]]

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
- `▶ olay +6ay` ile sıraya konan olay, karardan altı ay sonra açılır (olayın kendi tarihi daha geçse o tarihte). Zorunlu değilse bir yıl masada kalır.
- `yuva:` paylaşan olaylardan yalnız biri masaya gelir: tarih sırasında koşulu tutan ilki; biri cevaplanınca ötekiler düşer. Tarihî sürüm en sonda yazılır ([[GD 04 Dünya Durumu ve İplikler]]).
- **Kararlar** (`tür: karar`) masadaki evrak sayılmaz ve zamanı durdurmaz; haritadaki yerinin panelinde, tarihi ile `bitiş` arasında ve koşulu tuttukça açıktır.
- **Cepheler:** harp açıkken karara bağlanmamış her cephe her ay bir puan kayar ([[GD 05 Harita ve Harpler#Harpler ve cepheler]]).
- **Modlar:** Fantezi modunda (içeride `serbest`) her şey açıktır. Tarihî mod `alternatif` etiketli olayları ve kararları gizler; her olayda yalnız `(tarihî)` işaretli seçeneği, koşuluna bakmadan gösterir. Böylece Tarihî modun tek bir yolu vardır ve Son 3'e varır.
- **Kişi görselleri:** `görsel:` kişinin portresidir; `görseller: 1908=A.jpg · 1914=B.jpg` döneme göre değişen portrelerdir (o yıl için en son tarihli olan gösterilir). Portreler Wikimedia Commons'tandır (⚠ Not from vault sources; `game/tools/fetch_portraits.py` indirir, lisansları `Attachments/Image credits.md`'de).
- **Kişiler haritada:** `rol: figür` olan kişiler kabinede oturmaz; [[GD 05 Harita ve Harpler#Kişiler haritada]] tablosuna göre haritada görünürler.

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
`koşul: !⚑yol_ittihat & !⚑yol_ahrar`
1. **Uygula.** `Harbiye -1`

### 1883 · Goltz'un talimleri
`id: k_goltz` · `tür: kural`
`koşul: ⚑goltz_serbest & !⚑yol_ittihat & !⚑yol_ahrar`
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
`koşul: ⚑jurnal_ag & !⚑yol_ittihat & !⚑yol_ahrar`
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
`koşul: ⚑yol_ittihat | ⚑yol_ahrar`
1. **Uygula.** `Harbiye +1`

### 1914 · Harp ekonomisi
`id: k_harp` · `tür: kural`
`koşul: ⚑harpte`
1. **Uygula.** `Para -6`

### 1915 · Payitahta doğru (Harbiye çökük)
`id: k_cokus_agir` · `tür: kural`
`koşul: ⚑yol_hamid & ⚑harpte & Harbiye < 20`
1. **Uygula.** `cokus +20`

### 1915 · Payitahta doğru
`id: k_cokus` · `tür: kural`
`koşul: ⚑yol_hamid & ⚑harpte & Harbiye >= 20 & Harbiye < 35`
1. **Uygula.** `cokus +12`

### 1915 · Talim görmüş alaylar
`id: k_hamid_ordu` · `tür: kural`
`koşul: ⚑yol_hamid & ⚑harpte & Harbiye >= 35`
1. **Uygula.** `cokus -6`

### 1915 · Boğaz tutuldu
`id: k_hamid_bogaz` · `tür: kural`
`koşul: ⚑yol_hamid & ⚑hamid_bogaz_tutuldu`
1. **Uygula.** `cokus -5`

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

### 1878 · Ermeni meselesi Avrupa'yı soğutuyor
`id: k_iliski_ermeni` · `tür: kural`
`koşul: Ermeniler >= 45`
1. **Uygula.** `iliski_in -2 · iliski_fr -1 · avrupa_baskisi +1`

### 1878 · Rusya'nın gölgesi Balkan'da
`id: k_iliski_ru_balkan` · `tür: kural`
`koşul: iliski_ru < 35 & Harbiye < 45`
1. **Uygula.** `iliski_ru -1 · avrupa_baskisi +1`

### 1880 · Berlin'e yakınlık, Petersburg'un ve Londra'nın şüphesi
`id: k_iliski_alman` · `tür: kural`
`koşul: alman_nufuzu >= 30`
1. **Uygula.** `iliski_ru -2 · iliski_in -1 · iliski_fr -1 · iliski_av +1`

### 1878 · Alacaklılarla barış
`id: k_iliski_borc` · `tür: kural`
`koşul: ⚑duyun_umumiye`
1. **Uygula.** `iliski_fr +1 · iliski_in +1`

### 1882 · Mısır'da İngiliz bayrağı
`id: k_iliski_misir` · `tür: kural`
`koşul: misir = ingiliz`
1. **Uygula.** `iliski_in -1 · iliski_fr -1`

### 1897 · Girit ve Atina
`id: k_iliski_girit` · `tür: kural`
`koşul: girit = osmanli | girit = korundu`
1. **Uygula.** `iliski_yu -2`

### 1885 · Doğu Rumeli'nin gölgesi
`id: k_iliski_bulgar` · `tür: kural`
`koşul: dogu_rumeli = bulgar & !⚑bulgar_anlasma`
1. **Uygula.** `iliski_bu -1`

### 1900 · Zayıf ordu komşuları cesaretlendirir
`id: k_iliski_zayif_ordu` · `tür: kural`
`koşul: Harbiye < 35`
1. **Uygula.** `iliski_it -1 · iliski_bu -1 · iliski_yu -1`

### 1880 · Düşman başkentler Avrupa baskısını artırır
`id: k_iliski_baski_artar` · `tür: kural`
`koşul: iliski_in < 30 | iliski_fr < 30`
1. **Uygula.** `avrupa_baskisi +2`

### 1880 · Dost başkentler Avrupa baskısını hafifletir
`id: k_iliski_baski_azalir` · `tür: kural`
`koşul: iliski_in >= 65 & iliski_fr >= 60`
1. **Uygula.** `avrupa_baskisi -2`

### 1880 · Maaşlar gecikti, subay küskün
`id: k_ordu_maas` · `tür: kural`
`koşul: Para <= 10`
1. **Uygula.** `ordu_sadakati -3`

### 1880 · Jurnal ordunun güvenini kemiriyor
`id: k_ordu_jurnal` · `tür: kural`
`koşul: ⚑jurnal_ag & !⚑yol_ittihat`
1. **Uygula.** `ordu_sadakati -1`

### 1880 · Meşrutiyet ateşi saflara sızıyor
`id: k_ordu_jon_turk` · `tür: kural`
`koşul: jon_turk >= 50`
1. **Uygula.** `ordu_sadakati -2`

### 1880 · Meşrutiyet ateşi kışlada yangına dönüyor
`id: k_ordu_jon_turk_yuksek` · `tür: kural`
`koşul: jon_turk >= 75`
1. **Uygula.** `ordu_sadakati -3 · muhalefet +1`

### 1880 · İyi talim gören ordu sadık kalır
`id: k_ordu_toparlar` · `tür: kural`
`koşul: Harbiye >= 55 & jon_turk < 40`
1. **Uygula.** `ordu_sadakati +1`

### 1880 · Medresede fısıltı
`id: k_ulema_tepki` · `tür: kural`
`koşul: jon_turk >= 40`
1. **Uygula.** `ulema +2`

### 1880 · Saray baskısı muhalefeti yeraltına iter
`id: k_muhalefet_baski` · `tür: kural`
`koşul: hakimiyet >= 60`
1. **Uygula.** `muhalefet +2`

### 1880 · Gevşek yönetim muhalefeti açıkta büyütür
`id: k_muhalefet_gevsek` · `tür: kural`
`koşul: hakimiyet <= 30`
1. **Uygula.** `muhalefet +3`

### 1915 · Bulgaristan Merkez Devletleri safında
`id: k_saf_bu_ittifak` · `tür: kural` · `bitiş: 1919`
`koşul: saf_bu = ittifak`
1. **Uygula.** `iliski_bu +2 · avrupa_baskisi -1`

### 1915 · Bulgaristan tarafsız
`id: k_saf_bu_tarafsiz` · `tür: kural` · `bitiş: 1919`
`koşul: saf_bu = tarafsiz`
1. **Uygula.** `iliski_bu +1`

### 1915 · İtalya İtilaf safında
`id: k_saf_it_itilaf` · `tür: kural` · `bitiş: 1919`
`koşul: saf_it = itilaf`
1. **Uygula.** `iliski_it -3 · avrupa_baskisi +2`

### 1915 · İtalya Merkez Devletleri safında
`id: k_saf_it_ittifak` · `tür: kural` · `bitiş: 1919`
`koşul: saf_it = ittifak`
1. **Uygula.** `iliski_it +3 · avrupa_baskisi -2`

### 1915 · Romanya İtilaf safında
`id: k_saf_ro_itilaf` · `tür: kural` · `bitiş: 1919`
`koşul: saf_ro = itilaf`
1. **Uygula.** `avrupa_baskisi +1`

### 1915 · Romanya Merkez Devletleri safında
`id: k_saf_ro_ittifak` · `tür: kural` · `bitiş: 1919`
`koşul: saf_ro = ittifak`
1. **Uygula.** `avrupa_baskisi -1`

### 1915 · Yunanistan İtilaf safında
`id: k_saf_yu_itilaf` · `tür: kural` · `bitiş: 1919`
`koşul: saf_yu = itilaf`
1. **Uygula.** `iliski_yu -3`

### 1915 · Yunanistan tarafsız
`id: k_saf_yu_tarafsiz` · `tür: kural` · `bitiş: 1919`
`koşul: saf_yu = tarafsiz`
1. **Uygula.** `iliski_yu +1`

### 1878 · Harp ertelendi, kasa nefes aldı
`id: k_harp_93_onlendi` · `tür: kural` · `bitiş: 1880`
`koşul: ⚑harp_93_onlendi`
1. **Uygula.** `Para +3 · iliski_ru +1`

## Sistem olayları

### 1873 · Galata bankerleri
`id: dis_borc` · `tür: zorunlu · zincir` · `bayrak: OS`
Hazine boş. Maaş günü geldi; altı yüz bin lirayı bulmak Maliye Nazırı'na düşüyor. Avans alınacak kapılar belli: Osmanlı Bankası{eğer reji = fransiz | reji = ortak: , Tütün Rejisi}{eğer reji = milli: , Milli Tütün İdaresi'nin kasası}{eğer ⚑duyun_umumiye: , Düyun-u Umumiye}. Nazır kapı kapı dolaşıp "yalvar yakar" olacak.

[eğer: reji = milli] Tütünün kârı artık Galata'ya değil hazineye akıyor; Maliye Nazırı bu kez önce kendi kasasına bakıyor.

[eğer: misir = ingiliz] Mısır'ın vergisi yıllardır Kahire'deki İngiliz kasasında; oradan bir kuruş gelmeyecek.
💬 Maliye: "Efendimiz, faizi ağır ama başka kapı yok."
💬 Harbiye: "Askerin maaşı bir ay daha gecikirse kışlalarda ses çıkar."
> Kaynak: [[Enver (Murat Bardakçı)#p. 66|Bardakçı, *Enver*, p. 66]] · *Türk kaynağı* · [[Düyun-u Umumiye]]
1. **Avansı al.** (tarihî) `Para +20 · avrupa_baskisi +5` — Para bulundu; faizi de, alacaklıların sözü de büyüdü.
2. **Milli Tütün İdaresi'nin kasasından borç al.** [koşul: reji = milli] (ipucu: Tekel devletin elindeyse) `Para +14 · avrupa_baskisi -1` — Tütünün kârı maaşlara yetti; bu kez Galata'ya gidilmedi.
3. **Maaşları geciktir.** `Para +10 · Harbiye -5 · jon_turk +3` — Hazine nefes aldı; kışlalarda homurtu başladı.
4. **Berlin'den iste.** [koşul: alman_nufuzu >= 20] `Para +15 · alman_nufuzu +5` — Alman bankaları yardım etti; karşılığını da isteyecekler.

## Gazete manşetleri

Yıl dönümü gazetesinde (Abdülhamid devrinde *Takvim-i Vekâyi*, İttihat devrinde *Tanin*) görünen, gizli değerleri sezdiren satırlar. Bkz. [[Ottoman press]].

### 1878 · Sükûnet-i tamme
`id: m_hakimiyet` · `tür: manşet`
`koşul: hakimiyet >= 70 & !⚑yol_ittihat & !⚑yol_ahrar`
Vilayetlerden her gün aynı telgraf geliyor: "asayiş berkemal". Yıldız'a günde binlerce jurnal ulaşıyor.
> Kaynak: [[Birinci Dünya Savaşı'nda Türkiye (Ahmet Emin Yalman)#p. 56|Yalman, p. 56]] · *Türk kaynağı* · [[Mahşerin İki Gemisi - Part II (Video transcript)#loc. 10|Video, *Mahşerin İki Gemisi - Part II*, loc. 10]] · *video dökümü (ikincil)*

### 1878 · Mekteplerde fısıltı
`id: m_jon_turk` · `tür: manşet`
`koşul: jon_turk >= 50 & !⚑yol_ittihat & !⚑yol_ahrar`
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
