extends Control
## The ending: title, text, then the epilogue cards whose conditions hold (Suzerain-style, one per area).

const Logic := preload("res://game/scripts/logic.gd")
const UIKit := preload("res://game/scripts/ui/ui_kit.gd")
const GameState := preload("res://game/scripts/game_state.gd")
const EventPanel := preload("res://game/scripts/ui/event_panel.gd")

var state: GameState
var main: Node


func _ready() -> void:
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	var center := MarginContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for side in ["left", "right"]:
		center.add_theme_constant_override("margin_" + side, 220)
	center.add_theme_constant_override("margin_top", 40)
	center.add_theme_constant_override("margin_bottom", 40)
	scroll.add_child(center)
	var body := UIKit.vbox(14)
	center.add_child(body)
	var e: Dictionary = state.endings.get(state.ending_id, {"title": state.ending_id, "text": [], "sources": []})
	body.add_child(UIKit.label("SON", 16, UIKit.MUTED))
	body.add_child(UIKit.label(str(e["title"]), 32, UIKit.GOLD, true))
	if e.get("alternative", false):
		body.add_child(UIKit.label("Alternatif tarih", 15, UIKit.ALT))
	var img := UIKit.image(e.get("image"), 280)
	if img:
		body.add_child(img)
	for p in e["text"]:
		body.add_child(UIKit.rich(p, 15))
	body.add_child(UIKit.label(Logic.date_text(state.year, state.month), 15, UIKit.MUTED))
	# what in this game was not history (always shown, whatever the sources setting)
	var div := state.divergences()
	body.add_child(UIKit.section("Alternatif tarih · bu oyunda tarihten ayrılan %d karar" % div.size()))
	var alt := UIKit.panel(Color("2e2638"))
	var av := UIKit.vbox(4)
	alt.add_child(av)
	if e.get("alternative", false):
		av.add_child(UIKit.label("BU SON ALTERNATİF TARİHTİR.", 15, UIKit.ALT))
	if div.is_empty():
		av.add_child(UIKit.label("Bütün kararlar tarihte olduğu gibi verildi.", 13, UIKit.INK, true))
	for d in div:
		av.add_child(UIKit.rich("[color=#ab9d82]%s[/color] · [b]%s[/b] — %s\n   [color=#b9a6d8]%s[/color]" % [
			Logic.date_text(int(d["y"]), int(d["m"])), d["title"], EventPanel._plain(str(d["chose"])),
			EventPanel._plain(str(d["history"]))], 12))
	body.add_child(alt)
	body.add_child(UIKit.section("Yol haritası"))
	_roadmap(body, div)
	_near_misses(body)
	# the ending's own cards first, then the `son: *` cards (the composite axes ax_*), whatever the ending
	var cards: Array = state.epilog_cards()
	for ev in state.epilogs:
		if ev.get("ending") == "*" and Logic.eval_cond(ev.get("cond"), state):
			cards.append(ev)
	for card in cards:
		var c := UIKit.panel(UIKit.PANEL_2)
		var v := UIKit.vbox(6)
		c.add_child(v)
		v.add_child(UIKit.label(card["title"], 16, UIKit.GOLD))
		for p in card["text"]:
			var t := Logic.txt(p, state)
			if t != "":
				v.add_child(UIKit.rich(t, 13))
		UIKit.add_sources(v, card["sources"], func(bb, size): return UIKit.rich(bb, size), 12)
		body.add_child(c)
	# one card per story thread: how it ended and when (the Defter, closed)
	var threads := UIKit.section("Defter")
	body.add_child(threads)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	body.add_child(grid)
	for k in state.world_order:
		var steps := state.chronicle.filter(func(c): return c["kind"] == "world" and c["key"] == k)
		if steps.is_empty():
			continue
		var c := UIKit.panel(UIKit.PANEL_2)
		c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var v := UIKit.vbox(3)
		c.add_child(v)
		v.add_child(UIKit.label(str(state.world_defs[k]["name"]), 11, UIKit.GOLD))
		v.add_child(UIKit.label(state.world_label(k), 15, UIKit.INK, true))
		var last: Dictionary = steps[-1]
		v.add_child(UIKit.label("%d · %s" % [int(last["y"]), str(last.get("by", ""))], 11, UIKit.MUTED, true))
		grid.add_child(c)
	# the peoples of the empire: how many of each were still living in its lands (all 1873 provinces)
	body.add_child(UIKit.section("Nüfus (tahminî, 1873'teki bütün iller)"))
	var pop := UIKit.panel(UIKit.PANEL_2)
	var pv := UIKit.vbox(3)
	pop.add_child(pv)
	for g in state.pop_order:
		var then := state.group_total(g, true, true)
		if then < 1.0:
			continue
		var now := state.group_total(g, true)
		var ratio := now / then
		var line := "%s: %d bin → %d bin (%%%d) · %s" % [state.pop_groups[g]["name"], int(round(then)), int(round(now)),
			int(round(ratio * 100.0)), state.group_status(g, ratio)]
		pv.add_child(UIKit.label(line, 13, UIKit.INK if ratio >= 0.85 else Color("e0a080")))
	if not state.deaths.is_empty():
		pv.add_child(UIKit.section("Kayıplar (ölü, en yüksek tahminler)"))
		for g in state.pop_order:
			var n: float = state.deaths_of(g)
			if n >= 0.5:
				pv.add_child(UIKit.label("%s: ~%d bin ölü" % [state.pop_groups[g]["name"], int(round(n))], 13, Color("e0a080")))
	pv.add_child(UIKit.label("Rakamlar tahminîdir ve tartışmalıdır; bkz. GD 05 Nüfus.", 10, UIKit.MUTED))
	body.add_child(pop)
	var stats := UIKit.hbox(16)
	for id in state.resource_order:
		if state.resources[id]["visible"]:
			stats.add_child(UIKit.label("%s %d" % [state.resources[id]["name"], state.value_of(id)], 15, UIKit.MUTED))
	body.add_child(stats)
	var b := UIKit.button("Ana menü", UIKit.PANEL_2, 18)
	b.pressed.connect(func(): main.show_menu())
	body.add_child(b)


