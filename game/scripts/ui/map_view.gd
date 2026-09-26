extends Control
## The atlas: provinces painted in the colour of whoever holds them, hatched with the owner's colour where the
## two differ (Egypt after 1882), pan (drag) and zoom (wheel). Markers (landmarks, papers, fronts, people) are
## child controls pinned to a lon/lat and moved with the camera. Nothing overlaps: after every move the markers
## are laid out by priority and a marker that would cover a more important one is hidden (its name stays in the
## tooltip of its dot); province names are drawn only where they fit between the markers and each other.

const UIKit := preload("res://game/scripts/ui/ui_kit.gd")
const MAP_PATH := "res://game/data/map/provinces.json"
const PX_PER_DEG := 20.0

signal province_clicked(id: String)

var state                              # GameState
var provinces: Dictionary = {}         # id -> {polys: [PackedVector2Array], tris: [PackedInt32Array], label: Vector2, neighbors}
var neutral: Array = []                # [{poly, tris}]
var bounds := Rect2()
var ref_k := 1.0
var lon0 := 0.0
var lat1 := 0.0
var zoom := 1.0
var offset := Vector2.ZERO             # screen position of world origin
var selected := ""
var highlight: Dictionary = {}         # province id -> Color (front lines, events)
var markers: Array = []                # [{node, lonlat, px (pixel offset), min_zoom, prio, group}]
var left_inset := 0.0                  # width covered by the desk's left column: fit() frames the map beside it
var pulse = null                       # lon/lat of a ring drawn while the pointer rests on a paper card
var _occupied: Array = []              # screen rects of the markers shown, for the province names
var _resolve_queued := false
var _hatch: ImageTexture
var _dragging := false
var _drag_moved := 0.0
var _fitted := false
var _user_moved := false          # until the player pans or zooms, a window resize re-frames the map


func _ready() -> void:
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	_hatch = _make_hatch()
	_load()
	# the size may already be final when _ready runs (no resized signal follows): frame the map next frame too
	(func():
		if not _user_moved and size.x > 10:
			fit()).call_deferred()
	resized.connect(func():
		if not _user_moved and size.x > 10:
			fit()
		_clamp()
		queue_redraw()
		_place_markers())


func _load() -> void:
	var f := FileAccess.open(MAP_PATH, FileAccess.READ)
	if f == null:
		push_error("missing %s — run python3 game/tools/build_map.py" % MAP_PATH)
		return
	var d: Dictionary = JSON.parse_string(f.get_as_text())
	var b: Array = d["bounds"]
	lon0 = float(b[0])
	lat1 = float(b[3])
	ref_k = cos(deg_to_rad(float(d.get("ref_lat", 38.0))))
	bounds = Rect2(Vector2.ZERO, _world(Vector2(float(b[2]), float(b[1]))))
	for id in d["provinces"]:
		var src: Dictionary = d["provinces"][id]
		var polys: Array = []
		var tris: Array = []
		for pl in src["polys"]:
			var pts := PackedVector2Array()
			for p in pl:
				pts.append(_world(Vector2(float(p[0]), float(p[1]))))
			var t := Geometry2D.triangulate_polygon(pts)
			if t.is_empty():
				continue
			polys.append(pts)
			tris.append(t)
		var lp: Array = src["label"]
		provinces[id] = {"polys": polys, "tris": tris, "label": _world(Vector2(float(lp[0]), float(lp[1]))),
			"lonlat_label": Vector2(float(lp[0]), float(lp[1])), "neighbors": src.get("neighbors", []),
			"area": float(src.get("area", 1.0))}
	for pl in d.get("neutral", []):
		var pts := PackedVector2Array()
		for p in pl:
			pts.append(_world(Vector2(float(p[0]), float(p[1]))))
		var t := Geometry2D.triangulate_polygon(pts)
		if not t.is_empty():
			neutral.append({"poly": pts, "tris": t})


func _world(lonlat: Vector2) -> Vector2:
	return Vector2((lonlat.x - lon0) * ref_k, lat1 - lonlat.y) * PX_PER_DEG


func lonlat_to_screen(lonlat: Vector2) -> Vector2:
	return offset + _world(lonlat) * zoom


func screen_to_world(p: Vector2) -> Vector2:
	return (p - offset) / zoom


## Frame the Ottoman lands (Balkans to Basra) in the view.
func fit() -> void:
	if size.x < 10:
		return
	_fitted = true
	var a := _world(Vector2(16.0, 47.5))
	var c := _world(Vector2(50.0, 27.0))
	var r := Rect2(a, c - a)
	var view := Rect2(left_inset, 38.0, size.x - left_inset, size.y - 38.0)
	zoom = minf(view.size.x / r.size.x, view.size.y / r.size.y)
	offset = view.get_center() - (r.position + r.size / 2.0) * zoom
	_clamp()
	queue_redraw()
	_place_markers()


