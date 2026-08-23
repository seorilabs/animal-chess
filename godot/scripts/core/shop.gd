## 라운드에 따라 상점 제시 목록을 굴린다.
class_name Shop
extends RefCounted

const SIZE := 5
const REROLL_COST := 2

## 라운드가 오를수록 비싼 기물이 등장한다. 기획서 §10의 상점 규칙.
const UNLOCK_ROUNDS := {
	1: 1,
	2: 2,
	3: 4,
}


static func pool_for_round(catalog: UnitCatalog, round_number: int) -> PackedStringArray:
	var pool := PackedStringArray()
	for unit_def in catalog.defs():
		if round_number >= int(UNLOCK_ROUNDS.get(unit_def.cost, 1)):
			pool.append(unit_def.id)
	if pool.is_empty():
		pool = catalog.ids()
	return pool


static func roll(catalog: UnitCatalog, round_number: int, rng: RandomNumberGenerator) -> PackedStringArray:
	var pool := pool_for_round(catalog, round_number)
	var offers := PackedStringArray()
	for _i in range(SIZE):
		offers.append(pool[rng.randi_range(0, pool.size() - 1)])
	return offers
