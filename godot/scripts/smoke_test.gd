extends SceneTree

func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed = load("res://scenes/Main.tscn")
	var main = packed.instantiate()
	root.add_child(main)
	await process_frame

	if main._owned_cap() != 4 or main._deploy_cap() != 2:
		push_error("Unexpected round 1 caps.")
		quit(1)
		return

	var ids: Array = ["turtle", "rabbit"]
	var positions: Array = [
		Vector2i(3, 7),
		Vector2i(4, 7)
	]

	for i in range(ids.size()):
		var pos: Vector2i = positions[i]
		var unit: Dictionary = main._make_unit(str(ids[i]), "player")
		unit["x"] = pos.x
		unit["y"] = pos.y
		main.player_board[main._cell_key(pos.x, pos.y)] = unit

	main._refresh_all()
	var ai_wave: Array = main._generate_ai_wave()
	if ai_wave.size() != ids.size():
		push_error("AI wave should match player deployed count.")
		quit(1)
		return
	main._start_combat()

	for _tick in range(220):
		if not main.combat_running:
			break
		main._combat_tick()

	if main.combat_running:
		push_error("Combat did not finish within smoke budget.")
		quit(1)
		return

	if main.round_number < 2:
		push_error("Round did not advance after combat.")
		quit(1)
		return

	if not main.wrapup_active:
		push_error("Round wrap-up should be visible after combat.")
		quit(1)
		return

	print("animal-chess smoke ok: round=%d hp=%d gold=%d" % [main.round_number, main.player_hp, main.gold])
	quit(0)
