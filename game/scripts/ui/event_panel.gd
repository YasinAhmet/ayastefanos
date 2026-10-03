extends RefCounted
## The event letter: a narrow sheet in the middle of the screen with the text, image, the ministers' advice,
## the options (locked ones with their reason), the outcome and the sources. Decisions open in it too.

const Logic := preload("res://game/scripts/logic.gd")
const UIKit := preload("res://game/scripts/ui/ui_kit.gd")
const GameState := preload("res://game/scripts/game_state.gd")

const SEAT_RES := {"maliye": "para", "harbiye": "harbiye", "bahriye": "bahriye"}
const SEAT_NAME := {"maliye": "Maliye Nazırı", "harbiye": "Harbiye Nazırı", "bahriye": "Bahriye Nazırı"}
const WIDTH := 580
const HIST_BASIS := {
	"kasa": "{i:book} Tarihte olan: kasadaki kitaplara göre.",
	"wiki": "{i:wiki} Tarihte olan: Wikipedia'ya göre (⚠ kasa dışı kaynak; Kaynakça'da bağlantısı var).",
	"varsayım": "{i:guess} Tarihte olan: kaynak bulunamadı, varsayım.",
}

var state: GameState
var parent: Control
var on_close: Callable
var on_codex: Callable
var m: Dictionary
var chosen := false      # an option was taken here (closing it then leaves nothing to answer)
var ev_id := ""


func open(ev: Dictionary) -> void:
	ev_id = str(ev["id"])
	m = UIKit.modal(parent, Vector2(0.0, 0.80), WIDTH, true)
	var body: VBoxContainer = m["body"]
	m["closer"] = _dismiss  # the corner ✕ leaves the paper on the desk
	var nation: Dictionary = state.nations.get(ev["nation"], {})
	var head := UIKit.hbox(8)
	var when := Logic.date_text(state.year, state.month) if ev["kind"] == "karar" \
		else Logic.date_text(int(ev["date"]["y"]), int(ev["date"]["m"]))
	var where := str(state.landmarks.get(str(ev.get("place", "")), {}).get("name", nation.get("name", "")))
	var meta := UIKit.label(when + "  ·  " + where, 11, UIKit.MUTED)
	meta.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(meta)
	if ev["kind"] == "karar":
		head.add_child(UIKit.label("KARAR", 10, UIKit.GREEN))
	if ev["tags"].has("alternatif"):
		head.add_child(UIKit.label("ALTERNATİF TARİH", 10, UIKit.ALT))
	if ev["kind"] in GameState.MANDATORY:
		head.add_child(UIKit.label("ZORUNLU", 10, UIKit.RED))
	body.add_child(head)
	body.add_child(UIKit.label(ev["title"], 20, UIKit.GOLD, true))
	var img := UIKit.image(ev.get("image"), 150)
	if img:
		body.add_child(img)
	for p in ev["text"]:
		var t := Logic.txt(p, state)
		if t != "":
			body.add_child(_rich(t, 13))
	var advice: Array = ev["advice"].filter(func(a): return Logic.eval_cond(a.get("cond"), state))
	if not advice.is_empty():
		body.add_child(UIKit.section("Görüşler"))
		for a in advice:
			body.add_child(_advice(a))
	var opts_box := UIKit.vbox(5)
	body.add_child(opts_box)
	var outcome_box := UIKit.vbox(6)
	body.add_child(outcome_box)
	for i in state.visible_options(ev):
		var opt: Dictionary = ev["options"][i]
		var chips := Logic.effect_chips(opt["effects"], state.resources)
		var text: String = _plain(opt["label"])
		if chips != "":
			text += "\n" + chips
		var enabled := state.option_enabled(opt)
		if not enabled and opt.get("lock"):
			text += "\n(Kilitli: " + str(opt["lock"]) + ")"
		elif not enabled and not state.zeroed_by(opt).is_empty():
			text += "\n(Kilitli: " + ", ".join(state.zeroed_by(opt)) + " sıfıra düşer)"
		var b := UIKit.button(text, UIKit.PANEL_2, 13)
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.disabled = not enabled
		var tip: PackedStringArray = []
		if opt.get("hint"):
			tip.append(_plain(opt["hint"]))
		if opt.get("alt", false):
			tip.append("Alternatif tarih")
		b.tooltip_text = "\n".join(tip)
		b.set_meta("option", i)
		b.pressed.connect(_choose.bind(ev, i, opts_box, outcome_box))
		opts_box.add_child(b)
		if state.historical() and opt.get("hist") != null and UIKit.show_sources:
			var col := "#ab9d82" if str(opt["hist"]) == "kasa" else "#d9b26a"
			opts_box.add_child(UIKit.rich("[color=%s]%s[/color]" % [col, HIST_BASIS.get(str(opt["hist"]), "")], 10))
	m["opts_box"] = opts_box
	if not ev["sources"].is_empty() and UIKit.show_sources:
		var src_btn := UIKit.button("Kaynakça ▾", UIKit.PANEL, 11)
		var src := UIKit.vbox(3)
		src.visible = false
		for s in ev["sources"]:
			src.add_child(_rich(s, 11))
		src_btn.pressed.connect(func(): src.visible = not src.visible)
		body.add_child(src_btn)
		body.add_child(src)


## Autoplay: press option `i` as the player would.
func auto_choose(i: int) -> void:
	for c in m["opts_box"].get_children():
		if c is Button and int(c.get_meta("option", -1)) == i and not c.disabled:
			c.pressed.emit()
			return


func is_open() -> bool:
	return not m.is_empty() and is_instance_valid(m["layer"]) and not m["layer"].is_queued_for_deletion()


func _dismiss() -> void:
	m["layer"].queue_free()
	if on_close.is_valid():
		on_close.call()


func _choose(ev: Dictionary, i: int, opts_box: Control, outcome_box: Control) -> void:
	var res := state.choose(ev["id"], i)
	if res.is_empty():
		return
	chosen = true
	# no "Kapat": the letter closes at once and the result goes to the small box under it
	if parent.has_method("show_result"):
		parent.show_result(str(ev["title"]), _plain(str(ev["options"][i]["label"])), str(res.get("outcome", "")),
			bool(res.get("remembered", false)))
	_dismiss()


func _advice(a: Dictionary) -> Control:
	var seat: String = a["seat"]
	var who := seat
	var weak := false
	if SEAT_RES.has(seat):
		var p := state.minister(seat)
		who = str(p.get("title", SEAT_NAME[seat]))
		weak = state.value_of(SEAT_RES[seat]) < 20
	var r := _rich("[b]%s:[/b] %s" % [who, Logic.txt(a["text"], state)], 12)
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
	re.compile("\\[/?[a-z]+(=[^\\]]*)?\\]|\\{i:[a-z]+\\} ?")
	return re.sub(bb, "", true)
