## 준비 단계 규칙(한도, 구매, 배치, 결산)을 검증한다.
extends TestCase

const SEED := 20260823


func run(_host: Node) -> void:
	var catalog := UnitCatalog.load_default()
	_test_caps(catalog)
	_test_same_seed_same_shop(catalog)
	_test_buy_limits(catalog)
	_test_placement(catalog)
	_test_round_results(catalog)


func _test_caps(catalog: UnitCatalog) -> void:
	var run := RunState.create(catalog, SEED)
	var expected_owned := [4, 5, 6, 7, 8, 8, 10, 10, 12, 12, 12]
	var expected_deploy := [2, 3, 4, 5, 5, 6, 6, 7, 7, 8, 8]
	for index in range(expected_owned.size()):
		run.round_number = index + 1
		check_eq(run.owned_cap(), expected_owned[index], "%d라운드 보유 한도" % run.round_number)
		check_eq(run.deploy_cap(), expected_deploy[index], "%d라운드 배치 한도" % run.round_number)


## 같은 시드는 같은 상점을 만들어야 한다.
func _test_same_seed_same_shop(catalog: UnitCatalog) -> void:
	var first := RunState.create(catalog, SEED)
	var second := RunState.create(catalog, SEED)
	check_eq(first.shop_offers, second.shop_offers, "같은 시드는 같은 상점이어야 합니다")

	first.roll_shop()
	second.roll_shop()
	check_eq(first.shop_offers, second.shop_offers, "이후 리롤도 같은 순서여야 합니다")

	var other := RunState.create(catalog, SEED + 1)
	check(other.shop_offers != first.shop_offers, "다른 시드는 다른 상점이어야 합니다")


func _test_buy_limits(catalog: UnitCatalog) -> void:
	var run := RunState.create(catalog, SEED)
	run.gold = 0
	check_eq(run.buy(0), RunState.Action.NOT_ENOUGH_GOLD, "골드가 없으면 살 수 없습니다")

	run.gold = 999
	for _i in range(run.owned_cap()):
		run.buy(0)
	check_eq(run.owned_count(), run.owned_cap(), "보유 한도까지만 채워져야 합니다")
	check_eq(run.buy(0), RunState.Action.OWNED_CAP_REACHED, "보유 한도를 넘겨 살 수 없습니다")
	check_eq(run.buy(99), RunState.Action.INVALID, "없는 상점 칸은 거절해야 합니다")


func _test_placement(catalog: UnitCatalog) -> void:
	var run := RunState.create(catalog, SEED)
	run.gold = 999
	run.buy(0)
	run.buy(1)
	run.buy(2)

	check_eq(run.deploy(0, Vector2i(3, 1)), RunState.Action.INVALID, "적 진영에는 배치할 수 없습니다")
	check_eq(run.deploy(0, Vector2i(3, 7)), RunState.Action.OK, "아군 진영에는 배치할 수 있습니다")
	check_eq(run.deploy(1, Vector2i(4, 7)), RunState.Action.OK, "두 번째 배치")
	check_eq(run.deployed_count(), 2, "배치 수")
	check_eq(
		run.deploy(2, Vector2i(5, 7)),
		RunState.Action.DEPLOY_CAP_REACHED,
		"1라운드 배치 한도는 2마리입니다"
	)

	var moved: UnitState = run.board[Vector2i(3, 7)]
	var stayed: UnitState = run.board[Vector2i(4, 7)]
	check_eq(run.relocate(Vector2i(3, 7), Vector2i(4, 7)), RunState.Action.OK, "자리 맞바꾸기")
	check_eq(run.board[Vector2i(4, 7)], moved, "옮긴 기물이 도착 칸에 있어야 합니다")
	check_eq(run.board[Vector2i(3, 7)], stayed, "있던 기물이 출발 칸으로 밀려야 합니다")
	check_eq(stayed.position(), Vector2i(3, 7), "밀린 기물의 좌표도 갱신되어야 합니다")

	check_eq(run.recall(Vector2i(4, 7), 0), RunState.Action.OK, "대기석으로 되돌리기")
	check_eq(run.deployed_count(), 1, "되돌린 뒤 배치 수")


func _test_round_results(catalog: UnitCatalog) -> void:
	var run := RunState.create(catalog, SEED)
	var before_gold := run.gold
	var win := run.apply_result(CombatSim.Result.PLAYER_WIN, 0)
	check(int(win["gold_gain"]) > 0, "승리하면 골드를 받아야 합니다")
	check_eq(run.gold, before_gold + int(win["gold_gain"]), "골드 반영")
	check_eq(run.round_number, 2, "승리 후 라운드 진행")

	var before_hp := run.player_hp
	var loss := run.apply_result(CombatSim.Result.ENEMY_WIN, 3)
	check_eq(int(loss["hp_loss"]), 3, "남은 적 수만큼 체력을 잃어야 합니다")
	check_eq(run.player_hp, before_hp - 3, "체력 반영")

	var draw := run.apply_result(CombatSim.Result.DRAW, 1)
	check_eq(int(draw["gold_gain"]), 0, "무승부는 보상이 없어야 합니다")
	check_eq(int(draw["hp_loss"]), RunState.DRAW_DAMAGE, "무승부는 소액 피해만 있어야 합니다")

	run.player_hp = 0
	check(run.is_over(), "체력이 0이면 런이 끝나야 합니다")
