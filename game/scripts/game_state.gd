extends Node
## The whole game state and rules engine. No UI here, so tests/sim.gd can drive it headless.

const Logic := preload("res://game/scripts/logic.gd")

signal changed
signal ended(ending_id: String)

const DATA_PATH := "res://game/data/events.json"
const SAVE_PATH := "user://save.json"
const START := Vector2i(1873, 1)
const LAST_YEAR := 1919
const MANDATORY := ["zorunlu", "ara", "tetik"]
const PLAYABLE := ["zorunlu", "isteğe bağlı", "geçici", "ara", "tetik"]
const SAVE_VERSION := 3
const FAST_RANK := 45               # Hızlı tempo shows events up to this GD 01 rank (S and A tiers) and every chain / alternatif event
const START_YEARS := [1873, 1876, 1908, 1913, 1914, 1918]   # the menu's start years (earlier years replay the Tarihî choices)

# ---- static data (from events.json)
var data: Dictionary = {}
var resources: Dictionary = {}      # id -> {id, name, start, visible, desc}
var resource_order: Array = []
var events: Dictionary = {}         # id -> event
var event_order: Array = []         # playable events sorted by date
var rules: Array = []               # kural events
var headlines: Array = []           # manşet events
var epilogs: Array = []
var persons: Dictionary = {}
var nations: Dictionary = {}
var endings: Dictionary = {}
var cabinets: Array = []
var codex: Dictionary = {}
var world_defs: Dictionary = {}     # world-state key -> {id, name, start, values:{v: label}, desc}
var world_order: Array = []
var provinces: Dictionary = {}      # id -> {id, name, own, ctl, region}
var landmarks: Dictionary = {}      # id -> {id, name, province, nation, lonlat, icon, image, text, sources}
var decisions: Array = []           # karar events
var fronts: Dictionary = {}         # front id -> {id, name, war, value, enemy, lonlat, cond, start, strength, opposition, win, lose, provinces, results}
var _front_by_value: Dictionary = {}  # resource id -> front id
var pop_groups: Dictionary = {}     # group id -> {id, name, power, leave, press, revolt}
var pop_order: Array = []
var pop_start: Dictionary = {}      # province -> {group: thousands} in 1873 (GD 05 Nüfus)
var figures: Array = []             # [{person, from, to, place, label, lonlat, cond, source}] (GD 05 Kişiler haritada)

# ---- dynamic state
var year := START.x
var month := START.y
var values: Dictionary = {}
var flags: Dictionary = {}
var persona := "abdulaziz"
var answered: Dictionary = {}       # event id -> option index
var queued: Dictionary = {}         # event id -> true (chain events unlocked by ▶)
var dropped: Dictionary = {}        # queued events whose condition failed when they came due
var history: Array = []             # [{id, title, nation, y, m, option, outcome}]
var year_log: Array = []            # this year's decisions, for the gazette
var ending_id := ""
var last_gazettes: Array = []       # filled by advance()
var seen: Dictionary = {}           # event ids that were ever offered (for the simulation report)
var world: Dictionary = {}          # world-state key -> value id (GD 04)
var prov_owner: Dictionary = {}          # province -> nation code (de jure)
var prov_ctl: Dictionary = {}            # province -> nation code (de facto)
var chronicle: Array = []           # [{kind:"world"|"prov", key, from, to, y, m, by}] for the Defter
var slot_done: Dictionary = {}      # yuva -> true once one of its versions was answered
var mode := "serbest"               # "tarihi" hides alternatif events and options
var pace := "ayrintili"             # "hizli" answers minor events with their tarihî option and passes years quickly; "ayrintili" shows every event
var _settling := false
var _debt_ok := false              # set while a forced answer is applied: only then may Para go below 0
var _auto_answering := false
var _acting := ""                   # title of the event whose effects are being applied (for the chronicle)
var front_log: Dictionary = {}      # front id -> [{y, m, d, by}]: every change to the front's balance and its cause
var population: Dictionary = {}     # province -> {group: thousands}, changed by 👥 effects and cessions
var deaths: Array = []              # [{g, n, prov, y, m, by}] every † population loss, for the Kayıplar card
var front_taken: Dictionary = {}    # front id -> {"last": month key, "provs": [provinces the enemy took on its own]}
const BORDER_EVERY := 6             # months between two provinces lost (or won back) by a front's own course
const DRIFT_BY := "Cephenin kendi seyri"
const YEAR_BY := "Yıllık kural"
var rng := RandomNumberGenerator.new()
var rng_seed := 0
var value_log: Dictionary = {}      # resource id -> [{y, m, d, by}]: every change to a value and its cause
var _branches: Array = []           # roll/tier branches picked while applying the current answer ({label, text})


