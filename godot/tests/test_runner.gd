## 모든 테스트 케이스를 한 번에 실행하는 러너.
##
## `godot --headless --path godot --scene res://tests/test_runner.tscn`
## 또는 godot-game 스킬의 quality gate `--smoke-scene`으로 실행한다.
## 실패가 하나라도 있으면 exit code 1로 종료한다.
extends Node

const TEST_SCRIPTS: PackedStringArray = [
	"res://tests/combat_test.gd",
	"res://tests/run_state_test.gd",
	"res://tests/smoke_test.gd",
]


func _ready() -> void:
	var total_failures: Array[String] = []
	var passed := 0

	for path in TEST_SCRIPTS:
		var script: GDScript = load(path)
		if script == null:
			total_failures.append("%s — 스크립트를 불러오지 못했습니다." % path)
			continue
		var test_case: TestCase = script.new()
		await test_case.run(self)
		if test_case.failures.is_empty():
			passed += 1
			print("[PASS] %s" % test_case.name())
		else:
			for failure in test_case.failures:
				total_failures.append("%s: %s" % [test_case.name(), failure])
			print("[FAIL] %s (%d건)" % [test_case.name(), test_case.failures.size()])

	print("테스트 %d개 중 %d개 통과." % [TEST_SCRIPTS.size(), passed])
	if total_failures.is_empty():
		get_tree().quit(0)
		return

	for failure in total_failures:
		push_error(failure)
	get_tree().quit(1)
