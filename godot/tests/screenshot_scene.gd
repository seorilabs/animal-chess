## 실행 화면을 설계 해상도 그대로 PNG로 저장하는 시각 QA 도구.
##
## 데스크톱 창은 모니터 높이에 잘리므로 SubViewport에 오프스크린 렌더링한다.
## 렌더링 컨텍스트가 필요해 headless로는 동작하지 않는다.
##   godot --path godot --scene res://tests/screenshot_scene.tscn -- --shot prep
## `--shot <이름>`으로 저장 파일명을 지정하고, 없으면 `screen`을 쓴다.
extends Node

const OUTPUT_DIR := "user://shots"
const WARMUP_FRAMES := 30


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
	var args := OS.get_cmdline_user_args()
	var index := args.find("--shot")
	if index >= 0 and index + 1 < args.size():
		return args[index + 1]
	return "screen"