func load_data(path := DATA_PATH) -> bool:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("cannot open %s — run py game/tools/build_events.py" % path)
		return false
	var parsed = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("events.json is not valid JSON")
		return false
	data = parsed
	resources.clear()
	resource_order.clear()
	for r in data["resources"]:
		resources[r["id"]] = r
		resource_order.append(r["id"])
	persons = data.get("persons", {})
	nations = data.get("nations", {})
	endings = data.get("endings", {})
	cabinets = data.get("cabinets", [])
	codex = data.get("codex", {})
	world_defs.clear()
	world_order.clear()
	for w in data.get("world", []):
		world_defs[w["id"]] = w
		world_order.append(w["id"])
	provinces.clear()
	for p in data.get("provinces", []):
		provinces[p["id"]] = p
	landmarks = data.get("landmarks", {})
	fronts = data.get("fronts", {})
	pop_groups.clear()
	pop_order.clear()
	for g in data.get("pop_groups", []):
		pop_groups[g["id"]] = g
		pop_order.append(g["id"])
	pop_start = data.get("population", {})
	figures = data.get("figures", [])
	_front_by_value.clear()
	for id in fronts:
		_front_by_value[str(fronts[id]["value"])] = id
	events.clear()
	event_order.clear()
	rules.clear()
	headlines.clear()
	epilogs.clear()
	decisions.clear()
	for ev in data["events"]:
		events[ev["id"]] = ev
		match ev["kind"]:
			"kural": rules.append(ev)
			"manşet": headlines.append(ev)
			"epilog": epilogs.append(ev)
			"karar": decisions.append(ev)
			_: event_order.append(ev)
	return true


func new_game(game_mode := "serbest", game_pace := "ayrintili", start_year := START.x, seed := 0) -> void:
	mode = game_mode
	rng_seed = seed if seed != 0 else int(randi())
	rng.seed = rng_seed
	value_log.clear()
	_branches.clear()
	pace = "ayrintili"
	world.clear()
	for id in world_order:
		world[id] = str(world_defs[id]["start"])
	prov_owner.clear()
	prov_ctl.clear()
	for id in provinces:
		prov_owner[id] = str(provinces[id]["own"])
		prov_ctl[id] = str(provinces[id]["ctl"])
	chronicle.clear()
	slot_done.clear()
	front_log.clear()
	front_taken.clear()
	deaths.clear()
	population = pop_start.duplicate(true)
	year = START.x
	month = START.y
	values.clear()
	for id in resource_order:
		values[id] = int(resources[id]["start"])
	flags.clear()
	answered.clear()
	queued.clear()
	dropped.clear()
	history.clear()
	year_log.clear()
	seen.clear()
	persona = "abdulaziz"
	ending_id = ""
	last_gazettes.clear()
	if start_year > START.x:
		_replay_to(start_year)
	pace = game_pace
	settle()
	changed.emit()


## Start in a later year: play from 1873 with the Tarihî choices up to January of that year, then go on in the chosen mode.
func _replay_to(target_year: int) -> void:
	var keep := mode
	mode = "tarihi"
	var target := Logic.date_key(target_year, 1)
	var guard := 0
	while now_key() < target and ending_id == "" and guard < 5000:
		guard += 1
		var stuck := false
		var open := mandatory_open()
		while not open.is_empty() and ending_id == "":
			var i := _hist_choice(open[0])
			if i < 0 or choose(open[0]["id"], i).is_empty():
				stuck = true
				break
			open = mandatory_open()  # an answer can unlock chained mandatory events
		if stuck or ending_id != "" or not advance(target):
			break
	if now_key() < target and ending_id == "":
		push_warning("start year %d: the Tarihî replay stopped at %d-%d" % [target_year, year, month])
	mode = keep


# ---------------------------------------------------------------- queries

func has_flag(name: String) -> bool:
	return flags.has(name)


func world_value(key: String) -> String:
	return str(world.get(key, ""))


func world_label(key: String, value := "") -> String:
	var v := value if value != "" else world_value(key)
	var def: Dictionary = world_defs.get(key, {})
	return str(def.get("values", {}).get(v, v))


func province_holder(id: String, layer := "ctl") -> String:
	return str((prov_ctl if layer == "ctl" else prov_owner).get(id, ""))


func historical() -> bool:
	return mode == "tarihi"


## A dice throw on the game's own generator. Tarihî mode throws nothing: the likelier side happens.
func chance(p: float) -> bool:
	if historical():
		return p >= 0.5
	return rng.randf() < p


func roll_range(a: float, b: float) -> float:
	if historical():
		return (a + b) / 2.0
	return rng.randf_range(a, b)


func fast() -> bool:
	return pace == "hizli"


## Hızlı tempo: a ranked event below the S and A tiers, outside any chain or alternatif branch, is answered for the player.
func is_minor(ev: Dictionary) -> bool:
	if not fast() or ev["kind"] == "karar" or ev["tags"].has("zincir") or ev["tags"].has("alternatif"):
		return false
	var r = ev.get("rank")
	return r != null and str(r) != "" and int(str(r)) > FAST_RANK


## The option the game takes for the player: the tarihî one, else the first enabled one; -1 if none is enabled.
func _hist_choice(ev: Dictionary) -> int:
	var first := -1
	for i in visible_options(ev):
		var opt: Dictionary = ev["options"][i]
		if not option_enabled(opt):
			continue
		if opt.get("hist") != null:
			return i
		if first < 0:
			first = i
	return first


