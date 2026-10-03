extends RefCounted
## Secondary sheets: Payitaht (ruler + three ministers), a nation's file, the Defter (how every story thread
## stands and the land register), the codex and the year-turn gazette.

const Logic := preload("res://game/scripts/logic.gd")
const UIKit := preload("res://game/scripts/ui/ui_kit.gd")
const GameState := preload("res://game/scripts/game_state.gd")

const EventPanel := preload("res://game/scripts/ui/event_panel.gd")
const SEATS := [["dahiliye", "", "Dahiliye"], ["maliye", "para", "Maliye"], ["harbiye", "harbiye", "Harbiye"], ["bahriye", "bahriye", "Bahriye"]]

var state: GameState
var parent: Control
var on_event: Callable   # open an event by id
var _gundem_wins: Array = []
var _gundem_pending := false


func _close_button(m: Dictionary, text := "Kapat") -> Button:
	var b := UIKit.button(text, UIKit.PANEL_2, 12)
	b.pressed.connect(func(): m["layer"].queue_free())
	return b


func _title(body: VBoxContainer, text: String, sub := "") -> void:
	body.add_child(UIKit.label(text, 20, UIKit.GOLD, true))
	if sub != "":
		body.add_child(UIKit.label(sub, 11, UIKit.MUTED, true))


func _person_card(p: Dictionary, role_text: String, value := -1) -> Control:
	var card := UIKit.panel(UIKit.PANEL_2)
	var row := UIKit.hbox(10)
	card.add_child(row)
	var img := UIKit.image(state.person_image(str(p.get("id", ""))), 96)
	if img:
		img.custom_minimum_size = Vector2(76, 96)
		img.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		row.add_child(img)
	var col := UIKit.vbox(3)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(col)
	col.add_child(UIKit.label(role_text, 10, UIKit.GOLD))
	col.add_child(UIKit.label(str(p.get("title", "—")), 14, UIKit.INK, true))
	if value >= 0:
		var h := UIKit.hbox(6)
		h.add_child(UIKit.label("Nüfuz", 10, UIKit.MUTED))
		h.add_child(UIKit.bar(value))
		col.add_child(h)
	if str(p.get("text", "")) != "":
		col.add_child(_linked(p["text"], 12))
	UIKit.add_sources(col, p.get("sources", []), _linked)
	return card


func payitaht() -> void:
	var m := UIKit.modal(parent, Vector2(0.0, 0.86), 600)
	var body: VBoxContainer = m["body"]
	_title(body, "Payitaht", Logic.date_text(state.year, state.month))
	var head := state.ruler()
	var sultan := state.sultan()
	if str(state.cabinet().get("sadrazam", "-")) != "-" and not sultan.is_empty() and sultan.get("id") != head.get("id"):
		body.add_child(_person_card(sultan, "Padişah"))
		body.add_child(_person_card(head, "Sadrazam"))
	else:
		body.add_child(_person_card(head, "Hükümdar"))
	for s in SEATS:
		var p := state.minister(s[0])
		if not p.is_empty():
			body.add_child(_person_card(p, s[2], state.value_of(s[1]) if s[1] != "" else -1))
	body.add_child(_close_button(m))


## The Gündem window: the focus tree by era, each card coloured by its state (REWORK §10).
func gundem() -> void:
	var m := UIKit.modal(parent, Vector2(0.94, 0.9))
	var body: VBoxContainer = m["body"]
	_gundem_fill(body, m)
	_gundem_wins.append([weakref(m["layer"]), weakref(body)])
	if not state.changed.is_connected(_gundem_changed):
		state.changed.connect(_gundem_changed)


## Open Gündem windows refresh when the state changes (dead ones are dropped).
func _gundem_changed() -> void:
	if _gundem_pending or _gundem_wins.is_empty():
		return
	_gundem_pending = true
	_gundem_refresh_all.call_deferred()


func _gundem_refresh_all() -> void:
	_gundem_pending = false
	var live: Array = []
	for w in _gundem_wins:
		var layer: Control = w[0].get_ref()
		if layer != null and not layer.is_queued_for_deletion():
			live.append(w)
			_gundem_rebuild(w[0], w[1])
	_gundem_wins = live


func _gundem_rebuild(wr: WeakRef, wb: WeakRef) -> void:
	var layer: Control = wr.get_ref()
	var body: VBoxContainer = wb.get_ref()
	if layer == null or body == null or layer.is_queued_for_deletion():
		return
	for c in body.get_children():
		body.remove_child(c)
		c.queue_free()
	_gundem_fill(body, {"layer": layer})


const ERAS := [["Abdülhamid devri · 1876–1908", 1876, 1907], ["Meşrutiyet devri · 1908–1914", 1908, 1913], ["Harp devri · 1914–1918", 1914, 1919]]
const FOCUS_COLORS := {"done": Color("3d5a3a"), "active": Color("6a5420"), "available": Color("3a2e22"), "locked": Color("2a2420")}


