extends RefCounted
## Pure helpers: condition evaluation and effect descriptions.
## Conditions arrive pre-parsed from game/tools/build_events.py as JSON trees:
##   {"op":"and"|"or","args":[...]}, {"op":"not","arg":...}, {"op":"flag","name":...},
##   {"op":"cmp","cmp":">=","left":[[sign,"id"],...],"right":N},
##   {"op":"state","key":"reji","eq":true,"val":"milli"}, {"op":"prov","layer":"ctl"|"own","id":"kars","eq":true,"val":"RU"}
## Numeric expressions (REWORK §1) are ASTs: {"n":3.5}, {"v":id}, {"f":flag}, {"k":"ay"|"yil"},
##   {"op":"+"|"-"|"*"|"/","a":X,"b":X}, {"op":"neg","a":X}, {"fn":"min"|"max","args":[X,X]}; see eval_expr.
## Probabilistic effects (REWORK §2): {"t":"roll",...} and {"t":"tier",...}; see branch_odds, pick_branch, odds_text.


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
		if e["t"] in ["roll", "tier"]:
			continue
		if e["t"] == "res" and resources.has(e["id"]) and resources[e["id"]]["visible"]:
			var d := int(e["d"])
			var s := "+" if d > 0 else "−"
			parts.append("%s %s%d" % [resources[e["id"]]["name"], s, absi(d)])
	return " · ".join(parts)

## Evaluates a numeric expression AST (REWORK §1). null -> 0.0; division by zero -> 0.0.
static func eval_expr(node, state) -> float:
	if node == null:
		return 0.0
	if node.has("n"):
		return float(node["n"])
	if node.has("v"):
		return float(state.value_of(node["v"]))
	if node.has("f"):
		return 1.0 if state.has_flag(node["f"]) else 0.0
	if node.has("k"):
		return float(state.month) if node["k"] == "ay" else float(state.year)
	if node.has("fn"):
		var args: Array = node["args"]
		var a := eval_expr(args[0], state)
		var b := eval_expr(args[1], state)
		return minf(a, b) if node["fn"] == "min" else maxf(a, b)
	match node.get("op", ""):
		"neg":
			return -eval_expr(node["a"], state)
		"+":
			return eval_expr(node["a"], state) + eval_expr(node["b"], state)
		"-":
			return eval_expr(node["a"], state) - eval_expr(node["b"], state)
		"*":
			return eval_expr(node["a"], state) * eval_expr(node["b"], state)
		"/":
			var d := eval_expr(node["b"], state)
			return 0.0 if d == 0.0 else eval_expr(node["a"], state) / d
	return 0.0


static func _hist_index(effect: Dictionary) -> int:
	var br: Array = effect["branches"]
	for i in br.size():
		if br[i].get("hist", false):
			return i
	return -1


## Branch probabilities of a roll/tier effect: Array of {label, p} (p in 0..1).
static func branch_odds(effect: Dictionary, state) -> Array:
	var br: Array = effect["branches"]
	var out: Array = []
	if state.historical():
		var h := _hist_index(effect)
		if h >= 0:
			for i in br.size():
				out.append({"label": br[i]["label"], "p": 1.0 if i == h else 0.0})
			return out
	if effect["t"] == "roll":
		var p := clampf(eval_expr(effect["chance"], state), 5.0, 95.0) / 100.0
		return [{"label": br[0]["label"], "p": p}, {"label": br[1]["label"], "p": 1.0 - p}]
	var x := eval_expr(effect["expr"], state)
	var s := maxf(float(effect.get("spread", 10)), 0.001)
	var lo := x - s
	var hi := x + s
	var upper := INF
	for i in br.size():
		var m = br[i]["min"]
		var b_lo := -INF if m == null else float(m)
		var overlap := maxf(0.0, minf(hi, upper) - maxf(lo, b_lo))
		out.append({"label": br[i]["label"], "p": overlap / (2.0 * s)})
		if m != null:
			upper = b_lo
	return out


## Picks a branch index. roll: r in [0,1); tier: r in [-1,1]. Historical mode returns the hist branch.
static func pick_branch(effect: Dictionary, state, r: float) -> int:
	var br: Array = effect["branches"]
	if state.historical():
		var h := _hist_index(effect)
		if h >= 0:
			return h
	if effect["t"] == "roll":
		var p := clampf(eval_expr(effect["chance"], state), 5.0, 95.0) / 100.0
		return 0 if r < p else 1
	var x := eval_expr(effect["expr"], state) + r * float(effect.get("spread", 10))
	for i in br.size():
		var m = br[i]["min"]
		if m != null and x >= float(m):
			return i
	return br.size() - 1


## Preview text of a roll/tier effect: "Başarı %62" or "ezici %10 · zafer %35 · ...".
static func odds_text(effect: Dictionary, state) -> String:
	var odds := branch_odds(effect, state)
	if effect["t"] == "roll":
		var lbl := str(odds[0]["label"])
		return "%s %%%d" % [lbl.substr(0, 1).to_upper() + lbl.substr(1), roundi(float(odds[0]["p"]) * 100.0)]
	var parts: PackedStringArray = []
	for o in odds:
		var pct := roundi(float(o["p"]) * 100.0)
		if pct > 0:
			parts.append("%s %%%d" % [o["label"], pct])
	return " · ".join(parts)


## True if an option sets or clears a flag (the UI shows "Bu karar hatırlanacak").
static func remembers(effects: Array) -> bool:
	for e in effects:
		if e["t"] in ["flag", "world", "prov"]:
			return true
		if e["t"] == "if" and remembers(e["then"]):
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
