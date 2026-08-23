## 서식지 + 역할 2축 시너지의 집계와 효과 적용을 검증한다.
extends TestCase


func run(_host: Node) -> void:
	var catalog := UnitCatalog.load_default()
	_test_tiers()
	_test_evaluate(catalog)
	_test_habitat_effect(catalog)
	_test_team_wide_effect(catalog)
	_test_enemy_is_separate(catalog)


func _test_tiers() -> void:
	check_eq(Synergy.tier_for(1), 0, "1마리는 발동하지 않아야 합니다")
	check_eq(Synergy.tier_for(2), 1, "2마리는 1티어")
	check_eq(Synergy.tier_for(3), 1, "3마리도 1티어")
	check_eq(Synergy.tier_for(4), 2, "4마리는 2티어")
	check_eq(Synergy.tier_for(9), 2, "그 이상도 2티어")


func _test_evaluate(catalog: UnitCatalog) -> void:
	# 참새(하늘/사냥꾼) 2 + 곰(숲/돌격) 1
	var members := _team(catalog, ["sparrow", "sparrow", "bear"])
	var found := {}
	for active in Synergy.evaluate(members):
		found["%d:%s" % [active.axis, active.label]] = active

	var sky: Synergy.Active = found["%d:하늘" % Synergy.Axis.HABITAT]
	check_eq(sky.count, 2, "하늘 기물 수")
	check_eq(sky.tier, 1, "하늘 2마리는 발동해야 합니다")
	check_eq(sky.next_required, 2, "다음 단계까지 남은 수")

	var forest: Synergy.Active = found["%d:숲" % Synergy.Axis.HABITAT]
	check_eq(forest.count, 1, "숲 기물 수")
	check_eq(forest.tier, 0, "숲 1마리는 발동하지 않아야 합니다")

	var hunter: Synergy.Active = found["%d:사냥꾼" % Synergy.Axis.ROLE]
	check_eq(hunter.count, 2, "사냥꾼 수")
	check_eq(hunter.tier, 1, "사냥꾼 2마리는 발동해야 합니다")


## 하늘 2마리는 하늘 기물에게만 공격력을 준다.
func _test_habitat_effect(catalog: UnitCatalog) -> void:
	var members := _team(catalog, ["sparrow", "owl", "turtle"])
	var base_sparrow := catalog.get_def("sparrow").attack
	var base_turtle := catalog.get_def("turtle").attack
	Synergy.apply(members)

	var sky_bonus := int(Synergy.HABITAT_EFFECTS[UnitDef.Habitat.SKY][0]["attack"])
	check_eq(members[0].attack, base_sparrow + sky_bonus, "참새는 하늘 시너지를 받아야 합니다")
	check_eq(members[2].attack, base_turtle, "거북은 하늘 시너지를 받지 않아야 합니다")


## 지원 시너지는 팀 전체에 적용된다.
func _test_team_wide_effect(catalog: UnitCatalog) -> void:
	var members := _team(catalog, ["rabbit", "owl", "bear"])
	var base_bear := catalog.get_def("bear").attack
	Synergy.apply(members)

	var support_bonus := int(Synergy.ROLE_EFFECTS[UnitDef.Role.SUPPORT][0]["team_attack"])
	check_eq(members[2].attack, base_bear + support_bonus, "지원 시너지는 곰에게도 적용되어야 합니다")


## 상대 팀 조합이 아군 시너지에 섞이면 안 된다.
func _test_enemy_is_separate(catalog: UnitCatalog) -> void:
	var units: Array[UnitState] = []
	units.append(UnitState.create(catalog.get_def("sparrow"), UnitState.Team.PLAYER))
	units.append(UnitState.create(catalog.get_def("owl"), UnitState.Team.ENEMY))
	var base_attack := catalog.get_def("sparrow").attack
	Synergy.apply(units)
	check_eq(units[0].attack, base_attack, "적의 하늘 기물이 아군 시너지를 채우면 안 됩니다")


func _team(catalog: UnitCatalog, ids: Array) -> Array[UnitState]:
	var members: Array[UnitState] = []
	for id in ids:
		members.append(UnitState.create(catalog.get_def(str(id)), UnitState.Team.PLAYER))
	return members
