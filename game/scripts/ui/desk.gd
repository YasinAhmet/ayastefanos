extends Control
## The ruler's desk: date, resources, the map with nation buttons, the pile of events, "Zamanı ilerlet".

const Logic := preload("res://game/scripts/logic.gd")
const UIKit := preload("res://game/scripts/ui/ui_kit.gd")
const GameState := preload("res://game/scripts/game_state.gd")

const EventPanel := preload("res://game/scripts/ui/event_panel.gd")
const Panels := preload("res://game/scripts/ui/panels.gd")
const FRONTS := [["kafkas", "Kafkas"], ["canakkale", "Çanakkale"], ["irak", "Irak"], ["filistin", "Filistin"], ["hicaz", "Hicaz"]]

var state: GameState
var main: Node
var panels
var date_label: Label
var persona_label: Label
var res_box: HBoxContainer
var map_layer: Control
var event_list: VBoxContainer
var front_box: VBoxContainer
var status_label: Label
var advance_btn: Button


func _ready() -> void:
	panels = Panels.new()
	panels.state = state
	panels.parent = self
	panels.on_event = func(id): _open_event(state.events[id])
	var root := UIKit.vbox(8)
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 12
	root.offset_top = 10
	root.offset_right = -12
	root.offset_bottom = -10
	add_child(root)
	root.add_child(_top_bar())
	var mid := UIKit.hbox(10)
	mid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(mid)
	mid.add_child(_map_panel())
	mid.add_child(_side_panel())
	root.add_child(_bottom_bar())
	state.changed.connect(refresh)
	refresh()


func _top_bar() -> Control:
	var p := UIKit.panel()
	var h := UIKit.hbox(14)
	p.add_child(h)
	var left := UIKit.vbox(0)
	date_label = UIKit.label("", 22, UIKit.GOLD)
	persona_label = UIKit.label("", 13, UIKit.MUTED)
	persona_label.clip_text = true
	persona_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	left.custom_minimum_size = Vector2(230, 0)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_stretch_ratio = 0.6
	left.add_child(date_label)
	left.add_child(persona_label)
	h.add_child(left)
	res_box = UIKit.hbox(10)
	res_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	res_box.alignment = BoxContainer.ALIGNMENT_CENTER
	h.add_child(res_box)
	var b_pay := UIKit.button("Payitaht", UIKit.PANEL_2, 14)
	b_pay.pressed.connect(func(): panels.payitaht())
	h.add_child(b_pay)
	var b_codex := UIKit.button("Kaynakça", UIKit.PANEL_2, 14)
	b_codex.pressed.connect(func(): panels.codex())
	h.add_child(b_codex)
	var b_save := UIKit.button("Kaydet", UIKit.PANEL_2, 14)
	b_save.pressed.connect(_save)
	h.add_child(b_save)
	var b_menu := UIKit.button("Menü", UIKit.PANEL_2, 14)
	b_menu.pressed.connect(func(): main.show_menu())
	h.add_child(b_menu)
	return p


func _save() -> void:
	state.save_game()
	status_label.text = "Kaydedildi."


func _map_panel() -> Control:
	var p := UIKit.panel(Color("211d18"))
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	p.size_flags_stretch_ratio = 2.2
	map_layer = Control.new()
	map_layer.clip_contents = true
	p.add_child(map_layer)
	var os: Dictionary = state.nations.get("OS", {})
	var tex := Logic.load_texture(os.get("image"))
	if tex:
		var t := TextureRect.new()
		t.texture = tex
		t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		t.modulate = Color(1, 1, 1, 0.45)
		t.set_anchors_preset(Control.PRESET_FULL_RECT)
		map_layer.add_child(t)
	return p


func _side_panel() -> Control:
	var p := UIKit.panel()
	p.custom_minimum_size = Vector2(380, 0)
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	p.add_child(scroll)
	var v := UIKit.vbox(8)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(v)
	v.add_child(UIKit.label("Masadaki evrak", 18, UIKit.GOLD))
	event_list = UIKit.vbox(6)
	v.add_child(event_list)
	front_box = UIKit.vbox(4)
	v.add_child(front_box)
	return p


