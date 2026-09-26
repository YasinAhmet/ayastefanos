extends SceneTree
## Headless playthroughs of the real engine.
##   godot --headless --path . -s res://game/tests/sim.gd [-- quick]
## Seven scripted strategies must reach their endings; random runs must all end (no stuck year) and reach at least
## MIN_ENDINGS different endings.
## in both modes. Prints the ending distribution, how the story threads concluded, how many different
## worlds the random runs produced by 1900, and the events no run ever reached.

const GameState := preload("res://game/scripts/game_state.gd")
const Autoplay := preload("res://game/scripts/autoplay.gd")
const RANDOM_RUNS := 400
const MAX_STEPS := 20000
# the provinces whose holder tells two worlds apart in the divergence report
const WATCHED := ["kars", "batum", "kibris", "misir", "dogu_rumeli", "teselya", "girit"]

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
		"avoid": ["yol_hamid", "suveys_buyuk", "tehcir", "suriye_idamlari", "kafkas_savunma", "jurnal_ag", "meclis_tatil",
			"tarafsiz_1914", "itilaf_yolu"],
	},
	# Abdülhamid keeps the throne AND the army: Goltz free, the fleet out of the Golden Horn, rifles handed out
	"hamid_victory": {
		"expect": "son_hamid_zafer",
		"values": {"hakimiyet": 2.5, "jon_turk": -2.5, "harbiye": 2.0, "bahriye": 1.0, "para": 0.3},
		"flags": ["jurnal_ag", "meclis_tatil", "tibbiye_takip", "selanik_takip", "yol_hamid", "midhat_dusman", "bulgar_anlasma",
			"balkan_onlendi", "silah_dagitildi", "hamid_harpte", "hamid_bogaz_tutuldu", "hamid_kafkas_zafer", "maas_odendi_1908"],
		"avoid": ["yol_ittihat", "donanma_halicte", "hamid_tarafsiz"],
		# after the 1908 crackdown the throne is safe: spend on the army and the fleet
		"late": {"from": 1909, "values": {"harbiye": 3.0, "bahriye": 2.0, "cokus": -3.0, "kafkas": 1.5, "dogu_hazirligi": 1.0, "para": 0.2}},
	},
	# Talat keeps Enver in hand and the empire out of the Great War
	"neutral_talat": {
		"expect": "son_tarafsiz",
		"values": {"enver_iliskisi": 3.0, "alman_nufuzu": -3.0, "para": 0.5, "harbiye": 0.5},
		"flags": ["yol_ittihat", "baskin_yurudu", "tarafsiz_1914", "bogaz_tutuldu", "kars_geri"],
		"avoid": ["yol_hamid", "itilaf_yolu", "souchon_izin", "yol_ahrar", "bulgar_anlasma", "liman_heyeti"],
	},
	"entente": {
		"expect": "son_itilaf",
		"values": {"alman_nufuzu": -4.0, "avrupa_baskisi": -3.0, "enver_iliskisi": 1.0, "harbiye": 0.5},
		"flags": ["yol_ittihat", "baskin_yurudu", "itilaf_yolu", "bulgar_harbi"],
		"avoid": ["yol_hamid", "tarafsiz_1914", "souchon_izin", "yol_ahrar", "bulgar_anlasma", "liman_heyeti"],
	},
	# no Balkan War, no raid on the Porte: Kâmil Paşa's desk, armed neutrality
	"ahrar": {
		"expect": "son_ahrar",
		"values": {"harbiye": 2.0, "enver_iliskisi": 1.0, "para": 0.3, "avrupa_baskisi": -0.5},
		"flags": ["yol_ittihat", "bulgar_anlasma", "balkan_onlendi", "yol_ahrar", "tarafsiz_1914", "bogaz_tutuldu"],
		"avoid": ["yol_hamid", "terhis_1912", "itilaf_yolu", "baskin_yurudu", "souchon_izin"],
	},
}
const MIN_ENDINGS := 6   # different endings the random runs must reach

var gs
var reached := {}
var failures: Array = []
var outcomes := {}      # world key -> {value -> count}, at the end of random runs
var worlds_1900 := {}   # signature -> count
var front_ends := {}    # front id -> {result event id -> count}
var snapshot := ""
var kars_held := 0
var kars_bad := 0
var kars_probe := ""    # who held Kars in 1917-06, filled by play()
var figure_log := {}    # "YYYY-MM" -> ["person@label"], filled on the Tarihî path
const FIGURE_DATES := [Vector2i(1877, 9), Vector2i(1908, 7), Vector2i(1912, 3), Vector2i(1915, 5), Vector2i(1919, 6)]


