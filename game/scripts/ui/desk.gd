extends Control
## The ruler's desk, laid out like a grand-strategy screen: the atlas fills the window; a thin top bar holds the
## date, the resources and the menus; the papers waiting on the desk are cards in a column on the left; the
## ruler's portrait hangs at the Babıâli and the notable people stand where they are that month; clicking a
## place, a province, a front or a person opens a small panel at the bottom left. A debug bar plays by itself.

const Logic := preload("res://game/scripts/logic.gd")
const UIKit := preload("res://game/scripts/ui/ui_kit.gd")
const GameState := preload("res://game/scripts/game_state.gd")
const MapView := preload("res://game/scripts/ui/map_view.gd")
const EventPanel := preload("res://game/scripts/ui/event_panel.gd")
const Panels := preload("res://game/scripts/ui/panels.gd")
const Autoplay := preload("res://game/scripts/autoplay.gd")

const CARDS_W := 272
const PANEL_W := 344
const PANEL_H := 330
const HEAD_H := 36
const ISTANBUL := Vector2(28.976, 41.011)   # the capital's star; İstanbul's landmarks are listed in its panel
# who stays visible when two markers overlap
const PRIO_FRONT := 60
const PRIO_SEAL := 50
const PRIO_RULER := 45
const PRIO_FIGURE := 40
const PRIO_DOT := 30
const PRIO_NATION := 25
const PRIO_NAME := 10
const GROUP_COLORS := {
	"turk": Color("bf7a5f"), "kurt": Color("b3a37f"), "arap": Color("cdb68e"), "arnavut": Color("c79a9a"),
	"bosnak": Color("a79bc4"), "rum": Color("93b7cc"), "ermeni": Color("c96f5a"), "bulgar": Color("aab96d"),
	"sirp": Color("b58c6c"), "yahudi": Color("8397b5"), "diger": Color("9d9486"),
}

var state: GameState
var main: Node
var panels
var map: MapView
var date_label: Label
var persona_label: Label
var res_box: HBoxContainer
var cards_panel: PanelContainer
var cards: VBoxContainer
var toasts: VBoxContainer
var inspector: PanelContainer
var ruler_card: PanelContainer
var inspector_title: Label
var inspector_tabs: HBoxContainer
var inspector_scroll: ScrollContainer
var inspector_body: VBoxContainer
var collapse_btn: Button
var status_label: Label
var advance_btn: Button
var _inspecting := {}          # {kind, id} of what the panel shows, refreshed with the desk
var _collapsed := false

# debug autoplay
var auto_bar: PanelContainer
var auto_play_btn: Button
var auto_speed: HSlider
var auto_speed_label: Label
var auto_policy: OptionButton
var auto_show: CheckBox
var auto_timer: Timer
var autoplay_on_start := false  # set by the menu's "Otomatik" buttons
var _auto_running := false
var _auto_rng := RandomNumberGenerator.new()
var _auto_letter: EventPanel = null
var _auto_plan := {}
var _auto_phase := ""


func _ready() -> void:
	panels = Panels.new()
	panels.state = state
	panels.parent = self
	panels.on_event = func(id): _open_event(state.events[id])
	map = MapView.new()
	map.state = state
	map.left_inset = CARDS_W + 16
	map.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(map)
	map.province_clicked.connect(func(id):
		if id == "":
			close_inspector()
		else:
			show_province(id))
	add_child(_top_bar())
	add_child(_cards_column())
	add_child(_ruler_card())
	add_child(_inspector())
	add_child(_bottom_right())
	add_child(_auto_bar())
	state.changed.connect(refresh)
	resized.connect(_layout_left)
	refresh()
	if autoplay_on_start:
		auto_bar.visible = true
		_auto_start()


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F9:
		auto_bar.visible = not auto_bar.visible
		if not auto_bar.visible:
			_auto_stop()


# ---------------------------------------------------------------- layout

func _top_bar() -> Control:
	var p := UIKit.panel()
	p.set_anchors_preset(Control.PRESET_TOP_WIDE)
	p.offset_bottom = 38
	var h := UIKit.hbox(12)
	p.add_child(h)
	var left := UIKit.vbox(-2)
	date_label = UIKit.label("", 15, UIKit.GOLD)
	persona_label = UIKit.label("", 10, UIKit.MUTED)
	persona_label.clip_text = true
	persona_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	left.custom_minimum_size = Vector2(190, 0)
	left.add_child(date_label)
	left.add_child(persona_label)
	h.add_child(left)
	res_box = UIKit.hbox(14)
	res_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	res_box.alignment = BoxContainer.ALIGNMENT_CENTER
	h.add_child(res_box)
	var chip := UIKit.label("TARİHÎ" if state.historical() else "FANTEZİ", 10, UIKit.GOLD if state.historical() else UIKit.ALT)
	chip.tooltip_text = "Tarihî mod: her olayda yalnız tarihte olan seçenek; alternatif tarih gizli." if state.historical() \
		else "Fantezi: bütün seçenekler ve alternatif tarih açık."
	chip.mouse_filter = Control.MOUSE_FILTER_PASS
	h.add_child(chip)
	for spec in [["Payitaht", func(): panels.payitaht()], ["Defter", func(): panels.defter()],
			["Kaynakça", func(): panels.codex()], ["Otomatik", func():
				auto_bar.visible = not auto_bar.visible
				if not auto_bar.visible:
					_auto_stop()], ["Kaydet", _save], ["Menü", func():
				_auto_stop()
				main.show_menu()]]:
		var b := UIKit.button(spec[0], UIKit.PANEL_2, 12)
		b.pressed.connect(spec[1])
		if spec[0] == "Otomatik":
			b.tooltip_text = "Otomatik oynatma (debug) · F9"
		h.add_child(b)
	return p


## The column of paper cards on the left, under the top bar.
func _cards_column() -> Control:
	cards_panel = UIKit.panel(Color(UIKit.PANEL, 0.94))
	cards_panel.anchor_top = 0.0
	cards_panel.anchor_bottom = 1.0
	cards_panel.offset_left = 8
	cards_panel.offset_right = 8 + CARDS_W
	cards_panel.offset_top = 46
	cards_panel.offset_bottom = -8
	var v := UIKit.vbox(6)
	cards_panel.add_child(v)
	toasts = UIKit.vbox(4)
	v.add_child(toasts)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(scroll)
	cards = UIKit.vbox(6)
	cards.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(cards)
	return cards_panel


