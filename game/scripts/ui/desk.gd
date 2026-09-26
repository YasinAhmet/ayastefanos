extends Control
## The ruler's desk, laid out like a grand-strategy screen: the atlas fills the window; a thin top bar holds the
## date, the resources and the menus; papers sit on the map as wax seals at their place; the ruler's portrait
## hangs at the Babıâli; clicking a place, a province or a front opens a narrow panel on the right.

const Logic := preload("res://game/scripts/logic.gd")
const UIKit := preload("res://game/scripts/ui/ui_kit.gd")
const GameState := preload("res://game/scripts/game_state.gd")
const MapView := preload("res://game/scripts/ui/map_view.gd")
const EventPanel := preload("res://game/scripts/ui/event_panel.gd")
const Panels := preload("res://game/scripts/ui/panels.gd")

const INSPECTOR_W := 330
const ISTANBUL_RING := 70.0

var state: GameState
var main: Node
var panels
var map: MapView
var date_label: Label
var persona_label: Label
var res_box: HBoxContainer
var alerts: HBoxContainer
var inspector: PanelContainer
var inspector_body: VBoxContainer
var status_label: Label
var advance_btn: Button
var _inspecting := {}          # {kind, id} of what the right panel shows, refreshed with the desk


func _ready() -> void:
	panels = Panels.new()
	panels.state = state
	panels.parent = self
	panels.on_event = func(id): _open_event(state.events[id])
	map = MapView.new()
	map.state = state
	map.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(map)
	map.province_clicked.connect(func(id):
		if id == "":
			close_inspector()
		else:
			show_province(id))
	add_child(_top_bar())
	alerts = UIKit.hbox(4)
	alerts.position = Vector2(10, 46)
	add_child(alerts)
	add_child(_inspector())
	add_child(_bottom_right())
	state.changed.connect(refresh)
	refresh()


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
	if state.historical():
		var chip := UIKit.label("TARİHÎ", 10, UIKit.GOLD)
		chip.tooltip_text = "Tarihî mod: alternatif tarih olayları ve seçenekleri gizli."
		chip.mouse_filter = Control.MOUSE_FILTER_PASS
		h.add_child(chip)
	for spec in [["Payitaht", func(): panels.payitaht()], ["Defter", func(): panels.defter()],
			["Kaynakça", func(): panels.codex()], ["Kaydet", _save], ["Menü", func(): main.show_menu()]]:
		var b := UIKit.button(spec[0], UIKit.PANEL_2, 12)
		b.pressed.connect(spec[1])
		h.add_child(b)
	return p


func _inspector() -> Control:
	inspector = UIKit.panel()
	inspector.anchor_left = 1.0
	inspector.anchor_right = 1.0
	inspector.anchor_top = 0.0
	inspector.anchor_bottom = 1.0
	inspector.offset_left = -INSPECTOR_W - 8
	inspector.offset_right = -8
	inspector.offset_top = 46
	inspector.offset_bottom = -64
	inspector.visible = false
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	inspector.add_child(scroll)
	inspector_body = UIKit.vbox(6)
	inspector_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(inspector_body)
	return inspector


func _bottom_right() -> Control:
	var p := UIKit.panel()
	p.anchor_left = 1.0
	p.anchor_right = 1.0
	p.anchor_top = 1.0
	p.anchor_bottom = 1.0
	p.offset_left = -INSPECTOR_W - 8
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
	_refresh_alerts(open)
	_refresh_markers(open)
	map.queue_redraw()
	if not _inspecting.is_empty():
		_reinspect()
	var must := state.mandatory_open().size()
	advance_btn.disabled = not state.can_advance()
	if must > 0:
		status_label.text = "Cevap bekleyen %d zorunlu evrak var (kırmızı mühür)." % must
	elif not open.is_empty():
		status_label.text = "%d evrak masada. Zaman ilerletilebilir." % open.size()
	else:
		status_label.text = "Zaman ilerletilebilir."


