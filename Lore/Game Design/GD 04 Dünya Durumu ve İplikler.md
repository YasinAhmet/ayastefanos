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

## İplik nasıl yazılır

1. **Başlangıç olayı** bir dünya değerini koyar (`≡ reji = milli`) ve gerekiyorsa alt olayları göreli tarihle sıraya koyar: `▶ reji_nota +4ay`, `▶ misir_tahliye +3yıl`. Gecikmeli zincir olayı, olayın kendi tarihi ile kararın üstüne eklenen süreden hangisi geç ise o zaman açılır.
2. **Alt olaylar** `zincir` türündedir; `iplik: reji` alanı onları Defter'de ve harita panelinde ipliğin altında toplar.
3. **Sonraki olaylar** sonuca tepki verir:
   - Paragraf başında `[eğer: reji = milli]` → paragraf yalnız koşul tutarsa görünür. Görüş satırında: `💬 [eğer: misir = ingiliz] Maliye: "…"`.
   - Satır içinde `{eğer reji = milli: Milli Tütün İdaresi / aksi: Reji}` → iki metinden biri.
   - `yuva: misir_1886` → aynı yuvayı paylaşan olaylardan koşulu tutan **ilki** masaya gelir; tarihî sürüm koşulsuz ve en sonda yazılır.
4. **Kararlar** (`tür: karar`, `yer: galata`): oyuncunun haritadaki bir yerden kendisinin başlattığı eylemler. Tarihi gelince ve koşulu tuttukça o yerin panelinde açık kalır, zamanı durdurmaz.
5. **Tarihî mod** `alternatif` etiketli olayları ve sonuna `(alternatif)` yazılmış seçenekleri gizler. Her olayda en az bir tarihî seçenek kalmalıdır (derleyici denetler).