## The selection panel at the bottom left: a header (title, collapse, close), place tabs, a scrolling body.
func _inspector() -> Control:
	inspector = UIKit.panel()
	inspector.anchor_top = 1.0
	inspector.anchor_bottom = 1.0
	inspector.offset_left = 8
	inspector.offset_right = 8 + PANEL_W
	inspector.offset_bottom = -8
	inspector.offset_top = -8 - PANEL_H
	inspector.visible = false
	var v := UIKit.vbox(4)
	inspector.add_child(v)
	var head := UIKit.hbox(4)
	inspector_title = UIKit.label("", 15, UIKit.GOLD)
	inspector_title.clip_text = true
	inspector_title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	inspector_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(inspector_title)
	collapse_btn = UIKit.button("▾", UIKit.PANEL_2, 11)
	collapse_btn.tooltip_text = "Paneli küçült / aç"
	collapse_btn.pressed.connect(func():
		_collapsed = not _collapsed
		_layout_left())
	head.add_child(collapse_btn)
	var x := UIKit.button("✕", UIKit.PANEL_2, 11)
	x.pressed.connect(close_inspector)
	head.add_child(x)
	v.add_child(head)
	inspector_tabs = UIKit.hbox(4)
	v.add_child(inspector_tabs)
	inspector_scroll = ScrollContainer.new()
	inspector_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	inspector_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(inspector_scroll)
	inspector_body = UIKit.vbox(5)
	inspector_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inspector_scroll.add_child(inspector_body)
	return inspector


## Cards above, panel below; a collapsed panel keeps only its header.
func _layout_left() -> void:
	var h := HEAD_H + 12 if _collapsed else PANEL_H
	inspector.offset_top = -8 - h
	inspector_tabs.visible = not _collapsed
	inspector_scroll.visible = not _collapsed
	collapse_btn.text = "▸" if _collapsed else "▾"
	# the column is as tall as its cards, down to the panel (or the window's bottom) at most
	var room := size.y - 46.0 - ((16.0 + h) if inspector.visible else 8.0)
	var want := cards.get_combined_minimum_size().y + toasts.get_combined_minimum_size().y + 26.0
	cards_panel.anchor_bottom = 0.0
	cards_panel.offset_bottom = 46.0 + clampf(want, 60.0, maxf(60.0, room))


func _bottom_right() -> Control:
	var p := UIKit.panel()
	p.anchor_left = 1.0
	p.anchor_right = 1.0
	p.anchor_top = 1.0
	p.anchor_bottom = 1.0
	p.offset_left = -330
	p.offset_right = -8
	p.offset_top = -56
	p.offset_bottom = -8
	var h := UIKit.hbox(8)
	p.add_child(h)
	status_label = UIKit.label("", 11, UIKit.MUTED, true)
	status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(status_label)
	advance_btn = UIKit.button("Zamanı ilerlet ▸", UIKit.PANEL_2, 14)
	advance_btn.pressed.connect(_advance)
	h.add_child(advance_btn)
	return p


func _save() -> void:
	state.save_game()
	status_label.text = "Kaydedildi."


# ---------------------------------------------------------------- refresh

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
		var v := state.value_of(id)
		var cell := UIKit.vbox(1)
		cell.add_child(UIKit.label("%s  %d" % [res["name"], v], 11, UIKit.INK if v >= 25 else Color("e0a080")))
		cell.add_child(UIKit.bar(v, UIKit.GOLD if v >= 25 else UIKit.RED, 64))
		cell.tooltip_text = str(res.get("desc", ""))
		cell.mouse_filter = Control.MOUSE_FILTER_PASS
		res_box.add_child(cell)
	var open := state.open_events()
	_refresh_cards(open)
	_layout_left.call_deferred()
	_refresh_markers(open)
	map.queue_redraw()
	if not _inspecting.is_empty():
		_reinspect()
	var must := state.mandatory_open().size()
	advance_btn.disabled = not state.can_advance() or _auto_running
	if _auto_running:
		status_label.text = "Otomatik oynatılıyor…"
	elif must > 0:
		status_label.text = "Cevap bekleyen %d zorunlu evrak var." % must
	elif not open.is_empty():
		status_label.text = "%d evrak masada. Zaman ilerletilebilir." % open.size()
	else:
		status_label.text = "Zaman ilerletilebilir."


# ---------------------------------------------------------------- paper cards (left)

func _refresh_cards(open: Array) -> void:
	UIKit.clear(cards)
	var must := open.filter(func(ev): return ev["kind"] in GameState.MANDATORY)
	cards.add_child(UIKit.section("Masadaki evrak · %d" % open.size() + (" (%d zorunlu)" % must.size() if not must.is_empty() else "")))
	if open.is_empty():
		cards.add_child(UIKit.label("Masada bekleyen evrak yok. Zamanı ilerletin.", 11, UIKit.MUTED, true))
	var sorted := must + open.filter(func(ev): return not (ev["kind"] in GameState.MANDATORY))
	for ev in sorted:
		cards.add_child(_card(ev))
	var ds := state.open_decisions()
	if not ds.is_empty():
		cards.add_child(UIKit.section("Kararlar · %d" % ds.size()))
		for d in ds:
			cards.add_child(_card(d, true))


func _card(ev: Dictionary, decision := false) -> Control:
	var card := PanelContainer.new()
	var st := StyleBoxFlat.new()
	var mandatory: bool = ev["kind"] in GameState.MANDATORY
	st.bg_color = Color("3a2a22") if mandatory else (Color("2c2a22") if decision else UIKit.PANEL_2)
	st.border_color = UIKit.nation_color(str(ev["nation"]))
	st.border_width_left = 6
	st.border_width_bottom = 1
	st.set_corner_radius_all(3)
	st.content_margin_left = 10
	st.content_margin_right = 8
	st.content_margin_top = 6
	st.content_margin_bottom = 6
	var hover := st.duplicate()
	hover.bg_color = st.bg_color.lightened(0.12)
	card.add_theme_stylebox_override("panel", st)
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var v := UIKit.vbox(2)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(v)
	var title := UIKit.label(str(ev["title"]), 13, UIKit.INK if not decision else UIKit.INK.darkened(0.15), true)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(title)
	var place := state.event_place(ev)
	var where := _place_name(place)
	var when := Logic.date_text(state.year, state.month) if decision else Logic.date_text(int(ev["date"]["y"]), int(ev["date"]["m"]))
	var meta := UIKit.label("%s · %s" % [when, where], 10, UIKit.MUTED, true)
	meta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(meta)
	var badges := UIKit.hbox(4)
	badges.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if decision:
		badges.add_child(_badge("KARAR", UIKit.GREEN.darkened(0.3)))
	elif mandatory:
		badges.add_child(_badge("ZORUNLU", UIKit.SEAL))
	else:
		badges.add_child(_badge("İSTEĞE BAĞLI", UIKit.SEAL_2))
	if ev["tags"].has("alternatif"):
		badges.add_child(_badge("ALTERNATİF", UIKit.ALT.darkened(0.25)))
	v.add_child(badges)
	var ll = _place_lonlat(place)
	card.mouse_entered.connect(func():
		card.add_theme_stylebox_override("panel", hover)
		map.pulse = ll
		map.queue_redraw())
	card.mouse_exited.connect(func():
		card.add_theme_stylebox_override("panel", st)
		map.pulse = null
		map.queue_redraw())
	card.gui_input.connect(func(e):
		if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
			map.pulse = null
			_open_event(ev))
	return card