## The strip of seals under the top bar: every paper on the desk, even if its place is off-screen.
func _refresh_alerts(open: Array) -> void:
	UIKit.clear(alerts)
	for ev in open:
		var s := UIKit.seal(str(ev["nation"]), _seal_color(ev), 26)
		s.tooltip_text = ("ZORUNLU · " if ev["kind"] in GameState.MANDATORY else "") + str(ev["title"]) \
			+ ("  (alternatif tarih)" if ev["tags"].has("alternatif") else "")
		s.pressed.connect(_open_event.bind(ev))
		alerts.add_child(s)


func _seal_color(ev: Dictionary) -> Color:
	if ev["kind"] in GameState.MANDATORY:
		return UIKit.SEAL
	if ev["tags"].has("alternatif"):
		return UIKit.ALT.darkened(0.2)
	return UIKit.SEAL_2


## Where a place sits on the map: a landmark's lon/lat (İstanbul's fanned out in a ring) or a nation's point.
func place_anchor(place: String) -> Dictionary:
	if place.begins_with("nation:"):
		var n: Dictionary = state.nations.get(place.substr(7), {})
		var pos: Array = n.get("pos", [28.97, 41.01])
		return {"lonlat": Vector2(float(pos[0]), float(pos[1])), "px": Vector2.ZERO}
	var lm: Dictionary = state.landmarks.get(place, {})
	if lm.is_empty():
		return {"lonlat": Vector2(28.97, 41.01), "px": Vector2.ZERO}
	var ll: Array = lm["lonlat"]
	var istanbul := _istanbul_ring()
	if istanbul.has(place):
		return {"lonlat": Vector2(28.976, 41.011), "px": istanbul[place]}
	return {"lonlat": Vector2(float(ll[0]), float(ll[1])), "px": Vector2.ZERO}


## İstanbul's landmarks are a few hundred metres apart: fan them out around the Porte, keeping their bearing order.
func _istanbul_ring() -> Dictionary:
	var ids: Array = []
	var here := Vector2(28.976, 41.011)
	for id in state.landmarks:
		if str(state.landmarks[id].get("province", "")) == "istanbul" and id != "babiali":
			ids.append(id)
	var bearing := func(id):
		var ll: Array = state.landmarks[id]["lonlat"]
		return atan2(-(float(ll[1]) - here.y), float(ll[0]) - here.x)
	ids.sort_custom(func(a, b): return bearing.call(a) < bearing.call(b))
	var out := {"babiali": Vector2.ZERO}
	for i in ids.size():
		# a crown over the medallion: a flat half-ellipse, so the name tags sit side by side
		var a := deg_to_rad(200.0 + 140.0 * float(i) / maxf(1.0, float(ids.size() - 1)))
		out[ids[i]] = Vector2(cos(a) * 160.0, sin(a) * 78.0) * (ISTANBUL_RING / 70.0)
	return out


func _refresh_markers(open: Array) -> void:
	map.clear_markers()
	# landmarks
	for id in state.landmarks:
		var lm: Dictionary = state.landmarks[id]
		var a := place_anchor(id)
		if id == "babiali":
			continue
		var b := UIKit.button(str(lm["name"]), Color(UIKit.PANEL, 0.82), 10)
		b.tooltip_text = str(lm["name"])
		b.pressed.connect(show_place.bind(id))
		var in_ring: bool = str(lm.get("province", "")) == "istanbul"
		if in_ring:
			b.add_theme_font_size_override("font_size", 9)
		map.add_marker(b, a["lonlat"], a["px"] + Vector2(0, 0 if in_ring else 16), 0.0 if in_ring else 1.6)
		if not in_ring:
			var dot := UIKit.seal("", UIKit.GOLD.darkened(0.2), 9)
			dot.pressed.connect(show_place.bind(id))
			dot.tooltip_text = str(lm["name"])
			map.add_marker(dot, a["lonlat"], a["px"])
	# fronts: crossed swords at the middle of each front while its war is on
	map.highlight.clear()
	for fid in state.fronts:
		if not state.front_visible(fid):
			continue
		var f: Dictionary = state.fronts[fid]
		var ll: Array = f["lonlat"]
		map.add_marker(_front_marker(fid), Vector2(float(ll[0]), float(ll[1])))
		if state.front_active(fid):
			for pid in f["provinces"]:
				map.highlight[pid] = Color("c0392b")
	var porte := place_anchor("babiali")
	map.add_marker(_ruler_medallion(), porte["lonlat"], porte["px"] + Vector2(0, 8))
	# papers: one seal per place, with the count
	var by_place := {}
	for ev in open:
		var p := state.event_place(ev)
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
		else:
			s.pressed.connect(show_place.bind(p))
		var a := place_anchor(p)
		var shift := Vector2(22, -22) if p == "babiali" else Vector2(12, -12)
		map.add_marker(s, a["lonlat"], a["px"] + shift)
		if p.begins_with("nation:"):
			var code: String = p.substr(7)
			var nb := UIKit.button(str(state.nations.get(code, {}).get("short", code)), Color(UIKit.PANEL, 0.82), 10)
			nb.pressed.connect(show_nation.bind(code))
			map.add_marker(nb, a["lonlat"], a["px"] + Vector2(0, 8))


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