## Answer every minor event now on the desk (Hızlı tempo), including the ones their answers unlock.
func settle() -> void:
	if _settling or not fast():
		return
	_settling = true
	var again := true
	while again and ending_id == "":
		again = false
		for ev in open_events():
			if not is_minor(ev):
				continue
			var i := _hist_choice(ev)
			if i < 0:
				continue
			_auto_answering = true
			choose(ev["id"], i)
			_auto_answering = false
			again = true
			break
	_settling = false


func event_hidden(ev: Dictionary) -> bool:
	return historical() and ev["tags"].has("alternatif")


## Tarihî mod shows only what happened: the one (tarihî) option. Fantezi shows everything.
func option_visible(opt: Dictionary) -> bool:
	if historical():
		return opt.get("hist") != null
	return true


## Indices of the options this mode shows.
func visible_options(ev: Dictionary) -> Array:
	var out: Array = []
	for i in ev["options"].size():
		if option_visible(ev["options"][i]):
			out.append(i)
	return out


## The landmark an event is shown at: its own `yer`, else its nation's home landmark.
func event_place(ev: Dictionary) -> String:
	var p = ev.get("place")
	if p != null and str(p) != "":
		return str(p)
	return nation_place(str(ev["nation"]))


## Events of a nation without their own `yer`: the Porte for the Ottoman state, else the nation's map point.
func nation_place(code: String) -> String:
	return "babiali" if code == "OS" and landmarks.has("babiali") else "nation:" + code


func value_of(id: String) -> int:
	if id == "year":
		return year
	if id == "month":
		return month
	if id == "hist_mode":
		return 1 if historical() else 0
	return int(values.get(id, 0))


func now_key() -> int:
	return Logic.date_key(year, month)


## A queued event's due date (date key), or -1 when it was queued without a delay.
func _due(id: String) -> int:
	var q = queued.get(id, true)
	if typeof(q) == TYPE_INT or typeof(q) == TYPE_FLOAT:
		return int(q)
	return -1


func _in_window(ev: Dictionary, key: int) -> bool:
	var d: Dictionary = ev["date"]
	var start := Logic.date_key(int(d["y"]), int(d["m"]))
	var trig: bool = ev["kind"] == "tetik"
	var chain: bool = ev["tags"].has("zincir") or trig
	if chain and not queued.has(ev["id"]):
		return false
	var due := _due(ev["id"]) if chain else -1
	start = maxi(start, due)
	if key < start:
		return false
	if trig:
		return true  # a triggered paper waits on the desk until it is answered
	if ev.get("until") != null:
		var u: Dictionary = ev["until"]
		return key <= Logic.date_key(int(u["y"]), int(u["m"]))
	if ev["kind"] == "karar":
		return true
	if ev["kind"] == "geçici":
		return key == start
	if chain and ev["kind"] in MANDATORY:
		return true  # an unlocked mandatory chain event waits until it is answered
	if due >= 0:
		return key <= start + 11  # a delayed optional follow-up stays on the desk for a year
	return year == int(d["y"])


func is_open(ev: Dictionary) -> bool:
	if ev["kind"] == "karar":
		return open_decisions().has(ev)
	return open_events().has(ev)


## Events on the desk right now. Queued events whose condition fails when due are dropped.
## Of the events sharing a yuva (slot), only the first whose condition holds is offered.
func open_events() -> Array:
	var out: Array = []
	var slot_taken := {}
	for ev in event_order:
		if answered.has(ev["id"]) or dropped.has(ev["id"]) or event_hidden(ev):
			continue
		var slot = ev.get("slot")
		if slot != null and slot_done.has(slot):
			continue
		if not _in_window(ev, now_key()):
			continue
		if Logic.eval_cond(ev.get("cond"), self):
			if slot != null:
				if slot_taken.has(slot):
					continue
				slot_taken[slot] = true
			out.append(ev)
			seen[ev["id"]] = true
		elif queued.has(ev["id"]):
			dropped[ev["id"]] = true
	return out


## Player-initiated decisions (tür: karar) available now, optionally only those at one landmark.
func open_decisions(place := "") -> Array:
	var out: Array = []
	if historical():
		return out  # decisions are the player's own initiative, not history
	for ev in decisions:
		if answered.has(ev["id"]) or event_hidden(ev):
			continue
		if place != "" and str(ev.get("place", "")) != place:
			continue
		if _in_window(ev, now_key()) and Logic.eval_cond(ev.get("cond"), self):
			out.append(ev)
	return out


func mandatory_open() -> Array:
	return open_events().filter(func(ev): return ev["kind"] in MANDATORY)


func can_advance() -> bool:
	return ending_id == "" and mandatory_open().is_empty()


func option_enabled(opt: Dictionary) -> bool:
	if historical() and opt.get("hist") != null:
		return true  # history happened whatever our numbers say
	return Logic.eval_cond(opt.get("cond"), self) and zeroed_by(opt).is_empty()