func _badge(text: String, color: Color) -> Control:
	var p := PanelContainer.new()
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.set_corner_radius_all(2)
	s.content_margin_left = 5
	s.content_margin_right = 5
	s.content_margin_top = 0
	s.content_margin_bottom = 0
	p.add_theme_stylebox_override("panel", s)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var l := UIKit.label(text, 9, Color("f3e6c8"))
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(l)
	return p


func _place_name(place: String) -> String:
	if place.begins_with("nation:"):
		return str(state.nations.get(place.substr(7), {}).get("name", place.substr(7)))
	return str(state.landmarks.get(place, {}).get("name", place))


func _place_lonlat(place: String) -> Vector2:
	return place_anchor(place)["lonlat"]


## A short line over the cards (gazettes while the desk plays by itself).
func toast(text: String, seconds := 4.0) -> void:
	var p := UIKit.panel(Color("3b3020"))
	p.add_child(UIKit.rich(text, 11))
	toasts.add_child(p)
	while toasts.get_child_count() > 3:
		toasts.get_child(0).free()
	_layout_left.call_deferred()
	get_tree().create_timer(seconds).timeout.connect(func():
		if is_instance_valid(p):
			p.queue_free())


# ---------------------------------------------------------------- map markers

## Where a place sits on the map: a landmark's lon/lat (İstanbul's all at the capital's star) or a nation's point.
func place_anchor(place: String) -> Dictionary:
	if place.begins_with("nation:"):
		var n: Dictionary = state.nations.get(place.substr(7), {})
		var pos: Array = n.get("pos", [28.97, 41.01])
		return {"lonlat": Vector2(float(pos[0]), float(pos[1])), "px": Vector2.ZERO}
	var lm: Dictionary = state.landmarks.get(place, {})
	if lm.is_empty() or _in_istanbul(place):
		return {"lonlat": ISTANBUL, "px": Vector2.ZERO}
	var ll: Array = lm["lonlat"]
	return {"lonlat": Vector2(float(ll[0]), float(ll[1])), "px": Vector2.ZERO}


func _in_istanbul(place: String) -> bool:
	return str(state.landmarks.get(place, {}).get("province", "")) == "istanbul"


## The map key of a place: İstanbul's landmarks share the capital's star.
func _map_key(place: String) -> String:
	return "istanbul" if _in_istanbul(place) else place


func _refresh_markers(open: Array) -> void:
	map.clear_markers()
	# landmarks: a dot (stays) and a name tag (hidden first when crowded)
	for id in state.landmarks:
		var lm: Dictionary = state.landmarks[id]
		if _in_istanbul(id):
			continue
		var a := place_anchor(id)
		var b := UIKit.button(str(lm["name"]), Color(UIKit.PANEL, 0.82), 10)
		b.tooltip_text = str(lm["name"])
		b.pressed.connect(show_place.bind(id))
		# the name sits right under its dot; above or beside it when that is taken
		map.add_marker(b, a["lonlat"], Vector2(0, 14), 1.6, PRIO_NAME, id, [Vector2(0, -28), Vector2(40, -7), Vector2(-40, -7)])
		var dot := UIKit.seal("", UIKit.GOLD.darkened(0.2), 9)
		dot.pressed.connect(show_place.bind(id))
		dot.tooltip_text = str(lm["name"])
		map.add_marker(dot, a["lonlat"], Vector2.ZERO, 0.0, PRIO_DOT, id)
	# the capital: a gold star; its landmarks (Babıâli, Yıldız, Galata…) open from its panel
	map.add_marker(_capital_star(), ISTANBUL, Vector2.ZERO, 0.0, PRIO_RULER, "istanbul")
	# fronts: crossed swords at the middle of each front while its war is on
	map.highlight.clear()
	for fid in state.fronts:
		if not state.front_visible(fid):
			continue
		var f: Dictionary = state.fronts[fid]
		var ll: Array = f["lonlat"]
		map.add_marker(_front_marker(fid), Vector2(float(ll[0]), float(ll[1])), Vector2.ZERO, 0.0, PRIO_FRONT)
		if state.front_active(fid):
			for pid in f["provinces"]:
				map.highlight[pid] = Color("c0392b")
	_refresh_ruler_card()
	# papers: one seal per place, with the count
	var by_place := {}
	for ev in open:
		var p := _map_key(state.event_place(ev))
		if not by_place.has(p):
			by_place[p] = []
		by_place[p].append(ev)
	for p in by_place:
		var evs: Array = by_place[p]
		var worst: Dictionary = evs[0]
		for ev in evs:
			if ev["kind"] in GameState.MANDATORY:
				worst = ev
		var s := UIKit.seal(str(evs.size()) if evs.size() > 1 else "!", _seal_color(worst), 24)
		var titles: PackedStringArray = []
		for ev in evs:
			titles.append(str(ev["title"]))
		s.tooltip_text = "\n".join(titles)
		if evs.size() == 1:
			s.pressed.connect(_open_event.bind(evs[0]))
		elif p == "istanbul":
			s.pressed.connect(show_istanbul)
		else:
			s.pressed.connect(show_place.bind(p))
		var a := place_anchor("babiali" if p == "istanbul" else p)
		map.add_marker(s, a["lonlat"], Vector2(14, -14), 0.0, PRIO_SEAL, p)
		if p.begins_with("nation:"):
			var code: String = p.substr(7)
			var nb := UIKit.button(str(state.nations.get(code, {}).get("short", code)), Color(UIKit.PANEL, 0.82), 10)
			nb.pressed.connect(show_nation.bind(code))
			map.add_marker(nb, a["lonlat"], a["px"] + Vector2(0, 8), 0.0, PRIO_NATION, p)
	_refresh_figures()


func _seal_color(ev: Dictionary) -> Color:
	if ev["kind"] in GameState.MANDATORY:
		return UIKit.SEAL
	if ev["tags"].has("alternatif"):
		return UIKit.ALT.darkened(0.2)
	return UIKit.SEAL_2


## The notable people: small medallions where they are this month, side by side when several share a place.
func _refresh_figures() -> void:
	var by_place := {}
	for f in state.figure_places():
		var key := _map_key(str(f["place"])) if str(f["place"]) != "" else str(f["label"])
		if not by_place.has(key):
			by_place[key] = []
		by_place[key].append(f)
	for key in by_place:
		var group: Array = by_place[key]
		for i in group.size():
			var f: Dictionary = group[i]
			var ll := Vector2(float(f["lonlat"][0]), float(f["lonlat"][1]))
			var px := Vector2((i - (group.size() - 1) / 2.0) * 26.0, -22.0)
			if str(f["place"]) != "":
				ll = place_anchor(str(f["place"]))["lonlat"]
				if key == "istanbul":
					px.y = 26.0  # under the capital's star
			var alts := [Vector2(0, 44), Vector2(28, 0), Vector2(-28, 0), Vector2(0, -26), Vector2(28, 44), Vector2(-28, 44),
				Vector2(54, 0), Vector2(-54, 0)]
			map.add_marker(_figure_marker(f), ll, px, 0.0, PRIO_FIGURE, "fig:" + key, alts)


