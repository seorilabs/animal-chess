## 테스트 케이스가 공유하는 최소 단언 헬퍼.
##
## 케이스는 `run()`을 구현하고 실패를 `failures`에 남긴다.
## `run()`은 코루틴이어도 되며 러너가 `await`으로 호출한다.
class_name TestCase
extends RefCounted

var failures: Array[String] = []


func name() -> String:
	return get_script().resource_path.get_file().get_basename()


func run(_host: Node) -> void:
	push_error("run()을 구현해야 합니다.")


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func check_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		failures.append("%s — 실제 %s, 기대 %s" % [message, str(actual), str(expected)])


func check_range(value: float, low: float, high: float, message: String) -> void:
	if value < low or value > high:
		failures.append("%s — 실제 %s, 허용 %s~%s" % [message, str(value), str(low), str(high)])
