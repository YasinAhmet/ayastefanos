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
`gündem: g_alman_ordu` · `devir: 1880-1908` · `süre: 18ay` · `önce: g_harbiye_islahat` · `dışlar: g_ingiliz_bahriye` · `tarihî` · `bayrak: AL`
`koşul: !⚑goltz_serbest`
Prusyalı Goltz'un Harbiye'de açtığı yol genişletilir: Alman müşavirler talim ve kurmaylık eğitimini üstlenir. Ordu güçlenir, ama genç subaylar Avrupa fikirleriyle de tanışır ve Berlin'in nüfuzu artar.
> Kaynak: [[Colmar von der Goltz]] · [[100. Yılında Jön Türk Devrimi (Sina Akşin)#p. 661|Akşin, *100. Yılında Jön Türk Devrimi*, p. 661]] · *Türk kaynağı*
`etki: Harbiye +6 · alman_nufuzu +6 · jon_turk +3`

### Gündem · İngiliz usulü donanma
`gündem: g_ingiliz_bahriye` · `devir: 1880-1908` · `süre: 24ay` · `önce: g_harbiye_islahat` · `dışlar: g_alman_ordu` · `bayrak: IN`
Donanmanın bakımı ve eğitimi İngiliz müşavirlere bırakılır. Haliç'te çürüyen gemiler yeniden denize çıkabilir hâle gelir; karşılığında Londra'ya borçlanılır ve ordunun reformu geri plana düşer.
> Kaynak: Alternatif tarih. [[Ottoman Navy]] · [[Enver (Murat Bardakçı)#p. 69|Bardakçı, *Enver*, p. 69]] · *Türk kaynağı*
`etki: Bahriye +8 · para -5 · avrupa_baskisi +4`
