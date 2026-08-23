## 전투 시뮬레이션의 결정성과 승패 판정을 검증한다.
extends TestCase

const TICK_BUDGET := CombatSim.MAX_TICKS + 5


func run(_host: Node) -> void:
	var catalog := UnitCatalog.load_default()
	_test_deterministic(catalog)
	_test_decisive_win(catalog)
	_test_always_terminates(catalog)
	_test_win_requires_advantage(catalog)


## 같은 배치는 항상 같은 전투가 되어야 한다. RNG를 쓰지 않으므로 완전히 재현된다.
func _test_deterministic(catalog: UnitCatalog) -> void:
	var first := _run_to_end(_matchup(catalog))
	var second := _run_to_end(_matchup(catalog))
	check_eq(first["ticks"], second["ticks"], "같은 배치는 같은 틱 수로 끝나야 합니다")
	check_eq(first["result"], second["result"], "같은 배치는 같은 결과여야 합니다")
	check_eq(first["hp"], second["hp"], "같은 배치는 같은 체력 분포로 끝나야 합니다")


## 압도적인 전력은 적을 전멸시키고 승리해야 한다.
func _test_decisive_win(catalog: UnitCatalog) -> void:
	var players := _team(catalog, ["bear", "bear", "wolf"], UnitState.Team.PLAYER, 5)
	var enemies := _team(catalog, ["sparrow"], UnitState.Team.ENEMY, 1)
	var sim := CombatSim.new()
	sim.setup(players, enemies, RunState.BOARD)
	var summary := _run_to_end(sim)

	check_eq(summary["result"], CombatSim.Result.PLAYER_WIN, "압도적 전력은 승리해야 합니다")
	check_eq(sim.alive_count(UnitState.Team.ENEMY), 0, "승리했다면 적이 남지 않아야 합니다")


## 어떤 배치든 MAX_TICKS 안에 판정이 나야 한다.
func _test_always_terminates(catalog: UnitCatalog) -> void:
	var sim := _matchup(catalog)
	var summary := _run_to_end(sim)
	check(not sim.is_running(), "전투가 %d틱 안에 끝나야 합니다" % TICK_BUDGET)
	check(int(summary["ticks"]) <= CombatSim.MAX_TICKS, "틱 상한을 넘기면 안 됩니다")


## 승리는 적 전멸이거나 체력 비율 우위일 때만 나와야 한다.
## 예전에는 무승부와 시간 초과까지 승리로 처리됐다.
func _test_win_requires_advantage(catalog: UnitCatalog) -> void:
	var compositions := [
		[["turtle"], ["bear", "wolf", "fox"]],
		[["rabbit", "sparrow"], ["turtle", "turtle"]],
		[["frog"], ["frog"]],
		[["penguin", "wolf"], ["bear"]],
	]
	for pair in compositions:
		var sim := CombatSim.new()
		sim.setup(
			_team(catalog, pair[0], UnitState.Team.PLAYER, 5),
			_team(catalog, pair[1], UnitState.Team.ENEMY, 1),
			RunState.BOARD
		)
		_run_to_end(sim)

		var label := "%s 대 %s" % [str(pair[0]), str(pair[1])]
		check(sim.result() != CombatSim.Result.ONGOING, "%s — 판정이 나야 합니다" % label)
		if sim.result() != CombatSim.Result.PLAYER_WIN:
			continue
		var wiped := sim.alive_count(UnitState.Team.ENEMY) == 0
		var ahead := sim.hp_ratio(UnitState.Team.PLAYER) - sim.hp_ratio(UnitState.Team.ENEMY)
		check(
			wiped or ahead > CombatSim.TIMEOUT_MARGIN,
			"%s — 적이 남았는데 체력 우위 없이 승리로 판정됐습니다" % label
		)


func _matchup(catalog: UnitCatalog) -> CombatSim:
	var sim := CombatSim.new()
	sim.setup(
		_team(catalog, ["turtle", "sparrow", "wolf"], UnitState.Team.PLAYER, 6),
		_team(catalog, ["fox", "frog", "penguin"], UnitState.Team.ENEMY, 1),
		RunState.BOARD
	)
	return sim


func _team(
	catalog: UnitCatalog, ids: Array, team: UnitState.Team, row: int
) -> Array[UnitState]:
	var units: Array[UnitState] = []
	for index in range(ids.size()):
		var unit := UnitState.create(catalog.get_def(str(ids[index])), team)
		unit.set_position(Vector2i(index + 1, row))
		units.append(unit)
	return units


func _run_to_end(sim: CombatSim) -> Dictionary:
	var ticks := 0
	while sim.is_running() and ticks < TICK_BUDGET:
		sim.tick()
		ticks += 1
	var hp := PackedInt32Array()
	for unit in sim.units:
		hp.append(unit.hp)
	return {"ticks": ticks, "result": sim.result(), "hp": hp}