## Names of the resources this option would bring to 0 or below right now (its direct effects, plus the
## "if" branches that hold now). Such an option is locked; Para and the rest never fall below 0 by choice.
func zeroed_by(opt: Dictionary) -> Array:
	var delta := {}
	_sum_deltas(opt["effects"], delta)
	var out: Array = []
	for id in delta:
		if int(delta[id]) < 0 and int(values.get(id, 0)) + int(delta[id]) <= 0:
			out.append(str(resources.get(id, {}).get("name", id)))
	return out


func _sum_deltas(effects: Array, delta: Dictionary) -> void:
	for e in effects:
		match e["t"]:
			"res":
				delta[e["id"]] = int(delta.get(e["id"], 0)) + int(e["d"])
			"if":
				if Logic.eval_cond(e.get("cond"), self):
					_sum_deltas(e["then"], delta)


## A mandatory paper whose every option is locked: the game picks one at random and the treasury goes into debt.
## Returns the option index, or -1 when the paper can be answered normally.
func forced_option(ev: Dictionary) -> int:
	if ev["kind"] == "karar" or not (ev["kind"] in MANDATORY):
		return -1
	var vis := visible_options(ev)
	if vis.is_empty():
		return -1
	for i in vis:
		if option_enabled(ev["options"][i]):
			return -1
	return vis[rng.randi_range(0, vis.size() - 1)]


func cabinet() -> Dictionary:
	var key := now_key()
	for c in cabinets:
		var f: PackedStringArray = str(c["from"]).split("-")
		var t: PackedStringArray = str(c["to"]).split("-")
		var fk := Logic.date_key(int(f[0]), int(f[1]) if f.size() > 1 else 1)
		var tk := Logic.date_key(int(t[0]), int(t[1]) if t.size() > 1 else 12)
		if key >= fk and key <= tk and Logic.eval_cond(c.get("cond"), self):
			return c
	return {}


## The person sitting in a seat ("maliye", "harbiye", "bahriye") right now.
func minister(seat: String) -> Dictionary:
	var c := cabinet()
	if c.is_empty() or not persons.has(c.get(seat, "")):
		return {}
	return persons[c[seat]]


## A person's portrait for the current year: the latest of their dated images (`görseller:`), else `görsel:`.
func person_image(pid: String):
	var p: Dictionary = persons.get(pid, {})
	var img = p.get("image")
	var best := -1
	for e in p.get("images", []):
		if int(e["from"]) <= year and int(e["from"]) > best:
			best = int(e["from"])
			img = e["image"]
	return img


## Who sits at the table: the cabinet's Sadrazam when its row names one (1908 onward), else the persona
## (the sultan, or whoever the events seated).
func head_id() -> String:
	var sid := str(cabinet().get("sadrazam", "-"))
	return sid if persons.has(sid) else persona


func ruler() -> Dictionary:
	return persons.get(head_id(), {})


## The sultan of the cabinet row (Abdülhamid, V. Mehmed Reşad, Vahdettin).
func sultan() -> Dictionary:
	return persons.get(str(cabinet().get("ruler", "")), {})


func gazette_name() -> String:
	return "Tanin" if has_flag("yol_ittihat") else "Takvim-i Vekâyi"


# ---------------------------------------------------------------- actions

## Answer an event. Returns {outcome, remembered} for the UI.
func choose(ev_id: String, index: int) -> Dictionary:
	var ev: Dictionary = events[ev_id]
	var opts: Array = ev["options"]
	if index < 0 or index >= opts.size():
		return {}
	var opt: Dictionary = opts[index]
	if not option_visible(opt):
		return {}
	_debt_ok = not option_enabled(opt)  # answered although locked (forced): the treasury may go into debt
	answered[ev_id] = index
	queued.erase(ev_id)
	if ev.get("slot") != null:
		slot_done[ev["slot"]] = true
	_acting = ev["title"]
	_branches.clear()
	_apply(opt["effects"])
	_acting = ""
	_debt_ok = false
	var labels: PackedStringArray = []
	var texts: PackedStringArray = []
	for b in _branches:
		labels.append(str(b["label"]))
		if str(b["text"]) != "":
			texts.append(str(b["text"]))
	_branches.clear()
	var outcome := Logic.txt(opt.get("outcome", ""), self)
	if not texts.is_empty():
		outcome = (outcome + " " + " ".join(texts)).strip_edges()
	var rec := {"id": ev_id, "title": ev["title"], "nation": ev["nation"], "y": year, "m": month,
		"option": opt["label"], "outcome": outcome, "place": event_place(ev),
		"thread": ev.get("thread"), "auto": _auto_answering}
	if not labels.is_empty():
		rec["branch"] = ", ".join(labels)
		rec["branch_text"] = " ".join(texts)
	history.append(rec)
	year_log.append(rec)
	settle()
	changed.emit()
	if ending_id != "":
		ended.emit(ending_id)
	var res := {"outcome": rec["outcome"], "remembered": Logic.remembers(opt["effects"])}
	if rec.has("branch"):
		res["branch"] = rec["branch"]
	return res


