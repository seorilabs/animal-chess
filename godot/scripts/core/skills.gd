## 기물별 스킬. 마나가 차면 CombatSim이 여기로 넘긴다.
##
## 각 기물은 전투에서 하나의 뚜렷한 역할만 갖는다(기획서 §21).
## 강화 효과는 그 전투가 끝날 때까지 유지된다.
class_name Skills
extends RefCounted

const SHIELD_AMOUNT := 18
const RABBIT_SPEED := 1
const SPARROW_HITS := 3
const SPARROW_DAMAGE_SCALE := 0.7
const FROG_POISON_TICKS := 5
const FROG_SPLASH_RADIUS := 1
const FOX_DAMAGE_SCALE := 2.0
const WOLF_DAMAGE_SCALE := 1.8
const WOLF_PACK_ATTACK := 2
const PENGUIN_SLOW := 3
const PENGUIN_RADIUS := 1
const OWL_ATTACK := 2
const BEAR_RADIUS := 1
const BEAR_DAMAGE_SCALE := 1.2
const LEOPARD_RADIUS := 1
const LEOPARD_DAMAGE_SCALE := 1.5


static func cast(sim: CombatSim, caster: UnitState, events: Array[CombatEvent]) -> void:
	events.append(CombatEvent.skill(caster))
	match caster.def.id:
		"turtle":
			_shell_guard(caster, events)
		"rabbit":
			_carrot_cheer(sim, caster, events)
		"sparrow":
			_quick_peck(sim, caster, events)
		"frog":
			_poison_bubble(sim, caster, events)
		"fox":
			_ambush(sim, caster, events)
		"wolf":
			_pack_bite(sim, caster, events)
		"penguin":
			_ice_patch(sim, caster, events)
		"owl":
			_night_command(sim, caster, events)
		"bear":
			_paw_sweep(sim, caster, events)
		"snow_leopard":
			_blizzard_leap(sim, caster, events)
		_:
			push_error("스킬이 정의되지 않은 기물: %s" % caster.def.id)


## 거북 — 자신에게 보호막을 두른다.
static func _shell_guard(caster: UnitState, events: Array[CombatEvent]) -> void:
	caster.shield += SHIELD_AMOUNT
	events.append(CombatEvent.status(CombatEvent.Kind.SHIELD, caster, SHIELD_AMOUNT))


## 토끼 — 아군 전체의 행동 속도를 올린다.
static func _carrot_cheer(sim: CombatSim, caster: UnitState, events: Array[CombatEvent]) -> void:
	for ally in sim.allies_of(caster):
		ally.speed += RABBIT_SPEED
		events.append(CombatEvent.status(CombatEvent.Kind.BUFF, ally, RABBIT_SPEED))


## 참새 — 가장 가까운 적을 연달아 쫀다.
static func _quick_peck(sim: CombatSim, caster: UnitState, events: Array[CombatEvent]) -> void:
	var target := _nearest(sim.enemies_of(caster), caster)
	if target == null:
		return
	var damage := maxi(1, int(round(caster.attack * SPARROW_DAMAGE_SCALE)))
	for _hit in range(SPARROW_HITS):
		if not target.is_alive():
			break
		events.append(CombatEvent.attack(caster, target))
		sim.deal_damage(caster.uid, target, damage, events)


## 개구리 — 대상과 주변 적을 중독시킨다.
static func _poison_bubble(sim: CombatSim, caster: UnitState, events: Array[CombatEvent]) -> void:
	var target := _nearest(sim.enemies_of(caster), caster)
	if target == null:
		return
	var ticks := FROG_POISON_TICKS + caster.poison_power
	for enemy in sim.enemies_of(caster):
		if target.distance_to(enemy) > FROG_SPLASH_RADIUS:
			continue
		enemy.poison = maxi(enemy.poison, ticks)
		events.append(CombatEvent.status(CombatEvent.Kind.POISON, enemy, enemy.poison))


## 여우 — 체력이 가장 적은 적 옆으로 파고들어 강타한다.
static func _ambush(sim: CombatSim, caster: UnitState, events: Array[CombatEvent]) -> void:
	var enemies := sim.enemies_of(caster)
	var target := _weakest(enemies)
	if target == null:
		return
	_leap_next_to(sim, caster, target, events)
	sim.deal_damage(
		caster.uid, target, maxi(1, int(round(caster.attack * FOX_DAMAGE_SCALE))), events
	)


