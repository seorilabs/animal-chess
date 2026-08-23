## 전투에서 이긴 뒤 고르는 보상.
##
## 기획서 §7의 보상 화면에 대응한다. 보상형 광고는 같은 목록에서 하나를 더 받는 형태다.
class_name Reward
extends RefCounted

enum Kind { GOLD, HEAL, UNIT }

const CHOICE_COUNT := 3
const GOLD_BASE := 4
const GOLD_PER_ROUND := 1
const HEAL_AMOUNT := 4

var kind: Kind
var amount: int = 0
var unit_id: String = ""
var label: String = ""
var description: String = ""


## 이번 라운드에 고를 수 있는 보상 세 가지를 만든다.
static func roll_choices(run: RunState) -> Array[Reward]:
	var choices: Array[Reward] = []
	choices.append(_gold(run.round_number))
	choices.append(_heal())
	choices.append(_unit(run))
	return choices


static func _gold(round_number: int) -> Reward:
	var reward := Reward.new()
	reward.kind = Kind.GOLD
	reward.amount = GOLD_BASE + GOLD_PER_ROUND * round_number
	reward.label = "골드 +%d" % reward.amount
	reward.description = "다음 준비에서 더 많이 사거나 새로고침할 수 있습니다."
	return reward


static func _heal() -> Reward:
	var reward := Reward.new()
	reward.kind = Kind.HEAL
	reward.amount = HEAL_AMOUNT
	reward.label = "체력 +%d" % reward.amount
	reward.description = "패배를 몇 번 더 버틸 수 있습니다."
	return reward


static func _unit(run: RunState) -> Reward:
	var pool := Shop.pool_for_round(run.catalog, run.round_number)
	var reward := Reward.new()
	reward.kind = Kind.UNIT
	reward.unit_id = pool[run.rng.randi_range(0, pool.size() - 1)]
	var unit_def := run.catalog.get_def(reward.unit_id)
	reward.label = "%s 영입" % unit_def.display_name
	reward.description = "%s / %s — %s" % [
		unit_def.habitat_label(), unit_def.role_label(), unit_def.skill_name
	]
	return reward


## 보상을 실제로 적용한다. 대기석이 가득 차 기물을 받지 못하면 false.
func grant(run: RunState) -> bool:
	match kind:
		Kind.GOLD:
			run.gold += amount
			return true
		Kind.HEAL:
			run.player_hp += amount
			return true
		Kind.UNIT:
			var slot := run.first_empty_bench_slot()
			if slot == -1:
				return false
			run.bench[slot] = UnitState.create(
				run.catalog.get_def(unit_id), UnitState.Team.PLAYER
			)
			run.last_merges = Merge.resolve(run)
			return true
	return false