func center_on(lonlat: Vector2) -> void:
	offset = size / 2.0 - _world(lonlat) * zoom
	_clamp()
	queue_redraw()
	_place_markers()


## Keep the atlas sheet covering the view: no zooming out past its edges, no dragging it off-screen.
func _clamp() -> void:
	var min_zoom := maxf(size.x / bounds.size.x, size.y / bounds.size.y) if bounds.size.x > 0 else 0.6
	zoom = clampf(zoom, min_zoom, 9.0)
	var w := bounds.size * zoom
	offset.x = clampf(offset.x, size.x - w.x, 0.0)
	offset.y = clampf(offset.y, size.y - w.y, 38.0)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if event.pressed:
				_user_moved = true
				var f := 1.15 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0 / 1.15
				var before := screen_to_world(event.position)
				zoom *= f
				_clamp()
				offset = event.position - before * zoom
				_clamp()
				queue_redraw()
				_place_markers()
			accept_event()
		elif event.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE]:
			if event.pressed:
				_dragging = true
				_drag_moved = 0.0
			else:
				_dragging = false
				if event.button_index == MOUSE_BUTTON_LEFT and _drag_moved < 5.0:
					var id := province_at(screen_to_world(event.position))
					selected = id
					queue_redraw()
					province_clicked.emit(id)
			accept_event()
	elif event is InputEventMouseMotion and _dragging:
		_drag_moved += event.relative.length()
		_user_moved = true
		offset += event.relative
		_clamp()
		queue_redraw()
		_place_markers()
		accept_event()
	elif event is InputEventPanGesture:
		offset -= event.delta * 20.0
		_clamp()
		queue_redraw()
		_place_markers()
	elif event is InputEventMagnifyGesture:
		zoom *= event.factor
		_clamp()
		queue_redraw()
		_place_markers()


func province_at(world_pos: Vector2) -> String:
	for id in provinces:
		for pl in provinces[id]["polys"]:
			if Geometry2D.is_point_in_polygon(world_pos, pl):
				return id
	return ""


func _make_hatch() -> ImageTexture:
	var img := Image.create(8, 8, false, Image.FORMAT_RGBA8)
	for y in 8:
		for x in 8:
			var on := (x + y) % 8 < 3
			img.set_pixel(x, y, Color(1, 1, 1, 1) if on else Color(1, 1, 1, 0))
	return ImageTexture.create_from_image(img)


func _fill(pts: PackedVector2Array, tris: PackedInt32Array, color: Color, tex: Texture2D = null) -> void:
	var cols := PackedColorArray()
	cols.resize(pts.size())
	cols.fill(color)
	var uvs := PackedVector2Array()
	if tex != null:
		uvs.resize(pts.size())
		for i in pts.size():
			uvs[i] = pts[i] * zoom / 8.0
	RenderingServer.canvas_item_add_triangle_array(get_canvas_item(), tris, pts, cols, uvs, PackedInt32Array(),
		PackedFloat32Array(), tex.get_rid() if tex != null else RID())


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), UIKit.SEA)
	draw_set_transform(offset, 0.0, Vector2(zoom, zoom))
	# the atlas graticule, every five degrees
	var grid := Color(UIKit.BORDER, 0.12)
	for lon in range(5, 65, 5):
		draw_line(_world(Vector2(lon, 54)), _world(Vector2(lon, 10)), grid, 1.0 / zoom)
	for lat in range(10, 55, 5):
		draw_line(_world(Vector2(5, lat)), _world(Vector2(63, lat)), grid, 1.0 / zoom)
	for n in neutral:
		_fill(n["poly"], n["tris"], UIKit.LAND.darkened(0.04))
	var line_w := 1.0 / zoom
	for id in provinces:
		var p: Dictionary = provinces[id]
		var holder: String = state.province_holder(id, "ctl") if state else ""
		var owner: String = state.province_holder(id, "own") if state else ""
		var col := UIKit.nation_color(holder)
		if highlight.has(id):
			col = col.lerp(highlight[id], 0.35)
		for i in p["polys"].size():
			_fill(p["polys"][i], p["tris"][i], col)
			if owner != holder and owner != "":
				_fill(p["polys"][i], p["tris"][i], UIKit.nation_color(owner).darkened(0.1), _hatch)
	for n in neutral:
		draw_polyline(_closed(n["poly"]), UIKit.BORDER.lightened(0.3), line_w * 0.8, true)
	for id in provinces:
		var outline := UIKit.BORDER
		var w := line_w
		if id == selected:
			outline = Color("f6e7b0")
			w = line_w * 2.6
		for pl in provinces[id]["polys"]:
			draw_polyline(_closed(pl), outline, w, true)
	draw_set_transform(Vector2.ZERO)
	_draw_labels()
	if pulse != null:
		var c := lonlat_to_screen(pulse)
		draw_arc(c, 22.0, 0, TAU, 48, Color("f6e7b0"), 3.0, true)
		draw_arc(c, 28.0, 0, TAU, 48, Color(UIKit.RED, 0.8), 2.0, true)
	draw_rect(Rect2(Vector2.ZERO, size), UIKit.BORDER, false, 3.0)


