## 런 또는 전투 중에 실제로 변하는 기물 한 마리의 상태.
##
## 설계 기준값은 `def`가 들고, 여기에는 성장/버프/전투 중 변동값만 담는다.
class_name UnitState
extends RefCounted

enum Team { PLAYER, ENEMY }

## 별 1성당 공격력 배수. 합성 구현 전까지도 데미지 계산이 별을 반영한다.
const STAR_ATTACK_STEP := 0.6
const STAR_HP_STEP := 0.8

static var _next_uid := 1

var uid: int
var def: UnitDef
var team: Team = Team.PLAYER
var star: int = 1

var max_hp: int
var hp: int
var attack: int
var attack_range: int
var speed: int

var cooldown: int = 0
var poison: int = 0
var mana: int = 0
var max_mana: int = 10
## 피해를 먼저 흡수하는 보호막.
var shield: int = 0
## 시너지로 붙는 전투 보정값.
var regen: int = 0
var poison_power: int = 0
var chill: int = 0
var x: int = 0
var y: int = 0


static func create(unit_def: UnitDef, team_value: Team, star_value: int = 1) -> UnitState:
	var unit := UnitState.new()
	unit.uid = _next_uid
	_next_uid += 1
	unit.def = unit_def
	unit.team = team_value
	unit.star = star_value
	unit.reset_stats()
	return unit


## 테스트가 uid 시퀀스를 재현할 수 있도록 되돌린다.
static func reset_uid_sequence() -> void:
	_next_uid = 1


## 별 등급을 반영한 기준 스탯으로 되돌린다. 전투 전 버프는 이 위에 얹는다.
func reset_stats() -> void:
	var star_bonus := star - 1
	max_hp = int(round(def.max_hp * (1.0 + STAR_HP_STEP * star_bonus)))
	attack = int(round(def.attack * (1.0 + STAR_ATTACK_STEP * star_bonus)))
	attack_range = def.attack_range
	speed = def.speed
	max_mana = def.max_mana
	hp = max_hp
	cooldown = 0
	poison = 0
	mana = 0
	shield = 0
	regen = 0
	poison_power = 0
	chill = 0


## 전투 사본. 원본 보드 상태를 건드리지 않고 시뮬레이션하기 위해 쓴다.
func clone_for_battle() -> UnitState:
	var copy := UnitState.new()
	copy.uid = uid
	copy.def = def
	copy.team = team
	copy.star = star
	copy.reset_stats()
	copy.x = x
	copy.y = y
	return copy


func is_alive() -> bool:
	return hp > 0


func is_skill_ready() -> bool:
	return mana >= max_mana


## 마나를 쌓고 스킬이 준비됐는지 알려준다.
func gain_mana(amount: int) -> bool:
	if not is_alive():
		return false
	mana = mini(max_mana, mana + amount)
	return is_skill_ready()


func position() -> Vector2i:
	return Vector2i(x, y)


func set_position(value: Vector2i) -> void:
	x = value.x
	y = value.y


func distance_to(other: UnitState) -> int:
	return absi(x - other.x) + absi(y - other.y)
