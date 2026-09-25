# game/ · Ayastefanos Utancı metin ve görsel prototipi

Suzerain tarzı olay akışının Godot 4.7 (GDScript) iskeleti. 2.5D masa ve harita bunun üstüne oturacak.

## Kaynak tek yerde

Bütün olaylar, kişiler, devletler, sonlar ve kurallar `Lore/Game Design/GD *.md` dosyalarındadır (Obsidian'da okunur, elle düzenlenir). Oyun onları doğrudan okumaz; önce derlenir:

```bash
py game/tools/build_events.py --check
```

Bu komut:
- olayları, koşulları ve etkileri ayrıştırır;
- bayrakları (okunup hiç konmayan hata, konup hiç okunmayan uyarı), bağlantıları (`[[Kitap#p. N]]` gerçek bir sayfaya gitmeli), alıntıları (kitabın o sayfasında geçmeli) ve görselleri denetler;
- `game/data/events.json`'u yazar;
- kullanılan görselleri küçültüp `game/assets/images/`'a kopyalar, lisanslarını `CREDITS.md`'ye yazar.

`game/data/events.json` elle düzenlenmez.

## Dosyalar

| Yol | Ne yapar |
|---|---|
| `scenes/main.tscn` + `scripts/main.gd` | Kök sahne: oyun durumunu tutar, ekranları değiştirir (menü → masa → son) |
| `scripts/game_state.gd` | Bütün kurallar: kaynaklar, bayraklar, tarih, olayların açılması, seçimler, yıl dönümü (kurallar + gazete), kayıt |
| `scripts/logic.gd` | Koşul değerlendirme, maliyet etiketleri, tarih metni, görsel yükleme |
| `scripts/ui/desk.gd` | Masa: tarih, kaynak çubukları, harita ve devlet düğmeleri, masadaki evrak, cepheler, "Zamanı ilerlet" |
| `scripts/ui/event_panel.gd` | Ekranın %60'ını kaplayan olay menüsü: metin, görsel, nazır görüşleri, seçenekler (kilitli olanlar nedeniyle), sonuç, kaynakça |
| `scripts/ui/panels.gd` | Payitaht (hükümdar + üç nazır), devlet dosyası, kaynakça/sözlük, yıl sonu gazetesi |
| `scripts/ui/ending_screen.gd` | Son ekranı ve son kartları |
| `tests/sim.gd` | Başsız oynanış testi |
| `tools/build_events.py` | Derleyici ve denetleyici (Godot bu klasörü görmez: `.gdignore`) |

## Test

```bash
godot --headless --path . -s res://game/tests/sim.gd
```

Üç hazır strateji kendi sonuna ulaşmalı (Hamidiye sıkı yönetimi → Son 1, ihtiyatlı İttihat → Son 2, tarihî seçimler → Son 3). 400 rastgele oyunun hepsi bir sonla bitmeli. Test ayrıca hiçbir oyunda görülmeyen olayları listeler.