func _apply(effects: Array) -> void:
	var end := ""
	for e in effects:
		match e["t"]:
			"res":
				_add(e["id"], int(e["d"]))
			"set":
				var was := int(values.get(e["id"], 0))
				values[e["id"]] = int(e["v"])
				_log_value(str(e["id"]), int(e["v"]) - was)
			"roll", "tier":
				var r := rng.randf() if e["t"] == "roll" else rng.randf_range(-1.0, 1.0)
				var br: Dictionary = e["branches"][Logic.pick_branch(e, self, r)]
				_branches.append({"label": br["label"], "text": Logic.txt(br.get("text", ""), self)})
				_apply(br["effects"])
			"flag":
				if e["on"]:
					flags[e["name"]] = true
				else:
					flags.erase(e["name"])
			"queue":
				if not answered.has(e["id"]):
					var delay := int(e.get("delay", 0))
					queued[e["id"]] = (now_key() + delay) if delay > 0 else true
					dropped.erase(e["id"])
			"if":
				if Logic.eval_cond(e.get("cond"), self):
					_apply(e["then"])
			"world":
				_set_world(str(e["id"]), str(e["v"]))
			"prov":
				_set_province(str(e["id"]), str(e["v"]), bool(e.get("own", true)))
			"pop":
				_pop_change(str(e["g"]), float(e["d"]), bool(e["pct"]), e["to"], bool(e.get("dead", false)))
			"persona":
				persona = e["id"]
			"end":
				end = e["id"]
	if end == "karar":
		end = choose_ending()
	if end != "":
		ending_id = end


func _set_world(key: String, v: String) -> void:
	var old := world_value(key)
	if old == v:
		return
	world[key] = v
	chronicle.append({"kind": "world", "key": key, "from": old, "to": v, "y": year, "m": month, "by": _acting})


func _set_province(id: String, nation: String, cede: bool) -> void:
	var old_ctl := province_holder(id, "ctl")
	var old_own := province_holder(id, "own")
	prov_ctl[id] = nation
	if cede:
		prov_owner[id] = nation
		if old_own == "OS" and nation != "OS":
			_emigrate(id)
	if old_ctl != nation or (cede and old_own != nation):
		chronicle.append({"kind": "prov", "key": id, "from": old_ctl, "to": nation, "from_own": old_own,
			"own": prov_owner[id], "y": year, "m": month, "by": _acting})


## Plain-language line for a province change in the chronicle ("Kars: Devlet-i Aliyye → Rusya").
func province_change_text(c: Dictionary) -> String:
	var nm := func(code): return str(nations.get(str(code), {}).get("name", code))
	if str(c["from"]) != str(c["to"]):
		var t: String = "%s → %s" % [nm.call(c["from"]), nm.call(c["to"])]
		if str(c.get("own", c["to"])) != str(c["to"]):
			t += " (hukuken %s)" % nm.call(c["own"])
		return t
	return "hukuken %s → %s" % [nm.call(c.get("from_own", "")), nm.call(c.get("own", ""))]


func _add(id: String, d: int) -> void:
	var lo := -50 if (id == "para" and _debt_ok) else 0
	var before := int(values.get(id, 0))
	values[id] = clampi(before + d, lo, 100)
	_log_value(id, int(values[id]) - before)
	if _front_by_value.has(id) and values[id] != before:
		_log_front(_front_by_value[id], values[id] - before)


## The value ledger (REWORK §5): what changed a value, by whom; the same cause in the same month is summed.
func _log_value(id: String, d: int) -> void:
	if d == 0:
		return
	if not value_log.has(id):
		value_log[id] = []
	var log: Array = value_log[id]
	var by := _acting if _acting != "" else DRIFT_BY
	if not log.is_empty() and log[-1]["by"] == by and int(log[-1]["y"]) == year and int(log[-1]["m"]) == month:
		log[-1]["d"] = int(log[-1]["d"]) + d
		return
	log.append({"y": year, "m": month, "d": d, "by": by})


## Remember what moved a front's balance: the event, or the front's own monthly course (summed per year).
func _log_front(fid: String, d: int) -> void:
	if not front_log.has(fid):
		front_log[fid] = []
	var log: Array = front_log[fid]
	var by := _acting if _acting != "" else DRIFT_BY
	if by == DRIFT_BY and not log.is_empty() and log[-1]["by"] == DRIFT_BY and int(log[-1]["y"]) == year:
		log[-1]["d"] = int(log[-1]["d"]) + d
		return
	log.append({"y": year, "m": month, "d": d, "by": by})


# ---------------------------------------------------------------- fronts

## A front is on the map while its war is on (its condition holds) and its start date has come.
func front_visible(fid: String) -> bool:
	var f: Dictionary = fronts[fid]
	if now_key() < Logic.date_key(int(f["start"]["y"]), int(f["start"]["m"])):
		return false
	return Logic.eval_cond(f.get("cond"), self)


## The first of the front's result events that was answered: {id, title, option, y, m}; {} while undecided.
func front_result(fid: String) -> Dictionary:
	for rid in fronts[fid]["results"]:
		if answered.has(rid):
			for h in history:
				if h["id"] == rid:
					return h
	return {}


