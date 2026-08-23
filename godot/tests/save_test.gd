## 런 저장/복구와 누적 기록을 검증한다.
extends TestCase

const SEED := 987654


func run(_host: Node) -> void:
	var catalog := UnitCatalog.load_default()
	SaveService.clear_all()
	_test_run_round_trip(catalog)
	_test_save_and_load(catalog)
	_test_profile(catalog)
	_test_broken_save_is_discarded(catalog)
	SaveService.clear_all()


func _test_run_round_trip(catalog: UnitCatalog) -> void:
	var original := _sample_run(catalog)
	var restored := RunState.from_dict(catalog, original.to_dict())

	check(restored != null, "복구된 런이 있어야 합니다")
	check_eq(restored.round_number, original.round_number, "라운드")
	check_eq(restored.player_hp, original.player_hp, "체력")
	check_eq(restored.gold, original.gold, "골드")
	check_eq(restored.shop_offers, original.shop_offers, "상점 목록")
	check_eq(restored.deployed_count(), original.deployed_count(), "배치 수")
	check_eq(restored.owned_count(), original.owned_count(), "보유 수")
	check_eq(restored.next_wave.size(), original.next_wave.size(), "상대 수")

	var cell := original.board.keys()[0] as Vector2i
	check(restored.board.has(cell), "배치 좌표가 유지되어야 합니다")
	check_eq(
		(restored.board[cell] as UnitState).def.id,
		(original.board[cell] as UnitState).def.id,
		"배치된 기물 종류"
	)
	check_eq((restored.board[cell] as UnitState).star, 2, "합성 등급도 유지되어야 합니다")

	# 같은 지점에서 이어가면 같은 상점이 나와야 한다.
	original.roll_shop()
	restored.roll_shop()
	check_eq(restored.shop_offers, original.shop_offers, "이어하기 후에도 같은 순서여야 합니다")


func _test_save_and_load(catalog: UnitCatalog) -> void:
	var original := _sample_run(catalog)
	check(SaveService.save_run(original), "저장에 성공해야 합니다")
	check(SaveService.has_run(), "저장 파일이 있어야 합니다")

	var loaded := SaveService.load_run(catalog)
	check(loaded != null, "저장된 런을 읽어야 합니다")
	check_eq(loaded.round_number, original.round_number, "읽은 런의 라운드")
	check_eq(loaded.gold, original.gold, "읽은 런의 골드")

	SaveService.clear_run()
	check(not SaveService.has_run(), "지운 뒤에는 저장이 없어야 합니다")
	check(SaveService.load_run(catalog) == null, "저장이 없으면 null이어야 합니다")


func _test_profile(_catalog: UnitCatalog) -> void:
	var profile := Profile.new()
	check(profile.unlock("wolf"), "처음 해금은 true")
	check(not profile.unlock("wolf"), "이미 해금한 기물은 false")
	profile.record_round(7)
	profile.record_round(3)
	profile.record_run_end(true)
	profile.record_run_end(false)

	check(SaveService.save_profile(profile), "기록 저장에 성공해야 합니다")
	var loaded := SaveService.load_profile()
	check(loaded.is_unlocked("wolf"), "해금 목록이 유지되어야 합니다")
	check(not loaded.is_unlocked("bear"), "해금하지 않은 기물은 잠겨 있어야 합니다")
	check_eq(loaded.best_round, 7, "최고 라운드는 가장 높은 값이어야 합니다")
	check_eq(loaded.runs_played, 2, "플레이한 런 수")
	check_eq(loaded.runs_won, 1, "완주한 런 수")


## 망가진 저장 파일은 버리고 새 런으로 시작할 수 있어야 한다.
func _test_broken_save_is_discarded(catalog: UnitCatalog) -> void:
	var file := FileAccess.open(SaveService.RUN_PATH, FileAccess.WRITE)
	file.store_string("{ this is not json")
	file.close()

	check(SaveService.load_run(catalog) == null, "망가진 저장은 null이어야 합니다")
	check(not SaveService.has_run(), "망가진 저장은 지워져야 합니다")


func _sample_run(catalog: UnitCatalog) -> RunState:
	var run := RunState.create(catalog, SEED)
	run.round_number = 6
	run.prepare_round()
	run.player_hp = 27
	run.gold = 14

	var placed := UnitState.create(catalog.get_def("wolf"), UnitState.Team.PLAYER, 2)
	placed.set_position(Vector2i(3, 6))
	run.board[placed.position()] = placed
	run.bench[0] = UnitState.create(catalog.get_def("frog"), UnitState.Team.PLAYER)
	run.bench[3] = UnitState.create(catalog.get_def("bear"), UnitState.Team.PLAYER)
	return run
