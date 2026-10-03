extends SceneTree
## Engine checks for the rework: seeded RNG, roll/tier branches, MTTH triggers, value ledger, save/load.

const GameState := preload("res://game/scripts/game_state.gd")

var fails := 0


func check(name: String, cond: bool) -> void:
	if cond:
		print("OK   ", name)
	else:
		fails += 1
		print("FAIL ", name)


func _txt(s: String) -> Dictionary:
	return {"parts": [s]}


func _fresh() -> GameState:
	var gs := GameState.new()
	root.add_child(gs)
	gs.load_data()
	# a fake rolled paper and a fake trigger, copied from a real event for the required fields
	var base: Dictionary = {}
	for ev in gs.event_order:
		if ev["kind"] == "isteğe bağlı" and ev.get("slot") == null:
			base = ev
			break
	var roll := {"t": "roll", "chance": {"n": 50}, "branches": [
		{"label": "başarı", "min": null, "effects": [{"t": "res", "id": "para", "d": 1}, {"t": "flag", "name": "t_basari", "on": true}], "text": "BASARI", "hist": false},
		{"label": "başarısız", "min": null, "effects": [{"t": "flag", "name": "t_basarisiz", "on": true}], "text": "BASARISIZ", "hist": true}]}
	var fake: Dictionary = base.duplicate(true)
	fake["id"] = "t_sahte"
	fake["title"] = "Sahte"
	fake["kind"] = "zorunlu"
	fake["tags"] = []
	fake["slot"] = null
	fake["cond"] = null
	fake["date"] = {"y": 1873, "m": 2}
	fake["until"] = null
	fake["options"] = [{"label": "Dene", "hist": 0, "effects": [roll], "outcome": "", "cond": null, "alt": false}]
	var trig: Dictionary = base.duplicate(true)
	trig["id"] = "t_tetik"
	trig["title"] = "Sahte tetik"
	trig["kind"] = "tetik"
	trig["tags"] = ["alternatif"]
	trig["slot"] = null
	trig["cond"] = null
	trig["date"] = {"y": 1873, "m": 3}
	trig["until"] = null
	trig["mtth"] = 6
	trig["options"] = [{"label": "Tamam", "hist": null, "effects": [], "outcome": "", "cond": null, "alt": true}]
	for e in [fake, trig]:
		gs.events[e["id"]] = e
		gs.event_order.append(e)
	return gs


func _branch_run(gs: GameState, seed: int, mode := "serbest") -> String:
	gs.new_game(mode, "ayrintili", 1873, seed)
	gs.year = 1873
	gs.month = 2
	var r := gs.choose("t_sahte", 0)
	return str(r.get("branch", "")) + "|" + str(r.get("outcome", ""))


func _initialize() -> void:
	var gs := _fresh()
	# same seed, same result
	var a := _branch_run(gs, 77)
	var b := _branch_run(gs, 77)
	check("aynı tohum aynı sonuç (%s)" % a, a == b and a != "|")
	var seen := {}
	for s in range(1, 41):
		seen[_branch_run(gs, s).split("|")[0]] = true
	check("farklı tohumlarla iki dal da görülür", seen.has("başarı") and seen.has("başarısız"))
	var h := _branch_run(gs, 5, "tarihi")
	check("tarihî modda hist dalı (%s)" % h, h.begins_with("başarısız|") and h.contains("BASARISIZ"))
	check("dal kaydı history'de", str(gs.history[-1].get("branch", "")) == "başarısız" and str(gs.history[-1].get("branch_text", "")) == "BASARISIZ")
	# trigger in Fantezi eventually queues; never in Tarihî (alternatif)
	gs.new_game("serbest", "ayrintili", 1873, 9)
	var got := false
	for i in 400:
		gs._trigger_tick()
		gs.month += 1
		if gs.month > 12:
			gs.month = 1
			gs.year += 1
		if gs.queued.has("t_tetik"):
			got = true
			break
	check("tetik Fantezi'de kuyruğa girer (ay %d)" % [gs.now_key() - Logic_date(1873, 3)], got)
	check("kuyruktaki tetik açık ve zorunlu", gs.open_events().any(func(ev): return ev["id"] == "t_tetik") and not gs.can_advance())
	gs.new_game("tarihi", "ayrintili", 1873, 9)
	for i in 300:
		gs._trigger_tick()
		gs.month += 1
		if gs.month > 12:
			gs.month = 1
			gs.year += 1
	check("alternatif tetik Tarihî'de gelmez", not gs.queued.has("t_tetik"))
	gs.new_game("serbest", "ayrintili", 1873, 9)
	gs.year = 1873
	gs.month = 2
	check("tetik tarihinde kendiliğinden açılmaz", not gs.open_events().any(func(ev): return ev["id"] == "t_tetik"))
	# value log and save/load
	gs.new_game("serbest", "ayrintili", 1873, 3)
	gs.year = 1873
	gs.month = 2
	gs.choose("t_sahte", 0)
	gs.advance()
	check("value_log dolu", not gs.value_log.is_empty())
	gs.save_game()
	var next_a := gs.rng.randf()
	var gs2 := GameState.new()
	root.add_child(gs2)
	gs2.load_data()
	var ok := gs2.load_game()
	check("save/load rng durumunu korur", ok and gs2.rng_seed == 3 and gs2.rng.randf() == next_a and gs2.value_log.size() == gs.value_log.size())
	print("engine_test: %s" % ("OK" if fails == 0 else "FAIL (%d)" % fails))
	quit(0 if fails == 0 else 1)


func Logic_date(y: int, m: int) -> int:
	return y * 12 + (m - 1)