## 늑대 — 크게 물어뜯고 아군 돌격 기물을 강화한다.
static func _pack_bite(sim: CombatSim, caster: UnitState, events: Array[CombatEvent]) -> void:
	var target := _nearest(sim.enemies_of(caster), caster)
	if target == null:
		return
	events.append(CombatEvent.attack(caster, target))
	sim.deal_damage(
		caster.uid, target, maxi(1, int(round(caster.attack * WOLF_DAMAGE_SCALE))), events
	)
	for ally in sim.allies_of(caster):
		if ally.def.role != UnitDef.Role.CHARGER:
			continue
		ally.attack += WOLF_PACK_ATTACK
		events.append(CombatEvent.status(CombatEvent.Kind.BUFF, ally, WOLF_PACK_ATTACK))


## 펭귄 — 주변 적의 행동을 크게 늦춘다.
static func _ice_patch(sim: CombatSim, caster: UnitState, events: Array[CombatEvent]) -> void:
	for enemy in sim.enemies_of(caster):
		if caster.distance_to(enemy) > PENGUIN_RADIUS + caster.attack_range:
			continue
		enemy.cooldown += PENGUIN_SLOW
		events.append(CombatEvent.status(CombatEvent.Kind.SLOW, enemy, PENGUIN_SLOW))


## 부엉이 — 아군 전체의 공격력을 올린다.
static func _night_command(sim: CombatSim, caster: UnitState, events: Array[CombatEvent]) -> void:
	for ally in sim.allies_of(caster):
		ally.attack += OWL_ATTACK
		events.append(CombatEvent.status(CombatEvent.Kind.BUFF, ally, OWL_ATTACK))


## 곰 — 주변 적을 한꺼번에 때리고 한 칸 밀어낸다.
static func _paw_sweep(sim: CombatSim, caster: UnitState, events: Array[CombatEvent]) -> void:
	var damage := maxi(1, int(round(caster.attack * BEAR_DAMAGE_SCALE)))
	for enemy in sim.enemies_of(caster):
		if caster.distance_to(enemy) > BEAR_RADIUS + caster.attack_range:
			continue
		events.append(CombatEvent.attack(caster, enemy))
		sim.deal_damage(caster.uid, enemy, damage, events)
		_knock_back(sim, caster, enemy, events)


## 눈표범 — 적 후열로 뛰어들어 착지 지점 주변을 휩쓴다.
static func _blizzard_leap(sim: CombatSim, caster: UnitState, events: Array[CombatEvent]) -> void:
	var enemies := sim.enemies_of(caster)
	var target := _farthest(enemies, caster)
	if target == null:
		return
	_leap_next_to(sim, caster, target, events)
	var damage := maxi(1, int(round(caster.attack * LEOPARD_DAMAGE_SCALE)))
	for enemy in enemies:
		if caster.distance_to(enemy) <= LEOPARD_RADIUS:
			sim.deal_damage(caster.uid, enemy, damage, events)


# --- 공통 도우미 --------------------------------------------------------

static func _nearest(candidates: Array[UnitState], from_unit: UnitState) -> UnitState:
	var best: UnitState = null
	for candidate in candidates:
		if best == null or from_unit.distance_to(candidate) < from_unit.distance_to(best):
			best = candidate
	return best


static func _farthest(candidates: Array[UnitState], from_unit: UnitState) -> UnitState:
	var best: UnitState = null
	for candidate in candidates:
		if best == null or from_unit.distance_to(candidate) > from_unit.distance_to(best):
			best = candidate
	return best


static func _weakest(candidates: Array[UnitState]) -> UnitState:
	var best: UnitState = null
	for candidate in candidates:
		if best == null or candidate.hp < best.hp:
			best = candidate
	return best


## 대상 바로 옆 빈 칸으로 이동한다. 빈 칸이 없으면 제자리에 남는다.
static func _leap_next_to(
	sim: CombatSim, caster: UnitState, target: UnitState, events: Array[CombatEvent]
) -> void:
	for offset: Vector2i in [Vector2i.DOWN, Vector2i.UP, Vector2i.LEFT, Vector2i.RIGHT]:
		var landing := target.position() + offset
		if not sim.is_free(landing):
			continue
		var from_position := caster.position()
		caster.set_position(landing)
		events.append(CombatEvent.move(caster, from_position, landing))
		return


## 공격자에게서 멀어지는 방향으로 한 칸 밀어낸다.
static func _knock_back(
	sim: CombatSim, attacker: UnitState, target: UnitState, events: Array[CombatEvent]
) -> void:
	if not target.is_alive():
		return
	var delta := target.position() - attacker.position()
	var push := Vector2i(signi(delta.x), signi(delta.y))
	if push == Vector2i.ZERO:
		return
	var landing := target.position() + push
	if not sim.is_free(landing):
		return
	var from_position := target.position()
	target.set_position(landing)
	events.append(CombatEvent.move(target, from_position, landing))
