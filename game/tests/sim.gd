extends SceneTree
## Headless playthroughs of the real engine.
##   godot --headless --path . -s res://game/tests/sim.gd
## Three scripted strategies must reach their endings; random runs must all end (no stuck year).
## Prints the ending distribution and the events no run ever reached.

const GameState := preload("res://game/scripts/game_state.gd")
const RANDOM_RUNS := 400
const MAX_STEPS := 20000

# Scoring policies: an option's score = sum of weights of the values it moves + bonus for flags it sets.
const STRATEGIES := {
	"hamid_grip": {
		"expect": "son1",
		"values": {"hakimiyet": 3.0, "jon_turk": -3.0, "para": 0.3},
		"flags": ["jurnal_ag", "donanma_halicte", "meclis_tatil", "goltz_kisitli", "tibbiye_takip", "selanik_takip",
			"hamidiye_kuruldu", "yol_hamid", "hamid_tarafsiz", "midhat_dusman", "silah_depoda"],
		"avoid": ["yol_ittihat", "goltz_serbest", "silah_dagitildi"],
	},
	"cautious_cup": {
		"expect": "son2",
		"values": {"dogu_hazirligi": 4.0, "harbiye": 1.5, "para": 0.6, "araplar": -0.5, "jon_turk": 0.5},
		"flags": ["yol_ittihat", "goltz_serbest", "silah_dagitildi", "maas_odendi_1908", "dogu_hatti_1", "dogu_hatti_2",
			"kislik_techizat", "depo_kaputlar", "dogu_ikmal", "hilal_ahmer_dogu", "erzurum_kalesi", "hasan_izzet_kaldi",
			"dogu_jandarma", "liman_heyeti", "sarikamis_ertelendi", "hicaz_ozerklik", "suriye_uzlasma", "dogu_guvenlik_1915"],
		"avoid": ["yol_hamid", "suveys_buyuk", "tehcir", "suriye_idamlari", "kafkas_savunma", "jurnal_ag", "meclis_tatil"],
	},
	"historical": {
		"expect": "son3",
		"values": {"para": 0.5},
		"flags": ["jurnal_ag", "donanma_halicte", "meclis_tatil", "hamidiye_kuruldu", "yol_ittihat", "suveys_buyuk",
			"serif_tahsisat", "asiret_alaylari", "tehcir", "suriye_idamlari", "kanun_esasi", "midhat_soz"],
		"avoid": ["yol_hamid", "sarikamis_ertelendi", "kafkas_savunma", "hasan_izzet_kaldi", "depo_kaputlar", "kislik_techizat", "hicaz_ozerklik"],
	},
}

var gs
var reached := {}
var failures: Array = []


func _initialize() -> void:
	gs = GameState.new()
	root.add_child(gs)
	if not gs.load_data():
		quit(2)
		return
	var ok := true
	print("== scripted strategies")
	for name in STRATEGIES:
		var r := play(STRATEGIES[name], null)
		var want: String = STRATEGIES[name]["expect"]
		var mark := "OK " if r["ending"] == want else "FAIL"
		if r["ending"] != want:
			ok = false
		print("%s %-13s → %s (wanted %s) at %s · steps %d · %s" % [mark, name, r["ending"], want, r["date"], r["steps"], r["summary"]])
	print("\n== %d random runs" % RANDOM_RUNS)
	var dist := {}
	var rng := RandomNumberGenerator.new()
	rng.seed = 1873
	for i in RANDOM_RUNS:
		var r := play(null, rng)
		dist[r["ending"]] = int(dist.get(r["ending"], 0)) + 1
		if r["ending"] == "stuck":
			ok = false
			if failures.size() < 5:
				failures.append(r)
	for k in dist:
		print("  %-6s %d" % [k, dist[k]])
	for f in failures:
		print("  STUCK at %s: %s" % [f["date"], f["summary"]])
	var never: Array = []
	for ev in gs.event_order:
		if not reached.has(ev["id"]):
			never.append(ev["id"])
	print("\n== %d of %d playable events never reached" % [never.size(), gs.event_order.size()])
	for id in never:
		print("  - %s (%s)" % [id, gs.events[id]["file"]])
	quit(0 if ok else 1)


func play(strategy, rng) -> Dictionary:
	gs.new_game()
	var steps := 0
	while gs.ending_id == "" and steps < MAX_STEPS:
		steps += 1
		var open: Array = gs.open_events()
		for ev in open:
			reached[ev["id"]] = true
		if not open.is_empty():
			var ev: Dictionary = open[0]
			for e in open:
				if e["kind"] in GameState.MANDATORY:
					ev = e
					break
			if not (ev["kind"] in GameState.MANDATORY) and rng != null and rng.randf() < 0.3:
				# random players sometimes leave optional papers on the desk
				if gs.can_advance():
					gs.advance()
					continue
			if gs.choose(ev["id"], pick(ev, strategy, rng)).is_empty():
				return _result("stuck", steps)
			continue
		if not gs.can_advance():
			return _result("stuck", steps)
		var before := Vector2i(gs.year, gs.month)
		gs.advance()
		if Vector2i(gs.year, gs.month) == before and gs.ending_id == "":
			return _result("stuck", steps)
	return _result(gs.ending_id if gs.ending_id != "" else "stuck", steps)


func pick(ev: Dictionary, strategy, rng) -> int:
	var enabled: Array = []
	for i in ev["options"].size():
		if gs.option_enabled(ev["options"][i]):
			enabled.append(i)
	if enabled.is_empty():
		push_warning("no enabled option in %s" % ev["id"])
		return 0
	if strategy == null:
		return enabled[rng.randi_range(0, enabled.size() - 1)]
	var best: int = enabled[0]
	var best_score := -1e9
	for i in enabled:
		var s := 0.0
		for e in ev["options"][i]["effects"]:
			match e["t"]:
				"res":
					s += float(strategy["values"].get(e["id"], 0.0)) * float(e["d"])
				"flag":
					if e["on"] and e["name"] in strategy["flags"]:
						s += 100.0
					if e["on"] and e["name"] in strategy["avoid"]:
						s -= 100.0
		if s > best_score:
			best_score = s
			best = i
	return best


func _result(ending: String, steps: int) -> Dictionary:
	var parts: PackedStringArray = []
	for id in ["para", "harbiye", "bahriye", "hakimiyet", "jon_turk", "dogu_hazirligi", "araplar", "cokus"]:
		parts.append("%s %d" % [id, gs.value_of(id)])
	for f in ["yol_hamid", "yol_ittihat", "sarikamis_zafer", "sarikamis_felaket", "kafkas_cikmaz", "arap_isyani", "tehcir"]:
		if gs.has_flag(f):
			parts.append("⚑" + f)
	return {"ending": ending, "steps": steps, "date": "%d-%02d" % [gs.year, gs.month], "summary": ", ".join(parts)}
