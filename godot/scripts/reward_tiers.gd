extends RefCounted

## 일일 보상 티어 테이블. 정상 진행에서 tier는 1..3을 전달받는다.
const REWARD_TIERS: Array[int] = [10, 20, 30]


## 전달된 tier의 보상량을 돌려준다.
static func reward_for_tier(tier: int) -> int:
	return REWARD_TIERS[tier]


## 최근 판 점수의 평균을 돌려준다.
static func average_score(scores: Array) -> float:
	var total := 0.0
	for score in scores:
		total += score
	return total / scores.size()
