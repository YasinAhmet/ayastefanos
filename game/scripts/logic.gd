extends RefCounted
## Pure helpers: condition evaluation and effect descriptions.
## Conditions arrive pre-parsed from game/tools/build_events.py as JSON trees:
##   {"op":"and"|"or","args":[...]}, {"op":"not","arg":...}, {"op":"flag","name":...},
##   {"op":"cmp","cmp":">=","left":[[sign,"id"],...],"right":N},
##   {"op":"state","key":"reji","eq":true,"val":"milli"}, {"op":"prov","layer":"ctl"|"own","id":"kars","eq":true,"val":"RU"}


static func eval_cond(node, state) -> bool:
	if node == null:
		return true
	match node["op"]:
		"and":
			for a in node["args"]:
				if not eval_cond(a, state):
					return false
			return true
		"or":
			for a in node["args"]:
				if eval_cond(a, state):
					return true
			return false
		"not":
			return not eval_cond(node["arg"], state)
		"flag":
			return state.has_flag(node["name"])
		"state":
			return (state.world_value(node["key"]) == str(node["val"])) == bool(node["eq"])
		"prov":
			return (state.province_holder(node["id"], node["layer"]) == str(node["val"])) == bool(node["eq"])
		"cmp":
			var total := 0
			for term in node["left"]:
				total += int(term[0]) * state.value_of(term[1])
			var right := int(node["right"])
			match node["cmp"]:
				">=": return total >= right
				"<=": return total <= right
				">": return total > right
				"<": return total < right
				"=": return total == right
				"!=": return total != right
	push_warning("unknown condition node %s" % [node])
	return false


## Resolves a compiled text: a plain BBCode string, or {cond, parts} with [eğer: …] / {eğer …} variants.
## Returns "" when the paragraph's own condition fails.
static func txt(t, state) -> String:
	if t == null:
		return ""
	if typeof(t) == TYPE_STRING:
		return t
	if not eval_cond(t.get("cond"), state):
		return ""
	var out := ""
	for p in t["parts"]:
		if typeof(p) == TYPE_STRING:
			out += p
		else:
			out += str(p["a"]) if eval_cond(p.get("cond"), state) else str(p.get("b", ""))
	return out


## Short cost chips for the visible resources an option changes, e.g. "Para −10 · Harbiye +5".
static func effect_chips(effects: Array, resources: Dictionary) -> String:
	var parts: PackedStringArray = []
	for e in effects:
		if e["t"] == "res" and resources.has(e["id"]) and resources[e["id"]]["visible"]:
			var d := int(e["d"])
			var s := "+" if d > 0 else "−"
			parts.append("%s %s%d" % [resources[e["id"]]["name"], s, absi(d)])
	return " · ".join(parts)


## True if an option sets or clears a flag (the UI shows "Bu karar hatırlanacak").
static func remembers(effects: Array) -> bool:
	for e in effects:
		if e["t"] == "flag":
			return true
	return false


static func date_key(y: int, m: int) -> int:
	return y * 12 + (m - 1)


const MONTHS := ["Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"]


static func date_text(y: int, m: int) -> String:
	return "%s %d" % [MONTHS[clampi(m, 1, 12) - 1], y]


## Loads a texture from res:// even when the editor has not imported it yet.
static func load_texture(path) -> Texture2D:
	if path == null or str(path) == "":
		return null
	var p := str(path)
	if ResourceLoader.exists(p):
		var t = load(p)
		if t is Texture2D:
			return t
	var img := Image.load_from_file(ProjectSettings.globalize_path(p))
	if img == null or img.is_empty():
		return null
	return ImageTexture.create_from_image(img)
