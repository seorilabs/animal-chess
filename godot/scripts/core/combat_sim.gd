## 자동 전투 시뮬레이션. UI를 전혀 참조하지 않는다.
##
## 틱마다 CombatEvent 배열을 돌려주고, 표현 계층이 그것을 애니메이션으로 재생한다.
## RNG를 쓰지 않으므로 같은 배치는 항상 같은 결과가 나온다.
class_name CombatSim
extends RefCounted

enum Result { ONGOING, PLAYER_WIN, ENEMY_WIN, DRAW }

## 이 틱 수를 넘기면 남은 체력 비율로 판정한다.
const MAX_TICKS := 150
## 타임아웃 판정에서 승패를 가르는 최소 체력 비율 차이. 그 이하는 무승부.
const TIMEOUT_MARGIN := 0.05

const POISON_DAMAGE := 1
const BEAR_SPLASH_RADIUS := 1
## 개구리 독의 기본 지속 틱. 시너지의 poison_power가 여기에 더해진다.
const POISON_BASE_TICKS := 3
## 숲 시너지 회복이 발동하는 주기(틱).
const REGEN_INTERVAL := 5
## 공격 한 번, 피해 한 번에 쌓이는 마나.
const MANA_PER_ATTACK := 2
const MANA_PER_HIT := 1
## 스킬을 쓴 뒤 쉬는 틱.
const SKILL_COOLDOWN := 3

var units: Array[UnitState] = []
var tick_count: int = 0
var board_size: Vector2i = Vector2i(8, 8)

var _result: Result = Result.ONGOING
var _death_reported: Dictionary = {}


func setup(player_units: Array[UnitState], enemy_units: Array[UnitState], board: Vector2i) -> void:
	board_size = board
	tick_count = 0
	_result = Result.ONGOING
	_death_reported.clear()
	units.clear()
	for unit in player_units:
		var player_copy := unit.clone_for_battle()
		player_copy.team = UnitState.Team.PLAYER
		units.append(player_copy)
	for unit in enemy_units:
		var enemy_copy := unit.clone_for_battle()
		enemy_copy.team = UnitState.Team.ENEMY
		units.append(enemy_copy)
	Synergy.apply(units)


func is_running() -> bool:
	return _result == Result.ONGOING


func result() -> Result:
	return _result


func tick() -> Array[CombatEvent]:
	var events: Array[CombatEvent] = []
	if not is_running():
		return events

	tick_count += 1
	_tick_poison(events)
	_tick_regen(events)

	for unit in units:
		if not unit.is_alive():
			continue
		if unit.cooldown > 0:
			unit.cooldown -= 1
			continue
		var target := _choose_target(unit)
		if target == null:
			continue
		if unit.is_skill_ready():
			Skills.cast(self, unit, events)
			unit.mana = 0
			unit.cooldown = SKILL_COOLDOWN
			continue
		if unit.distance_to(target) <= unit.attack_range:
			_attack(unit, target, events)
			unit.cooldown = maxi(2, 6 - unit.speed)
		elif _step_toward(unit, target, events):
			unit.cooldown = maxi(1, 4 - int(unit.speed / 2.0))

	_report_deaths(events)
	_update_result()
	return events


func alive_count(team: UnitState.Team) -> int:
	var count := 0
	for unit in units:
		if unit.team == team and unit.is_alive():
			count += 1
	return count


func unit_by_uid(uid: int) -> UnitState:
	for unit in units:
		if unit.uid == uid:
			return unit
	return null


func hp_ratio(team: UnitState.Team) -> float:
	var remaining := 0
	var total := 0
	for unit in units:
		if unit.team != team:
			continue
		remaining += maxi(0, unit.hp)
		total += unit.max_hp
	if total <= 0:
		return 0.0
	return float(remaining) / float(total)


func _tick_poison(events: Array[CombatEvent]) -> void:
	for unit in units:
		if not unit.is_alive() or unit.poison <= 0:
			continue
		unit.poison -= 1
		deal_damage(0, unit, POISON_DAMAGE, events)


func _tick_regen(events: Array[CombatEvent]) -> void:
	if tick_count % REGEN_INTERVAL != 0:
		return
	for unit in units:
		if not unit.is_alive() or unit.regen <= 0 or unit.hp >= unit.max_hp:
			continue
		var healed := mini(unit.regen, unit.max_hp - unit.hp)
		unit.hp += healed
		events.append(CombatEvent.heal(unit, healed))


func _choose_target(unit: UnitState) -> UnitState:
	var best: UnitState = null
	var best_score := 0
	for candidate in units:
		if not candidate.is_alive() or candidate.team == unit.team:
			continue
		# 여우는 거리보다 마무리를 우선해 체력이 낮은 적을 노린다.
		var score := unit.distance_to(candidate) * 10 + candidate.hp
		if unit.def.id == "fox":
			score = candidate.hp * 3 + unit.distance_to(candidate)
		if best == null or score < best_score:
			best_score = score
			best = candidate
	return best


