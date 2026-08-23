class_name UnitPiece
extends Control

var unit_data: Dictionary = {}
var selected: bool = false
var draw_offset_px: Vector2 = Vector2.ZERO

func set_unit(value: Dictionary) -> void:
	unit_data = value
	queue_redraw()


func set_selected(value: bool) -> void:
	selected = value
	queue_redraw()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(48, 48)


func _process(_delta: float) -> void:
	if _animation_progress() < 1.0:
		queue_redraw()


func _draw() -> void:
	if unit_data.is_empty():
		return

	draw_offset_px = _current_draw_offset()

	var id := str(unit_data.get("id", "turtle"))
	var team := str(unit_data.get("team", "player"))
	var max_hp: int = int(unit_data.get("max_hp", unit_data.get("hp", 1)))
	if max_hp < 1:
		max_hp = 1
	var hp: int = int(unit_data.get("hp", max_hp))
	if hp < 0:
		hp = 0
	if hp > max_hp:
		hp = max_hp
	var star := int(unit_data.get("star", 1))

	_draw_shadow()
	_draw_team_ring(team)
	_draw_animal(id)
	_draw_attack_effect(id)
	_draw_hp_bar(hp, max_hp)
	_draw_stars(star)
	_draw_hit_flash()

	if selected:
		draw_rect(Rect2(Vector2.ZERO, size), Color8(255, 234, 130), false, 3.0)


func _scale() -> float:
	return min(size.x, size.y) / 48.0


func _origin() -> Vector2:
	var s := _scale()
	return (size - Vector2(48, 48) * s) * 0.5


func _px(x: int, y: int, w: int, h: int, color: Color) -> void:
	var s := _scale()
	draw_rect(Rect2(_origin() + (Vector2(x, y) + draw_offset_px) * s, Vector2(w, h) * s), color)


func _animation_progress() -> float:
	var start_ms := int(unit_data.get("anim_start_ms", 0))
	var duration_ms := int(unit_data.get("anim_duration_ms", 1))
	if start_ms <= 0:
		return 1.0
	if duration_ms < 1:
		duration_ms = 1
	var elapsed_ms := Time.get_ticks_msec() - start_ms
	var progress := float(elapsed_ms) / float(duration_ms)
	if progress < 0.0:
		return 0.0
	if progress > 1.0:
		return 1.0
	return progress


func _current_draw_offset() -> Vector2:
	var kind := str(unit_data.get("anim_kind", ""))
	var progress := _animation_progress()
	if progress >= 1.0:
		return Vector2.ZERO

	var dx := float(int(unit_data.get("anim_dx", 0)))
	var dy := float(int(unit_data.get("anim_dy", 0)))
	var direction := Vector2(dx, dy)
	if direction.length_squared() == 0.0:
		direction = Vector2(1, 0)
	else:
		direction = direction.normalized()

	match kind:
		"attack":
			var lunge := sin(progress * PI) * 5.0
			return direction * lunge
		"hit":
			var shake := sin(progress * PI * 8.0) * 2.4 * (1.0 - progress)
			return Vector2(shake, 0.0)
		"step":
			return -direction * 8.0 * (1.0 - progress)
		_:
			return Vector2.ZERO


func _effect_color(id: String) -> Color:
	match id:
		"frog":
			return Color8(163, 85, 207)
		"penguin":
			return Color8(124, 214, 232)
		"sparrow":
			return Color8(239, 184, 92)
		"bear":
			return Color8(245, 214, 136)
		_:
			return Color8(255, 237, 174)


func _draw_attack_effect(id: String) -> void:
	if str(unit_data.get("anim_kind", "")) != "attack":
		return
	var progress := _animation_progress()
	if progress >= 1.0:
		return

	var dx := int(unit_data.get("anim_dx", 1))
	var dy := int(unit_data.get("anim_dy", 0))
	var color := _effect_color(id)
	var pulse := int(round(sin(progress * PI) * 5.0))
	if abs(dx) >= abs(dy):
		var x := 30 if dx >= 0 else 8 - pulse
		_px(x, 21, 9 + pulse, 2, color)
		_px(x + 2, 25, 7 + pulse, 2, color)
	else:
		var y := 30 if dy >= 0 else 9 - pulse
		_px(22, y, 2, 9 + pulse, color)
		_px(26, y + 2, 2, 7 + pulse, color)


func _draw_hit_flash() -> void:
	if str(unit_data.get("anim_kind", "")) != "hit":
		return
	var progress := _animation_progress()
	if progress >= 1.0:
		return
	var s := _scale()
	var alpha := int(round(120.0 * (1.0 - progress)))
	var rect := Rect2(_origin() + (Vector2(10, 12) + draw_offset_px) * s, Vector2(28, 25) * s)
	draw_rect(rect, Color8(255, 245, 215, alpha))


func _draw_shadow() -> void:
	_px(11, 38, 26, 5, Color8(0, 0, 0, 80))


func _draw_team_ring(team: String) -> void:
	var color := Color8(83, 164, 255) if team == "player" else Color8(239, 91, 91)
	_px(8, 39, 32, 2, color)


func _draw_hp_bar(hp: int, max_hp: int) -> void:
	_px(8, 3, 32, 4, Color8(35, 38, 40))
	var width := int(round(30.0 * float(hp) / float(max_hp)))
	_px(9, 4, max(0, width), 2, Color8(88, 214, 116))


