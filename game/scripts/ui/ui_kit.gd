extends RefCounted
## Small helpers so every panel looks the same: dark walnut panels with brass edges over a Victorian atlas map.

const Logic := preload("res://game/scripts/logic.gd")

const BG := Color("1d1712")
const PANEL := Color("2b2219")
const PANEL_2 := Color("3a2e22")
const INK := Color("eadfc8")
const MUTED := Color("ab9d82")
const GOLD := Color("c8a15c")
const RED := Color("a8413a")
const GREEN := Color("6f8f55")
const ALT := Color("8a73b0")
const SEAL := Color("8e2a22")      # wax seal of a mandatory paper
const SEAL_2 := Color("6b5236")    # optional paper

# Victorian atlas palette: parchment land, grey-green sea, muted nation tints, ink borders.
const SEA := Color("aebfb8")
const SEA_DEEP := Color("9fb2ac")
const LAND := Color("e2d5b6")
const BORDER := Color("4a3a2a")
const NATION_COLORS := {
	"OS": Color("bf7a5f"), "RU": Color("8fa272"), "IN": Color("d8a0a0"), "FR": Color("8397b5"),
	"AL": Color("9d9486"), "AV": Color("d7bf76"), "IT": Color("c4a2bd"), "YU": Color("93b7cc"),
	"BU": Color("aab96d"), "SR": Color("b58c6c"), "RO": Color("d9b98f"), "MI": Color("dcc070"),
	"IR": Color("a7bca0"), "AR": Color("cdb68e"), "ER": Color("b9a0a0"), "KU": Color("b3a37f"),
	"RS": Color("d4b27a"), "AB": Color("b87a8a"),
}

const FONT := 13
const SETTINGS_PATH := "user://settings.cfg"

## "Kaynakçaları göster" (menu): when off, sources and the Tarihî bases are not shown at all.
static var show_sources := false


static func load_settings() -> void:
	var cf := ConfigFile.new()
	if cf.load(SETTINGS_PATH) == OK:
		show_sources = bool(cf.get_value("ui", "show_sources", false))


static func save_settings() -> void:
	var cf := ConfigFile.new()
	cf.load(SETTINGS_PATH)
	cf.set_value("ui", "show_sources", show_sources)
	cf.save(SETTINGS_PATH)


## The sources of a panel: shown only when "Kaynakçaları göster" is on.
static func add_sources(box: Control, sources: Array, linked: Callable, size := 10) -> void:
	if sources.is_empty():
		return
	if not show_sources:
		return  # the setting hides every trace of the sources
	for s in sources:
		box.add_child(linked.call("[color=#ab9d82]%s[/color]" % s, size))


static func nation_color(code: String) -> Color:
	return NATION_COLORS.get(code, Color("cfc2a2"))


static func panel_style(color := PANEL, border := GOLD, radius := 3) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.border_color = border
	s.set_border_width_all(1)
	s.set_corner_radius_all(radius)
	s.content_margin_left = 10
	s.content_margin_right = 10
	s.content_margin_top = 7
	s.content_margin_bottom = 7
	s.shadow_color = Color(0, 0, 0, 0.35)
	s.shadow_size = 3
	return s


static func panel(color := PANEL) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", panel_style(color))
	return p


static func label(text: String, size := FONT, color := INK, wrap := false) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	if wrap:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l


static func rich(bbcode: String, size := FONT) -> RichTextLabel:
	var r := RichTextLabel.new()
	r.bbcode_enabled = true
	r.fit_content = true
	r.scroll_active = false
	r.selection_enabled = true
	r.add_theme_font_size_override("normal_font_size", size)
	r.add_theme_font_size_override("bold_font_size", size)
	r.add_theme_font_size_override("italics_font_size", size)
	r.add_theme_color_override("default_color", INK)
	r.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if not bbcode.contains("{i:"):
		r.text = bbcode
		return r
	# source icons: {i:book} vault, {i:wiki} Wikipedia, {i:guess} assumption / alternative history
	var re := RegEx.new()
	re.compile("\\{i:(book|wiki|guess)\\}")
	var pos := 0
	for m in re.search_all(bbcode):
		if m.get_start() > pos:
			r.append_text(bbcode.substr(pos, m.get_start() - pos))
		var tex := icon(m.get_string(1))
		if tex:
			r.add_image(tex, size + 2, size + 2)
		pos = m.get_end()
	r.append_text(bbcode.substr(pos))
	return r