func _figure_marker(f: Dictionary) -> Control:
	var p: Dictionary = state.persons.get(str(f["person"]), {})
	var med := UIKit.medallion(state.person_image(str(f["person"])), 24, _initials(str(p.get("name", "?"))))
	med.tooltip_text = "%s\n%s" % [p.get("title", p.get("name", "")), f["label"]]
	med.mouse_filter = Control.MOUSE_FILTER_STOP
	med.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	med.gui_input.connect(func(ev):
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			show_person(str(f["person"])))
	var box := Control.new()
	box.custom_minimum_size = Vector2(24, 24)
	box.size = box.custom_minimum_size
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.name = "figure_" + str(f["person"])
	box.add_child(med)
	return box


func _front_marker(fid: String) -> Control:
	var f: Dictionary = state.fronts[fid]
	var v := state.value_of(str(f["value"]))
	var done := not state.front_result(fid).is_empty()
	var c := Control.new()
	c.custom_minimum_size = Vector2(34, 40)
	c.size = c.custom_minimum_size
	c.mouse_filter = Control.MOUSE_FILTER_STOP
	c.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	c.tooltip_text = "%s · %s\n%s" % [f["name"], f["war"], ("Sonuçlandı: " + str(state.front_result(fid)["title"])) if done else state.front_status(fid)]
	var ours := UIKit.nation_color("OS")
	var theirs := UIKit.nation_color(str(f["enemy"]))
	c.draw.connect(func():
		var ctr := Vector2(17, 15)
		c.draw_circle(ctr, 14.0, Color(UIKit.PANEL, 0.92))
		c.draw_arc(ctr, 14.0, 0, TAU, 32, UIKit.GOLD if not done else UIKit.MUTED, 1.5, true)
		var steel := Color("e9dcc0") if not done else UIKit.MUTED
		c.draw_line(ctr + Vector2(-8, -8), ctr + Vector2(8, 8), steel, 2.2, true)
		c.draw_line(ctr + Vector2(8, -8), ctr + Vector2(-8, 8), steel, 2.2, true)
		c.draw_line(ctr + Vector2(-9, -3), ctr + Vector2(-3, -9), steel, 1.5, true)
		c.draw_line(ctr + Vector2(9, -3), ctr + Vector2(3, -9), steel, 1.5, true)
		var w := 30.0
		var split := w * clampf(v / 100.0, 0.0, 1.0)
		c.draw_rect(Rect2(2, 33, split, 5), ours)
		c.draw_rect(Rect2(2 + split, 33, w - split, 5), theirs)
		c.draw_rect(Rect2(2, 33, w, 5), UIKit.BORDER, false, 1.0))
	c.gui_input.connect(func(ev):
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			show_front(fid))
	return c


## The capital's star (drawn: a five-pointed gold star with a dark rim).
func _capital_star() -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(30, 30)
	c.size = c.custom_minimum_size
	c.mouse_filter = Control.MOUSE_FILTER_STOP
	c.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	c.tooltip_text = "İstanbul · Payitaht\nBabıâli, Yıldız, Dolmabahçe, Galata, Haliç…"
	c.draw.connect(func():
		var pts := PackedVector2Array()
		for k in 10:
			var r := 14.0 if k % 2 == 0 else 6.0
			var a := -PI / 2.0 + k * PI / 5.0
			pts.append(Vector2(15, 16) + Vector2(cos(a), sin(a)) * r)
		c.draw_colored_polygon(pts, Color("e8c14a"))
		pts.append(pts[0])
		c.draw_polyline(pts, Color("5a3a12"), 1.5, true))
	c.gui_input.connect(func(ev):
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			show_istanbul())
	return c


## The ruler's card at the top right, under the bar: portrait, name, title; click for the Payitaht.
func _ruler_card() -> Control:
	ruler_card = PanelContainer.new()
	ruler_card.add_theme_stylebox_override("panel", UIKit.panel_style(Color(UIKit.PANEL, 0.94)))
	ruler_card.anchor_left = 1.0
	ruler_card.anchor_right = 1.0
	ruler_card.offset_left = -268
	ruler_card.offset_right = -8
	ruler_card.offset_top = 46
	ruler_card.mouse_filter = Control.MOUSE_FILTER_STOP
	ruler_card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	ruler_card.tooltip_text = "Payitaht: hükümdar ve nazırlar"
	ruler_card.gui_input.connect(func(ev):
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			panels.payitaht())
	return ruler_card


func _refresh_ruler_card() -> void:
	UIKit.clear(ruler_card)
	var r := state.ruler()
	var h := UIKit.hbox(10)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ruler_card.add_child(h)
	var med := UIKit.medallion(state.person_image(str(state.persona)), 60, _initials(str(r.get("name", ""))))
	med.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(med)
	var v := UIKit.vbox(1)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(v)
	for spec in [[str(r.get("name", "")), 14, UIKit.GOLD], [str(r.get("title", "")), 10, UIKit.MUTED], ["Payitaht ▸", 10, UIKit.INK]]:
		var l := UIKit.label(spec[0], spec[1], spec[2], true)
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		v.add_child(l)


func _initials(name: String) -> String:
	var words := name.replace("Sultan ", "").split(" ", false)
	return words[0].substr(0, 1) if not words.is_empty() else "?"


func _tight(c: Color) -> StyleBoxFlat:
	var s := UIKit.panel_style(c)
	s.content_margin_top = 1
	s.content_margin_bottom = 1
	s.content_margin_left = 5
	s.content_margin_right = 5
	s.shadow_size = 0
	return s


# ---------------------------------------------------------------- selection panel (bottom left)

func close_inspector() -> void:
	_inspecting = {}
	inspector.visible = false
	map.selected = ""
	map.queue_redraw()
	_layout_left()