func _attack(attacker: UnitState, target: UnitState, events: Array[CombatEvent]) -> void:
	events.append(CombatEvent.attack(attacker, target))
	attacker.gain_mana(MANA_PER_ATTACK)
	deal_damage(attacker.uid, target, attacker.attack, events)

	# 극지 시너지는 기물 종류와 무관하게 공격에 감속을 얹는다.
	if attacker.chill > 0 and target.is_alive():
		target.cooldown += attacker.chill
		events.append(CombatEvent.status(CombatEvent.Kind.SLOW, target, attacker.chill))

	match attacker.def.id:
		"frog":
			target.poison = maxi(target.poison, POISON_BASE_TICKS + attacker.poison_power)
			events.append(CombatEvent.status(CombatEvent.Kind.POISON, target, target.poison))
		"penguin":
			target.cooldown += 1
			events.append(CombatEvent.status(CombatEvent.Kind.SLOW, target, 1))
		"bear":
			var splash := maxi(1, int(attacker.attack / 2.0))
			for other in units:
				if not other.is_alive() or other.team == attacker.team or other == target:
					continue
				if target.distance_to(other) <= BEAR_SPLASH_RADIUS:
					deal_damage(attacker.uid, other, splash, events)


## 보호막을 먼저 깎고 남은 만큼 체력을 줄인다. 맞은 쪽은 마나를 얻는다.
func deal_damage(source_uid: int, target: UnitState, amount: int, events: Array[CombatEvent]) -> void:
	if not target.is_alive() or amount <= 0:
		return
	var absorbed := mini(target.shield, amount)
	target.shield -= absorbed
	var taken := amount - absorbed
	target.hp = maxi(0, target.hp - taken)
	events.append(CombatEvent.damage(source_uid, target, amount))
	target.gain_mana(MANA_PER_HIT)


## 팀 기준 살아있는 적 목록.
func enemies_of(unit: UnitState) -> Array[UnitState]:
	var result: Array[UnitState] = []
	for other in units:
		if other.is_alive() and other.team != unit.team:
			result.append(other)
	return result


## 자신을 뺀 살아있는 아군 목록.
func allies_of(unit: UnitState, include_self: bool = true) -> Array[UnitState]:
	var result: Array[UnitState] = []
	for other in units:
		if not other.is_alive() or other.team != unit.team:
			continue
		if other == unit and not include_self:
			continue
		result.append(other)
	return result


func _step_toward(unit: UnitState, target: UnitState, events: Array[CombatEvent]) -> bool:
	var delta := target.position() - unit.position()
	var step_x := Vector2i(unit.x + signi(delta.x), unit.y)
	var step_y := Vector2i(unit.x, unit.y + signi(delta.y))
	# 더 많이 벌어진 축을 먼저 좁힌다.
	var options: Array[Vector2i] = [step_x, step_y]
	if absi(delta.x) < absi(delta.y):
		options = [step_y, step_x]

	for option in options:
		if not is_free(option):
			continue
		var from_pos := unit.position()
		unit.set_position(option)
		events.append(CombatEvent.move(unit, from_pos, option))
		return true
	return false


func is_free(pos: Vector2i) -> bool:
	if pos.x < 0 or pos.x >= board_size.x or pos.y < 0 or pos.y >= board_size.y:
		return false
	for unit in units:
		if unit.is_alive() and unit.position() == pos:
			return false
	return true


func _report_deaths(events: Array[CombatEvent]) -> void:
	for unit in units:
		if unit.is_alive() or _death_reported.has(unit.uid):
			continue
		_death_reported[unit.uid] = true
		events.append(CombatEvent.death(unit))


func _update_result() -> void:
	var player_alive := alive_count(UnitState.Team.PLAYER)
	var enemy_alive := alive_count(UnitState.Team.ENEMY)

	if player_alive == 0 and enemy_alive == 0:
		_result = Result.DRAW
		return
	if enemy_alive == 0:
		_result = Result.PLAYER_WIN
		return
	if player_alive == 0:
		_result = Result.ENEMY_WIN
		return
	if tick_count < MAX_TICKS:
		return

	# 시간 초과. 남은 체력 비율이 확실히 높은 쪽이 이긴다.
	var difference := hp_ratio(UnitState.Team.PLAYER) - hp_ratio(UnitState.Team.ENEMY)
	if difference > TIMEOUT_MARGIN:
		_result = Result.PLAYER_WIN
	elif difference < -TIMEOUT_MARGIN:
		_result = Result.ENEMY_WIN
	else:
		_result = Result.DRAW
