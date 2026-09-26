extends SceneTree
## Windowed run that saves screenshots of the main screens (needs a display, not --headless).
##   godot --path . --resolution 1600x900 -s res://game/tests/screenshots.gd -- <out_dir>
## On a server: xvfb-run -s "-screen 0 1600x900x24" godot --path . --resolution 1600x900 -s … -- <out_dir>

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
	desk.show_place("galata")
	await _shot("06_galata_1886")
	desk.panels.defter()
	await _shot("07_defter")
	await _close_modals()
	desk.close_inspector()
	_autoplay_until(st, 1908, 7)
	desk.refresh()
	for ev in st.open_events():
		if ev["id"] == "ihtilal_1908":
			desk._open_event(ev)
			break
	await _shot("08_fork_1908")
	await _close_modals()
	_autoplay_until(st, 1914, 12)
	desk.refresh()
	await _shot("09_desk_1914")
	desk.panels.payitaht()
	await _shot("10_payitaht")
	await _close_modals()
	st.ending_id = "son3"
	st.flags["sarikamis_felaket"] = true
	main.show_ending()
	await _shot("11_ending")
	quit(0)