func _draw_stars(star: int) -> void:
	for i in range(star):
		_px(36 - i * 5, 8, 3, 3, Color8(244, 211, 94))


func _draw_animal(id: String) -> void:
	match id:
		"rabbit":
			_draw_rabbit()
		"sparrow":
			_draw_sparrow()
		"frog":
			_draw_frog()
		"fox":
			_draw_fox()
		"wolf":
			_draw_wolf()
		"penguin":
			_draw_penguin()
		"bear":
			_draw_bear()
		_:
			_draw_turtle()


func _draw_eye(x: int, y: int) -> void:
	_px(x, y, 3, 3, Color8(27, 29, 29))
	_px(x + 1, y, 1, 1, Color8(255, 255, 255))


func _draw_turtle() -> void:
	_px(13, 24, 22, 11, Color8(29, 99, 78))
	_px(16, 17, 16, 14, Color8(46, 137, 92))
	_px(19, 20, 10, 8, Color8(93, 157, 89))
	_px(33, 24, 7, 7, Color8(75, 151, 95))
	_px(9, 28, 5, 5, Color8(75, 151, 95))
	_px(14, 34, 5, 3, Color8(47, 90, 69))
	_px(29, 34, 5, 3, Color8(47, 90, 69))
	_draw_eye(35, 25)


func _draw_rabbit() -> void:
	_px(17, 11, 5, 15, Color8(237, 221, 186))
	_px(27, 11, 5, 15, Color8(237, 221, 186))
	_px(19, 13, 2, 10, Color8(233, 156, 163))
	_px(28, 13, 2, 10, Color8(233, 156, 163))
	_px(15, 24, 20, 13, Color8(237, 221, 186))
	_px(18, 20, 14, 10, Color8(247, 235, 209))
	_px(11, 31, 7, 5, Color8(247, 235, 209))
	_px(32, 31, 6, 5, Color8(237, 221, 186))
	_draw_eye(21, 23)
	_draw_eye(29, 23)


func _draw_sparrow() -> void:
	_px(9, 23, 15, 10, Color8(132, 90, 57))
	_px(24, 20, 14, 13, Color8(170, 119, 75))
	_px(14, 15, 18, 7, Color8(92, 151, 185))
	_px(32, 23, 7, 4, Color8(239, 171, 73))
	_px(12, 33, 4, 4, Color8(75, 50, 40))
	_px(25, 33, 4, 4, Color8(75, 50, 40))
	_draw_eye(29, 22)


func _draw_frog() -> void:
	_px(13, 21, 22, 15, Color8(58, 161, 82))
	_px(15, 16, 7, 8, Color8(93, 194, 103))
	_px(27, 16, 7, 8, Color8(93, 194, 103))
	_px(17, 28, 15, 5, Color8(132, 218, 117))
	_px(7, 31, 8, 5, Color8(58, 161, 82))
	_px(34, 31, 8, 5, Color8(58, 161, 82))
	_px(36, 20, 4, 4, Color8(160, 83, 188))
	_draw_eye(17, 18)
	_draw_eye(29, 18)


func _draw_fox() -> void:
	_px(10, 26, 10, 9, Color8(226, 113, 50))
	_px(18, 21, 18, 14, Color8(226, 113, 50))
	_px(19, 15, 5, 8, Color8(226, 113, 50))
	_px(30, 15, 5, 8, Color8(226, 113, 50))
	_px(24, 28, 9, 6, Color8(255, 232, 192))
	_px(35, 24, 8, 5, Color8(255, 232, 192))
	_px(8, 30, 7, 5, Color8(255, 232, 192))
	_draw_eye(29, 23)


func _draw_wolf() -> void:
	_px(12, 25, 25, 11, Color8(103, 113, 125))
	_px(19, 18, 17, 11, Color8(127, 137, 149))
	_px(21, 13, 5, 7, Color8(127, 137, 149))
	_px(31, 13, 5, 7, Color8(127, 137, 149))
	_px(35, 23, 8, 5, Color8(180, 188, 190))
	_px(13, 34, 5, 4, Color8(72, 78, 86))
	_px(30, 34, 5, 4, Color8(72, 78, 86))
	_draw_eye(31, 21)


func _draw_penguin() -> void:
	_px(16, 15, 18, 23, Color8(40, 48, 60))
	_px(20, 19, 10, 16, Color8(238, 243, 236))
	_px(12, 24, 5, 10, Color8(40, 48, 60))
	_px(33, 24, 5, 10, Color8(40, 48, 60))
	_px(23, 26, 5, 3, Color8(238, 166, 58))
	_px(17, 37, 6, 3, Color8(238, 166, 58))
	_px(27, 37, 6, 3, Color8(238, 166, 58))
	_px(36, 17, 4, 4, Color8(118, 199, 220))
	_draw_eye(21, 20)
	_draw_eye(28, 20)


func _draw_bear() -> void:
	_px(12, 22, 25, 15, Color8(104, 67, 43))
	_px(17, 15, 20, 15, Color8(124, 78, 48))
	_px(15, 13, 6, 6, Color8(104, 67, 43))
	_px(32, 13, 6, 6, Color8(104, 67, 43))
	_px(21, 25, 13, 8, Color8(176, 123, 75))
	_px(8, 28, 7, 6, Color8(104, 67, 43))
	_px(35, 28, 8, 6, Color8(104, 67, 43))
	_draw_eye(23, 20)
	_draw_eye(31, 20)
