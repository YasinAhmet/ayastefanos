extends Node
## The whole game state and rules engine. No UI here, so tests/sim.gd can drive it headless.

const Logic := preload("res://game/scripts/logic.gd")

signal changed
signal ended(ending_id: String)

const DATA_PATH := "res://game/data/events.json"
const SAVE_PATH := "user://save.json"
const START := Vector2i(1873, 1)
const LAST_YEAR := 1919
const MANDATORY := ["zorunlu", "ara"]
const PLAYABLE := ["zorunlu", "isteğe bağlı", "geçici", "ara"]

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
	events.clear()
	event_order.clear()
	rules.clear()
	headlines.clear()
	epilogs.clear()
	for ev in data["events"]:
		events[ev["id"]] = ev
		match ev["kind"]:
			"kural": rules.append(ev)
			"manşet": headlines.append(ev)
			"epilog": epilogs.append(ev)
			_: event_order.append(ev)
	return true


func new_game() -> void:
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
	changed.emit()


# ---------------------------------------------------------------- queries

func has_flag(name: String) -> bool:
	return flags.has(name)


func value_of(id: String) -> int:
	if id == "year":
		return year
	if id == "month":
		return month
	return int(values.get(id, 0))


func now_key() -> int:
	return Logic.date_key(year, month)


func _in_window(ev: Dictionary, key: int) -> bool:
	var d: Dictionary = ev["date"]
	var start := Logic.date_key(int(d["y"]), int(d["m"]))
	if key < start:
		return false
	var chain: bool = ev["tags"].has("zincir")
	if chain and not queued.has(ev["id"]):
		return false
	if ev.get("until") != null:
		var u: Dictionary = ev["until"]
		return key <= Logic.date_key(int(u["y"]), int(u["m"]))
	if ev["kind"] == "geçici":
		return key == start
	if chain and ev["kind"] in MANDATORY:
		return true  # an unlocked mandatory chain event waits until it is answered
	return year == int(d["y"])


func is_open(ev: Dictionary) -> bool:
	if answered.has(ev["id"]) or dropped.has(ev["id"]):
		return false
	if not _in_window(ev, now_key()):
		return false
	return Logic.eval_cond(ev.get("cond"), self)


## Events on the desk right now. Queued events whose condition fails when due are dropped.
func open_events() -> Array:
	var out: Array = []
	for ev in event_order:
		if answered.has(ev["id"]) or dropped.has(ev["id"]):
			continue
		if not _in_window(ev, now_key()):
			continue
		if Logic.eval_cond(ev.get("cond"), self):
			out.append(ev)
			seen[ev["id"]] = true
		elif queued.has(ev["id"]):
			dropped[ev["id"]] = true
	return out


func mandatory_open() -> Array:
	return open_events().filter(func(ev): return ev["kind"] in MANDATORY)


func can_advance() -> bool:
	return ending_id == "" and mandatory_open().is_empty()


func option_enabled(opt: Dictionary) -> bool:
	return Logic.eval_cond(opt.get("cond"), self)


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


func ruler() -> Dictionary:
	return persons.get(persona, {})


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
	answered[ev_id] = index
	queued.erase(ev_id)
	_apply(opt["effects"])
	var rec := {"id": ev_id, "title": ev["title"], "nation": ev["nation"], "y": year, "m": month,
		"option": opt["label"], "outcome": opt.get("outcome", "")}
	history.append(rec)
	year_log.append(rec)
	changed.emit()
	if ending_id != "":
		ended.emit(ending_id)
	return {"outcome": opt.get("outcome", ""), "remembered": Logic.remembers(opt["effects"])}


func _apply(effects: Array) -> void:
	var end := ""
	for e in effects:
		match e["t"]:
			"res":
				_add(e["id"], int(e["d"]))
			"set":
				values[e["id"]] = int(e["v"])
			"flag":
				if e["on"]:
					flags[e["name"]] = true
				else:
					flags.erase(e["name"])
			"queue":
				if not answered.has(e["id"]):
					queued[e["id"]] = true
					dropped.erase(e["id"])
			"persona":
				persona = e["id"]
			"end":
				end = e["id"]
	if end != "":
		ending_id = end


func _add(id: String, d: int) -> void:
	var lo := -50 if id == "para" else 0
	values[id] = clampi(int(values.get(id, 0)) + d, lo, 100)


## Move to the next month that has something on the desk, passing year turns on the way.
## Returns false if nothing moved (mandatory events open or game over).
func advance() -> bool:
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
		for ev in open_events():
			if not before.has(ev["id"]):
				changed.emit()
				return true
	changed.emit()
	return true


func _year_turn() -> void:
	var finished := year
	for r in rules:
		if int(r["date"]["y"]) > finished:
			continue
		if r.get("until") != null and int(r["until"]["y"]) < finished:
			continue
		if Logic.eval_cond(r.get("cond"), self):
			for opt in r["options"]:
				_apply(opt["effects"])
	var lines: Array = []
	for h in headlines:
		if int(h["date"]["y"]) <= finished and Logic.eval_cond(h.get("cond"), self):
			lines.append(" ".join(h["text"]))
	last_gazettes.append({"year": finished, "paper": gazette_name(), "decisions": year_log.duplicate(), "headlines": lines})
	year_log.clear()
	year = finished + 1
	month = 1
	if year > LAST_YEAR and ending_id == "":
		ending_id = _fallback_ending()
		ended.emit(ending_id)


func _fallback_ending() -> String:
	if has_flag("yol_hamid"):
		return "son1"
	if has_flag("sarikamis_zafer"):
		return "son2"
	return "son3"


func epilog_cards() -> Array:
	var out: Array = []
	for ev in epilogs:
		if ev.get("ending") == ending_id and Logic.eval_cond(ev.get("cond"), self):
			out.append(ev)
	return out


# ---------------------------------------------------------------- save / load

func save_game() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify({"year": year, "month": month, "values": values, "flags": flags,
		"persona": persona, "answered": answered, "queued": queued, "dropped": dropped,
		"history": history, "year_log": year_log, "ending": ending_id}))


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
	changed.emit()
	return true