## Open the panel for {kind, id}; `tabs` are [label, Callable] quick switches (a place and its province).
func _begin(kind: String, id: String, title: String, subtitle := "", tabs: Array = []) -> VBoxContainer:
	var same: bool = _inspecting.get("kind", "") == kind and _inspecting.get("id", "") == id
	_inspecting = {"kind": kind, "id": id}
	if kind != "province" and map.selected != "":
		map.selected = ""
		map.queue_redraw()
	inspector.visible = true
	if not same:
		_collapsed = false
	_layout_left()
	inspector_title.text = title
	inspector_title.tooltip_text = title
	UIKit.clear(inspector_tabs)
	for t in tabs:
		var b := UIKit.button(str(t[0]), UIKit.PANEL_2 if not t[2] else Color("5a4632"), 10)
		if t[2]:
			b.add_theme_color_override("font_color", UIKit.GOLD)  # the tab being shown
		b.pressed.connect(t[1])
		inspector_tabs.add_child(b)
	UIKit.clear(inspector_body)
	if not same:
		inspector_scroll.scroll_vertical = 0
	if subtitle != "":
		inspector_body.add_child(UIKit.label(subtitle, 11, UIKit.MUTED, true))
	return inspector_body


func _reinspect() -> void:
	match _inspecting.get("kind", ""):
		"place": show_place(_inspecting["id"])
		"province": show_province(_inspecting["id"])
		"nation": show_nation(_inspecting["id"])
		"front": show_front(_inspecting["id"])
		"person": show_person(_inspecting["id"])
		"istanbul": show_istanbul()


func _place_tabs(place: String, prov: String, on_place: bool) -> Array:
	if prov == "":
		return []
	if prov == "istanbul":
		return [["İstanbul", show_istanbul, false], ["Yer", show_place.bind(place), on_place],
			["İl ve nüfus", show_province.bind(prov), not on_place]]
	return [["Yer", show_place.bind(place), on_place],
		["İl ve nüfus: " + str(state.provinces.get(prov, {}).get("name", prov)).split(" (")[0], show_province.bind(prov), not on_place]]


## The capital: its landmarks as buttons, the papers and the people there.
func show_istanbul() -> void:
	var body := _begin("istanbul", "istanbul", "İstanbul", "Dersaadet · Payitaht", [["İstanbul", show_istanbul, true],
		["İl ve nüfus", show_province.bind("istanbul"), false]])
	var grid := GridContainer.new()
	grid.columns = 2
	body.add_child(grid)
	for lid in state.landmarks:
		if not _in_istanbul(lid):
			continue
		var n := state.open_events().filter(func(ev): return state.event_place(ev) == lid).size()
		var b := UIKit.button(str(state.landmarks[lid]["name"]) + ("  (%d)" % n if n > 0 else ""),
			Color("4a2620") if n > 0 else UIKit.PANEL_2, 11)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.pressed.connect(show_place.bind(lid))
		grid.add_child(b)
	for lid in state.landmarks:
		if _in_istanbul(lid):
			_papers_section(body, lid)
			_people_section(body, lid)


func show_place(id: String) -> void:
	if id.begins_with("nation:"):
		show_nation(id.substr(7))
		return
	var lm: Dictionary = state.landmarks.get(id, {})
	var prov := str(lm.get("province", ""))
	var sub := str(state.provinces.get(prov, {}).get("name", ""))
	if prov != "":
		sub += " · " + _holder_text(prov)
	var body := _begin("place", id, str(lm.get("name", id)), sub, _place_tabs(id, prov, true))
	if id == "babiali":
		var r := state.ruler()
		var row := UIKit.hbox(8)
		row.add_child(UIKit.medallion(state.person_image(str(state.persona)), 52, _initials(str(r.get("name", "")))))
		var col := UIKit.vbox(2)
		col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		col.add_child(UIKit.label(str(r.get("title", "")), 12, UIKit.INK, true))
		var b := UIKit.button("Payitaht: hükümdar ve nazırlar", UIKit.PANEL_2, 11)
		b.pressed.connect(func(): panels.payitaht())
		col.add_child(b)
		row.add_child(col)
		body.add_child(row)
	_papers_section(body, id)
	_decisions_section(body, id)
	_people_section(body, id)
	var img := UIKit.image(lm.get("image"), 90)
	if img:
		body.add_child(img)
	if str(lm.get("text", "")) != "":
		body.add_child(panels._linked(lm["text"], 12))
	_threads_section(body, id)
	_history_section(body, func(h): return str(h.get("place", "")) == id)
	UIKit.add_sources(body, lm.get("sources", []), panels._linked)


func show_province(id: String) -> void:
	map.selected = id
	map.queue_redraw()
	var p: Dictionary = state.provinces.get(id, {})
	var places: Array = []
	for lid in state.landmarks:
		if str(state.landmarks[lid].get("province", "")) == id:
			places.append(lid)
	var tabs: Array = []
	if not places.is_empty():
		tabs = _place_tabs(places[0], id, false)
	var body := _begin("province", id, str(p.get("name", id)), "", tabs)
	var holder := state.province_holder(id, "ctl")
	var chip := UIKit.hbox(6)
	var sw := ColorRect.new()
	sw.color = UIKit.nation_color(holder)
	sw.custom_minimum_size = Vector2(14, 14)
	chip.add_child(sw)
	var nb := UIKit.button(_holder_text(id), UIKit.PANEL_2, 11)
	nb.pressed.connect(show_nation.bind(holder))
	chip.add_child(nb)
	body.add_child(chip)
	_population_section(body, id)
	for lid in places:
		_papers_section(body, lid)
	if places.size() > 1:
		body.add_child(UIKit.section("Yerler"))
		for lid in places:
			var b := UIKit.button(str(state.landmarks[lid]["name"]), UIKit.PANEL_2, 11)
			b.alignment = HORIZONTAL_ALIGNMENT_LEFT
			b.pressed.connect(show_place.bind(lid))
			body.add_child(b)
	var changes := state.chronicle.filter(func(c): return c["kind"] == "prov" and c["key"] == id)
	if not changes.is_empty():
		body.add_child(UIKit.section("Toprak defteri"))
		for c in changes.slice(-5):
			body.add_child(UIKit.rich("[color=#ab9d82]%s[/color] · %s%s" % [
				Logic.date_text(int(c["y"]), int(c["m"])), state.province_change_text(c),
				("  [i](%s)[/i]" % c["by"]) if str(c.get("by", "")) != "" else ""], 11))


## Who lives in the province (estimates, thousands): a bar per group with its size, strength and condition.
func _population_section(body: VBoxContainer, id: String) -> void:
	var groups := state.province_groups(id)
	if groups.is_empty():
		body.add_child(UIKit.label("Bu il için nüfus tutulmuyor.", 10, UIKit.MUTED, true))
		return
	var total := state.province_pop(id)
	var start := 0.0
	for g in groups:
		start += float(g["start"])
	body.add_child(UIKit.section("Nüfus (tahminî)"))
	body.add_child(UIKit.label("%s bin · 1873'te %s bin" % [_thousands(total), _thousands(start)], 11, UIKit.INK))
	for g in groups:
		g["dead"] = state.deaths_of(str(g["id"]), id)
		body.add_child(_group_row(g, total))
	UIKit.add_sources(body, ["Rakamlar tahminîdir: 1881/82 Osmanlı sayımı özetlerinden (⚠ kasa dışı) ve kasadaki tartışmalardan; bkz. GD 05 Nüfus."], panels._linked, 9)


