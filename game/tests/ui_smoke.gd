extends SceneTree
## Opens every screen once, headless, to catch runtime errors in the UI code.
##   godot --headless --path . -s res://game/tests/ui_smoke.gd

const UIKit := preload("res://game/scripts/ui/ui_kit.gd")

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
	print("cards in the left column: ", desk.cards.get_child_count())
	desk.show_istanbul()
	desk.show_place("babiali")
	desk.show_place("galata")
	desk.show_province("misir")
	desk.show_province("erzurum")
	desk.show_nation("RU")
	desk.show_nation("OS")
	desk.show_person("mustafa_kemal")
	desk._collapsed = true
	desk._layout_left()
	desk._collapsed = false
	desk._layout_left()
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
	# debug autoplay: 50 quick steps without letters, then a few with the letters shown
	desk.auto_bar.visible = true
	desk._auto_start()
	for i in 50:
		desk._auto_tick()
		if st.ending_id != "" or not desk.is_autoplaying():
			break
	print("autoplay reached ", st.year, "-", st.month, " figures on the map: ", st.figure_places().size())
	desk.auto_show.button_pressed = true
	for i in 9:
		desk._auto_tick()
		await process_frame
	desk._auto_stop()
	await process_frame
	# the sources setting, both ways
	for on in [true, false]:
		UIKit.show_sources = on
		desk.show_place("galata")
		desk.show_person("enver")
		desk._open_event(st.events["tehcir_karar"])
	print("divergences so far: ", st.divergences().size())
	for y in [1908, 1914]:
		desk.jump_to(y, 1)
		print("debug jump → ", st.year, "-", st.month, " mode ", st.mode)
	desk.open_wiki("Cemal Paşa")
	desk.open_wiki("")
	desk.wiki._go(0)
	desk.debug_menu()
	await process_frame
	# the endings table: armed neutrality in 1914 ends as "Tarafsız İmparatorluk", whatever came before
	st.flags["tarafsiz_1914"] = true
	var tab: String = st.choose_ending()
	print("endings table with ⚑tarafsiz_1914 → ", tab)
	if tab != "son_tarafsiz":
		push_error("endings table: wanted son_tarafsiz, got " + tab)
		quit(1)
		return
	st.flags.erase("tarafsiz_1914")
	st.ending_id = "son3"
	main.show_ending()
	await process_frame
	await process_frame
	print("ui smoke OK")
	quit(0)