func _gundem_fill(body: VBoxContainer, m: Dictionary) -> void:
	_title(body, "Gündem", "Masadaki uzun soluklu devlet işleri: aynı anda biri yürür, süresi dolunca etkileri bir kerede uygulanır.")
	if state.historical():
		body.add_child(UIKit.label("Tarihî modda gündem tarihteki gibi yürür.", 12, UIKit.GOLD, true))
	var cols := UIKit.hbox(8)
	body.add_child(cols)
	for era in ERAS:
		var col := UIKit.vbox(6)
		col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		col.size_flags_stretch_ratio = 1.0
		cols.add_child(col)
		col.add_child(UIKit.section(era[0]))
		for id in state.focus_order:
			var f: Dictionary = state.focuses[id]
			if int(f["from"]) >= int(era[1]) and int(f["from"]) <= int(era[2]):
				col.add_child(_focus_card(id, f))
	body.add_child(_close_button(m))


func _focus_card(id: String, f: Dictionary) -> Control:
	var st := state.focus_state(id)
	var card := UIKit.panel(FOCUS_COLORS[st])
	var col := UIKit.vbox(3)
	card.add_child(col)
	var tag: String = {"done": "✔ Bitti", "active": "▶ Yürüyor", "available": "Açık", "locked": "🔒 Kilitli"}[st]
	col.add_child(UIKit.rich("[b]%s[/b]%s" % [f["name"], "  [color=#d9b26a]TARİHÎ[/color]" if f["hist"] and UIKit.show_sources else ""], 13))
	col.add_child(UIKit.label("%s · %d ay · %d–%d" % [tag, int(f["months"]), int(f["from"]), int(f["to"])], 10, UIKit.MUTED))
	if st == "active":
		var pb := UIKit.bar(int(100.0 * state.focus_progress / maxf(1.0, float(f["months"]))), UIKit.GOLD, 120)
		col.add_child(pb)
		col.add_child(UIKit.label("%d/%d ay" % [state.focus_progress, int(f["months"])], 10, UIKit.INK))
	elif st == "locked":
		col.add_child(UIKit.label(state.focus_lock_reason(id), 10, Color("c97a6a")))
	elif st == "done":
		col.add_child(UIKit.label("Bitti: " + str(state.focus_done[id]), 10, UIKit.MUTED))
	col.add_child(_linked(f["text"], 11))
	var chips := Logic.effect_chips(f["effects"], state.resources)
	var hidden := _focus_hidden(f["effects"])
	if chips != "" or hidden != "":
		col.add_child(UIKit.rich(("Etki: " + chips + ("  " if chips != "" and hidden != "" else "") + hidden), 11))
	if st == "available" and not state.historical():
		var b := UIKit.button("Başlat", UIKit.PANEL_2, 12)
		b.pressed.connect(func(): state.start_focus(id))
		col.add_child(b)
	elif st == "active" and not state.historical():
		var c := UIKit.button("İptal", UIKit.PANEL, 11)
		c.pressed.connect(func(): state.cancel_focus())
		col.add_child(c)
	return card


## Hidden resources as ▲/▼ (the event option preview, REWORK §7).
func _focus_hidden(effects: Array) -> String:
	var parts: PackedStringArray = []
	for e in effects:
		var r: Dictionary = state.resources.get(e.get("id", ""), {})
		if r.is_empty() or r["visible"]:
			continue
		if str(e["t"]) == "res":
			parts.append("%s %s" % ["▲" if float(e["d"]) > 0 else "▼", r["name"]])
		elif str(e["t"]) == "set":
			parts.append("%s %s" % ["▲" if float(e["v"]) >= float(state.value_of(e["id"])) else "▼", r["name"]])
	return " · ".join(parts)


func nation(code: String) -> void:
	var n: Dictionary = state.nations.get(code, {})
	var m := UIKit.modal(parent, Vector2(0.0, 0.8), 480)
	var body: VBoxContainer = m["body"]
	_title(body, "[%s] %s" % [code, n.get("name", code)])
	if str(n.get("text", "")) != "":
		body.add_child(_linked(n["text"], 13))
	var open := state.open_events().filter(func(ev): return ev["nation"] == code)
	if not open.is_empty():
		body.add_child(UIKit.section("Masadaki evrak"))
		for ev in open:
			var b := UIKit.button(ev["title"], UIKit.PANEL_2, 12)
			b.pressed.connect(func():
				m["layer"].queue_free()
				on_event.call(ev["id"]))
			body.add_child(b)
	var past := state.history.filter(func(h): return h["nation"] == code)
	if not past.is_empty():
		body.add_child(UIKit.section("Gelişmeler"))
		for h in past:
			body.add_child(UIKit.rich("[color=#ab9d82]%s[/color] · [b]%s[/b] — %s" % [Logic.date_text(int(h["y"]), int(h["m"])), h["title"], EventPanel._plain(h["option"])], 12))
	body.add_child(_close_button(m))


