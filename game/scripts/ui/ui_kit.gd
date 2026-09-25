extends RefCounted
## Small helpers so every panel looks the same. Text-and-image prototype: no art assets needed.

const Logic := preload("res://game/scripts/logic.gd")

const BG := Color("1b1814")
const PANEL := Color("2a241c")
const PANEL_2 := Color("342c22")
const INK := Color("efe6d2")
const MUTED := Color("b5a98f")
const GOLD := Color("c9a35a")
const RED := Color("b0413e")
const GREEN := Color("6f9a5b")
const ALT := Color("7f6aa8")


static func panel_style(color := PANEL, border := GOLD, radius := 6) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.border_color = border
	s.set_border_width_all(1)
	s.set_corner_radius_all(radius)
	s.content_margin_left = 14
	s.content_margin_right = 14
	s.content_margin_top = 10
	s.content_margin_bottom = 10
	return s


static func panel(color := PANEL) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", panel_style(color))
	return p


static func label(text: String, size := 16, color := INK, wrap := false) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	if wrap:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l


static func rich(bbcode: String, size := 16) -> RichTextLabel:
	var r := RichTextLabel.new()
	r.bbcode_enabled = true
	r.fit_content = true
	r.scroll_active = false
	r.selection_enabled = true
	r.add_theme_font_size_override("normal_font_size", size)
	r.add_theme_font_size_override("bold_font_size", size)
	r.add_theme_font_size_override("italics_font_size", size)
	r.add_theme_color_override("default_color", INK)
	r.text = bbcode
	r.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return r


static func button(text: String, color := PANEL_2, size := 16) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_font_size_override("font_size", size)
	b.add_theme_color_override("font_color", INK)
	b.add_theme_color_override("font_disabled_color", Color(MUTED, 0.6))
	for st in ["normal", "hover", "pressed", "disabled", "focus"]:
		var s := panel_style(color if st != "hover" else color.lightened(0.12), GOLD if st != "disabled" else Color(MUTED, 0.3), 4)
		s.content_margin_top = 6
		s.content_margin_bottom = 6
		s.content_margin_left = 10
		s.content_margin_right = 10
		if st == "disabled":
			s.bg_color = color.darkened(0.3)
		b.add_theme_stylebox_override(st, s)
	return b


static func vbox(sep := 8) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", sep)
	return v


static func hbox(sep := 8) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", sep)
	return h


static func image(path, max_h := 220) -> TextureRect:
	var tex := Logic.load_texture(path)
	if tex == null:
		return null
	var t := TextureRect.new()
	t.texture = tex
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.custom_minimum_size = Vector2(0, max_h)
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return t


## A dimmed full-screen layer with a centred panel covering `frac` of the screen (the GDD's 60% menu).
static func modal(parent: Control, frac := Vector2(0.6, 0.85)) -> Dictionary:
	var layer := Control.new()
	layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_STOP
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(dim)
	var p := panel(PANEL)
	p.anchor_left = (1.0 - frac.x) / 2.0
	p.anchor_right = 1.0 - p.anchor_left
	p.anchor_top = (1.0 - frac.y) / 2.0
	p.anchor_bottom = 1.0 - p.anchor_top
	layer.add_child(p)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	p.add_child(scroll)
	var body := vbox(10)
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(body)
	parent.add_child(layer)
	return {"layer": layer, "body": body, "scroll": scroll}


static func bar(value: int, color := GOLD) -> ProgressBar:
	var b := ProgressBar.new()
	b.min_value = 0
	b.max_value = 100
	b.value = value
	b.show_percentage = false
	b.custom_minimum_size = Vector2(56, 7)
	var fg := StyleBoxFlat.new()
	fg.bg_color = color
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0, 0, 0, 0.4)
	b.add_theme_stylebox_override("fill", fg)
	b.add_theme_stylebox_override("background", bg)
	return b


static func clear(node: Node) -> void:
	for c in node.get_children():
		c.queue_free()
