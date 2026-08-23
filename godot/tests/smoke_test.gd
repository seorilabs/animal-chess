## 준비 -> 배치 -> 전투 -> 라운드 마무리까지 한 바퀴가 도는지 확인한다.
extends TestCase

const UNIT_IDS: PackedStringArray = ["turtle", "rabbit"]
const PLACEMENTS: Array[Vector2i] = [Vector2i(3, 7), Vector2i(4, 7)]
const COMBAT_TICK_BUDGET := 220


func run(host: Node) -> void:
	var main: Control = load("res://scenes/main.tscn").instantiate()
	host.add_child(main)
	await host.get_tree().process_frame

	check_eq(main._owned_cap(), 4, "1라운드 보유 한도")
	check_eq(main._deploy_cap(), 2, "1라운드 배치 한도")

	for i in range(UNIT_IDS.size()):
		var pos: Vector2i = PLACEMENTS[i]
		var unit: Dictionary = main._make_unit(UNIT_IDS[i], "player")
		unit["x"] = pos.x
		unit["y"] = pos.y
		main.player_board[main._cell_key(pos.x, pos.y)] = unit
	main._refresh_all()

	check_eq(main._generate_ai_wave().size(), UNIT_IDS.size(), "AI wave 수는 플레이어 배치 수와 같아야 합니다")

	main._start_combat()
	for _tick in range(COMBAT_TICK_BUDGET):
		if not main.combat_running:
			break
		main._combat_tick()

	check(not main.combat_running, "전투가 %d틱 안에 끝나야 합니다" % COMBAT_TICK_BUDGET)
	check(main.round_number >= 2, "전투 후 라운드가 진행되어야 합니다")
	check(main.wrapup_active, "전투 후 라운드 결과 패널이 떠야 합니다")

	print("  라운드=%d 체력=%d 골드=%d" % [main.round_number, main.player_hp, main.gold])
	main.queue_free()
