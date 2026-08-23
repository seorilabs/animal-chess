## 기물 스킬이 마나가 찼을 때 발동하고 의도한 효과를 내는지 검증한다.
extends TestCase


func run(_host: Node) -> void:
	var catalog := UnitCatalog.load_default()
	_test_every_unit_has_a_skill(catalog)
	_test_mana_fills_and_casts(catalog)
	_test_shield_absorbs_damage(catalog)
	_test_team_buffs(catalog)
	_test_leap_relocates(catalog)


## 스킬이 정의되지 않은 기물이 있으면 cast가 오류를 낸다. 모두 도는지 확인한다.
func _test_every_unit_has_a_skill(catalog: UnitCatalog) -> void:
	for unit_def in catalog.defs():
		check(not unit_def.skill_name.is_empty(), "%s 스킬 이름" % unit_def.id)
		check(not unit_def.skill_text.is_empty(), "%s 스킬 설명" % unit_def.id)

		var sim := _sim(catalog, [unit_def.id], ["turtle", "turtle"])
		var caster := sim.units[0]
		var events: Array[CombatEvent] = []
		Skills.cast(sim, caster, events)
		check(not events.is_empty(), "%s 스킬이 아무 일도 하지 않았습니다" % unit_def.id)
		check_eq(events[0].kind, CombatEvent.Kind.SKILL, "%s 스킬 발동 이벤트" % unit_def.id)


## 공격과 피격으로 마나가 차면 스킬이 나가야 한다.
func _test_mana_fills_and_casts(catalog: UnitCatalog) -> void:
	var sim := _sim(catalog, ["sparrow"], ["turtle"])
	var caster := sim.units[0]
	check_eq(caster.mana, 0, "전투 시작 시 마나는 0")

	var cast_seen := false
	for _tick in range(CombatSim.MAX_TICKS):
		if not sim.is_running():
			break
		for event in sim.tick():
			if event.kind == CombatEvent.Kind.SKILL and event.actor_uid == caster.uid:
				cast_seen = true
		if cast_seen:
			break
	check(cast_seen, "마나가 차면 스킬이 발동해야 합니다")


## 거북의 보호막은 체력보다 먼저 깎여야 한다.
func _test_shield_absorbs_damage(catalog: UnitCatalog) -> void:
	var sim := _sim(catalog, ["turtle"], ["bear"])
	var turtle := sim.units[0]
	var events: Array[CombatEvent] = []
	Skills.cast(sim, turtle, events)
	check_eq(turtle.shield, Skills.SHIELD_AMOUNT, "보호막이 걸려야 합니다")

	var before_hp := turtle.hp
	sim.deal_damage(0, turtle, 5, events)
	check_eq(turtle.hp, before_hp, "보호막이 남았으면 체력이 줄면 안 됩니다")
	check_eq(turtle.shield, Skills.SHIELD_AMOUNT - 5, "보호막이 대신 깎여야 합니다")

	sim.deal_damage(0, turtle, Skills.SHIELD_AMOUNT, events)
	check_eq(turtle.shield, 0, "보호막이 다 깎여야 합니다")
	check(turtle.hp < before_hp, "보호막을 넘긴 피해는 체력에 들어가야 합니다")


## 부엉이와 토끼는 아군 전체를 강화한다.
func _test_team_buffs(catalog: UnitCatalog) -> void:
	var sim := _sim(catalog, ["owl", "bear"], ["turtle"])
	var owl := sim.units[0]
	var bear := sim.units[1]
	var before_attack := bear.attack
	var events: Array[CombatEvent] = []
	Skills.cast(sim, owl, events)
	check_eq(bear.attack, before_attack + Skills.OWL_ATTACK, "부엉이는 아군 공격력을 올려야 합니다")

	var speed_sim := _sim(catalog, ["rabbit", "bear"], ["turtle"])
	var before_speed := speed_sim.units[1].speed
	var speed_events: Array[CombatEvent] = []
	Skills.cast(speed_sim, speed_sim.units[0], speed_events)
	check_eq(
		speed_sim.units[1].speed, before_speed + Skills.RABBIT_SPEED,
		"토끼는 아군 속도를 올려야 합니다"
	)


## 여우와 눈표범은 대상 옆으로 이동해야 한다.
func _test_leap_relocates(catalog: UnitCatalog) -> void:
	var sim := _sim(catalog, ["fox"], ["sparrow", "turtle"])
	var fox := sim.units[0]
	var before := fox.position()
	var events: Array[CombatEvent] = []
	Skills.cast(sim, fox, events)
	check(fox.position() != before, "여우는 목표 옆으로 파고들어야 합니다")

	var target := Skills._weakest(sim.enemies_of(fox))
	check(fox.distance_to(target) <= 1, "여우는 목표 바로 옆에 서야 합니다")


func _sim(catalog: UnitCatalog, player_ids: Array, enemy_ids: Array) -> CombatSim:
	var sim := CombatSim.new()
	sim.setup(
		_team(catalog, player_ids, UnitState.Team.PLAYER, 6),
		_team(catalog, enemy_ids, UnitState.Team.ENEMY, 1),
		RunState.BOARD
	)
	return sim


func _team(catalog: UnitCatalog, ids: Array, team: UnitState.Team, row: int) -> Array[UnitState]:
	var units: Array[UnitState] = []
	for index in range(ids.size()):
		var unit := UnitState.create(catalog.get_def(str(ids[index])), team)
		unit.set_position(Vector2i(index + 1, row))
		units.append(unit)
	return units
