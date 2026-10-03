---
tags: [game-design]
---
# GD 04 · Dünya Durumu ve İplikler

Oyunun yarı doğrusal yapısı: büyük düğümler (1876, 1877–78, 1908, 1914) her oyunda gelir, ama aralarındaki hikâye iplikleri oyuncunun kararlarıyla ayrılır ve **açık bir sonuçla** kapanır. Sonuç *dünya durumuna* yazılır; sonraki olaylar onu okur (metin varyantı, yuva, koşul), harita onu boyar, Defter onu gösterir. Geri: [[GD 00 Rehber]] · [[GD 02 Sistemler]] · Harita ve harpler: [[GD 05 Harita ve Harpler]].

> [!info] Tasarımdır, tarih değildir
> Buradaki anahtarlar ve değerler oyun tasarımıdır. Tarihte gerçekleşen değer her satırda **tarihî** diye işaretlidir; ötekiler *Alternatif tarih*tir.

## Dünya durumu

Her satır bir hikâye ipliğidir. `Değerler` sütunu `id: oyunda görünen ad` biçimindedir, ` · ` ile ayrılır. Etki: `≡ reji = milli` (ASCII `set:reji=milli`). Koşul: `reji = milli`, `reji != fransiz`. Derleyici burada olmayan bir anahtar ya da değeri hata sayar; konup hiçbir olayın okumadığı değeri uyarı sayar.