func _closed(pts: PackedVector2Array) -> PackedVector2Array:
	var out := pts.duplicate()
	out.append(pts[0])
	return out


func _draw_labels() -> void:
	var font := get_theme_default_font()
	var taken: Array = _occupied.duplicate()
	var ids := provinces.keys()
	ids.sort_custom(func(a, b): return provinces[a]["area"] > provinces[b]["area"])  # big provinces first
	for id in ids:
		var p: Dictionary = provinces[id]
		# bigger provinces get their name earlier while zooming in
		if p["area"] * zoom * zoom < 18.0:
			continue
		var name: String = str(state.provinces.get(id, {}).get("name", id)) if state else str(id)
		if " (" in name:
			name = name.split(" (")[0]
		var pos: Vector2 = offset + p["label"] * zoom
		var fs := int(clampf(9.0 + zoom * 1.2, 10.0, 15.0))
		var w := font.get_string_size(name, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		var r := Rect2(pos.x - w / 2.0 - 2.0, pos.y - fs * 0.7, w + 4.0, fs * 1.2)
		if taken.any(func(o): return o.intersects(r)):
			continue
		taken.append(r)
		draw_string(font, pos - Vector2(w / 2.0, -4.0), name, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(UIKit.BORDER, 0.75))


# ---------------------------------------------------------------- markers

func clear_markers() -> void:
	for m in markers:
		if is_instance_valid(m["node"]):
			m["node"].queue_free()
	markers.clear()


## Pin a control at a lon/lat; `px` shifts it in screen pixels (used to fan out İstanbul's landmarks).
## `prio` decides who stays when two markers overlap; markers of the same `group` (one place) may overlap.
## `alts` are other pixel shifts to try before hiding it (people step aside instead of vanishing).
func add_marker(node: Control, lonlat: Vector2, px := Vector2.ZERO, min_zoom := 0.0, prio := 0, group := "",
		alts: Array = []) -> void:
	add_child(node)
	markers.append({"node": node, "lonlat": lonlat, "px": px, "min_zoom": min_zoom, "prio": prio, "group": group,
		"alts": alts})
	_place_marker(markers[-1])
	if not _resolve_queued:
		_resolve_queued = true
		(func():
			_resolve_queued = false
			_resolve()).call_deferred()


func _place_markers() -> void:
	for m in markers:
		_place_marker(m)
	_resolve()


## Hide every marker that would cover a more important one; remember what is shown for the province names.
func _resolve() -> void:
	var order: Array = markers.filter(func(m): return is_instance_valid(m["node"]) and m["node"].visible)
	order.sort_custom(func(a, b): return a["prio"] > b["prio"])
	var shown: Array = []   # [rect, group]
	var view := Rect2(Vector2.ZERO, size)
	for m in order:
		var n: Control = m["node"]
		var base := n.position
		var placed := false
		for shift in [Vector2.ZERO] + m.get("alts", []):
			var r := Rect2(base + shift, n.size).grow(-1.0)
			if not view.intersects(r):
				placed = true
				break
			var hit := false
			for s in shown:
				if s[1] != m["group"] or m["group"] == "":
					if s[0].intersects(r):
						hit = true
						break
			if not hit:
				n.position = base + shift
				shown.append([r, m["group"]])
				placed = true
				break
		if not placed:
			n.visible = false
	_occupied = shown.map(func(s): return s[0])
	queue_redraw()


func _place_marker(m: Dictionary) -> void:
	var n: Control = m["node"]
	if not is_instance_valid(n):
		return
	var s := n.get_combined_minimum_size()
	if n.size.x < s.x or n.size.y < s.y:
		n.size = s
	n.position = lonlat_to_screen(m["lonlat"]) + m["px"] - n.size / 2.0
	n.visible = zoom >= m["min_zoom"]