func _group_row(g: Dictionary, total: float) -> Control:
	var v := UIKit.vbox(0)
	var h := UIKit.hbox(6)
	var name := UIKit.label(str(g["name"]).split(" (")[0], 11, UIKit.INK)
	name.custom_minimum_size = Vector2(96, 0)
	name.clip_text = true
	h.add_child(name)
	var share := float(g["n"]) / total if total > 0.0 else 0.0
	var col: Color = GROUP_COLORS.get(g["id"], UIKit.GOLD)
	var bar := Control.new()
	bar.custom_minimum_size = Vector2(110, 10)
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var ratio := clampf(float(g["ratio"]), 0.0, 1.0)
	bar.draw.connect(func():
		var w := bar.size.x
		bar.draw_rect(Rect2(0, 0, w, 10), Color(0, 0, 0, 0.3))
		bar.draw_rect(Rect2(0, 0, w * share, 10), col)
		if float(g["start"]) > 0.0 and ratio < 1.0:
			# what was lost since 1873, as a faded tail
			var lost := w * share * (1.0 / maxf(ratio, 0.05) - 1.0)
			bar.draw_rect(Rect2(w * share, 0, minf(lost, w - w * share), 10), Color(col, 0.25))
		bar.draw_rect(Rect2(0, 0, w, 10), UIKit.BORDER, false, 1.0))
	h.add_child(bar)
	var n := UIKit.label("%s bin" % _thousands(float(g["n"])), 11, UIKit.INK)
	n.custom_minimum_size = Vector2(62, 0)
	n.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	h.add_child(n)
	v.add_child(h)
	var status := str(g["status"])
	var bad := status in ["yok edildi", "sürüldü", "azalıyor", "baskı altında", "ayaklandı"]
	var bits: PackedStringArray = [status]
	if int(g["power"]) >= 0:
		bits.append("güç %d" % int(g["power"]))
	if float(g["start"]) > 0.0 and absf(float(g["ratio"]) - 1.0) > 0.02:
		bits.append("1873'e göre %%%d" % int(round(float(g["ratio"]) * 100.0)))
	var dead := float(g.get("dead", 0.0))
	if dead >= 0.5:
		bits.append("~%s bin ölü" % _thousands(dead))
	var s := UIKit.label("   " + " · ".join(bits), 9, Color("e0a080") if bad else UIKit.MUTED)
	v.add_child(s)
	v.tooltip_text = "%s: %s bin (1873: %s bin)" % [g["name"], _thousands(float(g["n"])), _thousands(float(g["start"]))]
	v.mouse_filter = Control.MOUSE_FILTER_PASS
	return v


func _thousands(n: float) -> String:
	var s := str(int(round(n)))
	var out := ""
	while s.length() > 3:
		out = "." + s.substr(s.length() - 3) + out
		s = s.substr(0, s.length() - 3)
	return s + out


func show_nation(code: String) -> void:
	var n: Dictionary = state.nations.get(code, {})
	var body := _begin("nation", code, str(n.get("name", code)))
	if code == "OS":
		body.add_child(UIKit.section("İmparatorluğun nüfusu (tahminî)"))
		var total := 0.0
		var rows: Array = []
		for g in state.pop_order:
			# compared within today's borders: lost provinces do not count as a people's loss
			var now := state.group_total(g)
			total += now
			var then := state.group_total(g, false, true)
			if now >= 0.5 or then >= 0.5:
				var ratio := now / then if then > 0.0 else 1.0
				rows.append({"id": g, "name": state.pop_groups[g]["name"], "n": now, "start": then,
					"ratio": ratio, "status": state.group_status(g, ratio), "power": state.group_power(g)})
		rows.sort_custom(func(a, b): return a["n"] > b["n"])
		body.add_child(UIKit.label("Devletin bugünkü illerinde %s bin; oranlar aynı illerin 1873'üne göre." % _thousands(total), 11, UIKit.INK, true))
		for r in rows:
			r["dead"] = state.deaths_of(str(r["id"]))
			body.add_child(_group_row(r, total))
		_deaths_section(body)
	if str(n.get("text", "")) != "":
		body.add_child(panels._linked(n["text"], 12))
	var held: PackedStringArray = []
	for pid in state.provinces:
		if state.province_holder(pid, "ctl") == code and state.provinces[pid]["region"] != "Komşular":
			held.append(str(state.provinces[pid]["name"]))
	if not held.is_empty():
		body.add_child(UIKit.section("Elindeki topraklar"))
		body.add_child(UIKit.label(", ".join(held), 11, UIKit.INK, true))
	_papers_section(body, "nation:" + code, func(ev): return str(ev["nation"]) == code)
	_history_section(body, func(h): return str(h["nation"]) == code)


## The Kayıplar card: the dead (†) of every group so far, and the events that killed most.
func _deaths_section(body: VBoxContainer) -> void:
	if state.deaths.is_empty():
		return
	body.add_child(UIKit.section("Kayıplar (ölü, tahminî)"))
	for g in state.pop_order:
		var n: float = state.deaths_of(g)
		if n < 0.5:
			continue
		var per: Dictionary = state.deaths_of(g, "", true)
		var keys := per.keys()
		keys.sort_custom(func(a, b): return per[a] > per[b])
		var parts: PackedStringArray = []
		for k in keys.slice(0, 3):
			parts.append("%s: %s bin" % [k, _thousands(per[k])])
		body.add_child(UIKit.rich("[b]%s[/b] ~%s bin  [color=#ab9d82]%s[/color]" % [state.pop_groups[g]["name"],
			_thousands(n), " · ".join(parts)], 11))
	body.add_child(UIKit.label("En yüksek tahminler; tartışmalıdır (GD 05 Nüfus).", 9, UIKit.MUTED, true))


## A notable person: portrait, where they are now and on what authority, their card text.
func show_person(pid: String) -> void:
	var p: Dictionary = state.persons.get(pid, {})
	var body := _begin("person", pid, str(p.get("name", pid)), str(p.get("title", "")))
	var row := UIKit.hbox(8)
	row.add_child(UIKit.medallion(state.person_image(pid), 64, _initials(str(p.get("name", "?")))))
	var col := UIKit.vbox(2)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var here: Dictionary = {}
	for f in state.figure_places():
		if str(f["person"]) == pid:
			here = f
	if here.is_empty():
		col.add_child(UIKit.label("Bu ay haritada değil.", 11, UIKit.MUTED, true))
	else:
		col.add_child(UIKit.label("Şimdi: " + str(here["label"]), 12, UIKit.GOLD, true))
		UIKit.add_sources(col, ["Dayanak: " + str(here["source"])], panels._linked)
		if str(here["place"]) != "":
			var b := UIKit.button("Yeri aç", UIKit.PANEL_2, 10)
			b.pressed.connect(show_place.bind(str(here["place"])))
			col.add_child(b)
	row.add_child(col)
	body.add_child(row)
	if str(p.get("text", "")) != "":
		body.add_child(panels._linked(p["text"], 12))
	UIKit.add_sources(body, p.get("sources", []), panels._linked)


