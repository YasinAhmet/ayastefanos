extends Control
## Root of the game. Owns the GameState and swaps screens: menu → desk → ending.

const UIKit := preload("res://game/scripts/ui/ui_kit.gd")
const GameState := preload("res://game/scripts/game_state.gd")

const Desk := preload("res://game/scripts/ui/desk.gd")
const EndingScreen := preload("res://game/scripts/ui/ending_screen.gd")

var state: GameState
var screen: Control


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	UIKit.load_settings()
	var bg := ColorRect.new()
	bg.color = UIKit.BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	state = GameState.new()
	state.name = "GameState"
	add_child(state)
	if not state.load_data():
		_show_error("game/data/events.json bulunamadı.\nProje kökünde çalıştırın:  py game/tools/build_events.py")
		return
	show_menu()


func _swap(c: Control) -> void:
	if screen:
		screen.queue_free()
	screen = c
	c.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(c)


func show_menu() -> void:
	var root := CenterContainer.new()
	var box := UIKit.vbox(14)
	box.custom_minimum_size = Vector2(460, 0)
	root.add_child(box)
	box.add_child(UIKit.label("Ayastefanos Utancı", 44, UIKit.GOLD))
	box.add_child(UIKit.label("1873 – 1919", 20, UIKit.MUTED))
	box.add_child(UIKit.label("Masada bir padişah, önünde bir harita, kapıda bir imparatorluğun çöküşü.", 14, UIKit.INK, true))
	var mode_opt := _option_row(box, "Oyun türü", [["Tarihî", "tarihi"], ["Fantezi", "serbest"]], 0,
			"Tarihî: her olayda yalnız tarihte olan seçenek; alternatif tarih olayları gizlenir.\nFantezi: bütün seçenekler açık; tarihten ayrılan dallar \"Alternatif tarih\" diye işaretli.")
	var pace_opt := _option_row(box, "Tempo", [["Hızlı", "hizli"], ["Ayrıntılı", "ayrintili"]], 0,
			"Hızlı: yalnız hayati ve önemli olaylar masaya gelir (GD 01'in S ve A katmanları, zincirler ve alternatif dallar); ötekiler tarihteki seçenekle kendiliğinden geçer ve yıllar çabuk akar.\nAyrıntılı: her olay masaya gelir.")
	var year_opt := _option_row(box, "Başlangıç yılı", _start_year_items(), 0,
			"1873 dışındaki yıllarda oyun, o yılın Ocak ayına kadar tarihteki seçimlerle oynanmış sayılır.")
	var b_new := UIKit.button("Yeni Oyun", UIKit.PANEL_2, 17)
	b_new.pressed.connect(func(): _start(_meta(mode_opt), false, _meta(pace_opt), int(_meta(year_opt))))
	box.add_child(b_new)
	var auto_row := UIKit.hbox(8)
	for spec in [["Otomatik: Tarihî", "tarihi"], ["Otomatik: Fantezi", "serbest"]]:
		var b := UIKit.button(spec[0], Color("2a2330"), 13)
		b.tooltip_text = "Debug: masa kendi kendine oynar; hız ve durdurma sağ alttaki çubukta (F9). Tempo ve başlangıç yılı yukarıdaki seçimlerdir."
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.pressed.connect(func(): _start(spec[1], true, _meta(pace_opt), int(_meta(year_opt))))
		auto_row.add_child(b)
	box.add_child(auto_row)
	var b_load := UIKit.button("Devam Et", UIKit.PANEL_2, 17)
	b_load.disabled = not state.has_save()
	b_load.pressed.connect(func():
		if state.load_game():
			if state.ending_id != "":
				show_ending()
			else:
				show_desk())
	box.add_child(b_load)
	var src := CheckBox.new()
	src.text = "Kaynakçaları göster"
	src.tooltip_text = "Açıkken olayların, yerlerin ve kişilerin kaynakları ve Tarihî moddaki dayanaklar tam görünür.\nKapalıyken tek satırlık bir \"ⓘ kaynak\" ipucuna iner. Son ekranındaki Alternatif tarih listesi her zaman görünür."
	src.add_theme_font_size_override("font_size", 14)
	src.button_pressed = UIKit.show_sources
	src.toggled.connect(func(on):
		UIKit.show_sources = on
		UIKit.save_settings())
	box.add_child(src)
	var b_quit := UIKit.button("Çıkış", UIKit.PANEL_2, 17)
	b_quit.pressed.connect(func(): get_tree().quit())
	box.add_child(b_quit)
	box.add_child(UIKit.label("Tarihî bilgiler Lore/ kasasındaki kitaplardan, sayfa bağlantılarıyla. \"Alternatif tarih\" etiketli olaylar ve seçenekler tasarımdır.", 11, UIKit.MUTED, true))
	_swap(root)


## A labelled dropdown row on the menu. items: [[label, value]]; the value is read back with _meta().
func _option_row(box: VBoxContainer, title: String, items: Array, selected: int, tip: String) -> OptionButton:
	var row := UIKit.hbox(10)
	var l := UIKit.label(title, 14, UIKit.INK)
	l.custom_minimum_size = Vector2(140, 0)
	row.add_child(l)
	var ob := OptionButton.new()
	ob.add_theme_font_size_override("font_size", 15)
	ob.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ob.tooltip_text = tip
	for it in items:
		ob.add_item(it[0])
		ob.set_item_metadata(ob.item_count - 1, it[1])
	ob.select(selected)
	row.add_child(ob)
	box.add_child(row)
	return ob


func _meta(ob: OptionButton):
	return ob.get_item_metadata(ob.selected)


## The start years with a short reminder of what the year is.
func _start_year_items() -> Array:
	var names := {1873: "Abdülaziz'in son yılları", 1876: "Üç padişah yılı, Kanun-ı Esasi", 1908: "İkinci Meşrutiyet",
		1913: "Balkan Harbi sonrası, Babıâli Baskını", 1914: "Büyük Harp eşiği", 1918: "Mondros'a doğru"}
	var out: Array = []
	for y in GameState.START_YEARS:
		out.append(["%d · %s" % [y, names.get(y, "")], y])
	return out


func _start(game_mode: String, auto: bool, pace := "hizli", start_year := 1873) -> void:
	state.new_game(game_mode, pace, start_year)
	show_desk(auto)


func show_desk(auto := false) -> void:
	var d := Desk.new()
	d.state = state
	d.main = self
	d.autoplay_on_start = auto
	_swap(d)


func show_ending() -> void:
	var e := EndingScreen.new()
	e.state = state
	e.main = self
	_swap(e)


func _show_error(msg: String) -> void:
	var c := CenterContainer.new()
	c.add_child(UIKit.label(msg, 18, UIKit.RED, true))
	_swap(c)