## The Defter: every story thread with its current outcome and the steps that led there, then the land register.
func defter() -> void:
	var m := UIKit.modal(parent, Vector2(0.0, 0.86), 620)
	var body: VBoxContainer = m["body"]
	_title(body, "Defter", "Hikâye ipliklerinin şimdiki hâli ve toprakların el değiştirmesi.")
	for k in state.world_order:
		var def: Dictionary = state.world_defs[k]
		var card := UIKit.panel(UIKit.PANEL_2)
		var col := UIKit.vbox(2)
		card.add_child(col)
		var changed := state.world_value(k) != str(def["start"])
		col.add_child(UIKit.rich("[b]%s:[/b] %s" % [def["name"], state.world_label(k)], 13))
		var steps := state.chronicle.filter(func(c): return c["kind"] == "world" and c["key"] == k)
		if steps.is_empty():
			col.add_child(UIKit.label("Henüz açılmadı." if not changed else "", 11, UIKit.MUTED))
		for c in steps:
			col.add_child(UIKit.rich("[color=#ab9d82]%s[/color] · %s → [b]%s[/b]%s" % [Logic.date_text(int(c["y"]), int(c["m"])),
				state.world_label(k, str(c["from"])), state.world_label(k, str(c["to"])),
				("  [i](%s)[/i]" % c["by"]) if str(c.get("by", "")) != "" else ""], 11))
		body.add_child(card)
	var land := state.chronicle.filter(func(c): return c["kind"] == "prov")
	if not land.is_empty():
		body.add_child(UIKit.section("Toprak defteri"))
		for c in land:
			body.add_child(UIKit.rich("[color=#ab9d82]%s[/color] · [b]%s[/b]: %s%s" % [Logic.date_text(int(c["y"]), int(c["m"])),
				state.provinces.get(c["key"], {}).get("name", c["key"]), state.province_change_text(c),
				("  [i](%s)[/i]" % c["by"]) if str(c.get("by", "")) != "" else ""], 11))
	body.add_child(_close_button(m))


func _nation(code: String) -> String:
	return str(state.nations.get(code, {}).get("name", code))


func codex(entry := "") -> void:
	if parent.has_method("open_wiki"):
		parent.open_wiki(entry)
		return
	_codex_modal(entry)


func _codex_modal(entry := "") -> void:
	var m := UIKit.modal(parent, Vector2(0.0, 0.84), 560)
	var body: VBoxContainer = m["body"]
	if entry != "" and state.codex.has(entry):
		var e: Dictionary = state.codex[entry]
		_title(body, e["title"], "Kasadaki notun kitaplardan alıntıları")
		for q in e["quotes"]:
			body.add_child(UIKit.rich(q["text"], 13))
			body.add_child(UIKit.rich("[color=#ab9d82]— %s[/color]" % q["source"], 11))
		if e["quotes"].is_empty():
			body.add_child(UIKit.label("Bu not için alıntı yok.", 12, UIKit.MUTED))
		var back := UIKit.button("Bütün maddeler", UIKit.PANEL, 11)
		back.pressed.connect(func():
			m["layer"].queue_free()
			_codex_modal())
		body.add_child(back)
	else:
		_title(body, "Kaynakça ve sözlük", "Olay metinlerindeki altı çizili adlar buraya açılır. Görseller Wikimedia'dandır (game/assets/images/CREDITS.md); harita sınırları Natural Earth'ten sadeleştirilmiştir. İkisi de kasa kaynağı değildir.")
		var grid := GridContainer.new()
		grid.columns = 2
		body.add_child(grid)
		var keys := state.codex.keys()
		keys.sort()
		for k in keys:
			var b := UIKit.button(k, UIKit.PANEL_2, 11)
			b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			b.pressed.connect(func():
				m["layer"].queue_free()
				_codex_modal(k))
			grid.add_child(b)
	body.add_child(_close_button(m))


func gazette(g: Dictionary) -> void:
	var m := UIKit.modal(parent, Vector2(0.0, 0.8), 520)
	var body: VBoxContainer = m["body"]
	var head := UIKit.label(g["paper"], 26, UIKit.GOLD)
	head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_child(head)
	var sub := UIKit.label("%d senesinin hülâsası" % g["year"], 12, UIKit.MUTED)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_child(sub)
	if g["decisions"].is_empty():
		body.add_child(UIKit.label("Bu sene Babıâli'den mühim bir karar çıkmadı.", 12, UIKit.INK, true))
	for d in g["decisions"]:
		body.add_child(UIKit.rich("• [b]%s[/b] — %s" % [d["title"], EventPanel._plain(d["option"])], 12))
	if not g["headlines"].is_empty():
		body.add_child(UIKit.section("Havadis"))
		for h in g["headlines"]:
			body.add_child(UIKit.rich("[i]%s[/i]" % h, 12))
	body.add_child(_close_button(m, "Devam"))


func _linked(bb: String, size: int) -> RichTextLabel:
	var r := UIKit.rich(bb, size)
	r.meta_clicked.connect(func(meta):
		var s := str(meta)
		if s.begins_with("codex:"):
			codex(s.substr(6)))
	return r
