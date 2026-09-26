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
	var b_new := UIKit.button("Yeni Oyun · Serbest", UIKit.PANEL_2, 17)
	b_new.tooltip_text = "Bütün seçenekler açık; tarihten ayrılan dallar \"Alternatif tarih\" diye işaretli."
	b_new.pressed.connect(func():
		state.new_game("serbest")
		show_desk())
	box.add_child(b_new)
	var b_hist := UIKit.button("Yeni Oyun · Tarihî", UIKit.PANEL_2, 17)
	b_hist.tooltip_text = "Yalnız tarihte masada olan seçenekler: alternatif tarih olayları ve seçenekleri gizlenir."
	b_hist.pressed.connect(func():
		state.new_game("tarihi")
		show_desk())
	box.add_child(b_hist)
	var b_load := UIKit.button("Devam Et", UIKit.PANEL_2, 17)
	b_load.disabled = not state.has_save()
	b_load.pressed.connect(func():
		if state.load_game():
			if state.ending_id != "":
				show_ending()
			else:
				show_desk())
	box.add_child(b_load)
	var b_quit := UIKit.button("Çıkış", UIKit.PANEL_2, 17)
	b_quit.pressed.connect(func(): get_tree().quit())
	box.add_child(b_quit)
	box.add_child(UIKit.label("Tarihî bilgiler Lore/ kasasındaki kitaplardan, sayfa bağlantılarıyla. \"Alternatif tarih\" etiketli olaylar ve seçenekler tasarımdır.", 11, UIKit.MUTED, true))
	_swap(root)


func show_desk() -> void:
	var d := Desk.new()
	d.state = state
	d.main = self
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
