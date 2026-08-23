## 서식지 + 역할 2축 시너지.
##
## 기획서 §22(역할)와 §23(서식지)의 두 축을 그대로 쓴다.
## 배치한 기물 "마리 수"로 세므로 같은 동물을 여러 마리 모으는 선택도 시너지에 기여한다.
class_name Synergy
extends RefCounted

enum Axis { HABITAT, ROLE }

## 발동에 필요한 마리 수. 앞에서부터 1티어, 2티어다.
const TIERS: Array[int] = [2, 4]

## 서식지 축 효과. 해당 서식지 기물에게만 적용된다.
const HABITAT_EFFECTS := {
	UnitDef.Habitat.FOREST: [{"regen": 1}, {"regen": 2}],
	UnitDef.Habitat.GRASSLAND: [{"speed": 1}, {"speed": 2}],
	UnitDef.Habitat.SWAMP: [{"poison_power": 1}, {"poison_power": 3}],
	UnitDef.Habitat.POLAR: [{"chill": 1}, {"chill": 2}],
	UnitDef.Habitat.SKY: [{"attack": 2}, {"attack": 5}],
}

const HABITAT_TEXTS := {
	UnitDef.Habitat.FOREST: ["숲 기물이 전투 중 체력을 회복합니다.", "숲 기물의 회복량이 늘어납니다."],
	UnitDef.Habitat.GRASSLAND: ["초원 기물이 더 자주 행동합니다.", "초원 기물의 행동 속도가 크게 오릅니다."],
	UnitDef.Habitat.SWAMP: ["늪 기물의 독이 오래 갑니다.", "늪 기물의 독이 훨씬 오래 갑니다."],
	UnitDef.Habitat.POLAR: ["극지 기물의 공격이 적을 늦춥니다.", "극지 기물이 적을 더 크게 늦춥니다."],
	UnitDef.Habitat.SKY: ["하늘 기물의 공격력이 오릅니다.", "하늘 기물의 공격력이 크게 오릅니다."],
}

## 역할 축 효과. `team_` 접두 효과는 팀 전체에 적용된다.
const ROLE_EFFECTS := {
	UnitDef.Role.DEFENDER: [{"max_hp": 8}, {"max_hp": 20}],
	UnitDef.Role.CHARGER: [{"attack": 2}, {"attack": 5}],
	UnitDef.Role.HUNTER: [{"attack": 2}, {"attack": 5}],
	UnitDef.Role.TRICKSTER: [{"speed": 1}, {"speed": 2}],
	UnitDef.Role.SHAMAN: [{"poison_power": 1}, {"poison_power": 2}],
	UnitDef.Role.SUPPORT: [{"team_attack": 1}, {"team_attack": 3}],
}

const ROLE_TEXTS := {
	UnitDef.Role.DEFENDER: ["방어 기물의 체력이 늘어납니다.", "방어 기물의 체력이 크게 늘어납니다."],
	UnitDef.Role.CHARGER: ["돌격 기물의 공격력이 오릅니다.", "돌격 기물의 공격력이 크게 오릅니다."],
	UnitDef.Role.HUNTER: ["사냥꾼의 공격력이 오릅니다.", "사냥꾼의 공격력이 크게 오릅니다."],
	UnitDef.Role.TRICKSTER: ["교란 기물이 더 빠르게 파고듭니다.", "교란 기물이 훨씬 빠르게 파고듭니다."],
	UnitDef.Role.SHAMAN: ["주술 기물의 상태 이상이 오래 갑니다.", "주술 기물의 상태 이상이 훨씬 오래 갑니다."],
	UnitDef.Role.SUPPORT: ["아군 전체의 공격력이 오릅니다.", "아군 전체의 공격력이 크게 오릅니다."],
}


## 화면에 보여줄 시너지 한 줄.
class Active extends RefCounted:
	var axis: Axis
	var key: int
	var label: String
	var count: int
	var tier: int
	var next_required: int
	var description: String

	func is_active() -> bool:
		return tier > 0


