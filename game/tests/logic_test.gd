extends SceneTree

class FakeState:
	var month := 3
	var year := 1877
	var vals := {"harbiye": 60}
	var flags := {"x": true}
	var hist := false
	func value_of(id): return vals.get(id, 0)
	func has_flag(n): return flags.has(n)
	func historical(): return hist

var fails := 0


func check(name: String, cond: bool) -> void:
	if cond:
		print("OK   ", name)
	else:
		fails += 1
		print("FAIL ", name)


func near(a: float, b: float) -> bool:
	return absf(a - b) < 0.001


func _initialize() -> void:
	var L = load("res://game/scripts/logic.gd")
	var st := FakeState.new()
	check("null", L.eval_expr(null, st) == 0.0)
	check("v", L.eval_expr({"v": "harbiye"}, st) == 60.0)
	check("f", L.eval_expr({"f": "x"}, st) == 1.0 and L.eval_expr({"f": "y"}, st) == 0.0)
	check("k", L.eval_expr({"k": "ay"}, st) == 3.0 and L.eval_expr({"k": "yil"}, st) == 1877.0)
	check("div0", L.eval_expr({"op": "/", "a": {"n": 5}, "b": {"n": 0}}, st) == 0.0)
	check("arith", near(L.eval_expr({"op": "+", "a": {"op": "*", "a": {"n": 2}, "b": {"v": "harbiye"}}, "b": {"op": "neg", "a": {"n": 20}}}, st), 100.0))
	check("minmax", L.eval_expr({"fn": "min", "args": [{"n": 3}, {"n": 7}]}, st) == 3.0 and L.eval_expr({"fn": "max", "args": [{"n": 3}, {"n": 7}]}, st) == 7.0)

	var roll := {"t": "roll", "chance": {"n": 62}, "branches": [
		{"label": "başarı", "min": null, "effects": [], "hist": false},
		{"label": "başarısız", "min": null, "effects": [], "hist": true}]}
	var o: Array = L.branch_odds(roll, st)
	check("roll odds", near(o[0]["p"], 0.62) and near(o[1]["p"], 0.38))
	var lo := roll.duplicate(true)
	lo["chance"] = {"n": 1}
	check("roll clamp", near(L.branch_odds(lo, st)[0]["p"], 0.05))
	check("roll pick", L.pick_branch(roll, st, 0.61) == 0 and L.pick_branch(roll, st, 0.62) == 1)
	check("roll text", L.odds_text(roll, st) == "Başarı %62")

	var tier := {"t": "tier", "expr": {"n": 0}, "spread": 20, "branches": [
		{"label": "ezici", "min": 10, "hist": false},
		{"label": "zafer", "min": 0, "hist": false},
		{"label": "yenilgi", "min": -10, "hist": false},
		{"label": "bozgun", "min": null, "hist": true}]}
	var t: Array = L.branch_odds(tier, st)
	var sum := 0.0
	for b in t:
		sum += b["p"]
	check("tier odds", near(t[0]["p"], 0.25) and near(t[1]["p"], 0.25) and near(t[2]["p"], 0.25) and near(t[3]["p"], 0.25))
	check("tier sum", near(sum, 1.0))
	check("tier pick", L.pick_branch(tier, st, 1.0) == 0 and L.pick_branch(tier, st, 0.0) == 1 and L.pick_branch(tier, st, -0.25) == 2 and L.pick_branch(tier, st, -1.0) == 3)
	var tw := tier.duplicate(true)
	tw["expr"] = {"n": 50}
	check("tier hide zero", L.odds_text(tw, st) == "ezici %100")
	check("tier text", L.odds_text(tier, st) == "ezici %25 · zafer %25 · yenilgi %25 · bozgun %25")
	st.hist = true
	var h: Array = L.branch_odds(tier, st)
	check("hist odds", h[3]["p"] == 1.0 and h[0]["p"] == 0.0)
	check("hist pick", L.pick_branch(tier, st, 1.0) == 3 and L.pick_branch(roll, st, 0.0) == 1)
	check("chips skip", L.effect_chips([roll, tier], {}) == "")
	print("FAILS: ", fails)
	quit(1 if fails > 0 else 0)
