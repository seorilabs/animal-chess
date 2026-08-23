## 준비 -> 배치 -> 전투 -> 라운드 마무리까지 실제 화면을 통해 한 바퀴가 도는지 확인한다.
extends TestCase

const RUN_SEED := 20260823
const UNIT_IDS: PackedStringArray = ["turtle", "rabbit"]
const PLACEMENTS: Array[Vector2i] = [Vector2i(3, 7), Vector2i(4, 7)]
const TICK_BUDGET := CombatSim.MAX_TICKS + 5


func run(host: Node) -> void:
	var main: Control = load("res://scenes/main.tscn").instantiate()
	host.add_child(main)
	await host.get_tree().process_frame
	main.new_run(RUN_SEED)

	check_eq(main.run.owned_cap(), 4, "1라운드 보유 한도")
	check_eq(main.run.deploy_cap(), 2, "1라운드 배치 한도")

	for index in range(UNIT_IDS.size()):
		var unit := UnitState.create(
			main.catalog.get_def(UNIT_IDS[index]), UnitState.Team.PLAYER
		)
		unit.set_position(PLACEMENTS[index])
		main.run.board[PLACEMENTS[index]] = unit
	main._refresh_all()

	main._start_combat()
	check_eq(main.sim.alive_count(UnitState.Team.ENEMY), UNIT_IDS.size(),
		"AI 조합 규모는 플레이어 배치 수와 같아야 합니다")

	for _tick in range(TICK_BUDGET):
		if not main.sim.is_running():
			break
		main._on_combat_tick()

	check(not main.sim.is_running(), "전투가 %d틱 안에 끝나야 합니다" % TICK_BUDGET)
	check_eq(main.run.round_number, 2, "전투 후 라운드가 진행되어야 합니다")
	check(main._wrapup_active, "전투 후 라운드 결과 패널이 떠야 합니다")

	print("  라운드=%d 체력=%d 골드=%d" % [
		main.run.round_number, main.run.player_hp, main.run.gold
	])
	main.queue_free()
