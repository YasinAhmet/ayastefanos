extends SceneTree
## Opens every screen once, headless, to catch runtime errors in the UI code.
##   godot --headless --path . -s res://game/tests/ui_smoke.gd

var main: Control


func _initialize() -> void:
	main = load("res://game/scenes/main.tscn").instantiate()
	root.add_child(main)
	_run.call_deferred()


func _run() -> void:
	await process_frame
	var st = main.state
	st.new_game()
	# jump to the first year that has an open event, answering nothing
	var guard := 0
	while st.open_events().is_empty() and st.ending_id == "" and guard < 60:
		st.advance()
		guard += 1
	main.show_desk()
	await process_frame
	await process_frame
	var desk = main.screen
	print("desk at ", st.year, "-", st.month, " open events: ", st.open_events().size())
	var open: Array = st.open_events()
	if not open.is_empty():
		desk._open_event(open[0])
		await process_frame
		var ev: Dictionary = open[0]
		for i in ev["options"].size():
			if st.option_enabled(ev["options"][i]):
				print("choosing option ", i, " of ", ev["id"])
				st.choose(ev["id"], i)
				break
	desk.show_place("babiali")
	desk.show_place("galata")
	desk.show_province("misir")
	desk.show_nation("RU")
	for fid in st.fronts:
		desk.show_front(fid)
	desk.close_inspector()
	desk.panels.defter()
	for d in st.decisions:
		desk._open_event(d)
		break
	desk.panels.payitaht()
	desk.panels.codex()
	if not st.codex.is_empty():
		desk.panels.codex(st.codex.keys()[0])
	desk.panels.nation("RU")
	desk.panels.gazette({"year": st.year, "paper": st.gazette_name(), "decisions": st.history, "headlines": ["deneme"]})
	await process_frame
	st.ending_id = "son3"
	main.show_ending()
	await process_frame
	await process_frame
	print("ui smoke OK")
	quit(0)