func _bottom_bar() -> Control:
	var p := UIKit.panel()
	var h := UIKit.hbox(12)
	p.add_child(h)
	status_label = UIKit.label("", 15, UIKit.MUTED, true)
	status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(status_label)
	advance_btn = UIKit.button("Zamanı ilerlet ▸", UIKit.PANEL_2, 18)
	advance_btn.pressed.connect(_advance)
	h.add_child(advance_btn)
	return p


func refresh() -> void:
	if not is_inside_tree():
		return
	date_label.text = Logic.date_text(state.year, state.month)
	var r := state.ruler()
	persona_label.text = str(r.get("title", ""))
	persona_label.tooltip_text = persona_label.text
	UIKit.clear(res_box)
	for id in state.resource_order:
		var res: Dictionary = state.resources[id]
		if not res["visible"]:
			continue
		var cell := UIKit.vbox(2)
		cell.add_child(UIKit.label("%s %d" % [res["name"], state.value_of(id)], 13))
		cell.add_child(UIKit.bar(state.value_of(id), UIKit.GOLD if state.value_of(id) >= 25 else UIKit.RED))
		cell.tooltip_text = str(res.get("desc", ""))
		res_box.add_child(cell)
	var open := state.open_events()
	UIKit.clear(event_list)
	if open.is_empty():
		event_list.add_child(UIKit.label("Masada bekleyen evrak yok.", 14, UIKit.MUTED))
	for ev in open:
		var tag := "●  " if ev["kind"] in GameState.MANDATORY else "○  "
		var txt := "%s[%s] %s" % [tag, ev["nation"], ev["title"]]
		if ev["tags"].has("alternatif"):
			txt += "  (alternatif)"
		var b := UIKit.button(txt, UIKit.PANEL_2 if not (ev["kind"] in GameState.MANDATORY) else Color("3a2320"), 15)
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.pressed.connect(_open_event.bind(ev))
		event_list.add_child(b)
	_refresh_map(open)
	UIKit.clear(front_box)
	if state.has_flag("harpte"):
		front_box.add_child(UIKit.label("Cepheler", 16, UIKit.GOLD))
		for f in FRONTS:
			var v := state.value_of(f[0])
			var word := "sağlam" if v >= 60 else ("sarsılıyor" if v >= 30 else "çöktü")
			front_box.add_child(UIKit.label("%s: %s" % [f[1], word], 14, UIKit.GREEN if v >= 60 else (UIKit.GOLD if v >= 30 else UIKit.RED)))
	var must := state.mandatory_open().size()
	advance_btn.disabled = not state.can_advance()
	status_label.text = ("Cevap bekleyen %d zorunlu evrak var." % must) if must > 0 else "Zaman ilerletilebilir."


var _map_gen := 0


func _refresh_map(open: Array) -> void:
	_map_gen += 1
	var gen := _map_gen
	for c in map_layer.get_children():
		if c is Button:
			map_layer.remove_child(c)
			c.queue_free()
	var counts := {}
	for ev in open:
		counts[ev["nation"]] = int(counts.get(ev["nation"], 0)) + 1
	if map_layer.size.x < 10:
		await get_tree().process_frame
		if gen != _map_gen:
			return
	var size := map_layer.size
	for code in state.nations:
		var n: Dictionary = state.nations[code]
		var label := str(n.get("short", code))
		if counts.has(code):
			label += "  (%d)" % counts[code]
		var b := UIKit.button(label, Color("3a2320") if counts.has(code) else UIKit.PANEL_2, 13)
		var pos: Array = n.get("pos", [0.5, 0.5])
		b.position = Vector2(float(pos[0]) * size.x, float(pos[1]) * size.y) - Vector2(40, 14)
		b.pressed.connect(func(): panels.nation(code))
		map_layer.add_child(b)


func _open_event(ev: Dictionary) -> void:
	var p := EventPanel.new()
	p.state = state
	p.parent = self
	p.on_codex = func(entry): panels.codex(entry)
	p.on_close = func():
		if state.ending_id != "":
			main.show_ending()
		else:
			refresh()
	p.open(ev)


func _advance() -> void:
	if not state.advance():
		return
	var gz: Array = state.last_gazettes.duplicate()
	gz.reverse()  # the earliest year ends up on top
	for g in gz:
		panels.gazette(g)
	if state.ending_id != "":
		main.show_ending()