## The front panel: the balance of power, who is winning, what moved it and how the front ended.
func show_front(fid: String) -> void:
	var f: Dictionary = state.fronts[fid]
	var enemy := _nation_name(str(f["enemy"]))
	var body := _begin("front", fid, str(f["name"]), "%s · Devlet-i Aliyye ile %s" % [f["war"], enemy])
	var v := state.value_of(str(f["value"]))
	var row := UIKit.hbox(6)
	row.add_child(UIKit.label("Osmanlı", 10, UIKit.INK))
	var bal := UIKit.balance(v, UIKit.nation_color("OS"), UIKit.nation_color(str(f["enemy"])), 220)
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
	if str(f.get("text", "")) != "":
		body.add_child(panels._linked(f["text"], 12))
	var log: Array = state.front_log.get(fid, [])
	if not log.is_empty():
		body.add_child(UIKit.section("Dengeyi değiştirenler"))
		var rows := log.duplicate()
		rows.reverse()
		for e in rows:
			var d := int(e["d"])
			var col := "#8fbf6f" if d > 0 else "#e08070"
			body.add_child(UIKit.rich("[color=%s]%s%d[/color]  %s [color=#ab9d82](%s)[/color]" % [col, "+" if d > 0 else "−", absi(d),
				e["by"], Logic.date_text(int(e["y"]), int(e["m"])) if e["by"] != GameState.DRIFT_BY else str(e["y"])], 11))
	var names: PackedStringArray = []
	for pid in f["provinces"]:
		names.append("%s (%s)" % [state.provinces.get(pid, {}).get("name", pid), _holder_text(pid)])
	if not names.is_empty():
		body.add_child(UIKit.section("Çekişilen iller"))
		body.add_child(UIKit.label("\n".join(names), 11, UIKit.INK, true))
	for s in f.get("sources", []):
		body.add_child(panels._linked("[color=#ab9d82]%s[/color]" % s, 10))


func _ruler_medallion() -> Control:
	var r := state.ruler()
	var box := UIKit.vbox(0)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	var med := UIKit.medallion(r.get("image"), 58, _initials(str(r.get("name", ""))))
	med.tooltip_text = "%s\nBabıâli · tıklayın: Payitaht" % str(r.get("title", ""))
	med.mouse_filter = Control.MOUSE_FILTER_STOP
	med.gui_input.connect(func(ev):
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			show_place("babiali"))
	box.add_child(med)
	var name := UIKit.label(str(r.get("name", "")), 10, UIKit.INK)
	name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var bg := UIKit.panel(Color(UIKit.PANEL, 0.85))
	bg.add_theme_stylebox_override("panel", _tight(Color(UIKit.PANEL, 0.85)))
	bg.add_child(name)
	box.add_child(bg)
	return box


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


# ---------------------------------------------------------------- inspector (right panel)

func close_inspector() -> void:
	_inspecting = {}
	inspector.visible = false
	map.selected = ""
	map.queue_redraw()


func _begin(kind: String, id: String, title: String, subtitle := "") -> VBoxContainer:
	_inspecting = {"kind": kind, "id": id}
	inspector.visible = true
	UIKit.clear(inspector_body)
	var head := UIKit.hbox(6)
	var t := UIKit.label(title, 17, UIKit.GOLD, true)
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(t)
	var x := UIKit.button("✕", UIKit.PANEL_2, 11)
	x.pressed.connect(close_inspector)
	head.add_child(x)
	inspector_body.add_child(head)
	if subtitle != "":
		inspector_body.add_child(UIKit.label(subtitle, 11, UIKit.MUTED, true))
	return inspector_body


