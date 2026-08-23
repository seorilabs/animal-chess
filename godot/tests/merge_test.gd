## 같은 기물 3마리 합성과 연쇄 합성을 검증한다.
extends TestCase

const SEED := 424242


func run(_host: Node) -> void:
	var catalog := UnitCatalog.load_default()
	_test_bench_merge(catalog)
	_test_board_slot_is_kept(catalog)
	_test_chain_merge(catalog)
	_test_max_star_stops(catalog)
	_test_buy_allowed_when_it_merges(catalog)


func _test_bench_merge(catalog: UnitCatalog) -> void:
	var run := RunState.create(catalog, SEED)
	for index in range(3):
		run.bench[index] = UnitState.create(catalog.get_def("wolf"), UnitState.Team.PLAYER)

	var merges := Merge.resolve(run)
	check_eq(merges.size(), 1, "3마리는 한 번 합성되어야 합니다")
	check_eq(run.owned_count(), 1, "3마리가 1마리로 합쳐져야 합니다")

	var merged: UnitState = run.bench[0]
	check_eq(merged.star, 2, "합성 결과는 2성")
	check(merged.max_hp > catalog.get_def("wolf").max_hp, "2성은 체력이 더 높아야 합니다")
	check(merged.attack > catalog.get_def("wolf").attack, "2성은 공격력이 더 높아야 합니다")
	check_eq(merged.hp, merged.max_hp, "합성 후 체력은 가득 차야 합니다")


## 보드에 있던 기물의 자리는 합성 후에도 유지되어야 한다.
func _test_board_slot_is_kept(catalog: UnitCatalog) -> void:
	var run := RunState.create(catalog, SEED)
	var cell := Vector2i(3, 6)
	var placed := UnitState.create(catalog.get_def("fox"), UnitState.Team.PLAYER)
	placed.set_position(cell)
	run.board[cell] = placed
	run.bench[0] = UnitState.create(catalog.get_def("fox"), UnitState.Team.PLAYER)
	run.bench[1] = UnitState.create(catalog.get_def("fox"), UnitState.Team.PLAYER)

	Merge.resolve(run)
	check(run.board.has(cell), "합성 결과가 보드 자리를 지켜야 합니다")
	check_eq((run.board[cell] as UnitState).star, 2, "보드 위 기물이 2성이 되어야 합니다")
	check_eq(run.owned_count(), 1, "대기석 기물은 소모되어야 합니다")


## 2성 3개가 모이면 3성으로 이어져야 한다.
func _test_chain_merge(catalog: UnitCatalog) -> void:
	var run := RunState.create(catalog, SEED)
	for index in range(9):
		run.bench.append(UnitState.create(catalog.get_def("frog"), UnitState.Team.PLAYER))

	var merges := Merge.resolve(run)
	check_eq(merges.size(), 4, "2성 세 번과 3성 한 번, 총 네 번 합성되어야 합니다")
	check_eq(run.owned_count(), 1, "9마리가 1마리로 합쳐져야 합니다")
	check_eq(int(merges[-1]["star"]), 3, "마지막 합성은 3성")


## 3성은 더 합쳐지지 않아야 한다.
func _test_max_star_stops(catalog: UnitCatalog) -> void:
	var run := RunState.create(catalog, SEED)
	for index in range(3):
		var unit := UnitState.create(catalog.get_def("bear"), UnitState.Team.PLAYER)
		unit.star = Merge.MAX_STAR
		unit.reset_stats()
		run.bench[index] = unit

	check(Merge.resolve(run).is_empty(), "3성끼리는 합성되지 않아야 합니다")
	check_eq(run.owned_count(), 3, "3성 3마리는 그대로 남아야 합니다")


## 보유 한도에 걸려도 합성이 되는 구매는 허용해야 한다.
func _test_buy_allowed_when_it_merges(catalog: UnitCatalog) -> void:
	var run := RunState.create(catalog, SEED)
	run.gold = 999
	var target_id := run.shop_offers[0]

	# 한도를 같은 기물로 가득 채운다.
	for index in range(run.owned_cap()):
		run.bench[index] = UnitState.create(catalog.get_def(target_id), UnitState.Team.PLAYER)
	check_eq(run.owned_count(), run.owned_cap(), "한도를 채웠습니다")

	check_eq(run.buy(0), RunState.Action.OK, "합성으로 이어지는 구매는 허용되어야 합니다")
	check(not run.last_merges.is_empty(), "구매 직후 합성이 일어나야 합니다")

	# 합성이 되지 않는 기물이면 한도에 걸려야 한다.
	var other_id := "bear" if target_id != "bear" else "turtle"
	run.shop_offers[0] = other_id
	while run.owned_count() < run.owned_cap():
		run.bench[run.first_empty_bench_slot()] = UnitState.create(
			catalog.get_def("snow_leopard"), UnitState.Team.PLAYER
		)
	check_eq(run.buy(0), RunState.Action.OWNED_CAP_REACHED, "합성이 안 되면 한도에 걸려야 합니다")
