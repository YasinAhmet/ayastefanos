extends RefCounted
## Secondary menus: Payitaht (ruler + three ministers), a nation's file, the codex, the year-turn gazette.

const Logic := preload("res://game/scripts/logic.gd")
const UIKit := preload("res://game/scripts/ui/ui_kit.gd")
const GameState := preload("res://game/scripts/game_state.gd")

const EventPanel := preload("res://game/scripts/ui/event_panel.gd")
const SEATS := [["maliye", "para", "Maliye"], ["harbiye", "harbiye", "Harbiye"], ["bahriye", "bahriye", "Bahriye"]]

var state: GameState
var parent: Control
var on_event: Callable   # open an event by id


func _close_button(m: Dictionary, text := "Kapat") -> Button:
	var b := UIKit.button(text, UIKit.PANEL_2, 16)
	b.pressed.connect(func(): m["layer"].queue_free())
	return b


func _person_card(p: Dictionary, role_text: String, value := -1) -> Control:
	var card := UIKit.panel(UIKit.PANEL_2)
	var row := UIKit.hbox(12)
	card.add_child(row)
	var img := UIKit.image(p.get("image"), 120)
	if img:
		img.custom_minimum_size = Vector2(96, 120)
		img.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		row.add_child(img)
	var col := UIKit.vbox(4)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(col)
	col.add_child(UIKit.label(role_text, 13, UIKit.GOLD))
	col.add_child(UIKit.label(str(p.get("title", "—")), 19, UIKit.INK, true))
	if value >= 0:
		var h := UIKit.hbox(6)
		h.add_child(UIKit.label("Nüfuz", 13, UIKit.MUTED))
		h.add_child(UIKit.bar(value))
		col.add_child(h)
	if str(p.get("text", "")) != "":
		col.add_child(_linked(p["text"], 14))
	for s in p.get("sources", []):
		col.add_child(_linked(s, 12))
	return card


func payitaht() -> void:
	var m := UIKit.modal(parent, Vector2(0.62, 0.9))
	var body: VBoxContainer = m["body"]
	body.add_child(UIKit.label("Payitaht", 28, UIKit.GOLD))
	body.add_child(UIKit.label(Logic.date_text(state.year, state.month), 15, UIKit.MUTED))
	body.add_child(_person_card(state.ruler(), "Hükümdar"))
	for s in SEATS:
		var p := state.minister(s[0])
		if not p.is_empty():
			body.add_child(_person_card(p, s[2], state.value_of(s[1])))
	body.add_child(_close_button(m))


func nation(code: String) -> void:
	var n: Dictionary = state.nations.get(code, {})
	var m := UIKit.modal(parent, Vector2(0.5, 0.8))
	var body: VBoxContainer = m["body"]
	body.add_child(UIKit.label("[%s] %s" % [code, n.get("name", code)], 26, UIKit.GOLD, true))
	if str(n.get("text", "")) != "":
		body.add_child(_linked(n["text"], 16))
	var open := state.open_events().filter(func(ev): return ev["nation"] == code)
	if not open.is_empty():
		body.add_child(UIKit.label("Masadaki evrak", 16, UIKit.GOLD))
		for ev in open:
			var b := UIKit.button(ev["title"], UIKit.PANEL_2, 15)
			b.pressed.connect(func():
				m["layer"].queue_free()
				on_event.call(ev["id"]))
			body.add_child(b)
	var past := state.history.filter(func(h): return h["nation"] == code)
	if not past.is_empty():
		body.add_child(UIKit.label("Gelişmeler", 16, UIKit.GOLD))
		for h in past:
			body.add_child(UIKit.rich("[color=#b5a98f]%s[/color] · [b]%s[/b] — %s" % [Logic.date_text(int(h["y"]), int(h["m"])), h["title"], EventPanel._plain(h["option"])], 14))
	body.add_child(_close_button(m))


func codex(entry := "") -> void:
	var m := UIKit.modal(parent, Vector2(0.55, 0.85))
	var body: VBoxContainer = m["body"]
	if entry != "" and state.codex.has(entry):
		var e: Dictionary = state.codex[entry]
		body.add_child(UIKit.label(e["title"], 26, UIKit.GOLD, true))
		body.add_child(UIKit.label("Kasadaki notun kitaplardan alıntıları", 13, UIKit.MUTED))
		for q in e["quotes"]:
			body.add_child(UIKit.rich(q["text"], 15))
			body.add_child(UIKit.rich("[color=#b5a98f]— %s[/color]" % q["source"], 13))
		if e["quotes"].is_empty():
			body.add_child(UIKit.label("Bu not için alıntı yok.", 14, UIKit.MUTED))
		var back := UIKit.button("Bütün maddeler", UIKit.PANEL, 14)
		back.pressed.connect(func():
			m["layer"].queue_free()
			codex())
		body.add_child(back)
	else:
		body.add_child(UIKit.label("Kaynakça ve sözlük", 26, UIKit.GOLD))
		body.add_child(UIKit.label("Olay metinlerindeki altı çizili adlar buraya açılır. Görseller Wikimedia'dandır (game/assets/images/CREDITS.md); kasa kaynağı değildir.", 13, UIKit.MUTED, true))
		var grid := GridContainer.new()
		grid.columns = 2
		body.add_child(grid)
		var keys := state.codex.keys()
		keys.sort()
		for k in keys:
			var b := UIKit.button(k, UIKit.PANEL_2, 13)
			b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			b.pressed.connect(func():
				m["layer"].queue_free()
				codex(k))
			grid.add_child(b)
	body.add_child(_close_button(m))


func gazette(g: Dictionary) -> void:
	var m := UIKit.modal(parent, Vector2(0.5, 0.8))
	var body: VBoxContainer = m["body"]
	body.add_child(UIKit.label(g["paper"], 30, UIKit.GOLD))
	body.add_child(UIKit.label("%d senesinin hülâsası" % g["year"], 16, UIKit.MUTED))
	if g["decisions"].is_empty():
		body.add_child(UIKit.label("Bu sene Babıâli'den mühim bir karar çıkmadı.", 15, UIKit.INK, true))
	for d in g["decisions"]:
		body.add_child(UIKit.rich("• [b]%s[/b] — %s" % [d["title"], EventPanel._plain(d["option"])], 15))
	if not g["headlines"].is_empty():
		body.add_child(UIKit.label("Havadis", 16, UIKit.GOLD))
		for h in g["headlines"]:
			body.add_child(UIKit.rich("[i]%s[/i]" % h, 15))
	body.add_child(_close_button(m, "Devam"))


func _linked(bb: String, size: int) -> RichTextLabel:
	var r := UIKit.rich(bb, size)
	r.meta_clicked.connect(func(meta):
		var s := str(meta)
		if s.begins_with("codex:"):
			codex(s.substr(6)))
	return r