## The front panel: the balance of power, who is winning, what moved it and how the front ended.
func show_front(fid: String) -> void:
	var f: Dictionary = state.fronts[fid]
	var enemy := _nation_name(str(f["enemy"]))
	var body := _begin("front", fid, str(f["name"]), "%s · Devlet-i Aliyye ile %s" % [f["war"], enemy])
	var v := state.value_of(str(f["value"]))
	var row := UIKit.hbox(6)
	row.add_child(UIKit.label("Osmanlı", 10, UIKit.INK))
	var bal := UIKit.balance(v, UIKit.nation_color("OS"), UIKit.nation_color(str(f["enemy"])), 200)
	bal.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(bal)
	row.add_child(UIKit.label(enemy.split(" ")[0], 10, UIKit.INK))
	body.add_child(row)
	var res := state.front_result(fid)
	if res.is_empty():
		body.add_child(UIKit.label("%s  (%d / 100)" % [state.front_status(fid), v], 13, UIKit.GOLD))
		body.add_child(UIKit.label("Her ay denge, ordunun gücüne göre bir puan kayar. %d ve üstü üstünlük, %d ve altı bozgun sayılır; cephe kendi sonuç olayıyla karara bağlanır." % [int(f["win"]), int(f["lose"])], 10, UIKit.MUTED, true))
	else:
		body.add_child(UIKit.section("Sonuç"))
		body.add_child(UIKit.rich("[b]%s[/b] (%s) — %s" % [res["title"], Logic.date_text(int(res["y"]), int(res["m"])), EventPanel._plain(str(res["option"]))], 12))
		if str(res.get("outcome", "")) != "":
			body.add_child(UIKit.rich("[i]%s[/i]" % res["outcome"], 11))
	var log: Array = state.front_log.get(fid, [])
	if not log.is_empty():
		body.add_child(UIKit.section("Dengeyi değiştirenler"))
		var rows := log.duplicate()
		rows.reverse()
		for e in rows.slice(0, 6):
			var d := int(e["d"])
			var col := "#8fbf6f" if d > 0 else "#e08070"
			body.add_child(UIKit.rich("[color=%s]%s%d[/color]  %s [color=#ab9d82](%s)[/color]" % [col, "+" if d > 0 else "−", absi(d),
				e["by"], Logic.date_text(int(e["y"]), int(e["m"])) if e["by"] != GameState.DRIFT_BY else str(e["y"])], 11))
		if rows.size() > 6:
			body.add_child(UIKit.label("… ve %d kayıt daha" % (rows.size() - 6), 10, UIKit.MUTED))
	var names: PackedStringArray = []
	for pid in f["provinces"]:
		names.append("%s (%s)" % [state.provinces.get(pid, {}).get("name", pid), _holder_text(pid)])
	if not names.is_empty():
		body.add_child(UIKit.section("Çekişilen iller"))
		body.add_child(UIKit.label("\n".join(names), 11, UIKit.INK, true))
	if str(f.get("text", "")) != "":
		body.add_child(panels._linked(f["text"], 12))
	UIKit.add_sources(body, f.get("sources", []), panels._linked)


func _holder_text(prov: String) -> String:
	var ctl := state.province_holder(prov, "ctl")
	var own := state.province_holder(prov, "own")
	if ctl == own:
		return _nation_name(ctl)
	return "%s işgalinde · hukuken %s" % [_nation_name(ctl), _nation_name(own)]


func _nation_name(code: String) -> String:
	return str(state.nations.get(code, {}).get("name", code))


func _papers_section(body: VBoxContainer, place: String, extra := Callable()) -> void:
	var evs := state.open_events().filter(func(ev):
		return state.event_place(ev) == place or (extra.is_valid() and extra.call(ev)))
	if evs.is_empty():
		return
	body.add_child(UIKit.section("Masadaki evrak"))
	for ev in evs:
		var b := UIKit.button(("● " if ev["kind"] in GameState.MANDATORY else "○ ") + str(ev["title"]),
			Color("4a2620") if ev["kind"] in GameState.MANDATORY else UIKit.PANEL_2, 11)
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.pressed.connect(_open_event.bind(ev))
		body.add_child(b)


func _decisions_section(body: VBoxContainer, place: String) -> void:
	var ds := state.open_decisions(place)
	if ds.is_empty():
		return
	body.add_child(UIKit.section("Kararlar"))
	for d in ds:
		var b := UIKit.button("◆ " + str(d["title"]), Color("2f3a2a"), 11)
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if d["tags"].has("alternatif"):
			b.tooltip_text = "Alternatif tarih"
		b.pressed.connect(_open_event.bind(d))
		body.add_child(b)


func _people_section(body: VBoxContainer, place: String) -> void:
	var here := state.figure_places().filter(func(f): return str(f["place"]) == place)
	if here.is_empty():
		return
	body.add_child(UIKit.section("Burada"))
	for f in here:
		var p: Dictionary = state.persons.get(str(f["person"]), {})
		var b := UIKit.button(str(p.get("title", f["person"])), UIKit.PANEL_2, 11)
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.pressed.connect(show_person.bind(str(f["person"])))
		body.add_child(b)


## The story threads that pass through this place: their current outcome and how they got there.
func _threads_section(body: VBoxContainer, place: String) -> void:
	var keys := {}
	for ev in state.events.values():
		if str(ev.get("place", "")) == place and ev.get("thread") != null and state.world_defs.has(ev["thread"]):
			keys[ev["thread"]] = true
	if keys.is_empty():
		return
	body.add_child(UIKit.section("İplikler"))
	for k in keys:
		body.add_child(UIKit.rich("[b]%s:[/b] %s" % [state.world_defs[k]["name"], state.world_label(k)], 12))
		for c in state.chronicle:
			if c["kind"] == "world" and c["key"] == k:
				body.add_child(UIKit.rich("   [color=#ab9d82]%d[/color] · %s" % [int(c["y"]), state.world_label(k, str(c["to"]))], 11))


func _history_section(body: VBoxContainer, pred: Callable) -> void:
	var past := state.history.filter(pred)
	if past.is_empty():
		return
	body.add_child(UIKit.section("Geçmiş"))
	for h in past.slice(-5):
		body.add_child(UIKit.rich("[color=#ab9d82]%s[/color] · [b]%s[/b] — %s" % [Logic.date_text(int(h["y"]), int(h["m"])),
			h["title"], EventPanel._plain(h["option"])], 11))
	if past.size() > 5:
		var b := UIKit.button("Defter'de hepsi (%d)" % past.size(), UIKit.PANEL, 10)
		b.pressed.connect(func(): panels.defter())
		body.add_child(b)