## Decisions that shaped the game, in time order: the big forks plus every decision that left history.
const MAJOR := ["ihtilal_1908", "baskin_karari", "balkan_esik", "harp_kapida", "sarikamis_karar"]
const NEAR_MISS_SHOWN := 3
const NEAR_FLAG_PENALTY := 25.0


func _roadmap(body: VBoxContainer, div: Array) -> void:
	var off := {}
	for d in div:
		off["%d-%d-%s" % [int(d["y"]), int(d["m"]), str(d["title"])]] = true
	var rows: Array = []
	for h in state.history:
		var key := "%d-%d-%s" % [int(h["y"]), int(h["m"]), str(h["title"])]
		if MAJOR.has(str(h["id"])) or off.has(key):
			rows.append({"h": h, "alt": off.has(key)})
	if rows.is_empty():
		body.add_child(UIKit.label("Kayda geçen büyük bir ayrım yok.", 13, UIKit.MUTED))
		return
	var line := UIKit.vbox(0)
	for r in rows:
		var h: Dictionary = r["h"]
		var row := UIKit.hbox(10)
		row.add_child(UIKit.label("●", 13, UIKit.ALT if r["alt"] else UIKit.GOLD))
		var txt := UIKit.vbox(1)
		txt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var head := UIKit.hbox(8)
		head.add_child(UIKit.label("%s · %s" % [Logic.date_text(int(h["y"]), int(h["m"])), str(h["title"])], 13, UIKit.INK))
		if str(h.get("branch", "")) != "":
			head.add_child(_badge(str(h["branch"])))
		txt.add_child(head)
		txt.add_child(UIKit.label(EventPanel._plain(str(h.get("option", ""))), 12, UIKit.MUTED, true))
		row.add_child(txt)
		line.add_child(row)
	body.add_child(line)


func _badge(label: String) -> Control:
	var good := ["zafer", "ezici", "başarı"]
	var bad := ["bozgun", "yenilgi", "başarısız"]
	var col := UIKit.GREEN if good.has(label) else (UIKit.RED if bad.has(label) else UIKit.SEAL_2)
	var p := UIKit.panel(col)
	p.add_child(UIKit.label(label, 11, UIKit.INK))
	return p


## Distance of the current state to a condition tree: {"d": total, "gaps": {resource name: shortfall}, "closed": doors shut}.
## cmp nodes cost their numeric shortfall; flag/world/province nodes that do not hold cost NEAR_FLAG_PENALTY.
func _cond_distance(node) -> Dictionary:
	var zero := {"d": 0.0, "gaps": {}, "closed": 0}
	if node == null or Logic.eval_cond(node, state):
		return zero
	match node["op"]:
		"and":
			var out := {"d": 0.0, "gaps": {}, "closed": 0}
			for a in node["args"]:
				var r := _cond_distance(a)
				out["d"] += r["d"]
				out["closed"] += r["closed"]
				for k in r["gaps"]:
					out["gaps"][k] = float(out["gaps"].get(k, 0.0)) + float(r["gaps"][k])
			return out
		"or":
			var best := {}
			for a in node["args"]:
				var r := _cond_distance(a)
				if best.is_empty() or r["d"] < best["d"]:
					best = r
			return best
		"cmp":
			var total := 0
			var names: Array = []
			for term in node["left"]:
				total += int(term[0]) * state.value_of(term[1])
				names.append(str(state.resources[term[1]]["name"]) if state.resources.has(term[1]) else str(term[1]))
			var gap := absf(float(total - int(node["right"])))
			if node["cmp"] in [">", "<"]:
				gap += 1.0
			return {"d": gap, "gaps": {" + ".join(names): gap}, "closed": 0}
	return {"d": NEAR_FLAG_PENALTY, "gaps": {}, "closed": 1}


## "Closest escaped endings": the endings whose conditions were nearest to holding.
func _near_misses(body: VBoxContainer) -> void:
	var rows: Array = []
	for e in state.endings.values():
		if str(e["id"]) == state.ending_id or e.get("cond") == null:
			continue
		var r := _cond_distance(e["cond"])
		r["e"] = e
		rows.append(r)
	rows.sort_custom(func(a, b): return a["d"] < b["d"])
	if rows.is_empty():
		return
	body.add_child(UIKit.section("En yakın kaçan sonlar"))
	for i in mini(NEAR_MISS_SHOWN, rows.size()):
		var r: Dictionary = rows[i]
		var parts: Array = []
		var gaps: Dictionary = r["gaps"]
		for k in gaps:
			parts.append("%d %s" % [int(round(float(gaps[k]))), k])
		if int(r["closed"]) > 0:
			parts.append("%d kapalı kapı (yol ya da bayrak)" % int(r["closed"]))
		var how := ", ".join(parts) if not parts.is_empty() else "bir adım"
		body.add_child(UIKit.label("%s — %s uzaktaydınız" % [str(r["e"]["title"]), how], 13, UIKit.INK, true))