func front_active(fid: String) -> bool:
	return front_visible(fid) and front_result(fid).is_empty()


## "Who is winning" in one word, from the front's balance (0 = the enemy's, 100 = ours).
func front_status(fid: String) -> String:
	var v := value_of(str(fronts[fid]["value"]))
	var f: Dictionary = fronts[fid]
	if v >= int(f["win"]):
		return "Osmanlı ordusu üstün"
	if v >= 55:
		return "Osmanlı ordusu hafif üstün"
	if v > 45:
		return "Denge"
	if v > int(f["lose"]):
		return "Düşman hafif üstün"
	return "Düşman üstün"


## Once a month an undecided front drifts one point toward whoever is stronger (army vs. the enemy's pressure).
func _front_tick() -> void:
	for fid in fronts:
		if not front_active(fid):
			continue
		var f: Dictionary = fronts[fid]
		var total := 0.0
		for sid in f["strength"]:
			total += value_of(str(sid))
		var ours := total / maxf(1.0, float(f["strength"].size()))
		var d := clampi(roundi((ours - float(f["opposition"])) / 20.0), -1, 1)
		if d != 0:
			_add(str(f["value"]), d)
		_front_border(fid)


## A front with a `sınır` list moves the border by itself: at `yenilgi` the enemy takes the next province we
## still hold on it, at `zafer` we take back the last one it took this way (at most one every BORDER_EVERY months).
func _front_border(fid: String) -> void:
	var f: Dictionary = fronts[fid]
	var border: Array = f.get("border", [])
	if border.is_empty() or not front_result(fid).is_empty():
		return
	var rec: Dictionary = front_taken.get(fid, {"last": -999, "provs": []})
	if now_key() - int(rec["last"]) < BORDER_EVERY:
		return
	var v := value_of(str(f["value"]))
	var enemy := str(f["enemy"])
	var was := _acting
	_acting = DRIFT_BY
	if v <= int(f["lose"]):
		for pid in border:
			if province_holder(str(pid), "ctl") == "OS":
				_set_province(str(pid), enemy, false)
				rec["provs"].append(str(pid))
				rec["last"] = now_key()
				break
	elif v >= int(f["win"]) and not rec["provs"].is_empty():
		var pid: String = rec["provs"].pop_back()
		if province_holder(pid, "ctl") == enemy:
			_set_province(pid, "OS", false)
		rec["last"] = now_key()
	_acting = was
	front_taken[fid] = rec



## Move to the next month that has something on the desk, passing year turns on the way.
## Returns false if nothing moved (mandatory events open or game over).
func advance(until_key := -1) -> bool:
	if not can_advance():
		return false
	last_gazettes.clear()
	var before := {}
	for ev in open_events():
		before[ev["id"]] = true
	var guard := 0
	while guard < 12 * 60:
		guard += 1
		if month == 12:
			_year_turn()
			if ending_id != "":
				changed.emit()
				return true
		else:
			month += 1
		_front_tick()
		_trigger_tick()
		settle()
		if ending_id != "" or (until_key >= 0 and now_key() >= until_key):
			changed.emit()
			return true
		for ev in open_events():
			if not before.has(ev["id"]):
				changed.emit()
				return true
	changed.emit()
	return true


## Tetik events (MTTH): each month an unanswered one whose window is open and whose condition holds may come due.
## Tarihî mode: alternatif ones never, the others in the month of their date.
func _trigger_tick() -> void:
	var key := now_key()
	for ev in event_order:
		var id: String = ev["id"]
		if ev["kind"] != "tetik" or answered.has(id) or queued.has(id) or dropped.has(id) or event_hidden(ev):
			continue
		var slot = ev.get("slot")
		if slot != null and slot_done.has(slot):
			continue
		var d: Dictionary = ev["date"]
		var start := Logic.date_key(int(d["y"]), int(d["m"]))
		if key < start:
			continue
		if ev.get("until") != null:
			var u: Dictionary = ev["until"]
			if key > Logic.date_key(int(u["y"]), int(u["m"])):
				continue
		if not Logic.eval_cond(ev.get("cond"), self):
			continue
		if historical():
			if key == start:
				queued[id] = true
		elif rng.randf() < 1.0 - pow(0.5, 1.0 / maxf(1.0, float(ev.get("mtth", 12)))):
			queued[id] = true


func _year_turn() -> void:
	var finished := year
	for r in rules:
		if int(r["date"]["y"]) > finished:
			continue
		if r.get("until") != null and int(r["until"]["y"]) < finished:
			continue
		if Logic.eval_cond(r.get("cond"), self):
			_acting = r["title"]
			for opt in r["options"]:
				_apply(opt["effects"])
			_acting = ""
			_branches.clear()
	var lines: Array = []
	for h in headlines:
		if int(h["date"]["y"]) <= finished and Logic.eval_cond(h.get("cond"), self):
			var parts: PackedStringArray = []
			for t in h["text"]:
				var line := Logic.txt(t, self)
				if line != "":
					parts.append(line)
			lines.append(" ".join(parts))
	last_gazettes.append({"year": finished, "paper": gazette_name(), "decisions": year_log.duplicate(), "headlines": lines})
	year_log.clear()
	year = finished + 1
	month = 1
	if year > LAST_YEAR and ending_id == "":
		ending_id = _fallback_ending()
		ended.emit(ending_id)