## 전투 시작 직전 한 번 호출한다.
static func apply(units: Array[UnitState]) -> void:
	for team in [UnitState.Team.PLAYER, UnitState.Team.ENEMY]:
		var members := members_of(units, team)
		if members.is_empty():
			continue
		for active in evaluate(members):
			if active.is_active():
				_apply_effect(members, active)


## 발동 여부와 관계없이 한 마리라도 있는 시너지를 마리 수 내림차순으로 돌려준다.
static func evaluate(members: Array[UnitState]) -> Array[Active]:
	var actives: Array[Active] = []
	actives.append_array(_evaluate_axis(members, Axis.HABITAT))
	actives.append_array(_evaluate_axis(members, Axis.ROLE))
	actives.sort_custom(func(a: Active, b: Active) -> bool: return a.count > b.count)
	return actives


static func members_of(units: Array[UnitState], team: UnitState.Team) -> Array[UnitState]:
	var members: Array[UnitState] = []
	for unit in units:
		if unit.team == team:
			members.append(unit)
	return members


static func _evaluate_axis(members: Array[UnitState], axis: Axis) -> Array[Active]:
	var counts := {}
	for unit in members:
		var key := _key_of(unit, axis)
		counts[key] = int(counts.get(key, 0)) + 1

	var actives: Array[Active] = []
	for key in counts:
		var active := Active.new()
		active.axis = axis
		active.key = key
		active.count = counts[key]
		active.label = _label_of(key, axis)
		active.tier = tier_for(active.count)
		active.next_required = _next_required(active.count)
		active.description = _text_of(key, axis, active.tier)
		actives.append(active)
	return actives


static func tier_for(count: int) -> int:
	var tier := 0
	for index in range(TIERS.size()):
		if count >= TIERS[index]:
			tier = index + 1
	return tier


static func _next_required(count: int) -> int:
	for threshold in TIERS:
		if count < threshold:
			return threshold - count
	return 0


static func _key_of(unit: UnitState, axis: Axis) -> int:
	return unit.def.habitat if axis == Axis.HABITAT else unit.def.role


static func _label_of(key: int, axis: Axis) -> String:
	if axis == Axis.HABITAT:
		return str(UnitDef.HABITAT_LABELS.get(key, ""))
	return str(UnitDef.ROLE_LABELS.get(key, ""))


static func _text_of(key: int, axis: Axis, tier: int) -> String:
	var texts: Array = ROLE_TEXTS.get(key, []) if axis == Axis.ROLE else HABITAT_TEXTS.get(key, [])
	if texts.is_empty():
		return ""
	return str(texts[clampi(maxi(tier, 1) - 1, 0, texts.size() - 1)])


static func _effects_of(key: int, axis: Axis, tier: int) -> Dictionary:
	var table: Array = ROLE_EFFECTS.get(key, []) if axis == Axis.ROLE else HABITAT_EFFECTS.get(key, [])
	if table.is_empty() or tier <= 0:
		return {}
	return table[clampi(tier - 1, 0, table.size() - 1)]


static func _apply_effect(members: Array[UnitState], active: Active) -> void:
	var effects := _effects_of(active.key, active.axis, active.tier)
	for effect_key in effects:
		var amount := int(effects[effect_key])
		var field := str(effect_key)
		var targets := _matching(members, active)
		if field.begins_with("team_"):
			field = field.trim_prefix("team_")
			targets = members
		for unit in targets:
			_add(unit, field, amount)


static func _matching(members: Array[UnitState], active: Active) -> Array[UnitState]:
	var matched: Array[UnitState] = []
	for unit in members:
		if _key_of(unit, active.axis) == active.key:
			matched.append(unit)
	return matched


static func _add(unit: UnitState, field: String, amount: int) -> void:
	match field:
		"attack":
			unit.attack += amount
		"speed":
			unit.speed += amount
		"max_hp":
			unit.max_hp += amount
			unit.hp += amount
		"regen":
			unit.regen += amount
		"poison_power":
			unit.poison_power += amount
		"chill":
			unit.chill += amount
		_:
			push_error("알 수 없는 시너지 효과: %s" % field)
