extends Control
## The ending: title, text, then the epilogue cards whose conditions hold (Suzerain-style, one per area).

const Logic := preload("res://game/scripts/logic.gd")
const UIKit := preload("res://game/scripts/ui/ui_kit.gd")
const GameState := preload("res://game/scripts/game_state.gd")

var state: GameState
var main: Node


func _ready() -> void:
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	var center := MarginContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for side in ["left", "right"]:
		center.add_theme_constant_override("margin_" + side, 180)
	center.add_theme_constant_override("margin_top", 40)
	center.add_theme_constant_override("margin_bottom", 40)
	scroll.add_child(center)
	var body := UIKit.vbox(14)
	center.add_child(body)
	var e: Dictionary = state.endings.get(state.ending_id, {"title": state.ending_id, "text": [], "sources": []})
	body.add_child(UIKit.label("SON", 16, UIKit.MUTED))
	body.add_child(UIKit.label(str(e["title"]), 40, UIKit.GOLD, true))
	if e.get("alternative", false):
		body.add_child(UIKit.label("Alternatif tarih", 15, UIKit.ALT))
	var img := UIKit.image(e.get("image"), 280)
	if img:
		body.add_child(img)
	for p in e["text"]:
		body.add_child(UIKit.rich(p, 19))
	body.add_child(UIKit.label(Logic.date_text(state.year, state.month), 15, UIKit.MUTED))
	for card in state.epilog_cards():
		var c := UIKit.panel(UIKit.PANEL_2)
		var v := UIKit.vbox(6)
		c.add_child(v)
		v.add_child(UIKit.label(card["title"], 20, UIKit.GOLD))
		for p in card["text"]:
			var t := Logic.txt(p, state)
			if t != "":
				v.add_child(UIKit.rich(t, 16))
		for s in card["sources"]:
			v.add_child(UIKit.rich("[color=#b5a98f]%s[/color]" % s, 12))
		body.add_child(c)
	var stats := UIKit.hbox(16)
	for id in state.resource_order:
		if state.resources[id]["visible"]:
			stats.add_child(UIKit.label("%s %d" % [state.resources[id]["name"], state.value_of(id)], 15, UIKit.MUTED))
	body.add_child(stats)
	var b := UIKit.button("Ana menü", UIKit.PANEL_2, 18)
	b.pressed.connect(func(): main.show_menu())
	body.add_child(b)