func _fallback_ending() -> String:
	return choose_ending()


## The endings table (GD 03): rows in `sıra` order, the first whose koşul holds. The last row has no koşul.
func choose_ending() -> String:
	var rows: Array = endings.values()
	rows.sort_custom(func(a, b): return int(a.get("order", 999)) < int(b.get("order", 999)))
	for e in rows:
		if e.get("cond") == null or Logic.eval_cond(e["cond"], self):
			return str(e["id"])
	return "son3"


func epilog_cards() -> Array:
	var out: Array = []
	for ev in epilogs:
		if ev.get("ending") == ending_id and Logic.eval_cond(ev.get("cond"), self):
			out.append(ev)
	return out


# ---------------------------------------------------------------- save / load

# ---------------------------------------------------------------- population and figures

## Provinces a 👥 target names: ["*"] is every province the empire owns right now.
func _pop_targets(to: Array) -> Array:
	if to.has("*"):
		return population.keys().filter(func(p): return province_holder(p, "own") == "OS")
	return to.filter(func(p): return population.has(p))


## 👥 group ±N% (a share of the group in each target) or ±N (thousands, spread over the targets by their size).
func _pop_change(g: String, d: float, pct: bool, to: Array, dead := false) -> void:
	var targets := _pop_targets(to)
	if pct:
		for p in targets:
			var row: Dictionary = population[p]
			if row.has(g):
				var before := float(row[g])
				row[g] = maxf(0.0, before * (1.0 + d / 100.0))
				if dead:
					_record_death(g, before - float(row[g]), p)
		return
	var total := 0.0
	for p in targets:
		total += province_pop(p)
	if dead and d < 0.0:
		# the dead are taken where the group lives, in proportion to its size there
		total = 0.0
		for p in targets:
			total += float(population[p].get(g, 0.0))
	for p in targets:
		var share := province_pop(p) / total if total > 0.0 else 1.0 / targets.size()
		if dead and d < 0.0:
			share = float(population[p].get(g, 0.0)) / total if total > 0.0 else 0.0
		var row: Dictionary = population[p]
		var before := float(row.get(g, 0.0))
		row[g] = maxf(0.0, before + d * share)
		if dead:
			_record_death(g, before - float(row[g]), p)


func _record_death(g: String, n: float, prov: String) -> void:
	if n > 0.01:
		deaths.append({"g": g, "n": n, "prov": prov, "y": year, "m": month, "by": _acting})


## Deaths (†) of a group, all or in one province; with `by_event`, {title: thousands} instead of the total.
func deaths_of(g := "", prov := "", by_event := false):
	var total := 0.0
	var per := {}
	for e in deaths:
		if (g == "" or e["g"] == g) and (prov == "" or e["prov"] == prov):
			total += float(e["n"])
			var k := "%s (%d)" % [e["by"], int(e["y"])]
			per[k] = float(per.get(k, 0.0)) + float(e["n"])
	return per if by_event else total


## A province leaves the empire: each group's Göç share moves to Anatolia and the capital (the muhacirs).
func _emigrate(id: String) -> void:
	if not population.has(id):
		return
	var dest: Array = population.keys().filter(func(p):
		return p != id and province_holder(p, "own") == "OS" and str(provinces[p]["region"]) in ["Anadolu", "Payitaht"])
	var row: Dictionary = population[id]
	for g in row.keys():
		var leave := float(pop_groups.get(g, {}).get("leave", 0)) / 100.0
		if leave <= 0.0:
			continue
		var n := float(row[g]) * leave
		row[g] = float(row[g]) - n
		if not dest.is_empty():
			_pop_change(g, n, false, dest)


func province_pop(id: String) -> float:
	var s := 0.0
	for v in population.get(id, {}).values():
		s += float(v)
	return s


## The groups living in a province, largest first: [{id, name, n, start, ratio, status, power}].
func province_groups(id: String) -> Array:
	var out: Array = []
	var row: Dictionary = population.get(id, {})
	var start: Dictionary = pop_start.get(id, {})
	for g in pop_order:
		var n := float(row.get(g, 0.0))
		var s := float(start.get(g, 0.0))
		if n < 0.5 and s < 0.5:
			continue
		var ratio := n / s if s > 0.0 else 2.0
		out.append({"id": g, "name": pop_groups[g]["name"], "n": n, "start": s, "ratio": ratio,
			"status": group_status(g, ratio), "power": group_power(g)})
	out.sort_custom(func(a, b): return a["n"] > b["n"])
	return out


## A group's total across the empire's provinces (owned now), or everywhere with `all`.
func group_total(g: String, all := false, start := false) -> float:
	var s := 0.0
	for p in population:
		if all or province_holder(p, "own") == "OS":
			s += float((pop_start if start else population)[p].get(g, 0.0))
	return s


