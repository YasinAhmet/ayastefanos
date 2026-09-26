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
