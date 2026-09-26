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
		center.add_theme_constant_override("margin_" + side, 220)
	center.add_theme_constant_override("margin_top", 40)
	center.add_theme_constant_override("margin_bottom", 40)
	scroll.add_child(center)
	var body := UIKit.vbox(14)
	center.add_child(body)
	var e: Dictionary = state.endings.get(state.ending_id, {"title": state.ending_id, "text": [], "sources": []})
	body.add_child(UIKit.label("SON", 16, UIKit.MUTED))
	body.add_child(UIKit.label(str(e["title"]), 32, UIKit.GOLD, true))
	if e.get("alternative", false):
		body.add_child(UIKit.label("Alternatif tarih", 15, UIKit.ALT))
	var img := UIKit.image(e.get("image"), 280)
	if img:
		body.add_child(img)
	for p in e["text"]:
		body.add_child(UIKit.rich(p, 15))
	body.add_child(UIKit.label(Logic.date_text(state.year, state.month), 15, UIKit.MUTED))
	for card in state.epilog_cards():
		var c := UIKit.panel(UIKit.PANEL_2)
		var v := UIKit.vbox(6)
		c.add_child(v)
		v.add_child(UIKit.label(card["title"], 16, UIKit.GOLD))
		for p in card["text"]:
			var t := Logic.txt(p, state)
			if t != "":
				v.add_child(UIKit.rich(t, 13))
		for s in card["sources"]:
			v.add_child(UIKit.rich("[color=#b5a98f]%s[/color]" % s, 12))
		body.add_child(c)
	# one card per story thread: how it ended and when (the Defter, closed)
	var threads := UIKit.section("Defter")
	body.add_child(threads)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	body.add_child(grid)
	for k in state.world_order:
		var steps := state.chronicle.filter(func(c): return c["kind"] == "world" and c["key"] == k)
		if steps.is_empty():
			continue
		var c := UIKit.panel(UIKit.PANEL_2)
		c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var v := UIKit.vbox(3)
		c.add_child(v)
		v.add_child(UIKit.label(str(state.world_defs[k]["name"]), 11, UIKit.GOLD))
		v.add_child(UIKit.label(state.world_label(k), 15, UIKit.INK, true))
		var last: Dictionary = steps[-1]
		v.add_child(UIKit.label("%d · %s" % [int(last["y"]), str(last.get("by", ""))], 11, UIKit.MUTED, true))
		grid.add_child(c)
	var stats := UIKit.hbox(16)
	for id in state.resource_order:
		if state.resources[id]["visible"]:
			stats.add_child(UIKit.label("%s %d" % [state.resources[id]["name"], state.value_of(id)], 15, UIKit.MUTED))
	body.add_child(stats)
	var b := UIKit.button("Ana menü", UIKit.PANEL_2, 18)
	b.pressed.connect(func(): main.show_menu())
	body.add_child(b)