## The group's resource value (Ermeniler, Araplar, Kürtler), or -1 when it has none.
func group_power(g: String) -> int:
	var r = pop_groups.get(g, {}).get("power")
	return value_of(str(r)) if r != null else -1


func group_status(g: String, ratio: float) -> String:
	if ratio < 0.05:
		return "yok edildi"
	if ratio < 0.35:
		return "sürüldü"
	if ratio < 0.85:
		return "azalıyor"
	if ratio > 1.15:
		return "muhacirle artıyor"
	var gd: Dictionary = pop_groups.get(g, {})
	if gd.get("revolt") != null and Logic.eval_cond(gd["revolt"], self):
		return "ayaklandı"
	if gd.get("press") != null and Logic.eval_cond(gd["press"], self):
		return "baskı altında"
	return "yerleşik"


## Where the notable people are this month: [{person, lonlat, label, place, source}]. The one whose medallion
## stands at the Porte (the ruler, or Talat at the head of the government) is left out.
func figure_places() -> Array:
	var out: Array = []
	var key := now_key()
	var skip := head_id()
	var taken := {}
	for f in figures:
		var pid := str(f["person"])
		if pid == skip or taken.has(pid) or key < int(f["from"]) or key > int(f["to"]):
			continue
		if f.get("cond") != null and not Logic.eval_cond(f["cond"], self):
			continue
		taken[pid] = true
		out.append(f)
	return out


## Where this game left history: every answered alternatif event, every decision the player took, and every
## event answered with an option other than the (tarihî) one. [{title, y, m, chose, history}] in order.
func divergences() -> Array:
	var out: Array = []
	for h in history:
		var ev: Dictionary = events.get(str(h["id"]), {})
		if ev.is_empty() or not answered.has(ev["id"]):
			continue
		var chosen: Dictionary = ev["options"][int(answered[ev["id"]])]
		var hist_opt := {}
		for o in ev["options"]:
			if o.get("hist") != null:
				hist_opt = o
		var what := ""
		if ev["tags"].has("alternatif"):
			what = "Bu olay tarihte yaşanmadı."
		elif ev["kind"] == "karar":
			what = "Oyuncunun kararı; tarihte böyle bir adım atılmadı."
		elif not hist_opt.is_empty() and chosen != hist_opt:
			what = "Tarihte: " + str(hist_opt["label"])
		if what != "":
			out.append({"title": h["title"], "y": h["y"], "m": h["m"], "chose": chosen["label"], "history": what})
	return out


func save_game() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify({"version": SAVE_VERSION, "year": year, "month": month, "values": values,
		"flags": flags, "persona": persona, "answered": answered, "queued": queued, "dropped": dropped,
		"history": history, "year_log": year_log, "ending": ending_id, "world": world, "owner": prov_owner, "ctl": prov_ctl,
		"chronicle": chronicle, "slot_done": slot_done, "mode": mode, "pace": pace, "front_log": front_log,
		"population": population, "front_taken": front_taken,
		"deaths": deaths, "rng_seed": rng_seed, "rng_state": str(rng.state), "value_log": value_log}))


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func load_game() -> bool:
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return false
	var s = JSON.parse_string(f.get_as_text())
	if typeof(s) != TYPE_DICTIONARY:
		return false
	year = int(s["year"])
	month = int(s["month"])
	values = s["values"]
	for k in values.keys():
		values[k] = int(values[k])
	flags = s["flags"]
	persona = s["persona"]
	answered = s["answered"]
	queued = s["queued"]
	dropped = s.get("dropped", {})
	history = s["history"]
	year_log = s.get("year_log", [])
	ending_id = s.get("ending", "")
	for k in queued.keys():
		if typeof(queued[k]) == TYPE_FLOAT:
			queued[k] = int(queued[k])
	# version 1 saves have no world state: start from the defaults
	mode = str(s.get("mode", "serbest"))
	pace = str(s.get("pace", "ayrintili"))
	world.clear()
	for id in world_order:
		world[id] = str(world_defs[id]["start"])
	world.merge(s.get("world", {}), true)
	prov_owner.clear()
	prov_ctl.clear()
	for id in provinces:
		prov_owner[id] = str(provinces[id]["own"])
		prov_ctl[id] = str(provinces[id]["ctl"])
	prov_owner.merge(s.get("owner", {}), true)
	prov_ctl.merge(s.get("ctl", {}), true)
	chronicle = s.get("chronicle", [])
	slot_done = s.get("slot_done", {})
	front_log = s.get("front_log", {})
	front_taken = s.get("front_taken", {})
	deaths = s.get("deaths", [])
	value_log = s.get("value_log", {})
	rng_seed = int(s.get("rng_seed", 0))
	rng.seed = rng_seed
	if s.has("rng_state"):
		rng.state = int(str(s["rng_state"]))
	population = pop_start.duplicate(true)
	population.merge(s.get("population", {}), true)
	changed.emit()
	return true
