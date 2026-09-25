---
tags: [game-design]
---
# GD 00 · Rehber

> [!warning] Bu klasör oyun tasarımıdır, lore değildir
> `Game Design/` klasöründeki dosyalar *Ayastefanos Utancı* oyununun tasarımıdır. Tarihî bilgiler kasanın kitaplarından alınır ve her biri sayfa bağlantısıyla gösterilir ([[Rules]] ve [[Handbook]] geçerlidir). Ama seçenekler, sayılar ve **Alternatif tarih** olayları tasarımdır, tarih değildir. Buradaki hiçbir şey lore notlarına kanıt olarak taşınmaz.

## Dosyalar

| Dosya | İçerik |
|---|---|
| [[GD 01 Olay Sıralaması]] | Kasadaki olayların önem sıralaması (100+ olay) ve yıllara dağılımı |
| [[GD 02 Sistemler]] | Kaynaklar, gizli değerler, Payitaht (hükümdar + 3 nazır), devletler, olay yazım kuralları, yıllık kurallar |
| [[GD 03 Sonlar ve Yollar]] | Üç son, yol ayrımları, kaldıraçlar, bayrak (flag) kaydı, akış şeması, son kartları |
| `GD 1873` … `GD 1919` | Her yılın olayları. Olay olmayan yılların dosyası yoktur |
| [[GD 99 Açık Sorular]] | İncelemen için açık bıraktığım tasarım soruları |

## Bir olay nasıl okunur

```
### 1877-07 · Plevne Kuşatması                     ← tarih · başlık
`id: plevne` · `tür: zorunlu` · `bayrak: RU` · `görsel: Grivita 1877.jpg` · `sıra: 12`
`koşul: ⚑harp_93`                                  ← olay ancak bu doğruysa çıkar
Olay metni (hükümdara hitaben).
💬 Harbiye: "Nazırın görüşü."                       ← Suzerain'deki kabine görüşleri
> Kaynak: [[Siege of Plevne (1877)]] · [[Kitap (Yazar)#p. N|Yazar, *Kitap*, p. N]] · *Türk kaynağı*
1. **Seçenek.** `Para -10 · Harbiye +5 · +⚑plevne_tutuldu` — Sonuç metni.
2. **Seçenek.** [koşul: Bahriye >= 40] `▶ baska_olay` — Sonuç metni.
```

- **Etkiler** (ters tırnak içinde, ` · ` ile ayrılır): `Para -10` kaynak değişimi · `+⚑bayrak` / `-⚑bayrak` bayrak koy/kaldır · `▶ olay_id` zincir olayı sıraya koy · `👤 persona` hükümdarı değiştir · `☠ son_id` oyunu bitir.
  - Klavyede kolay yazmak için: `+f:bayrak`, `-f:bayrak`, `>olay_id`, `@persona`, `end:son_id` da geçerlidir.
- **Koşullar:** `⚑bayrak`, `!⚑bayrak`, `Para >= 20`, `hakimiyet - jon_turk >= 20`, `yıl >= 1900`, `&` (ve), `|` (veya), parantez.
- **Tür:** `zorunlu` (cevaplanmadan zaman ilerlemez) · `isteğe bağlı` (yıl sonuna kadar açık) · `geçici` (sadece o ay) · `ara` (yalnız metin, "Devam") · `kural` (yıl dönümünde kendiliğinden işler, oyuncu görmez) · `manşet` (yıl sonu gazetesinde bir satır) · `epilog` (son kartı). Ek işaretler: `zincir` (sadece `▶` ile açılır), `alternatif` (Alternatif tarih).
- **bayrak:** olay düğmesinde görünen devlet (ör. `RU` Rusya, `OS` Osmanlı/Payitaht). Liste [[GD 02 Sistemler#Devletler]]'de.
- **sıra:** [[GD 01 Olay Sıralaması]]'ndaki sıra numarası.

## Değiştirmek istersen

Bir `GD` dosyasında olayı sil, metni değiştir, seçenek ekle ya da çıkar. Sonra proje kökünde:

```bash
py game/tools/build_events.py --check
```

Bu komut her şeyi denetler (bağlantılar, bayraklar, koşullar, görseller) ve oyunun verisini (`game/data/events.json`) yeniden üretir. Oyunu açınca değişikliği görürsün.