# ---------------------------------------------------------------- actions

func _open_event(ev: Dictionary) -> EventPanel:
	var p := EventPanel.new()
	p.state = state
	p.parent = self
	p.on_codex = func(entry): panels.codex(entry)
	p.on_close = func():
		if state.ending_id != "":
			_auto_stop()
			main.show_ending()
		else:
			refresh()
	p.open(ev)
	return p


func _advance() -> void:
	if not state.advance():
		return
	_show_gazettes()
	if state.ending_id != "":
		main.show_ending()


func _show_gazettes() -> void:
	var gz: Array = state.last_gazettes.duplicate()
	if _auto_running:
		for g in gz:
			toast("[b]%s[/b] · %d senesi: %d karar" % [g["paper"], int(g["year"]), g["decisions"].size()], 3.0)
		return
	gz.reverse()  # the earliest year ends up on top
	for g in gz:
		panels.gazette(g)


# ---------------------------------------------------------------- debug autoplay

## The autoplay bar (F9 or "Otomatik"): play / pause / stop, speed in seconds per step, policy, show the letters.
func _auto_bar() -> Control:
	auto_bar = UIKit.panel(Color("2a2330"))
	auto_bar.anchor_left = 1.0
	auto_bar.anchor_right = 1.0
	auto_bar.anchor_top = 1.0
	auto_bar.anchor_bottom = 1.0
	auto_bar.offset_left = -330
	auto_bar.offset_right = -8
	auto_bar.offset_top = -152
	auto_bar.offset_bottom = -64
	auto_bar.visible = false
	var v := UIKit.vbox(4)
	auto_bar.add_child(v)
	var h := UIKit.hbox(6)
	v.add_child(h)
	h.add_child(UIKit.label("OTOMATİK (debug)", 10, UIKit.ALT))
	auto_play_btn = UIKit.button("▶", UIKit.PANEL_2, 13)
	auto_play_btn.tooltip_text = "Oynat / duraklat"
	auto_play_btn.pressed.connect(func():
		if _auto_running:
			_auto_stop()
		else:
			_auto_start())
	h.add_child(auto_play_btn)
	var stop := UIKit.button("■", UIKit.PANEL_2, 13)
	stop.tooltip_text = "Durdur ve çubuğu kapat"
	stop.pressed.connect(func():
		_auto_stop()
		auto_bar.visible = false)
	h.add_child(stop)
	auto_policy = OptionButton.new()
	auto_policy.add_theme_font_size_override("font_size", 11)
	for pol in Autoplay.POLICIES:
		if state.historical() and pol != "tarihi":
			continue
		auto_policy.add_item(Autoplay.POLICY_NAMES[pol])
		auto_policy.set_item_metadata(auto_policy.item_count - 1, pol)
	if not state.historical():
		auto_policy.select(1)
	auto_policy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(auto_policy)
	var h2 := UIKit.hbox(6)
	v.add_child(h2)
	h2.add_child(UIKit.label("Hız", 10, UIKit.MUTED))
	auto_speed = HSlider.new()
	auto_speed.min_value = 0.05
	auto_speed.max_value = 2.0
	auto_speed.step = 0.05
	auto_speed.value = 0.4
	auto_speed.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	auto_speed.custom_minimum_size = Vector2(110, 16)
	h2.add_child(auto_speed)
	auto_speed_label = UIKit.label("", 10, UIKit.INK)
	auto_speed_label.custom_minimum_size = Vector2(62, 0)
	h2.add_child(auto_speed_label)
	auto_show = CheckBox.new()
	auto_show.text = "Olayları göster"
	auto_show.add_theme_font_size_override("font_size", 10)
	h2.add_child(auto_show)
	auto_speed.value_changed.connect(func(x):
		auto_speed_label.text = "%.2f sn/adım" % x
		auto_timer.wait_time = x)
	auto_timer = Timer.new()
	auto_timer.one_shot = false
	auto_timer.wait_time = auto_speed.value
	auto_timer.timeout.connect(_auto_tick)
	add_child(auto_timer)
	auto_speed_label.text = "%.2f sn/adım" % auto_speed.value
	_auto_rng.randomize()
	return auto_bar


func _auto_policy() -> String:
	return str(auto_policy.get_item_metadata(auto_policy.selected)) if auto_policy.selected >= 0 else "tarihi"


func _auto_start() -> void:
	if state.ending_id != "":
		return
	_auto_running = true
	auto_play_btn.text = "❚❚"
	auto_timer.start(auto_speed.value)
	refresh()


func _auto_stop() -> void:
	if not _auto_running:
		return
	_auto_running = false
	auto_play_btn.text = "▶"
	auto_timer.stop()
	_auto_phase = ""
	refresh()


func is_autoplaying() -> bool:
	return _auto_running


## One tick: with "Olayları göster" a letter is opened, then answered, then closed on the next ticks;
## without it every tick is one choice or one month.
func _auto_tick() -> void:
	if not _auto_running:
		return
	if _auto_phase == "shown" and _auto_letter != null:
		_auto_letter.auto_choose(int(_auto_plan["option"]))
		_auto_phase = "chosen"
		return
	if _auto_phase == "chosen" and _auto_letter != null:
		if _auto_letter.is_open():
			_auto_letter.m["layer"].queue_free()
		_auto_letter = null
		_auto_phase = ""
		_auto_after_step()
		return
	var p := Autoplay.plan(state, _auto_policy(), _auto_rng)
	match p["kind"]:
		"end":
			_auto_stop()
			main.show_ending()
			return
		"stuck":
			_auto_stop()
			status_label.text = "Otomatik oynatma takıldı: %s" % str(p.get("ev", {}).get("title", "zaman ilerlemiyor"))
			return
		"choose", "decision":
			if auto_show.button_pressed:
				_auto_plan = p
				_auto_letter = _open_event(p["ev"])
				_auto_letter.on_close = func(): pass
				_auto_phase = "shown"
				return
	var done := Autoplay.perform(state, p)
	if done["kind"] == "stuck":
		_auto_stop()
		status_label.text = "Otomatik oynatma takıldı."
		return
	if done["kind"] == "advance":
		_show_gazettes()
	elif not auto_show.button_pressed:
		toast("[color=#ab9d82]%s[/color] %s → %s" % [Logic.date_text(state.year, state.month), done["ev"]["title"],
			EventPanel._plain(str(done["ev"]["options"][int(done["option"])]["label"]))], maxf(1.0, auto_speed.value * 3.0))
	_auto_after_step()


func _auto_after_step() -> void:
	if state.ending_id != "":
		_auto_stop()
		main.show_ending()
