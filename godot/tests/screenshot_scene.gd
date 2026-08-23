## 실행 화면을 설계 해상도 그대로 PNG로 저장하는 시각 QA 도구.
##
## 데스크톱 창은 모니터 높이에 잘리므로 SubViewport에 오프스크린 렌더링한다.
## 렌더링 컨텍스트가 필요해 headless로는 동작하지 않는다.
##   godot --path godot --scene res://tests/screenshot_scene.tscn -- --shot prep
## `--shot <이름>`으로 저장 파일명을 지정하고, 없으면 `screen`을 쓴다.
extends Node

const OUTPUT_DIR := "user://shots"
const WARMUP_FRAMES := 30
## `--scenario combat`에서 전투를 미리 굴리는 틱 수.
const COMBAT_PREVIEW_TICKS := 12


func _ready() -> void:
	var design_size := Vector2i(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height")
	)

	var viewport := SubViewport.new()
	viewport.size = design_size
	viewport.transparent_bg = false
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)

	var main: Control = load("res://scenes/main.tscn").instantiate()
	viewport.add_child(main)

	for _i in range(WARMUP_FRAMES):
		await get_tree().process_frame
	_apply_scenario(main)
	for _i in range(WARMUP_FRAMES):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw

	DirAccess.make_dir_recursive_absolute(OUTPUT_DIR)
	var path := "%s/%s.png" % [OUTPUT_DIR, _shot_name()]
	var error := viewport.get_texture().get_image().save_png(path)
	if error != OK:
		push_error("스크린샷 저장 실패: %s (오류 %d)" % [path, error])
		get_tree().quit(1)
		return

	print("스크린샷 저장: %s" % ProjectSettings.globalize_path(path))
	get_tree().quit(0)


func _shot_name() -> String:
	return _arg("--shot", "screen")


## 장면별 상태를 만든다. combat / preview / wrapup / prep(기본).
func _apply_scenario(main: Control) -> void:
	var scenario := _arg("--scenario", "prep")
	if scenario == "prep":
		return

	main.run.round_number = 4
	main.run.prepare_round()
	_place_sample_board(main)
	main._refresh_all()

	match scenario:
		"preview":
			main._on_preview()
		"combat":
			main._start_combat()
			for _i in range(COMBAT_PREVIEW_TICKS):
				main._on_combat_tick()
		"wrapup":
			main._start_combat()
			while main.sim.is_running():
				main._on_combat_tick()


func _place_sample_board(main: Control) -> void:
	var placements := {
		Vector2i(2, 4): "turtle",
		Vector2i(3, 4): "bear",
		Vector2i(4, 4): "wolf",
		Vector2i(3, 5): "sparrow",
		Vector2i(4, 5): "frog",
	}
	for cell: Vector2i in placements:
		var unit := UnitState.create(main.catalog.get_def(placements[cell]), UnitState.Team.PLAYER)
		unit.set_position(cell)
		main.run.board[cell] = unit


func _arg(key: String, fallback: String) -> String:
	var args := OS.get_cmdline_user_args()
	var index := args.find(key)
	if index >= 0 and index + 1 < args.size():
		return args[index + 1]
	return fallback
