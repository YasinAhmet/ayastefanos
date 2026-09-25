extends SceneTree
## Windowed run that saves screenshots of the main screens (needs a display, not --headless).
##   godot --path . --resolution 1600x900 -s res://game/tests/screenshots.gd -- <out_dir>

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


func _autoplay_until(st, y: int, m: int) -> void:
	var guard := 0
	while (st.year < y or (st.year == y and st.month < m)) and st.ending_id == "" and guard < 3000:
		guard += 1
		var open: Array = st.open_events()
		if open.is_empty():
			st.advance()
			continue
		var ev: Dictionary = open[0]
		var pick := 0
		for i in ev["options"].size():
			if st.option_enabled(ev["options"][i]):
				pick = i
				break
		st.choose(ev["id"], pick)


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
	# the 1908 fork, reached by always taking the first open option (grip too low → option B locked)
	_autoplay_until(st, 1908, 7)
	desk.refresh()
	for ev in st.open_events():
		if ev["id"] == "ihtilal_1908":
			desk._open_event(ev)
			break
	await _shot("04a_fork_1908")
	for c in desk.get_children():
		if c is Control and c.get_child_count() > 1 and c.get_child(1) is PanelContainer:
			var sc: ScrollContainer = c.get_child(1).get_child(0)
			sc.scroll_vertical = 100000
	await _shot("04b_fork_1908_options")
	await _close_modals()
	desk.panels.payitaht()
	await _shot("05_payitaht")
	await _close_modals()
	desk.panels.gazette({"year": st.year - 1, "paper": st.gazette_name(), "decisions": st.history.slice(-6), "headlines": ["Harbiye ve Tıbbiye koğuşlarında el altından Vatan'ın sayfaları dolaşıyor."]})
	await _shot("06_gazette")
	await _close_modals()
	desk.panels.codex("Sarıkamış Operation (1914-1915)" if st.codex.has("Sarıkamış Operation (1914-1915)") else st.codex.keys()[0])
	await _shot("07_codex")
	await _close_modals()
	_autoplay_until(st, 1914, 12)
	desk.refresh()
	await _shot("08_desk_1914")
	st.ending_id = "son3"
	st.flags["sarikamis_felaket"] = true
	main.show_ending()
	await _shot("09_ending")
	quit(0)