func _initialize() -> void:
	gs = GameState.new()
	root.add_child(gs)
	if not gs.load_data():
		quit(2)
		return
	var ok := true
	print("== scripted strategies")
	for name in STRATEGIES:
		var st: Dictionary = STRATEGIES[name]
		var r := play(st, null, str(st.get("mode", "serbest")))
		var want: String = st["expect"]
		var mark := "OK " if r["ending"] == want else "FAIL"
		if r["ending"] != want:
			ok = false
		print("%s %-14s → %s (wanted %s) at %s · steps %d · %s" % [mark, name, r["ending"], want, r["date"], r["steps"], r["summary"]])
	var rng := RandomNumberGenerator.new()
	rng.seed = 1873
	# Tarihî mode has one path: every event must show exactly one option and the path must reach Son 3
	var many: Array = []
	var h := play(null, rng, "tarihi", many)
	var hmark := "OK " if h["ending"] == "son3" and many.is_empty() else "FAIL"
	if hmark != "OK ":
		ok = false
	print("%s tarihî yol    → %s (wanted son3) at %s · steps %d · %s" % [hmark, h["ending"], h["date"], h["steps"], h["summary"]])
	for m in many:
		print("  more than one option shown in Tarihî mode: ", m)
	print("  population at the end (all provinces, thousands, vs 1873):")
	for g in ["ermeni", "turk", "arap", "rum", "bulgar"]:
		var now: float = gs.group_total(g, true)
		var then: float = gs.group_total(g, true, true)
		print("    %-7s %6.0f / %6.0f  (%3.0f%%)" % [g, now, then, 100.0 * now / maxf(then, 1.0)])
	var dogu_now := 0.0
	var dogu_then := 0.0
	for pid in gs.population:
		if str(gs.provinces[pid]["region"]) == "Doğu":
			dogu_now += float(gs.population[pid].get("ermeni", 0.0))
			dogu_then += float(gs.pop_start[pid].get("ermeni", 0.0))
	print("    ermeni in Doğu: %.0f / %.0f (%.0f%%)" % [dogu_now, dogu_then, 100.0 * dogu_now / maxf(dogu_then, 1.0)])
	var dead: PackedStringArray = []
	for g in gs.pop_order:
		if gs.deaths_of(g) >= 0.5:
			dead.append("%s %.0fk" % [g, gs.deaths_of(g)])
	print("  deaths (†) on the Tarihî path: ", ", ".join(dead))
	print("  figures on the map (Tarihî path):")
	for k in figure_log:
		print("    %s  %s" % [k, ", ".join(figure_log[k])])
	if not str(figure_log.get("1912-03", [])).contains("enver@Derne"):
		ok = false
		print("  FAIL Enver should be at Derne in 1912")
	var hist_seen := reached.duplicate()
	var missed: Array = []
	for ev in gs.event_order:
		if not ev["tags"].has("alternatif") and not hist_seen.has(ev["id"]):
			missed.append("%s (%s, koşul: %s)" % [ev["id"], ev["file"], ev.get("cond_src")])
	print("  %d historical events not shown on the Tarihî path:" % missed.size())
	for m in missed:
		print("    - ", m)
	reached.clear()
	for mode in ["serbest"]:
		var runs := 0 if OS.get_cmdline_user_args().has("quick") else RANDOM_RUNS   # `-- quick`: strategies only
		print("\n== %d random runs (fantezi)" % runs)
		var dist := {}
		for i in runs:
			var r := play(null, rng, mode)
			dist[r["ending"]] = int(dist.get(r["ending"], 0)) + 1
			if r["ending"] == "stuck":
				ok = false
				if failures.size() < 5:
					failures.append(r)
			# a Kars held in 1877 must not survive a lost Caucasus war
			if gs.has_flag("kars_tutuldu") and gs.has_flag("sarikamis_felaket") and kars_probe == "OS":
				kars_bad += 1
			if gs.has_flag("kars_tutuldu"):
				kars_held += 1
			if mode == "serbest":
				for k in gs.world:
					if not outcomes.has(k):
						outcomes[k] = {}
					outcomes[k][gs.world[k]] = int(outcomes[k].get(gs.world[k], 0)) + 1
				worlds_1900[snapshot] = int(worlds_1900.get(snapshot, 0)) + 1
				for fid in gs.fronts:
					var res: Dictionary = gs.front_result(fid)
					var key: String = str(res.get("id", "—"))
					if not front_ends.has(fid):
						front_ends[fid] = {}
					front_ends[fid][key] = int(front_ends[fid].get(key, 0)) + 1
		for k in dist:
			print("  %-18s %d" % [k, dist[k]])
		var distinct: int = dist.keys().filter(func(k): return k != "stuck").size()
		if runs > 0 and distinct < MIN_ENDINGS:
			ok = false
			print("  FAIL only %d different endings (want %d)" % [distinct, MIN_ENDINGS])
		else:
			print("  OK %d different endings" % distinct)
		print("  Kars held in 1877 in %d runs; still Ottoman after a lost Caucasus war in %d" % [kars_held, kars_bad])
		if kars_bad > 0:
			ok = false
	for f in failures:
		print("  STUCK at %s: %s" % [f["date"], f["summary"]])
	print("\n== how the threads ended (random runs, serbest)")
	for k in outcomes:
		var parts: PackedStringArray = []
		for v in outcomes[k]:
			parts.append("%s %d" % [v, outcomes[k][v]])
		print("  %-12s %s" % [k, ", ".join(parts)])
	print("\n== how the fronts ended (random runs, serbest; — = never decided)")
	for fid in front_ends:
		var parts: PackedStringArray = []
		for k in front_ends[fid]:
			parts.append("%s %d" % [k, front_ends[fid][k]])
		print("  %-10s %s" % [fid, ", ".join(parts)])
	print("\n== %d different worlds in 1900 across %d random runs (world state + %s)" % [worlds_1900.size(), RANDOM_RUNS, ", ".join(WATCHED)])
	var never: Array = []
	for ev in gs.event_order + gs.decisions:
		if not reached.has(ev["id"]):
			never.append(ev["id"])
	print("\n== %d of %d playable events and decisions never reached" % [never.size(), gs.event_order.size() + gs.decisions.size()])
	for id in never:
		print("  - %s (%s)" % [id, gs.events[id]["file"]])
	quit(0 if ok else 1)


