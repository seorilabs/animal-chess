## 전투 시작 시 팀 단위로 적용되는 보너스.
##
## 기획서 §23의 서식지 축과 §22의 역할 축을 다루며, 전투 사본에만 적용한다.
class_name Synergy
extends RefCounted

const HABITAT_PAIR_ATTACK := 1
const TURTLE_BONUS_HP := 6
const WOLF_PACK_ATTACK := 2
const RABBIT_SPEED := 1


## 각 팀에 시너지 보너스를 적용한다. 전투 시작 직전 한 번만 호출한다.
static func apply(units: Array[UnitState]) -> void:
	for team in [UnitState.Team.PLAYER, UnitState.Team.ENEMY]:
		_apply_team(units, team)


static func _apply_team(units: Array[UnitState], team: UnitState.Team) -> void:
	var members: Array[UnitState] = []
	for unit in units:
		if unit.team == team:
			members.append(unit)
	if members.is_empty():
		return

	var habitat_counts := habitat_counts(members)
	var id_counts := id_counts(members)

	for unit in members:
		if habitat_counts.get(unit.def.habitat, 0) >= 2:
			unit.attack += HABITAT_PAIR_ATTACK
		if unit.def.id == "turtle":
			unit.max_hp += TURTLE_BONUS_HP
			unit.hp += TURTLE_BONUS_HP
		if unit.def.id == "wolf" and id_counts.get("wolf", 0) >= 2:
			unit.attack += WOLF_PACK_ATTACK
		if id_counts.get("rabbit", 0) > 0 and unit.def.id != "rabbit":
			unit.speed += RABBIT_SPEED


static func habitat_counts(members: Array[UnitState]) -> Dictionary:
	var counts := {}
	for unit in members:
		counts[unit.def.habitat] = int(counts.get(unit.def.habitat, 0)) + 1
	return counts


static func role_counts(members: Array[UnitState]) -> Dictionary:
	var counts := {}
	for unit in members:
		counts[unit.def.role] = int(counts.get(unit.def.role, 0)) + 1
	return counts


static func id_counts(members: Array[UnitState]) -> Dictionary:
	var counts := {}
	for unit in members:
		counts[unit.def.id] = int(counts.get(unit.def.id, 0)) + 1
	return counts