func _reinspect() -> void:
	match _inspecting.get("kind", ""):
		"place": show_place(_inspecting["id"])
		"province": show_province(_inspecting["id"])
		"nation": show_nation(_inspecting["id"])
		"front": show_front(_inspecting["id"])


func show_place(id: String) -> void:
	if id.begins_with("nation:"):
		show_nation(id.substr(7))
		return
	var lm: Dictionary = state.landmarks.get(id, {})
	var prov := str(lm.get("province", ""))
	var sub := str(state.provinces.get(prov, {}).get("name", ""))
	if prov != "":
		sub += " · " + _holder_text(prov)
	var body := _begin("place", id, str(lm.get("name", id)), sub)
	if id == "babiali":
		var r := state.ruler()
		var row := UIKit.hbox(8)
		row.add_child(UIKit.medallion(r.get("image"), 64, _initials(str(r.get("name", "")))))
		var col := UIKit.vbox(2)
		col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		col.add_child(UIKit.label(str(r.get("title", "")), 12, UIKit.INK, true))
		var b := UIKit.button("Payitaht: hükümdar ve nazırlar", UIKit.PANEL_2, 11)
		b.pressed.connect(func(): panels.payitaht())
		col.add_child(b)
		row.add_child(col)
		body.add_child(row)
	var img := UIKit.image(lm.get("image"), 110)
	if img:
		body.add_child(img)
	if str(lm.get("text", "")) != "":
		body.add_child(panels._linked(lm["text"], 12))
	_papers_section(body, id)
	_decisions_section(body, id)
	_threads_section(body, id)
	_history_section(body, func(h): return str(h.get("place", "")) == id)
	for s in lm.get("sources", []):
		body.add_child(panels._linked("[color=#ab9d82]%s[/color]" % s, 10))


func show_province(id: String) -> void:
	map.selected = id
	map.queue_redraw()
	var p: Dictionary = state.provinces.get(id, {})
	var body := _begin("province", id, str(p.get("name", id)), _holder_text(id))
	var holder := state.province_holder(id, "ctl")
	var chip := UIKit.hbox(6)
	var sw := ColorRect.new()
	sw.color = UIKit.nation_color(holder)
	sw.custom_minimum_size = Vector2(14, 14)
	chip.add_child(sw)
	var nb := UIKit.button(str(state.nations.get(holder, {}).get("name", holder)), UIKit.PANEL_2, 11)
	nb.pressed.connect(show_nation.bind(holder))
	chip.add_child(nb)
	body.add_child(chip)
	var places: Array = []
	for lid in state.landmarks:
		if str(state.landmarks[lid].get("province", "")) == id:
			places.append(lid)
	if not places.is_empty():
		body.add_child(UIKit.section("Yerler"))
		for lid in places:
			var b := UIKit.button(str(state.landmarks[lid]["name"]), UIKit.PANEL_2, 11)
			b.alignment = HORIZONTAL_ALIGNMENT_LEFT
			b.pressed.connect(show_place.bind(lid))
			body.add_child(b)
	var changes := state.chronicle.filter(func(c): return c["kind"] == "prov" and c["key"] == id)
	if not changes.is_empty():
		body.add_child(UIKit.section("Toprak defteri"))
		for c in changes:
			body.add_child(UIKit.rich("[color=#ab9d82]%s[/color] · %s%s" % [
				Logic.date_text(int(c["y"]), int(c["m"])), state.province_change_text(c),
				("  [i](%s)[/i]" % c["by"]) if str(c.get("by", "")) != "" else ""], 11))
	for lid in places:
		_papers_section(body, lid)


func show_nation(code: String) -> void:
	var n: Dictionary = state.nations.get(code, {})
	var body := _begin("nation", code, str(n.get("name", code)))
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
	for h in past.slice(-8):
		body.add_child(UIKit.rich("[color=#ab9d82]%s[/color] · [b]%s[/b] — %s" % [Logic.date_text(int(h["y"]), int(h["m"])),
			h["title"], EventPanel._plain(h["option"])], 11))


# ---------------------------------------------------------------- actions

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