func play(strategy, rng, mode := "serbest", many = null) -> Dictionary:
	gs.new_game(mode)
	snapshot = ""
	kars_probe = ""
	var steps := 0
	var policy := "tarihi" if mode == "tarihi" else "rastgele"
	while gs.ending_id == "" and steps < MAX_STEPS:
		steps += 1
		if snapshot == "" and gs.year >= 1900:
			snapshot = _signature()
		if kars_probe == "" and gs.year * 12 + gs.month >= 1917 * 12 + 6:
			kars_probe = gs.province_holder("kars", "ctl")
		if mode == "tarihi":
			for d in FIGURE_DATES:
				var ym := "%d-%02d" % [d.x, d.y]
				if figure_log.has(ym) or gs.year * 12 + gs.month < d.x * 12 + d.y:
					continue
				var names: Array = ["(%d-%02d)" % [gs.year, gs.month]]
				for f in gs.figure_places():
					names.append("%s@%s" % [f["person"], f["label"]])
				figure_log[ym] = names
		var open: Array = gs.open_events()
		for ev in open:
			reached[ev["id"]] = true
			if many != null and gs.visible_options(ev).size() != 1 and not many.has(ev["id"]):
				many.append(ev["id"])
		for d in gs.open_decisions():
			reached[d["id"]] = true
		if strategy == null:
			var st: Dictionary = Autoplay.step(gs, policy, rng)
			if st["kind"] == "stuck":
				return _result("stuck", steps)
			continue
		if not open.is_empty():
			var ev: Dictionary = open[0]
			for e in open:
				if e["kind"] in GameState.MANDATORY:
					ev = e
					break
			var i := pick(ev, strategy)
			if strategy.get("trace", false) and gs.year >= 1905 and i >= 0:
				print("    %d-%02d %-24s → %d  harbiye %d bahriye %d para %d cokus %d kafkas %d" % [gs.year, gs.month, ev["id"], i + 1,
					gs.value_of("harbiye"), gs.value_of("bahriye"), gs.value_of("para"), gs.value_of("cokus"), gs.value_of("kafkas")])
			if i < 0 or gs.choose(ev["id"], i).is_empty():
				return _result("stuck", steps)
			continue
		if not gs.can_advance():
			return _result("stuck", steps)
		var before := Vector2i(gs.year, gs.month)
		gs.advance()
		if Vector2i(gs.year, gs.month) == before and gs.ending_id == "":
			return _result("stuck", steps)
	return _result(gs.ending_id if gs.ending_id != "" else "stuck", steps)


func _signature() -> String:
	var parts: PackedStringArray = []
	for k in gs.world_order:
		parts.append("%s=%s" % [k, gs.world[k]])
	for p in WATCHED:
		parts.append("%s:%s" % [p, gs.province_holder(p)])
	return ",".join(parts)


## Scripted strategies: an option's score = the weights of the values it moves + a bonus for the flags it sets.
func pick(ev: Dictionary, strategy) -> int:
	var enabled: Array = []
	for i in gs.visible_options(ev):
		if gs.option_enabled(ev["options"][i]):
			enabled.append(i)
	if enabled.is_empty():
		return -1
	var values: Dictionary = strategy["values"]
	if strategy.has("late") and gs.year >= int(strategy["late"]["from"]):
		values = strategy["late"]["values"]
	var best: int = enabled[0]
	var best_score := -1e9
	for i in enabled:
		var s := 0.0
		for e in ev["options"][i]["effects"]:
			match e["t"]:
				"res":
					s += float(values.get(e["id"], 0.0)) * float(e["d"])
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
	for f in ["yol_hamid", "yol_ittihat", "yol_ahrar", "tarafsiz_1914", "itilaf_yolu", "hamid_kafkas_zafer", "hamid_bogaz_tutuldu",
			"balkan_onlendi", "sarikamis_zafer", "sarikamis_felaket", "kafkas_cikmaz", "arap_isyani", "tehcir"]:
		if gs.has_flag(f):
			parts.append("⚑" + f)
	for k in gs.world_order:
		parts.append("%s=%s" % [k, gs.world[k]])
	return {"ending": ending, "steps": steps, "date": "%d-%02d" % [gs.year, gs.month], "summary": ", ".join(parts)}
