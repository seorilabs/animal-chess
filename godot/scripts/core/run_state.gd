## 한 판(런)의 진행 상태와 준비 단계 규칙.
##
## 전투 자체는 CombatSim이 맡고, 여기서는 상점/대기석/배치/보상만 다룬다.
## 모든 무작위는 `seed`에서 파생되므로 같은 시드는 같은 런을 만든다.
class_name RunState
extends RefCounted

enum Action { OK, NOT_ENOUGH_GOLD, BENCH_FULL, OWNED_CAP_REACHED, DEPLOY_CAP_REACHED, INVALID }
enum Outcome { ONGOING, VICTORY, DEFEAT }

const BOARD := Vector2i(8, 8)
const BENCH_SIZE := 8
## 플레이어는 보드 아래 절반에만 배치할 수 있다.
const PLAYER_MIN_ROW := 4
const START_HP := 40
const START_GOLD := 10
const WIN_GOLD_BASE := 5
const WIN_GOLD_ROUND_BONUS_CAP := 4
const MIN_DEFEAT_DAMAGE := 2
## 패배 피해가 후반에 감당 못 할 만큼 커지지 않도록 상한을 둔다.
const MAX_DEFEAT_DAMAGE := 8
const DRAW_DAMAGE := 1

## 라운드별 보유/배치 한도. 마지막 값이 이후 라운드에 계속 적용된다.
const OWNED_CAPS: Array[int] = [4, 5, 6, 7, 8, 8, 10, 10, 12]
const DEPLOY_CAPS: Array[int] = [2, 3, 4, 5, 5, 6, 6, 7, 7, 8]

## 이 라운드의 상대를 이기면 런이 끝난다.
const FINAL_ROUND := 18
## 평소보다 한 마리 많은 정예 상대가 나오는 라운드.
const ELITE_ROUNDS: Array[int] = [5, 10, 15]
const ELITE_EXTRA_UNITS := 1
## 최종 상대는 수가 아니라 등급으로 강해진다. 수까지 늘리면 조합 완성도와
## 무관하게 이길 수 없어진다.
const BOSS_STAR := 2

var seed: int = 0
var round_number: int = 1
var player_hp: int = START_HP
var gold: int = START_GOLD
var bench: Array[UnitState] = []
var board: Dictionary = {}
var shop_offers: PackedStringArray = PackedStringArray()
## 이번 라운드에 맞설 상대. 준비 단계에서 미리 볼 수 있도록 먼저 만든다.
var next_wave: Array[UnitState] = []
var outcome: Outcome = Outcome.ONGOING
## 마지막 구매에서 일어난 합성 결과. 화면이 안내 문구를 만들 때 쓴다.
var last_merges: Array[Dictionary] = []

var catalog: UnitCatalog
var rng := RandomNumberGenerator.new()


static func create(unit_catalog: UnitCatalog, run_seed: int) -> RunState:
	var run := RunState.new()
	run.catalog = unit_catalog
	run.start(run_seed)
	return run


func start(run_seed: int) -> void:
	seed = run_seed
	rng.seed = run_seed
	round_number = 1
	player_hp = START_HP
	gold = START_GOLD
	outcome = Outcome.ONGOING
	board.clear()
	bench.clear()
	last_merges.clear()
	bench.resize(BENCH_SIZE)
	prepare_round()


func is_over() -> bool:
	return outcome != Outcome.ONGOING


## 다음 라운드의 상점과 상대를 준비한다.
func prepare_round() -> void:
	roll_shop()
	next_wave = AIDirector.build_wave(catalog, round_number, wave_size(), wave_star(), BOARD, rng)


func is_elite_round() -> bool:
	return round_number in ELITE_ROUNDS


func is_boss_round() -> bool:
	return round_number >= FINAL_ROUND


## 상대 규모. 플레이어가 배치 한도를 다 쓰는 것을 전제로 한다.
func wave_size() -> int:
	if is_elite_round():
		return deploy_cap() + ELITE_EXTRA_UNITS
	return deploy_cap()


func wave_star() -> int:
	return BOSS_STAR if is_boss_round() else 1


## 상대를 가리키는 이름. 미리보기와 전투 안내에 쓴다.
func round_label() -> String:
	if is_boss_round():
		return "최종 상대"
	if is_elite_round():
		return "정예 상대"
	return "%d라운드 상대" % round_number


## 상태 표시줄에 쓰는 라운드 표기. 라운드 번호가 항상 보여야 한다.
func round_status() -> String:
	if is_boss_round():
		return "%d라운드 · 최종" % round_number
	if is_elite_round():
		return "%d라운드 · 정예" % round_number
	return "%d라운드" % round_number


# --- 한도 ---------------------------------------------------------------

func owned_cap() -> int:
	return OWNED_CAPS[clampi(round_number - 1, 0, OWNED_CAPS.size() - 1)]


func deploy_cap() -> int:
	return DEPLOY_CAPS[clampi(round_number - 1, 0, DEPLOY_CAPS.size() - 1)]


func deployed_count() -> int:
	return board.size()


func owned_count() -> int:
	var count := deployed_count()
	for unit in bench:
		if unit != null:
			count += 1
	return count


