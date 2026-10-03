extends RefCounted
## A window inside the game that shows a Wikipedia article (Turkish when it exists, else English) with a scrollbar.
## The text is fetched live from the MediaWiki API, so it is marked "Not from vault sources" (Lore/Rules.md).

const UIKit := preload("res://game/scripts/ui/ui_kit.gd")

const UA := "AyastefanosUtanci/1.0 (Godot game; Wikipedia reader)"

var _layer: Control
var _body: VBoxContainer
var _scroll: ScrollContainer
var _title_label: Label
var _status: Label
var _lang_btns := {}
var _en_title := ""
var _titles := {"en": ""}     # language -> article title
var _lang := ""
var _token := 0               # a newer request makes older answers stale


## Open the window on the English Wikipedia article `en_title`; `shown` is the name in the window's title bar.
static func open(parent: Control, en_title: String, shown: String) -> void:
	var w := new()
	w._build(parent, en_title, shown)


func _build(parent: Control, en_title: String, shown: String) -> void:
	_en_title = en_title
	_titles["en"] = en_title
	var m := UIKit.modal(parent, Vector2(0.62, 0.88))
	_layer = m["layer"]
	_scroll = m["scroll"]
	_body = m["body"]
	var panel: PanelContainer = m["panel"]
	panel.remove_child(_scroll)
	var v := UIKit.vbox(6)
	panel.add_child(v)
	var head := UIKit.hbox(6)
	_title_label = UIKit.label(shown, 18, UIKit.GOLD)
	_title_label.clip_text = true
	_title_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(_title_label)
	for spec in [["tr", "Türkçe"], ["en", "English"]]:
		var b := UIKit.button(spec[1], UIKit.PANEL_2, 11)
		b.pressed.connect(_show.bind(spec[0]))
		head.add_child(b)
		_lang_btns[spec[0]] = b
	var ext := UIKit.button("Tarayıcıda aç", UIKit.PANEL_2, 11)
	ext.pressed.connect(func(): OS.shell_open(_url(_lang if _lang != "" else "en")))
	head.add_child(ext)
	var x := UIKit.button("✕", UIKit.PANEL_2, 11)
	x.pressed.connect(func(): _layer.queue_free())
	head.add_child(x)
	v.add_child(head)
	v.add_child(UIKit.label("⚠ Vikipedi'den canlı çekilir; kasa kaynağı değildir.", 10, UIKit.ALT, true))
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(_scroll)
	_status = UIKit.label("", 12, UIKit.MUTED, true)
	_body.add_child(_status)
	_lang_btns["tr"].disabled = true
	_lang_btns["en"].disabled = true
	_find_turkish()


func _url(lang: String) -> String:
	return "https://%s.wikipedia.org/wiki/%s" % [lang, str(_titles.get(lang, _en_title)).uri_encode()]


## Look for the Turkish title of the English article, then show Turkish if there is one, else English.
func _find_turkish() -> void:
	_set_status("Vikipedi'den yükleniyor…")
	var q := "https://en.wikipedia.org/w/api.php?action=query&format=json&redirects=1&origin=*&prop=langlinks&lllang=tr&titles=" + _en_title.uri_encode()
	_fetch(q, _on_langlinks, _on_langlinks_failed)


func _on_langlinks(data: Dictionary) -> void:
	var pages: Dictionary = data.get("query", {}).get("pages", {})
	for id in pages:
		var ll: Array = pages[id].get("langlinks", [])
		if not ll.is_empty():
			_titles["tr"] = str(ll[0].get("*", ll[0].get("title", "")))
	_lang_btns["en"].disabled = false
	_lang_btns["tr"].disabled = not _titles.has("tr")
	_show("tr" if _titles.has("tr") else "en")


func _on_langlinks_failed(_err: String) -> void:
	_lang_btns["en"].disabled = false
	_show("en")


func _show(lang: String) -> void:
	_lang = lang
	_token += 1
	var mine := _token
	_clear_body()
	_set_status("Yükleniyor…")
	var q := "https://%s.wikipedia.org/w/api.php?action=query&format=json&redirects=1&origin=*&prop=extracts&explaintext=1&exsectionformat=wiki&titles=%s" % [lang, str(_titles[lang]).uri_encode()]
	_fetch(q, _on_article.bind(lang, mine), _on_article_failed.bind(mine))


func _on_article(data: Dictionary, lang: String, mine: int) -> void:
	if mine != _token:
		return
	var text := ""
	var pages: Dictionary = data.get("query", {}).get("pages", {})
	for id in pages:
		text = str(pages[id].get("extract", ""))
		_title_label.text = str(pages[id].get("title", _titles[lang]))
	_clear_body()
	if text.strip_edges() == "":
		_set_status("Bu dilde madde metni bulunamadı.")
		return
	_render(text)
	_scroll.scroll_vertical = 0


func _on_article_failed(err: String, mine: int) -> void:
	if mine == _token:
		_clear_body()
		_set_status("Vikipedi'ye ulaşılamadı (%s). İnternet bağlantısını denetleyin ya da \"Tarayıcıda aç\"ı kullanın." % err)


## Plain-text extract: "== Heading ==" lines become headings, the rest paragraphs.
func _render(text: String) -> void:
	for raw in text.split("\n"):
		var line := raw.strip_edges()
		if line == "":
			continue
		if line.begins_with("=="):
			var h := line.trim_prefix("==").trim_suffix("==").strip_edges().trim_prefix("=").trim_suffix("=").strip_edges()
			if h in ["Notes", "References", "External links", "Further reading", "Dipnotlar", "Kaynakça", "Dış bağlantılar", "Ayrıca bakınız", "See also", "Notlar"]:
				continue
			_body.add_child(UIKit.section(h))
		else:
			_body.add_child(UIKit.rich(line.replace("[", "[lb]"), 13))
	_body.add_child(UIKit.label("Metin: Vikipedi, CC BY-SA 4.0.", 10, UIKit.MUTED, true))


func _clear_body() -> void:
	UIKit.clear(_body)
	_status = UIKit.label("", 12, UIKit.MUTED, true)
	_body.add_child(_status)


func _set_status(t: String) -> void:
	_status.text = t
	_status.visible = t != ""


## GET a JSON document; ok(data: Dictionary) or fail(reason: String).
func _fetch(url: String, ok: Callable, fail: Callable) -> void:
	var req := HTTPRequest.new()
	req.timeout = 20.0
	_layer.add_child(req)
	req.request_completed.connect(func(result: int, code: int, _h: PackedStringArray, body: PackedByteArray):
		req.queue_free()
		if result != HTTPRequest.RESULT_SUCCESS or code != 200:
			fail.call("HTTP %d" % code if result == HTTPRequest.RESULT_SUCCESS else "bağlantı hatası %d" % result)
			return
		var parsed = JSON.parse_string(body.get_string_from_utf8())
		if typeof(parsed) != TYPE_DICTIONARY:
			fail.call("geçersiz yanıt")
			return
		ok.call(parsed))
	var err := req.request(url, ["User-Agent: " + UA])
	if err != OK:
		req.queue_free()
		fail.call("istek başlatılamadı %d" % err)
