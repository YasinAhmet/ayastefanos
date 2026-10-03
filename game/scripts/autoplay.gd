extends RefCounted
## Choosing on the player's behalf: used by the debug autoplay on the desk and by tests/sim.gd.
##   tarihi      — Tarihî mode: the one option that happened
##   rastgele    — any enabled option (seeded), sometimes a decision
##   alternatif  — prefers alternative-history options and decisions, to walk the Fantezi branches

const GameState := preload("res://game/scripts/game_state.gd")

const POLICIES := ["tarihi", "rastgele", "alternatif"]
const POLICY_NAMES := {"tarihi": "Tarihî", "rastgele": "Rastgele", "alternatif": "Alternatif öncelikli"}


## Index of the option to take among those this mode shows; -1 if none is enabled.
static func pick(state, ev: Dictionary, policy: String, rng: RandomNumberGenerator) -> int:
	var enabled: Array = []
	for i in state.visible_options(ev):
		if state.option_enabled(ev["options"][i]):
			enabled.append(i)
	if enabled.is_empty():
		var vis: Array = state.visible_options(ev)
		return -1 if vis.is_empty() else vis[rng.randi_range(0, vis.size() - 1)]  # all locked: forced, into debt
	if policy == "tarihi":
		for i in enabled:
			if ev["options"][i].get("hist") != null:
				return i
		return enabled[0]
	if policy == "alternatif":
		var alt: Array = enabled.filter(func(i): return _leads_elsewhere(state, ev["options"][i]))
		if not alt.is_empty() and rng.randf() < 0.8:
			return alt[rng.randi_range(0, alt.size() - 1)]
	return enabled[rng.randi_range(0, enabled.size() - 1)]


## An option that departs from history: marked (alternatif), or queues an alternative event, or moves the world.
static func _leads_elsewhere(state, opt: Dictionary) -> bool:
	if opt.get("alt", false):
		return true
	for e in opt["effects"]:
		if e["t"] == "queue" and state.events.has(e["id"]) and state.events[e["id"]]["tags"].has("alternatif"):
			return true
	return false


## What the next step would be, without doing it: {kind: "choose"|"decision"|"advance"|"end"|"stuck", ev, option}.
## Split from step() so the desk can show the letter before the choice is made.
static func plan(state, policy: String, rng: RandomNumberGenerator) -> Dictionary:
	if state.ending_id != "":
		return {"kind": "end"}
	var decisions: Array = state.open_decisions()
	var chance := 0.25 if policy == "alternatif" else 0.08
	if policy != "tarihi" and not decisions.is_empty() and rng.randf() < chance:
		var d: Dictionary = decisions[rng.randi_range(0, decisions.size() - 1)]
		var di := pick(state, d, policy, rng)
		if di >= 0:
			return {"kind": "decision", "ev": d, "option": di}
	var open: Array = state.open_events()
	if not open.is_empty():
		var ev: Dictionary = open[0]
		for e in open:
			if e["kind"] in GameState.MANDATORY:
				ev = e
				break
		# a player sometimes leaves optional papers on the desk (never in Tarihî mode: history answered them)
		if policy != "tarihi" and not (ev["kind"] in GameState.MANDATORY) and rng.randf() < 0.3 and state.can_advance():
			return {"kind": "advance"}
		var i := pick(state, ev, policy, rng)
		if i < 0:
			return {"kind": "stuck", "ev": ev}
		return {"kind": "choose", "ev": ev, "option": i}
	if not state.can_advance():
		return {"kind": "stuck"}
	return {"kind": "advance"}


## Fantezi: with no Gündem running, start a random available one (Tarihî mode runs its own).
static func maybe_focus(state, rng: RandomNumberGenerator) -> void:
	if state.historical() or state.focus_current != "":
		return
	var avail: Array = state.available_focuses()
	if not avail.is_empty():
		state.start_focus(avail[rng.randi_range(0, avail.size() - 1)])


## Carry out a planned step. Returns the plan, with kind "stuck" when it could not be done.
## `focus_rng` (optional): a Gündem is started on the way, drawn from this generator.
static func perform(state, p: Dictionary, focus_rng: RandomNumberGenerator = null) -> Dictionary:
	match p["kind"]:
		"choose", "decision":
			if state.choose(p["ev"]["id"], int(p["option"])).is_empty():
				return {"kind": "stuck", "ev": p["ev"]}
		"advance":
			if focus_rng != null:
				maybe_focus(state, focus_rng)
			var before := Vector2i(state.year, state.month)
			state.advance()
			if Vector2i(state.year, state.month) == before and state.ending_id == "":
				return {"kind": "stuck"}
	return p


## One step of play. Returns {kind: "choose"|"decision"|"advance"|"end"|"stuck", ev, option}.
## `focus_rng` keeps the Gündem draws apart from the paper choices' generator (default: none, no Gündem is started).
static func step(state, policy: String, rng: RandomNumberGenerator, focus_rng: RandomNumberGenerator = null) -> Dictionary:
	return perform(state, plan(state, policy, rng), focus_rng)
