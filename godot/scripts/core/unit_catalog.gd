## 게임에 등장하는 모든 기물 설계값의 단일 출처.
##
## 실제 목록은 res://data/unit_catalog.tres에 있다.
## 디렉터리 스캔 대신 명시적 목록을 쓰는 이유는 export 빌드에서도 확실히 포함되기 때문이다.
class_name UnitCatalog
extends Resource

const RESOURCE_PATH := "res://data/unit_catalog.tres"

@export var units: Array = []

var _by_id: Dictionary = {}


static func load_default() -> UnitCatalog:
	var catalog: UnitCatalog = load(RESOURCE_PATH)
	catalog.rebuild_index()
	return catalog


func rebuild_index() -> void:
	_by_id.clear()
	for entry in units:
		var unit_def := entry as UnitDef
		if unit_def == null:
			push_error("unit_catalog.tres에 UnitDef가 아닌 항목이 있습니다.")
			continue
		_by_id[unit_def.id] = unit_def


func has(id: String) -> bool:
	return _by_id.has(id)


func get_def(id: String) -> UnitDef:
	var unit_def: UnitDef = _by_id.get(id)
	if unit_def == null:
		push_error("알 수 없는 기물 id: %s" % id)
	return unit_def


func ids() -> PackedStringArray:
	var result := PackedStringArray()
	for entry in units:
		result.append((entry as UnitDef).id)
	return result


func defs() -> Array[UnitDef]:
	var result: Array[UnitDef] = []
	for entry in units:
		result.append(entry as UnitDef)
	return result
