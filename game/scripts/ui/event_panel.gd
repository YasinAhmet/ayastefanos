extends RefCounted
## The event menu: covers ~60% of the screen; text, image, the ministers' advice, options, outcome, sources.

const Logic := preload("res://game/scripts/logic.gd")
const UIKit := preload("res://game/scripts/ui/ui_kit.gd")
const GameState := preload("res://game/scripts/game_state.gd")

const SEAT_RES := {"maliye": "para", "harbiye": "harbiye", "bahriye": "bahriye"}
const SEAT_NAME := {"maliye": "Maliye Nazırı", "harbiye": "Harbiye Nazırı", "bahriye": "Bahriye Nazırı"}

var state: GameState
var parent: Control
var on_close: Callable
var on_codex: Callable
var m: Dictionary


func open(ev: Dictionary) -> void:
	m = UIKit.modal(parent, Vector2(0.6, 0.88))
	var body: VBoxContainer = m["body"]
	var nation: Dictionary = state.nations.get(ev["nation"], {})
	var head := UIKit.hbox(12)
	head.add_child(UIKit.label("[%s]" % ev["nation"], 16, UIKit.GOLD))
	head.add_child(UIKit.label(Logic.date_text(int(ev["date"]["y"]), int(ev["date"]["m"])) + "  ·  " + str(nation.get("name", "")), 15, UIKit.MUTED))
	if ev["tags"].has("alternatif"):
		head.add_child(UIKit.label("ALTERNATİF TARİH", 14, UIKit.ALT))
	if ev["kind"] in GameState.MANDATORY:
		head.add_child(UIKit.label("ZORUNLU", 14, UIKit.RED))
	body.add_child(head)
	body.add_child(UIKit.label(ev["title"], 28, UIKit.INK, true))
	var img := UIKit.image(ev.get("image"), 240)
	if img:
		body.add_child(img)
	for p in ev["text"]:
		body.add_child(_rich(p, 17))
	if not ev["advice"].is_empty():
		body.add_child(UIKit.label("Görüşler", 15, UIKit.GOLD))
		for a in ev["advice"]:
			body.add_child(_advice(a))
	var opts_box := UIKit.vbox(8)
	body.add_child(opts_box)
	var outcome_box := UIKit.vbox(8)
	body.add_child(outcome_box)
	for i in ev["options"].size():
		var opt: Dictionary = ev["options"][i]
		var chips := Logic.effect_chips(opt["effects"], state.resources)
		var text: String = _plain(opt["label"])
		if chips != "":
			text += "\n" + chips
		var enabled := state.option_enabled(opt)
		if not enabled and opt.get("lock"):
			text += "\n(Kilitli: " + str(opt["lock"]) + ")"
		var b := UIKit.button(text, UIKit.PANEL_2, 16)
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.disabled = not enabled
		if opt.get("hint"):
			b.tooltip_text = _plain(opt["hint"])
		b.pressed.connect(_choose.bind(ev, i, opts_box, outcome_box))
		opts_box.add_child(b)
	if not ev["sources"].is_empty():
		var src_btn := UIKit.button("Kaynakça ▾", UIKit.PANEL, 14)
		var src := UIKit.vbox(4)
		src.visible = false
		for s in ev["sources"]:
			src.add_child(_rich(s, 14))
		src_btn.pressed.connect(func(): src.visible = not src.visible)
		body.add_child(src_btn)
		body.add_child(src)


func _choose(ev: Dictionary, i: int, opts_box: Control, outcome_box: Control) -> void:
	var res := state.choose(ev["id"], i)
	for c in opts_box.get_children():
		if c is Button:
			c.disabled = true
	var chosen: Button = opts_box.get_child(i)
	chosen.add_theme_color_override("font_disabled_color", UIKit.GOLD)
	if str(res.get("outcome", "")) != "":
		outcome_box.add_child(_rich(res["outcome"], 17))
	if res.get("remembered", false):
		outcome_box.add_child(UIKit.label("Bu karar hatırlanacak.", 14, UIKit.GOLD))
	var close := UIKit.button("Sona git" if state.ending_id != "" else "Kapat", UIKit.PANEL_2, 18)
	close.pressed.connect(func():
		m["layer"].queue_free()
		if on_close.is_valid():
			on_close.call())
	outcome_box.add_child(close)
	await parent.get_tree().process_frame
	m["scroll"].scroll_vertical = int(m["scroll"].get_v_scroll_bar().max_value)


func _advice(a: Dictionary) -> Control:
	var seat: String = a["seat"]
	var who := seat
	var weak := false
	if SEAT_RES.has(seat):
		var p := state.minister(seat)
		who = str(p.get("title", SEAT_NAME[seat]))
		weak = state.value_of(SEAT_RES[seat]) < 20
	var r := _rich("[b]%s:[/b] %s" % [who, a["text"]], 16)
	if weak:
		r.add_theme_color_override("default_color", UIKit.MUTED)
		r.text += "  [i](sözü pek dinlenmiyor)[/i]"
	return r


func _rich(bb: String, size: int) -> RichTextLabel:
	var r := UIKit.rich(bb, size)
	r.meta_clicked.connect(func(meta):
		var s := str(meta)
		if s.begins_with("codex:") and on_codex.is_valid():
			on_codex.call(s.substr(6)))
	return r


static func _plain(bb: String) -> String:
	var re := RegEx.new()
	re.compile("\\[/?[a-z]+(=[^\\]]*)?\\]")
	return re.sub(bb, "", true)
