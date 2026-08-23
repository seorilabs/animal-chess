## 런을 넘어 남는 기록. 해금한 기물과 최고 성적.
class_name Profile
extends RefCounted

var unlocked: PackedStringArray = PackedStringArray()
var best_round: int = 0
var runs_played: int = 0
var runs_won: int = 0


## 처음 해금됐으면 true.
func unlock(id: String) -> bool:
	if id in unlocked:
		return false
	unlocked.append(id)
	return true


func is_unlocked(id: String) -> bool:
	return id in unlocked


func record_round(round_number: int) -> void:
	best_round = maxi(best_round, round_number)


func record_run_end(victory: bool) -> void:
	runs_played += 1
	if victory:
		runs_won += 1


func to_dict() -> Dictionary:
	return {
		"unlocked": Array(unlocked),
		"best_round": best_round,
		"runs_played": runs_played,
		"runs_won": runs_won,
	}


static func from_dict(data: Dictionary) -> Profile:
	var profile := Profile.new()
	for id in data.get("unlocked", []):
		profile.unlock(str(id))
	profile.best_round = int(data.get("best_round", 0))
	profile.runs_played = int(data.get("runs_played", 0))
	profile.runs_won = int(data.get("runs_won", 0))
	return profile