# --- 상점 ---------------------------------------------------------------

func roll_shop() -> void:
	shop_offers = Shop.roll(catalog, round_number, rng)


func reroll() -> Action:
	if gold < Shop.REROLL_COST:
		return Action.NOT_ENOUGH_GOLD
	gold -= Shop.REROLL_COST
	roll_shop()
	return Action.OK


func buy(offer_index: int) -> Action:
	if offer_index < 0 or offer_index >= shop_offers.size():
		return Action.INVALID
	var unit_def := catalog.get_def(shop_offers[offer_index])
	# 합성으로 이어지는 구매는 보유 한도에 걸려도 허용한다.
	# 막으면 마지막 한 마리를 못 사서 합성이 영영 불가능해진다.
	if owned_count() >= owned_cap() and not _completes_merge(unit_def.id):
		return Action.OWNED_CAP_REACHED
	if gold < unit_def.cost:
		return Action.NOT_ENOUGH_GOLD
	var slot := first_empty_bench_slot()
	if slot == -1:
		return Action.BENCH_FULL

	gold -= unit_def.cost
	bench[slot] = UnitState.create(unit_def, UnitState.Team.PLAYER)
	shop_offers[offer_index] = _random_offer()
	last_merges = Merge.resolve(self)
	return Action.OK


## 이 기물을 한 마리 더 사면 곧바로 합성이 되는가.
func _completes_merge(id: String) -> bool:
	var same := 0
	for unit in owned_units():
		if unit.def.id == id and unit.star == 1:
			same += 1
	return same >= Merge.UNITS_PER_STAR - 1


func owned_units() -> Array[UnitState]:
	var units := deployed_units()
	for unit in bench:
		if unit != null:
			units.append(unit)
	return units


func _random_offer() -> String:
	var pool := Shop.pool_for_round(catalog, round_number)
	return pool[rng.randi_range(0, pool.size() - 1)]


func first_empty_bench_slot() -> int:
	for index in range(bench.size()):
		if bench[index] == null:
			return index
	return -1


# --- 배치 ---------------------------------------------------------------

func is_player_cell(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < BOARD.x and cell.y >= PLAYER_MIN_ROW and cell.y < BOARD.y


## 대기석의 기물을 보드에 놓는다. 이미 기물이 있으면 자리를 맞바꾼다.
func deploy(bench_index: int, cell: Vector2i) -> Action:
	if bench_index < 0 or bench_index >= bench.size() or bench[bench_index] == null:
		return Action.INVALID
	if not is_player_cell(cell):
		return Action.INVALID
	if not board.has(cell) and deployed_count() >= deploy_cap():
		return Action.DEPLOY_CAP_REACHED

	var unit: UnitState = bench[bench_index]
	bench[bench_index] = board.get(cell)
	unit.set_position(cell)
	board[cell] = unit
	return Action.OK


## 보드 위 기물을 다른 칸으로 옮긴다. 도착 칸에 기물이 있으면 맞바꾼다.
func relocate(from_cell: Vector2i, to_cell: Vector2i) -> Action:
	if not board.has(from_cell) or not is_player_cell(to_cell):
		return Action.INVALID
	if from_cell == to_cell:
		return Action.OK

	var moving: UnitState = board[from_cell]
	board.erase(from_cell)
	if board.has(to_cell):
		var swapped: UnitState = board[to_cell]
		swapped.set_position(from_cell)
		board[from_cell] = swapped
	moving.set_position(to_cell)
	board[to_cell] = moving
	return Action.OK


## 보드 위 기물을 대기석으로 되돌린다.
func recall(cell: Vector2i, bench_index: int) -> Action:
	if not board.has(cell):
		return Action.INVALID
	if bench_index < 0 or bench_index >= bench.size() or bench[bench_index] != null:
		return Action.BENCH_FULL
	bench[bench_index] = board[cell]
	board.erase(cell)
	return Action.OK


func deployed_units() -> Array[UnitState]:
	var units: Array[UnitState] = []
	for cell in board:
		units.append(board[cell])
	return units


# --- 라운드 결산 --------------------------------------------------------

func apply_result(result: CombatSim.Result, enemy_alive: int) -> Dictionary:
	var gold_gain := 0
	var hp_loss := 0

	match result:
		CombatSim.Result.PLAYER_WIN:
			gold_gain = WIN_GOLD_BASE + mini(WIN_GOLD_ROUND_BONUS_CAP, round_number)
			gold += gold_gain
		CombatSim.Result.ENEMY_WIN:
			hp_loss = clampi(
				MIN_DEFEAT_DAMAGE + int(enemy_alive / 2.0), MIN_DEFEAT_DAMAGE, MAX_DEFEAT_DAMAGE
			)
			player_hp = maxi(0, player_hp - hp_loss)
		CombatSim.Result.DRAW:
			hp_loss = DRAW_DAMAGE
			player_hp = maxi(0, player_hp - hp_loss)

	if player_hp <= 0:
		outcome = Outcome.DEFEAT
	elif is_boss_round() and result == CombatSim.Result.PLAYER_WIN:
		outcome = Outcome.VICTORY

	round_number += 1
	return {"gold_gain": gold_gain, "hp_loss": hp_loss}