static var _icons := {}


static func icon(name: String) -> Texture2D:
	if not _icons.has(name):
		_icons[name] = Logic.load_texture("res://game/assets/ui/%s.png" % name)
	return _icons[name]


static func button(text: String, color := PANEL_2, size := FONT) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_font_size_override("font_size", size)
	b.add_theme_color_override("font_color", INK)
	b.add_theme_color_override("font_hover_color", Color.WHITE)
	b.add_theme_color_override("font_disabled_color", Color(MUTED, 0.6))
	for st in ["normal", "hover", "pressed", "disabled", "focus"]:
		var s := panel_style(color if st != "hover" else color.lightened(0.12), GOLD if st != "disabled" else Color(MUTED, 0.3), 3)
		s.shadow_size = 0
		s.content_margin_top = 3
		s.content_margin_bottom = 3
		s.content_margin_left = 8
		s.content_margin_right = 8
		if st == "disabled":
			s.bg_color = color.darkened(0.3)
		if st == "focus":
			s.draw_center = false
		b.add_theme_stylebox_override(st, s)
	return b


## A round wax seal with a count: mandatory papers are red, optional ones brown, alternative ones violet.
static func seal(text: String, color := SEAL, diameter := 22) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(diameter, diameter)
	b.add_theme_font_size_override("font_size", 11)
	b.add_theme_color_override("font_color", Color("f3e6c8"))
	b.add_theme_color_override("font_hover_color", Color.WHITE)
	for st in ["normal", "hover", "pressed", "focus"]:
		var s := StyleBoxFlat.new()
		s.bg_color = color if st != "hover" else color.lightened(0.15)
		s.set_corner_radius_all(diameter)
		s.border_color = color.darkened(0.45)
		s.set_border_width_all(2)
		s.shadow_color = Color(0, 0, 0, 0.4)
		s.shadow_size = 2
		s.shadow_offset = Vector2(1, 1)
		if st == "focus":
			s.draw_center = false
		b.add_theme_stylebox_override(st, s)
	return b


static func vbox(sep := 6) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", sep)
	return v


static func hbox(sep := 6) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", sep)
	return h


static func image(path, max_h := 160) -> TextureRect:
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


## A portrait at its own proportions, `height` tall (the ruler's card); a medallion when there is no image.
static func portrait(path, height := 96, initials := "") -> Control:
	var tex := Logic.load_texture(path)
	if tex == null:
		return medallion(path, height, initials)
	var t := TextureRect.new()
	t.texture = tex
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.custom_minimum_size = Vector2(round(height * float(tex.get_width()) / maxf(1.0, float(tex.get_height()))), height)
	t.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	t.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return t


