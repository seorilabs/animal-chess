## 한 런이 목표 시간(12~18분) 안에 끝나는지 시뮬레이션으로 확인한다.
##
## 기획서 §10의 "1런 약 15분" 목표를 검증한다.
## 사람 대신 단순 자동 플레이어가 사고 배치한 뒤 전투를 끝까지 돌린다.
extends TestCase

## 사람이 한 라운드를 준비하는 데 걸린다고 보는 시간.
const PREP_SECONDS_PER_ROUND := 30.0
const TARGET_MIN_MINUTES := 12.0
const TARGET_MAX_MINUTES := 18.0
## 전투가 무한히 이어지지 않는지 확인하기 위한 안전 상한.
const ROUND_LIMIT := 40
const SEEDS: Array[int] = [11, 2026, 77777, 314159, 8080, 55, 90210, 1618]


func run(_host: Node) -> void:
	var catalog := UnitCatalog.load_default()
	_test_boss_is_beatable(catalog)
	_test_run_length(catalog)


## 최종 상대는 시너지를 한쪽으로 몰고 합성까지 챙긴 조합이면 이길 수 있어야 한다.
## 서식지를 넓게 펼친 조합으로는 티어 2 시너지를 쌓은 상대를 넘기 어렵다.
func _test_boss_is_beatable(catalog: UnitCatalog) -> void:
	var run := RunState.create(catalog, 20260823)
	run.round_number = RunState.FINAL_ROUND
	run.prepare_round()

	# 시너지가 겹치도록 짜고 근접은 앞줄, 원거리는 뒷줄에 세운 2성 조합.
	# 숲 + 돌격에 몰아준 조합. 근접은 앞줄, 원거리는 뒷줄.
	var front := [["bear", 3], ["bear", 2], ["wolf", 2], ["fox", 2], ["turtle", 2]]
	var back := [["fox", 2], ["bear", 2], ["sparrow", 2]]
	var players: Array[UnitState] = []
	for index in range(front.size()):
		players.append(_built_unit(
			catalog, front[index], Vector2i(index + 1, RunState.PLAYER_MIN_ROW)
		))
	for index in range(back.size()):
		players.append(_built_unit(
			catalog, back[index], Vector2i(index + 2, RunState.PLAYER_MIN_ROW + 1)
		))

	var sim := CombatSim.new()
	sim.setup(players, run.next_wave, RunState.BOARD)
	while sim.is_running():
		sim.tick()

	check_eq(sim.result(), CombatSim.Result.PLAYER_WIN, "잘 키운 조합은 최종 상대를 이겨야 합니다")


func _built_unit(catalog: UnitCatalog, entry: Array, cell: Vector2i) -> UnitState:
	var unit := UnitState.create(catalog.get_def(str(entry[0])), UnitState.Team.PLAYER, int(entry[1]))
	unit.set_position(cell)
	return unit


func _test_run_length(catalog: UnitCatalog) -> void:
	var total_minutes := 0.0
	var reached_final := 0

	for seed_value in SEEDS:
		var summary := _play_run(catalog, seed_value)
		var minutes := float(summary["minutes"])
		total_minutes += minutes
		if summary["outcome"] == RunState.Outcome.VICTORY:
			reached_final += 1

		check(
			int(summary["rounds"]) < ROUND_LIMIT,
			"시드 %d — 런이 %d라운드 안에 끝나야 합니다" % [seed_value, ROUND_LIMIT]
		)
		print("  시드 %d: %d라운드, 전투 %d틱, 약 %.1f분, 결과 %s" % [
			seed_value, summary["rounds"], summary["ticks"], minutes,
			_outcome_label(summary["outcome"])
		])

	var average := total_minutes / SEEDS.size()
	print("  평균 %.1f분, 완주 %d/%d" % [average, reached_final, SEEDS.size()])
	check_range(average, TARGET_MIN_MINUTES, TARGET_MAX_MINUTES, "평균 런 길이(분)")


func _play_run(catalog: UnitCatalog, seed_value: int) -> Dictionary:
	var run := RunState.create(catalog, seed_value)
	var ticks := 0
	var rounds := 0

	while not run.is_over() and rounds < ROUND_LIMIT:
		_auto_prepare(run)
		var sim := CombatSim.new()
		sim.setup(run.deployed_units(), run.next_wave, RunState.BOARD)
		while sim.is_running():
			sim.tick()
			ticks += 1

		run.apply_result(sim.result(), sim.alive_count(UnitState.Team.ENEMY))
		rounds += 1
		if not run.is_over():
			run.prepare_round()

	var seconds := ticks * _tick_seconds() + rounds * PREP_SECONDS_PER_ROUND
	return {
		"rounds": rounds,
		"ticks": ticks,
		"minutes": seconds / 60.0,
		"outcome": run.outcome,
	}


## 화면이 쓰는 전투 템포. 시뮬레이션 시간 환산에 쓴다.
func _tick_seconds() -> float:
	return load("res://scripts/main.gd").COMBAT_TICK_SECONDS


## 살 수 있으면 사고, 배치 한도까지 채우는 단순 전략.
func _auto_prepare(run: RunState) -> void:
	var guard := 0
	while run.owned_count() < run.owned_cap() and guard < 50:
		guard += 1
		var bought := false
		for index in range(run.shop_offers.size()):
			if run.buy(index) == RunState.Action.OK:
				bought = true
				break
		if not bought:
			break

	# 비싼 기물부터 내보낸다.
	var order := range(run.bench.size())
	order.sort_custom(func(a: int, b: int) -> bool: return _bench_cost(run, a) > _bench_cost(run, b))
	for index in order:
		if run.bench[index] == null or run.deployed_count() >= run.deploy_cap():
			continue
		var cell := _free_cell(run, run.bench[index])
		if cell.x >= 0:
			run.deploy(index, cell)


func _bench_cost(run: RunState, index: int) -> int:
	var unit: UnitState = run.bench[index]
	return 0 if unit == null else unit.def.cost * unit.star


## 근접은 앞줄, 원거리는 뒷줄에 세운다.
func _free_cell(run: RunState, unit: UnitState) -> Vector2i:
	var rows: Array[int] = [RunState.PLAYER_MIN_ROW, RunState.PLAYER_MIN_ROW + 1,
		RunState.BOARD.y - 2, RunState.BOARD.y - 1]
	if unit.def.attack_range > 1:
		rows.reverse()
	for row in rows:
		for column in range(RunState.BOARD.x):
			var cell := Vector2i(column, row)
			if not run.board.has(cell):
				return cell
	return Vector2i(-1, -1)


func _outcome_label(outcome: RunState.Outcome) -> String:
	match outcome:
		RunState.Outcome.VICTORY:
			return "완주"
		RunState.Outcome.DEFEAT:
			return "패배"
		_:
			return "진행중"
