extends SceneTree
## Windowed run that saves screenshots of the main screens (needs a display, not --headless).
##   godot --path . --resolution 1600x900 -s res://game/tests/screenshots.gd -- <out_dir>
## On a server: xvfb-run -s "-screen 0 1600x900x24" godot --path . --resolution 1600x900 -s … -- <out_dir>

const Autoplay := preload("res://game/scripts/autoplay.gd")
const UIKit := preload("res://game/scripts/ui/ui_kit.gd")

var main: Control
var out := ""


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	out = args[0] if args.size() > 0 else ProjectSettings.globalize_path("user://shots")
	DirAccess.make_dir_recursive_absolute(out)
	main = load("res://game/scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _shot(name: String) -> void:
	for i in 4:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out.path_join(name + ".png"))
	print("saved ", name)


func _close_modals() -> void:
	for c in main.screen.get_children():
		if c is Control and c.get_child_count() > 1 and c.get_child(0) is ColorRect:
			c.queue_free()
	await process_frame


## Plays on, always taking the first enabled option, except where `prefer` names one (event id -> option index).
func _autoplay_until(st, y: int, m: int, prefer := {}) -> void:
	var guard := 0
	while (st.year < y or (st.year == y and st.month < m)) and st.ending_id == "" and guard < 3000:
		guard += 1
		var open: Array = st.open_events()
		if open.is_empty():
			st.advance()
			continue
		var ev: Dictionary = open[0]
		var pick := -1
		if prefer.has(ev["id"]) and st.option_enabled(ev["options"][prefer[ev["id"]]]):
			pick = prefer[ev["id"]]
		if pick < 0:
			for i in st.visible_options(ev):
				if st.option_enabled(ev["options"][i]):
					pick = i
					break
		st.choose(ev["id"], maxi(pick, 0))


## The one Tarihî path, step by step (the debug autoplay's own policy), up to a month.
func _history_until(st, y: int, m: int) -> void:
	var rng := RandomNumberGenerator.new()
	var guard := 0
	while (st.year < y or (st.year == y and st.month < m)) and st.ending_id == "" and guard < 3000:
		guard += 1
		if Autoplay.step(st, "tarihi", rng)["kind"] == "stuck":
			break


func _run() -> void:
	await _shot("01_menu")
	var st = main.state
	st.new_game()
	main.show_desk()
	await _shot("02_desk_1873")
	var desk = main.screen
	var open: Array = st.open_events()
	desk._open_event(open[0])
	await _shot("03_event")
	await _close_modals()
	desk.show_place("babiali")
	await _shot("04_babiali")
	# Egypt held with Ottoman battalions, the Régie refused for a state monopoly
	_autoplay_until(st, 1886, 6, {"urabi": 2, "misir_osmanli_kuvvet": 1, "reji": 3, "ayastefanos_muzakere": 1,
		"kibris": 0, "berlin_batum": 0, "reji_nota": 0})
	desk.refresh()
	desk.show_province("misir")
	await _shot("05_egypt_1886")
	desk.panels.defter()
	await _shot("07_defter")
	await _close_modals()
	desk.close_inspector()
	# Tarihî mode: one option per event, the people on the map follow history
	st.new_game("tarihi")
	main.show_desk()
	desk = main.screen
	_history_until(st, 1877, 8)
	desk.refresh()
	UIKit.show_sources = true
	for ev in st.open_events():
		var p = desk._open_event(ev)
		await process_frame
		p.m["body"].get_children().filter(func(c): return c is Button and c.text.begins_with("Kaynakça")).map(func(b): b.pressed.emit())
		p.m["scroll"].scroll_vertical = 2000
		break
	await _shot("06_tarihi_event_1877")
	desk.open_wiki("Siege of Plevne (1877)")
	await _shot("06b_wiki")
	desk.wiki.visible = false
	UIKit.show_sources = false
	await _close_modals()
	desk.show_province("tuna")
	await _shot("08_plevne_1877")
	desk.show_nation("RU")
	await _shot("08b_russia")
	_history_until(st, 1912, 2)
	desk.refresh()
	desk.show_person("enver")
	await _shot("09_trablus_1912")
	_history_until(st, 1915, 9)
	desk.refresh()
	desk.show_province("bitlis")
	desk.auto_bar.visible = true
	await _shot("10_tehcir_1915")
	desk.show_front("canakkale")
	await _shot("10b_front_1915")
	desk.show_nation("OS")
	await _shot("10c_empire_1915")
	desk.close_inspector()
	desk.panels.payitaht()
	await _shot("11_payitaht")
	await _close_modals()
	st.ending_id = "son3"
	st.flags["sarikamis_felaket"] = true
	main.show_ending()
	await _shot("12_ending")
	quit(0)
