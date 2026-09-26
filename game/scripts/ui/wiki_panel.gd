extends PanelContainer
## The wiki: a panel on the right that opens when a blue word is clicked in an event, a card or another page.
## Each page is a vault note: its Turkish summary (GD 06 Sözlük), quotes from the books, sources. Links inside
## a page open other pages; back and forward walk the reading history; "Bütün maddeler" lists and searches them.

const UIKit := preload("res://game/scripts/ui/ui_kit.gd")

const WIDTH := 400

var state
var title_label: Label
var body: VBoxContainer
var scroll: ScrollContainer
var back_btn: Button
var fwd_btn: Button
var _history: Array = []    # page ids ("" = the index)
var _at := -1


func _ready() -> void:
	add_theme_stylebox_override("panel", UIKit.panel_style(Color(UIKit.PANEL, 0.97)))
	anchor_left = 1.0
	anchor_right = 1.0
	anchor_top = 0.0
	anchor_bottom = 1.0
	offset_left = -WIDTH - 8
	offset_right = -8
	offset_top = 46
	offset_bottom = -8
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	var v := UIKit.vbox(6)
	add_child(v)
	var head := UIKit.hbox(4)
	back_btn = UIKit.button("◀", UIKit.PANEL_2, 11)
	back_btn.tooltip_text = "Geri"
	back_btn.pressed.connect(func(): _go(_at - 1))
	head.add_child(back_btn)
	fwd_btn = UIKit.button("▶", UIKit.PANEL_2, 11)
	fwd_btn.tooltip_text = "İleri"
	fwd_btn.pressed.connect(func(): _go(_at + 1))
	head.add_child(fwd_btn)
	title_label = UIKit.label("", 16, UIKit.GOLD)
	title_label.clip_text = true
	title_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title_label)
	var idx := UIKit.button("Maddeler", UIKit.PANEL_2, 11)
	idx.pressed.connect(func(): open(""))
	head.add_child(idx)
	var x := UIKit.button("✕", UIKit.PANEL_2, 11)
	x.pressed.connect(func(): visible = false)
	head.add_child(x)
	v.add_child(head)
	scroll = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(scroll)
	body = UIKit.vbox(8)
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(body)


## Open a page (a vault note name), or the index with "". Opening adds to the reading history.
func open(page: String) -> void:
	_history = _history.slice(0, _at + 1)
	if _history.is_empty() or _history[-1] != page:
		_history.append(page)
	_go(_history.size() - 1)


func _go(i: int) -> void:
	if i < 0 or i >= _history.size():
		return
	_at = i
	visible = true
	get_parent().move_child(self, -1)  # above the event letter
	back_btn.disabled = _at <= 0
	fwd_btn.disabled = _at >= _history.size() - 1
	UIKit.clear(body)
	scroll.scroll_vertical = 0
	var page: String = _history[_at]
	if page == "" or not state.codex.has(page):
		_index()
		return
	var e: Dictionary = state.codex[page]
	title_label.text = str(e.get("name", page))
	title_label.tooltip_text = title_label.text
	var paras: Array = e.get("text", [])
	if paras.is_empty():
		body.add_child(UIKit.label("Bu madde için henüz Türkçe özet yazılmadı; aşağıda kitaplardan alıntılar var.", 11, UIKit.MUTED, true))
	for p in paras:
		body.add_child(_linked(p, 13))
	if not e.get("quotes", []).is_empty():
		body.add_child(UIKit.section("Kitaplardan"))
		for q in e["quotes"]:
			body.add_child(_linked("[i]%s[/i]" % q["text"], 12))
			if UIKit.show_sources:
				body.add_child(_linked("[color=#ab9d82]— %s[/color]" % q["source"], 10))
	UIKit.add_sources(body, e.get("sources", []), _linked)
	var back := _backlinks(page)
	if not back.is_empty():
		body.add_child(UIKit.section("Bu maddeye bağlananlar"))
		body.add_child(_linked(", ".join(back.map(func(n): return "[url=codex:%s][color=#8db4e2]%s[/color][/url]" % [n, state.codex[n].get("name", n)])), 11))


## Pages whose text links here.
func _backlinks(page: String) -> Array:
	var out: Array = []
	var needle := "codex:" + page + "]"
	for n in state.codex:
		if n != page and "\n".join(state.codex[n].get("text", [])).contains(needle):
			out.append(n)
	out.sort()
	return out


func _index() -> void:
	title_label.text = "Bütün maddeler"
	var search := LineEdit.new()
	search.placeholder_text = "Ara…"
	body.add_child(search)
	var list := UIKit.vbox(2)
	body.add_child(list)
	var fill := func(q: String):
		UIKit.clear(list)
		var names: Array = state.codex.keys()
		names.sort_custom(func(a, b): return str(state.codex[a].get("name", a)) < str(state.codex[b].get("name", b)))
		for n in names:
			var shown := str(state.codex[n].get("name", n))
			if q != "" and not shown.to_lower().contains(q.to_lower()) and not str(n).to_lower().contains(q.to_lower()):
				continue
			var b := UIKit.button(shown, UIKit.PANEL_2, 11)
			b.alignment = HORIZONTAL_ALIGNMENT_LEFT
			b.pressed.connect(open.bind(n))
			list.add_child(b)
	fill.call("")
	search.text_changed.connect(func(q): fill.call(q))


func _linked(bb: String, size: int) -> RichTextLabel:
	var r := UIKit.rich(bb, size)
	r.meta_clicked.connect(func(meta):
		var s := str(meta)
		if s.begins_with("codex:"):
			open(s.substr(6)))
	return r