## A square crop from the top of a portrait, masked to a circle (the ruler's medallion).
static func medallion(path, diameter := 56, initials := "") -> Control:
	var tex := Logic.load_texture(path)
	if tex == null:
		# no portrait in the vault's images: an engraved-looking roundel with the initials
		var c := Control.new()
		c.custom_minimum_size = Vector2(diameter, diameter)
		c.size = c.custom_minimum_size
		c.size_flags_horizontal = Control.SIZE_SHRINK_CENTER  # a container must never stretch the roundel
		c.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		c.draw.connect(func():
			var r := diameter / 2.0
			c.draw_circle(Vector2(r, r), r, Color("5a4632"))
			c.draw_arc(Vector2(r, r), r - 2.0, 0, TAU, 48, GOLD, 3.0, true)
			var font := c.get_theme_default_font()
			var fs := int(diameter * 0.42)
			var w := font.get_string_size(initials, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
			c.draw_string(font, Vector2(r - w / 2.0, r + fs * 0.36), initials, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, INK))
		return c
	var t := TextureRect.new()
	t.custom_minimum_size = Vector2(diameter, diameter)
	t.size = Vector2(diameter, diameter)
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.size_flags_horizontal = Control.SIZE_SHRINK_CENTER  # a container must never stretch the portrait
	t.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	if tex != null:
		var side := mini(tex.get_width(), tex.get_height())
		var at := AtlasTexture.new()
		at.atlas = tex
		at.region = Rect2((tex.get_width() - side) / 2.0, 0, side, side)
		t.texture = at
	var mat := ShaderMaterial.new()
	var sh := Shader.new()
	sh.code = """shader_type canvas_item;
uniform vec4 rim : source_color = vec4(0.78, 0.63, 0.36, 1.0);
void fragment() {
	float d = length(UV - vec2(0.5));
	if (d > 0.5) { discard; }
	vec4 c = texture(TEXTURE, UV);
	c.rgb = mix(c.rgb, vec3(dot(c.rgb, vec3(0.3, 0.59, 0.11))) * vec3(1.05, 0.95, 0.8), 0.35);
	COLOR = d > 0.44 ? rim : c;
}"""
	mat.shader = sh
	t.material = mat
	return t


## A dimmed full-screen layer with a centred panel `width` pixels wide (at most `max_h` of the screen height).
static func modal(parent: Control, frac := Vector2(0.4, 0.8), width := 0) -> Dictionary:
	var layer := Control.new()
	layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_STOP
	var dim := ColorRect.new()
	dim.color = Color(0.05, 0.03, 0.02, 0.45)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(dim)
	var p := panel(PANEL)
	if width > 0:
		p.anchor_left = 0.5
		p.anchor_right = 0.5
		p.offset_left = -width / 2.0
		p.offset_right = width / 2.0
	else:
		p.anchor_left = (1.0 - frac.x) / 2.0
		p.anchor_right = 1.0 - p.anchor_left
	p.anchor_top = (1.0 - frac.y) / 2.0
	p.anchor_bottom = 1.0 - p.anchor_top
	layer.add_child(p)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	p.add_child(scroll)
	var body := vbox(7)
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(body)
	parent.add_child(layer)
	dim.gui_input.connect(func(ev):
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_RIGHT:
			layer.queue_free())
	return {"layer": layer, "body": body, "scroll": scroll, "panel": p}


static func bar(value: int, color := GOLD, width := 48) -> ProgressBar:
	var b := ProgressBar.new()
	b.min_value = 0
	b.max_value = 100
	b.value = value
	b.show_percentage = false
	b.custom_minimum_size = Vector2(width, 5)
	var fg := StyleBoxFlat.new()
	fg.bg_color = color
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0, 0, 0, 0.4)
	b.add_theme_stylebox_override("fill", fg)
	b.add_theme_stylebox_override("background", bg)
	return b


## Two-sided balance bar: `value` 0–100 is how much of it belongs to the left side.
static func balance(value: float, left: Color, right: Color, width := 300) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(width, 12)
	c.draw.connect(func():
		var w := c.size.x
		var split := clampf(value / 100.0, 0.0, 1.0) * w
		c.draw_rect(Rect2(0, 0, split, c.size.y), left)
		c.draw_rect(Rect2(split, 0, w - split, c.size.y), right)
		c.draw_rect(Rect2(0, 0, w, c.size.y), GOLD, false, 1.0)
		c.draw_line(Vector2(w / 2.0, -2), Vector2(w / 2.0, c.size.y + 2), INK, 1.0))
	return c


static func section(text: String) -> Label:
	var l := label(text.to_upper(), 11, GOLD)
	l.add_theme_constant_override("outline_size", 0)
	return l


static func clear(node: Node) -> void:
	for c in node.get_children():
		node.remove_child(c)  # out of the layout now (its size must not count), freed at the end of the frame
		c.queue_free()
