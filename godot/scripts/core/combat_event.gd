## 전투 시뮬레이션이 표현 계층에 넘기는 사건 한 건.
##
## CombatSim은 UI를 모르고 이 이벤트만 뱉는다. BoardView가 트윈/파티클로,
## AudioService가 효과음으로 재생하고, 테스트는 같은 스트림을 그대로 검증한다.
class_name CombatEvent
extends RefCounted

enum Kind {
	MOVE,      ## actor가 from에서 to로 한 칸 이동
	ATTACK,    ## actor가 target을 향해 공격 모션을 시작
	DAMAGE,    ## target이 amount만큼 피해를 입음
	POISON,    ## target에게 독이 걸림 (amount = 남은 틱)
	SLOW,      ## target의 행동이 늦춰짐
	HEAL,      ## target이 amount만큼 회복
	DEATH,     ## target이 쓰러짐
}

var kind: Kind
var actor_uid: int = 0
var target_uid: int = 0
var from: Vector2i = Vector2i.ZERO
var to: Vector2i = Vector2i.ZERO
var amount: int = 0


static func move(actor: UnitState, from_pos: Vector2i, to_pos: Vector2i) -> CombatEvent:
	var event := CombatEvent.new()
	event.kind = Kind.MOVE
	event.actor_uid = actor.uid
	event.from = from_pos
	event.to = to_pos
	return event


static func attack(actor: UnitState, target: UnitState) -> CombatEvent:
	var event := CombatEvent.new()
	event.kind = Kind.ATTACK
	event.actor_uid = actor.uid
	event.target_uid = target.uid
	event.from = actor.position()
	event.to = target.position()
	return event


static func damage(actor_uid_value: int, target: UnitState, amount_value: int) -> CombatEvent:
	var event := CombatEvent.new()
	event.kind = Kind.DAMAGE
	event.actor_uid = actor_uid_value
	event.target_uid = target.uid
	event.to = target.position()
	event.amount = amount_value
	return event


static func heal(target: UnitState, amount_value: int) -> CombatEvent:
	var event := CombatEvent.new()
	event.kind = Kind.HEAL
	event.target_uid = target.uid
	event.to = target.position()
	event.amount = amount_value
	return event


static func status(kind_value: Kind, target: UnitState, amount_value: int) -> CombatEvent:
	var event := CombatEvent.new()
	event.kind = kind_value
	event.target_uid = target.uid
	event.to = target.position()
	event.amount = amount_value
	return event


static func death(target: UnitState) -> CombatEvent:
	var event := CombatEvent.new()
	event.kind = Kind.DEATH
	event.target_uid = target.uid
	event.to = target.position()
	return event
