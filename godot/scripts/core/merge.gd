## 같은 기물 3마리를 한 단계 위 등급으로 합친다.
##
## 기획서 §10의 "같은 동물 3마리 합성" 규칙이다.
## 합성 결과가 다시 3마리를 채우면 연쇄로 계속 합쳐진다.
class_name Merge
extends RefCounted

const UNITS_PER_STAR := 3
const MAX_STAR := 3


## 보유한 기물 전체를 훑어 더 합칠 것이 없을 때까지 합성한다.
## 합성이 일어난 순서대로 결과를 돌려준다.
static func resolve(run: RunState) -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	var merged := _merge_once(run)
	while not merged.is_empty():
		results.append(merged)
		merged = _merge_once(run)
	return results


## 합성 한 번. 합칠 것이 없으면 빈 사전을 돌려준다.
static func _merge_once(run: RunState) -> Dictionary:
	for entries in _group_by_kind(run).values():
		if entries.size() < UNITS_PER_STAR:
			continue

		var consumed: Array = entries.slice(0, UNITS_PER_STAR)
		var anchor: Dictionary = consumed[0]
		var unit: UnitState = anchor["unit"]

		for entry in consumed:
			_clear_slot(run, entry)

		unit.star += 1
		unit.reset_stats()
		_restore_slot(run, anchor, unit)
		return {
			"id": unit.def.id,
			"display_name": unit.def.display_name,
			"star": unit.star,
			"on_board": anchor["cell"] != null,
		}
	return {}


## 아직 최대 등급이 아닌 기물을 (종류, 등급)별로 모은다.
## 보드에 있는 기물을 앞에 두어 합성 결과가 배치를 유지하게 한다.
static func _group_by_kind(run: RunState) -> Dictionary:
	var groups := {}
	for cell: Vector2i in run.board:
		_add_entry(groups, run.board[cell], cell, -1)
	for index in range(run.bench.size()):
		if run.bench[index] != null:
			_add_entry(groups, run.bench[index], null, index)
	return groups


static func _add_entry(groups: Dictionary, unit: UnitState, cell: Variant, bench_index: int) -> void:
	if unit.star >= MAX_STAR:
		return
	var key := "%s:%d" % [unit.def.id, unit.star]
	if not groups.has(key):
		groups[key] = []
	groups[key].append({"unit": unit, "cell": cell, "bench_index": bench_index})


static func _clear_slot(run: RunState, entry: Dictionary) -> void:
	if entry["cell"] != null:
		run.board.erase(entry["cell"])
		return
	run.bench[entry["bench_index"]] = null


static func _restore_slot(run: RunState, entry: Dictionary, unit: UnitState) -> void:
	if entry["cell"] != null:
		unit.set_position(entry["cell"])
		run.board[entry["cell"]] = unit
		return
	run.bench[entry["bench_index"]] = unit
