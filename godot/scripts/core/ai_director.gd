## AI 상대 조합을 만든다.
##
## 기획서의 AI 설계대로 초반은 고정 wave로 기본 대응법을 가르치고,
## 중반부터는 시너지 목표를 가진 조합을 뽑는다.
class_name AIDirector
extends RefCounted

## 이 라운드까지는 정해진 조합만 나온다.
const SCRIPTED_ROUNDS := 2
## 시너지 목표 서식지가 조합에서 차지하는 비율.
const THEME_SHARE := 0.6

const SCRIPTED_WAVES := {
	1: ["turtle", "sparrow"],
	2: ["turtle", "frog", "sparrow"],
}


## 적 조합을 만든다. `count`는 플레이어 배치 수와 맞춘 규모다.
static func build_wave(
	catalog: UnitCatalog,
	round_number: int,
	count: int,
	star: int,
	board: Vector2i,
	rng: RandomNumberGenerator
) -> Array[UnitState]:
	var ids := _pick_ids(catalog, round_number, count, rng)
	var wave: Array[UnitState] = []
	for id in ids:
		wave.append(UnitState.create(catalog.get_def(id), UnitState.Team.ENEMY, star))
	_place(wave, board)
	return wave


static func _pick_ids(
	catalog: UnitCatalog,
	round_number: int,
	count: int,
	rng: RandomNumberGenerator
) -> PackedStringArray:
	var ids := PackedStringArray()
	if round_number <= SCRIPTED_ROUNDS and SCRIPTED_WAVES.has(round_number):
		var scripted: Array = SCRIPTED_WAVES[round_number]
		for i in range(count):
			ids.append(str(scripted[i % scripted.size()]))
		return ids

	var pool := Shop.pool_for_round(catalog, round_number)
	var theme := _pick_theme(catalog, pool, rng)
	var theme_ids := PackedStringArray()
	for id in pool:
		if catalog.get_def(id).habitat == theme:
			theme_ids.append(id)

	var theme_slots := int(round(count * THEME_SHARE))
	for i in range(count):
		var source := theme_ids if i < theme_slots and not theme_ids.is_empty() else pool
		ids.append(source[rng.randi_range(0, source.size() - 1)])
	return ids


static func _pick_theme(
	catalog: UnitCatalog,
	pool: PackedStringArray,
	rng: RandomNumberGenerator
) -> UnitDef.Habitat:
	var habitats: Array[UnitDef.Habitat] = []
	for id in pool:
		var habitat := catalog.get_def(id).habitat
		if habitat not in habitats:
			habitats.append(habitat)
	return habitats[rng.randi_range(0, habitats.size() - 1)]


## 근접 역할은 앞줄(플레이어 쪽), 원거리 역할은 뒷줄에 세운다.
static func _place(wave: Array[UnitState], board: Vector2i) -> void:
	var enemy_rows := int(board.y / 2.0)
	var front_row := enemy_rows - 1
	var occupied: Dictionary = {}

	for index in range(wave.size()):
		var unit := wave[index]
		var preferred_row := front_row if _is_melee(unit) else 0
		var column := _column_for(index, board.x)
		unit.set_position(_free_slot(occupied, column, preferred_row, board, enemy_rows))
		occupied[unit.position()] = true


static func _is_melee(unit: UnitState) -> bool:
	return unit.def.attack_range <= 1


static func _column_for(index: int, width: int) -> int:
	# 가운데부터 좌우로 번갈아 채워 대칭에 가까운 진형을 만든다.
	var center := int(width / 2.0)
	var offset := int((index + 1) / 2.0)
	if index % 2 == 0:
		return clampi(center - offset, 0, width - 1)
	return clampi(center + offset, 0, width - 1)


static func _free_slot(
	occupied: Dictionary,
	column: int,
	preferred_row: int,
	board: Vector2i,
	enemy_rows: int
) -> Vector2i:
	for row_offset in range(enemy_rows):
		for row in [preferred_row - row_offset, preferred_row + row_offset]:
			if row < 0 or row >= enemy_rows:
				continue
			for column_offset in range(board.x):
				for candidate_column in [column - column_offset, column + column_offset]:
					if candidate_column < 0 or candidate_column >= board.x:
						continue
					var slot := Vector2i(candidate_column, row)
					if not occupied.has(slot):
						return slot
	return Vector2i(column, preferred_row)
