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
	# front state: transfer/incoming, stance, save/load
	gs.new_game("serbest", "ayrintili", 1873, 4)
	gs.values["harbiye"] = 80
	gs.flags["harp_93"] = true
	gs.flags["harpte"] = true
	gs.year = 1877
	gs.month = 7
	gs._front_tick()
	check("harpte cephe durumu oluşur", gs.fstate.has("tuna_93") and float(gs.fstate["tuna_93"]["div"]) > 0.0)
	var res0: int = gs.army_reserve()
	check("havuz: 80 harbiye → 48 tümen, cephelere ayrılmış", gs.army_total() == 48 and res0 == 48 - roundi(float(gs.fstate["tuna_93"]["div"]) + float(gs.fstate.get("kafkas_93", {}).get("div", 0.0))))
	var div0: float = float(gs.fstate["tuna_93"]["div"])
	check("transfer havuzdan gelir", gs.transfer("tuna_93", 3) and gs.army_reserve() == res0 - 3 and gs.fstate["tuna_93"]["incoming"].size() == 1)
	check("duruş değişir", gs.set_stance("tuna_93", "taarruz") and gs.fstate["tuna_93"]["stance"] == "taarruz" and not gs.set_stance("tuna_93", "uçmak"))
	gs.save_game()
	var gs3 := GameState.new()
	root.add_child(gs3)
	gs3.load_data()
	check("fstate kayıtta", gs3.load_game() and gs3.fstate["tuna_93"]["stance"] == "taarruz" and gs3.fstate["tuna_93"]["incoming"].size() == 1 and is_equal_approx(float(gs3.fstate["tuna_93"]["div"]), div0))
	gs.month = 9
	gs._front_tick()
	check("2 ay sonra incoming cepheye katılır", gs.fstate["tuna_93"]["incoming"].is_empty() and float(gs.fstate["tuna_93"]["div"]) > div0 + 2.0)
	var rep: Dictionary = gs.front_report("tuna_93")
	check("front_report anahtarları", rep.has_all(["ours", "enemy", "ratio", "cap", "eff", "expected_drift", "expected_losses", "morale", "div", "depth", "next_target", "overextended"]))
	check("geri transfer havuza döner", gs.transfer("tuna_93", -2) and gs.army_reserve() > res0 - 3)
	# Gündem (REWORK §10): synthetic focuses so the test does not depend on the content
	var ff := func(id: String, months: int, req: Array, exc: Array, hist: bool, effs: Array) -> Dictionary:
		return {"id": id, "name": "G " + id, "text": "", "from": 1873, "to": 1919, "months": months, "requires": req,
			"excludes": exc, "hist": hist, "cond": null, "effects": effs, "sources": [], "nation": "OS"}
	var fx := {
		"g_a": ff.call("g_a", 3, [], [], true, [{"t": "res", "id": "para", "d": 7}, {"t": "flag", "name": "t_gundem", "on": true}]),
		"g_b": ff.call("g_b", 2, ["g_a"], [], true, [{"t": "res", "id": "para", "d": 1}]),
		"g_c": ff.call("g_c", 2, [], ["g_d"], false, []),
		"g_d": ff.call("g_d", 2, [], ["g_c"], false, []),
	}
	gs.new_game("serbest", "ayrintili", 1873, 5)
	gs.focuses = fx
	gs.focus_order = fx.keys()
	check("focus: başlangıçta a açık, b kilitli (önce)", gs.focus_state("g_a") == "available" and gs.focus_state("g_b") == "locked" and gs.focus_lock_reason("g_b") != "")
	check("focus: Fantezi'de otomatik başlamaz", gs.focus_current == "")
	check("focus: kilitli başlatılamaz", not gs.start_focus("g_b"))
	var para0: int = gs.value_of("para")
	check("focus: start_focus", gs.start_focus("g_a") and gs.focus_current == "g_a" and gs.focus_progress == 0 and gs.focus_state("g_a") == "active")
	gs._focus_tick()
	gs._focus_tick()
	check("focus: ilerleme", gs.focus_progress == 2 and gs.focus_current == "g_a" and gs.value_of("para") == para0)
	check("focus: iptal ilerlemeyi siler", _cancel(gs) and gs.focus_current == "" and gs.focus_progress == 0 and gs.focus_state("g_a") == "available")
	gs.start_focus("g_a")
	gs._focus_tick()
	check("focus: yeni başlatma aktif olanın yerini alır", gs.start_focus("g_c") and gs.focus_current == "g_c" and gs.focus_progress == 0)
	gs.cancel_focus()
	gs.start_focus("g_a")
	for i in 3:
		gs._focus_tick()
	check("focus: tamamlanınca etki ve bayrak", gs.focus_state("g_a") == "done" and gs.value_of("para") == para0 + 7 and gs.has_flag("t_gundem") and gs.focus_current == "")
	check("focus: history ve year_log kaydı", gs.history[-1].get("focus", false) == true and gs.history[-1]["option"] == "Gündem tamamlandı" and gs.year_log[-1]["id"] == "g_a")
	check("focus: önce sağlanınca b açılır", gs.focus_state("g_b") == "available")
	check("focus: dışlama kilidi", gs.start_focus("g_c") and gs.focus_state("g_d") == "locked" and gs.focus_lock_reason("g_d").contains("G g_c"))
	gs.save_game()
	var gs4 := GameState.new()
	root.add_child(gs4)
	gs4.load_data()
	gs4.focuses = fx
	gs4.focus_order = fx.keys()
	check("focus: kayıtta", gs4.load_game() and gs4.focus_current == "g_c" and gs4.focus_done.has("g_a") and gs4.focus_progress == 0)
	gs.cancel_focus()
	check("focus: iptalde dışlama kalkar", gs.focus_state("g_d") == "available")
	# Tarihî: hist focuses run on their own, in order; the player cannot start one
	gs.new_game("tarihi", "ayrintili", 1873, 6)
	gs.focuses = fx
	gs.focus_order = fx.keys()
	gs._focus_auto()
	check("focus tarihî: ilk hist otomatik başlar", gs.focus_current == "g_a" and not gs.start_focus("g_c"))
	for i in 3:
		gs._focus_tick()
	check("focus tarihî: a bitince b başlar", gs.focus_done.has("g_a") and gs.focus_current == "g_b")
	for i in 2:
		gs._focus_tick()
	check("focus tarihî: hist biter, hist olmayan başlamaz", gs.focus_done.has("g_b") and gs.focus_current == "")
	gs.new_game("tarihi", "ayrintili", 1908, 7)
	check("focus tarihî: 1908 replay'inde gündemler yürüdü", not gs.focus_done.is_empty() or gs.focus_current != "")
	print("engine_test: %s" % ("OK" if fails == 0 else "FAIL (%d)" % fails))
	quit(0 if fails == 0 else 1)


func Logic_date(y: int, m: int) -> int:
	return y * 12 + (m - 1)


func _cancel(gs: GameState) -> bool:
	gs.cancel_focus()
	return true