| id | Ad | Başlangıç | Değerler | Açıklama |
|---|---|---|---|---|
| reji | Tütün geliri | devlet | devlet: Tütün öşrünü devlet topluyor · fransiz: Reji (yabancı sermaye, şartsız) · ortak: Reji (kolcu kadrosunda denge şartıyla) · milli: Milli Tütün İdaresi | 1883 `reji` olayı açar; Galata'daki karar ve 1913'te imtiyazın bitişi değiştirebilir. Tarihî: *fransiz* ya da *ortak* (Reji kuruldu, 1913'te yenilendi). |
| misir | Mısır | hidiv | hidiv: Hıdiv idaresinde, Osmanlı'ya bağlı · ingiliz: İngiliz işgalinde · ortak: İngiliz-Osmanlı ortak denetiminde · osmanli: Osmanlı askeri Kahire'de · tahliye: İngiliz askeri çekiliyor (Drummond Wolff) | 1882 `urabi` ve `misir_isgali` açar; 1887 Drummond Wolff sözleşmesi değiştirebilir. Tarihî: *ingiliz*. |
| ayastefanos | Ayastefanos'taki pazarlık | yok | yok: Henüz masaya oturulmadı · ege: Ege kıyısı ve Makedonya için direnildi · kafkas: Kars ve Batum için direnildi · plevne: Plevne'nin hatırı masaya kondu · zaman: İngiliz donanmasının gölgesinde zaman kazanıldı | 1878 `ayastefanos_muzakere` açar; Berlin Kongresi ve 1885 Doğu Rumeli olayları okur. |
| girit | Girit | osmanli | osmanli: Osmanlı idaresinde · ozerk: Özerk (Büyük Devletlerin gözetiminde) · korundu: Teselya karşılığında Osmanlı'da kaldı · yunan: Yunanistan'a bağlandı | 1896–97 Girit ve Yunan harbi olayları açar. Tarihî: *ozerk* (1897), sonra *yunan*. |
| dogu_rumeli | Doğu Rumeli | berlin | berlin: Berlin'in çizdiği özerk vilayet · bulgar: Bulgaristan'a katıldı · osmanli: Balkan geçitlerindeki askerle Osmanlı'da tutuldu | 1885 `dogu_rumeli` açar. Tarihî: *bulgar*. |
| arap | Arap vilayetleri | merkez | merkez: İstanbul'dan, merkeziyetçi yönetiliyor · rahat: Kimi rahatlamalar: Arapça mahkeme ve mektep, yerli memur · ozerk: Arap vilayetleri özerk | 1913 `el_ahd` (İttihat) ve `ahrar_sabahaddin` (Ahrar) açar; 1914 `arap_ozerklik` özerkliğe götürebilir. `arap_isyani` ve Hicaz cephesi okur: özerk Arap vilayetlerinde 1916 isyanı çıkmaz. Tarihî: *rahat* (Mart–Nisan 1913'teki düzenlemeler; [[Kısa Türkiye Tarihi (Sina Akşin)#loc. 69\|Akşin, loc. 69]]).
| saf_bu | Büyük Harp'te Bulgaristan | tarafsiz | tarafsiz: Tarafsız · ittifak: Merkez Devletleri safında · itilaf: İtilaf safında | 1915 `bulgar_ittifak_1915` koyar. Tarihî: *ittifak* (Bulgaristan 1915 sonbaharında Merkez Devletleri safında harbe girdi; [[Osmanlı Piyadesi 1914-1918 (David Nicolle)#p. 51\|Nicolle, p. 51]]). Alternatif: ilişkiye bağlı pazarlıkla *tarafsiz*. |
| saf_it | Büyük Harp'te İtalya | tarafsiz | tarafsiz: Tarafsız · ittifak: Merkez Devletleri safında · itilaf: İtilaf safında | 1915 `londra_1915` koyar. Tarihî: *itilaf* (24 Mayıs 1915; [[Osmanlı Piyadesi 1914-1918 (David Nicolle)#p. 51\|Nicolle, p. 51]]). Alternatif: ilişki yüksekse *ittifak*. |
| saf_yu | Büyük Harp'te Yunanistan | tarafsiz | tarafsiz: Tarafsız · ittifak: Merkez Devletleri safında · itilaf: İtilaf safında | 1917 `yunan_1917` koyar. Tarihî: *itilaf* (29 Haziran 1917; [[Osmanlı Piyadesi 1914-1918 (David Nicolle)#p. 51\|Nicolle, p. 51]]). Alternatif: ilişki yüksekse *tarafsiz* kalır. |
| saf_ro | Büyük Harp'te Romanya | tarafsiz | tarafsiz: Tarafsız · ittifak: Merkez Devletleri safında · itilaf: İtilaf safında | 1916 `romanya_1916` koyar. Tarihî: *itilaf* (27 Ağustos 1916; [[Osmanlı Piyadesi 1914-1918 (David Nicolle)#p. 10\|Nicolle, p. 10]]). Alternatif: Bulgaristan ilişkisi ve Alman nüfuzu yüksekse *ittifak*. |

## İplik nasıl yazılır

1. **Başlangıç olayı** bir dünya değerini koyar (`≡ reji = milli`) ve gerekiyorsa alt olayları göreli tarihle sıraya koyar: `▶ reji_nota +4ay`, `▶ misir_tahliye +3yıl`. Gecikmeli zincir olayı, olayın kendi tarihi ile kararın üstüne eklenen süreden hangisi geç ise o zaman açılır.
2. **Alt olaylar** `zincir` türündedir; `iplik: reji` alanı onları Defter'de ve harita panelinde ipliğin altında toplar.
3. **Sonraki olaylar** sonuca tepki verir:
   - Paragraf başında `[eğer: reji = milli]` → paragraf yalnız koşul tutarsa görünür. Görüş satırında: `💬 [eğer: misir = ingiliz] Maliye: "…"`.
   - Satır içinde `{eğer reji = milli: Milli Tütün İdaresi / aksi: Reji}` → iki metinden biri.
   - `yuva: misir_1886` → aynı yuvayı paylaşan olaylardan koşulu tutan **ilki** masaya gelir; tarihî sürüm koşulsuz ve en sonda yazılır.
4. **Kararlar** (`tür: karar`, `yer: galata`): oyuncunun haritadaki bir yerden kendisinin başlattığı eylemler. Tarihi gelince ve koşulu tuttukça o yerin panelinde açık kalır, zamanı durdurmaz.
5. **Tarihî mod** `alternatif` etiketli olayları ve sonuna `(alternatif)` yazılmış seçenekleri gizler. Her olayda en az bir tarihî seçenek kalmalıdır (derleyici denetler).

## Kararlar

Haritadaki yerlerden oyuncunun kendisinin başlattığı eylemler. Olay değildir: masadaki evrak sayısına girmez, zamanı durdurmaz; o yerin panelinde koşulu tuttukça açık kalır. Reji'nin millileştirilmesi [[GD 1883]]'tedir.

### 1879 · Donanmayı Haliç'ten çıkar
`id: karar_donanma` · `tür: karar` · `bayrak: OS` · `yer: halic` · `bitiş: 1896-12`
`koşul: ⚑donanma_halicte`
Zırhlılar '93 Harbi'nden beri Haliç'te demirli; padişah bir darbeden korktuğu için donanmanın Haliç'in dışına çıkmasına izin vermiyor. Bir emirle kazanlar yakılabilir, gemiler Marmara'ya çıkabilir. Bedeli hazineden ve sarayın uykusundan ödenir.
💬 Bahriye: "Bir kez açık denize çıkarsak, gemiler de mürettebat da yeniden donanma olur."
💬 Harbiye: "Topları Yıldız'a dönük bir zırhlı Boğaz'da demirlerse, saray bir daha uyuyamaz."
> Kaynak: [[Birinci Dünya Savaşı'nda Türkiye (Ahmet Emin Yalman)#p. 56|Yalman, *Birinci Dünya Savaşı'nda Türkiye*, p. 56]] · [[Enver (Murat Bardakçı)#p. 69|Bardakçı, *Enver*, p. 69]] · *Türk kaynağı* · [[Ottoman Navy]]
> “Bu korku yüzünden orduya talim yaptırmıyor, donanmanın ise Haliç'in dışına çıkmasına izin vermiyordu.”
1. **Donanmayı Marmara'ya çıkarın.** `-⚑donanma_halicte · Para -10 · Bahriye +6 · hakimiyet -4 · jon_turk +2` — Zırhlılar dumanlarını tüttürerek Haliç'ten çıktı. Yıldız'dan dürbünle izlendi; o gece sarayın muhafız taburu iki katına çıkarıldı.

### 1880 · Büyük manevra
`id: karar_manevra` · `tür: karar` · `bayrak: OS` · `yer: harbiye_mektebi` · `bitiş: 1907-12`
`koşul: !⚑yol_ittihat & Para >= 8`
Yıllardır büyük manevra yapılmadı; gelecek vaat eden subaylar izleniyor, çünkü bir darbeye yardım edeceklerinden korkuluyor. Bir emirle Trakya'da kolordular birlikte yürüyebilir.
💬 Harbiye: "Subay savaşı kitaptan öğrenmesin, Efendimiz."
💬 Maliye: "Bir manevra bir yılın talim tahsisatını yer."
> Kaynak: [[Osmanlı Piyadesi 1914-1918 (David Nicolle)#p. 19|Nicolle, *Osmanlı Piyadesi 1914-1918*, p. 19]] · *İngiliz kaynağı* · [[Ottoman War Academy]]
1. **Trakya'da büyük manevra emredin.** `Para -6 · Harbiye +6 · jon_turk +4 · hakimiyet -3` — Kolordular ilk kez yıllar sonra birlikte yürüdü. Harbiyeli genç subaylar bir haftalığına gerçek bir ordunun içinde olduklarını hissetti; birbirlerini de tanıdılar.

### 1880 · Jurnal ağını dağıt
`id: karar_jurnal` · `tür: karar · alternatif` · `bayrak: OS` · `yer: yildiz` · `bitiş: 1907-12`
`koşul: ⚑jurnal_ag & !⚑yol_ittihat`
Yıldız'a her gün düzinelerce jurnal geliyor; kimisi saçma. Hafiye ağı sarayın gözü ama subayların, mekteplilerin ve memurların küskünlüğü de ondan doğuyor.
💬 Harbiye: "Jurnalci subay, jurnallenen subaydan çoktur artık, Efendimiz."
💬 Maliye: "Hafiye tahsisatı kalkarsa hazine nefes alır."
> Kaynak: Alternatif tarih. [[Yıldız Sarayı]] · [[Informants and spies (jurnal system)]]
1. **Hafiye tahsisatını kesin, jurnal ağını dağıtın.** `-⚑jurnal_ag · hakimiyet -8 · jon_turk -4 · Para +3` — Yıldız'ın kapısındaki kalabalık seyreldi. Saray artık vilayetleri valilerin raporlarından okuyacak; subaylar ise ilk kez birbirinden korkmadan konuşuyor.

### 1880 · İngiliz sefaretiyle yakınlaşma
`id: karar_ingiliz_yakin` · `tür: karar · alternatif` · `bayrak: IN` · `yer: babiali` · `bitiş: 1913-12`
`koşul: iliski_in < 85 & Para >= 6`
Londra'nın sefiri Babıâli'ye uğrayıp gidiyor; Mısır, Kıbrıs ve Ermeni meselesi her görüşmenin sonunda masaya geliyor. Sefaretle daha sıcak bir ilişki kurulabilir, ama Petersburg bunu hemen fark eder.
💬 Maliye: "Sefire verilecek her yemek bir imtiyaz sözü demektir, Efendimiz."
💬 Harbiye: "Donanmasız bir devletin Londra'dan başka dostu olmaz."
> Kaynak: Alternatif tarih.
1. **Sefire akşam yemeği verin, Mısır'da ve Kıbrıs'ta anlayış isteyin.** `Para -5 · iliski_in +8 · iliski_ru -2 · hakimiyet -1` — Sefir yemekten memnun ayrıldı; Londra'ya giden raporda Babıâli'nin "dost" olduğu yazıldı.
2. **Bahriye'ye bir İngiliz heyeti çağırın.** `Para -8 · Bahriye +5 · iliski_in +6 · iliski_fr -2 · alman_nufuzu -2` — İngiliz subaylar tersanelerde dolaşıyor; Fransız ve Alman sefaretleri bu heyeti not ediyor.

### 1881 · Rusya ile Boğazlar anlaşması arayışı
`id: karar_bogazlar_ru` · `tür: karar · alternatif` · `bayrak: RU` · `yer: ayastefanos` · `bitiş: 1914-06`
`koşul: iliski_ru >= 20 & Para >= 4`
Ayastefanos'ta dikilen taş bir kuşak boyunca Petersburg'un iştahını hatırlatıyor. Ama Rus sefiri gizli bir görüşme önerdi: Boğazlar'ın kapanması konusunda karşılıklı güvence verilirse, Çarlık Kafkas sınırında sakin duracak.
💬 Maliye: "Rusya'yla Boğazlar'ı konuşmak, İngiltere'ye sırt çevirmek demektir."
💬 Harbiye: "Kafkas'ta bir yıl barış için Petersburg'a söz vermeye değer."
> Kaynak: Alternatif tarih.
1. **Petersburg'a gizli bir heyet gönderin: Boğazlar'da ortak güvence arayın.** `Para -4 · iliski_ru +9 · iliski_in -5 · avrupa_baskisi +2` — Heyet Çar'ın yaverleriyle üç gün görüştü; Londra bu görüşmeyi iki hafta içinde öğrendi.
2. **Rus buğday gemilerine Boğaz'da kolaylık tanıyın.** `Para +4 · iliski_ru +5 · iliski_in -2` — Karadeniz'den gelen buğday gemileri artık bekletilmiyor; Çarlık ticaret heyeti memnun ayrıldı.

### 1880 · Paris'ten borç
`id: karar_fransa_borc` · `tür: karar · alternatif` · `bayrak: FR` · `yer: galata` · `bitiş: 1913-12`
`koşul: iliski_fr >= 30 & Para <= 25`
Galata'nın Fransız bankacıları yeni bir tahvil için masada. Faiz ağır; ama hazine boşken kapı kapı dolaşmak daha ağır.
💬 Maliye: "Fransız tahvili bir yıl nefes aldırır, on yıl bağlar."
💬 Harbiye: "Paris'ten gelen para bir de Paris'in sözünü getirir."
> Kaynak: Alternatif tarih.
1. **Paris'te tahvil çıkarın.** `Para +12 · iliski_fr +5 · avrupa_baskisi +3` — Tahvil bir haftada kapandı; Maliye Nazırı maaşları ödedi, Galata alacaklıların listesini yeniledi.
2. **Fransız bankalarına demiryolu imtiyazı karşılığı borç isteyin.** `Para +16 · iliski_fr +4 · iliski_in -2 · avrupa_baskisi +5` — Bir imtiyaz verildi, bir hat çizildi; Paris'in sefiri Babıâli'ye ilk kez teşekkür etti.

### 1900 · İtalya ile Trablus'ta pazarlık
`id: karar_italya_trablus` · `tür: karar · alternatif` · `bayrak: IT` · `yer: trablus` · `bitiş: 1911-08`
`koşul: iliski_it < 75 & Para >= 6`
Roma'nın gözü Trablusgarp'ta; İtalyan bankası ve mektebi için imtiyaz istiyor. Verilirse Roma bir süre sakin kalabilir, ama Trablus'un Arapları bunu bir ilk adım olarak okuyacak.
💬 Maliye: "Trablus'ta bir imtiyaz verirsek Roma yarın daha fazlasını ister."
💬 Harbiye: "İtalyan donanmasına karşı elimizde sözden başka bir şey yok, Efendimiz."
> Kaynak: Alternatif tarih.
1. **Roma'ya Trablus'ta ticaret ve mektep imtiyazı verin.** `Para -6 · iliski_it +10 · Araplar -2 · avrupa_baskisi -2` — İtalyan mektebi Trablus'ta açıldı; Roma'nın sefiri teşekkür notu gönderdi.
2. **İtalyan bankasına yer verin; harp çıkarmama sözü isteyin.** `Para -3 · iliski_it +6 · hakimiyet -2` — Banka şubesi Trablus'ta açıldı; söz kâğıtta kaldı, ama Roma sakin duruyor.

### 1887 · Bulgaristan ile anlaşma
`id: karar_bulgar_anlasma` · `tür: karar · alternatif` · `bayrak: BU` · `yer: filibe` · `bitiş: 1912-08`
`koşul: iliski_bu < 80 & Para >= 6`
Sofya'daki prens Berlin'in antlaşmasına rağmen kendi yolunu çiziyor. Filibe üzerinden bir murahhas, Makedonya'da Bulgar kilisesi ve mektepleri karşılığında Trakya sınırında sükûnet öneriyor.
💬 Maliye: "Bulgar komitacılar Makedonya'da sessiz kalmaz, ama bir anlaşma kâğıdı kalkan olur."
💬 Harbiye: "Sofya'ya güvenmeyelim; ama onunla konuşmayı da bırakmayalım."
> Kaynak: Alternatif tarih.
1. **Sofya'ya Makedonya'da ıslahat ve ticaret anlaşması önerin.** `Para -5 · iliski_bu +9 · iliski_yu -2 · iliski_ru -1` — Murahhas Filibe'den Sofya'ya gitti; Atina ve Petersburg ters bakışla izledi.
2. **Bulgar kilisesine Makedonya'da piskopos tayini hakkı verin.** `Para -3 · iliski_bu +5 · hakimiyet -2` — Bulgar piskoposlar Manastır'da göreve başladı; Patrikhane itiraz etti.
