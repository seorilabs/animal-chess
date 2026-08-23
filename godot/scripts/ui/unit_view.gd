## 보드와 대기석에 올라가는 기물 한 마리의 표시.
##
## 그림은 아직 절차적 드로잉이다. 실제 스프라이트로 교체할 때 _draw_animal 계열만 바뀐다.
## 애니메이션 상태는 데이터가 아니라 이 뷰가 들고 있으며 CombatEvent가 촉발한다.
class_name UnitView
extends Control

enum Motion { NONE, ATTACK, HIT, STEP }

const CANVAS := 48.0
const ATTACK_MS := 300
const HIT_MS := 260
const STEP_MS := 280

var unit: UnitState = null
var selected := false

var _motion: Motion = Motion.NONE
var _motion_direction := Vector2.ZERO
var _motion_start_ms := 0
var _motion_duration_ms := 1
var _draw_offset := Vector2.ZERO


func set_unit(value: UnitState) -> void:
	unit = value
	queue_redraw()


func set_selected(value: bool) -> void:
	if selected == value:
		return
	selected = value
	queue_redraw()


func play(motion: Motion, direction: Vector2i) -> void:
	_motion = motion
	_motion_direction = Vector2(direction)
	_motion_start_ms = Time.get_ticks_msec()
	_motion_duration_ms = _duration_for(motion)
	queue_redraw()


func _duration_for(motion: Motion) -> int:
	match motion:
		Motion.ATTACK:
			return ATTACK_MS
		Motion.HIT:
			return HIT_MS
		Motion.STEP:
			return STEP_MS
		_:
			return 1


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(_delta: float) -> void:
	if _motion == Motion.NONE:
		return
	if _progress() >= 1.0:
		_motion = Motion.NONE
	queue_redraw()


func _draw() -> void:
	if unit == null:
		return

	_draw_offset = _current_offset()

	_draw_shadow()
	_draw_team_ring()
	_draw_animal(unit.def.id)
	_draw_attack_effect(unit.def.id)
	_draw_hp_bar()
	_draw_mana_bar()
	_draw_stars()
	_draw_hit_flash()

	if selected:
		draw_rect(Rect2(Vector2.ZERO, size), Color8(255, 234, 130), false, 3.0)


func _scale() -> float:
	return minf(size.x, size.y) / CANVAS


func _origin() -> Vector2:
	return (size - Vector2(CANVAS, CANVAS) * _scale()) * 0.5


func _px(x: int, y: int, w: int, h: int, color: Color) -> void:
	var scale := _scale()
	draw_rect(Rect2(_origin() + (Vector2(x, y) + _draw_offset) * scale, Vector2(w, h) * scale), color)


func _progress() -> float:
	if _motion == Motion.NONE:
		return 1.0
	var elapsed := Time.get_ticks_msec() - _motion_start_ms
	return clampf(float(elapsed) / float(maxi(1, _motion_duration_ms)), 0.0, 1.0)


func _current_offset() -> Vector2:
	var progress := _progress()
	if _motion == Motion.NONE or progress >= 1.0:
		return Vector2.ZERO

	var direction := _motion_direction
	direction = Vector2(1, 0) if direction.length_squared() == 0.0 else direction.normalized()

	match _motion:
		Motion.ATTACK:
			return direction * sin(progress * PI) * 5.0
		Motion.HIT:
			return Vector2(sin(progress * PI * 8.0) * 2.4 * (1.0 - progress), 0.0)
		Motion.STEP:
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
	if _motion != Motion.ATTACK:
		return
	var progress := _progress()
	if progress >= 1.0:
		return

	var direction := _motion_direction
	var color := _effect_color(id)
	var pulse := int(round(sin(progress * PI) * 5.0))
	if absf(direction.x) >= absf(direction.y):
		var x := 30 if direction.x >= 0.0 else 8 - pulse
		_px(x, 21, 9 + pulse, 2, color)
		_px(x + 2, 25, 7 + pulse, 2, color)
	else:
		var y := 30 if direction.y >= 0.0 else 9 - pulse
		_px(22, y, 2, 9 + pulse, color)
		_px(26, y + 2, 2, 7 + pulse, color)


func _draw_hit_flash() -> void:
	if _motion != Motion.HIT:
		return
	var progress := _progress()
	if progress >= 1.0:
		return
	var scale := _scale()
	var alpha := int(round(120.0 * (1.0 - progress)))
	draw_rect(
		Rect2(_origin() + (Vector2(10, 12) + _draw_offset) * scale, Vector2(28, 25) * scale),
		Color8(255, 245, 215, alpha)
	)


func _draw_shadow() -> void:
	_px(11, 38, 26, 5, Color8(0, 0, 0, 80))


func _draw_team_ring() -> void:
	var color := Color8(83, 164, 255) if unit.team == UnitState.Team.PLAYER else Color8(239, 91, 91)
	_px(8, 39, 32, 2, color)


func _draw_hp_bar() -> void:
	_px(8, 2, 32, 4, Color8(35, 38, 40))
	var ratio := clampf(float(unit.hp) / float(maxi(1, unit.max_hp)), 0.0, 1.0)
	_px(9, 3, int(round(30.0 * ratio)), 2, Color8(88, 214, 116))
	if unit.shield > 0:
		var shield_ratio := clampf(float(unit.shield) / float(maxi(1, unit.max_hp)), 0.0, 1.0)
		_px(9, 3, int(round(30.0 * shield_ratio)), 2, Color8(214, 226, 240))


func _draw_mana_bar() -> void:
	if unit.max_mana <= 0:
		return
	_px(8, 7, 32, 3, Color8(28, 34, 44))
	var ratio := clampf(float(unit.mana) / float(unit.max_mana), 0.0, 1.0)
	var color := Color8(244, 224, 120) if unit.is_skill_ready() else Color8(110, 200, 232)
	_px(9, 8, int(round(30.0 * ratio)), 1, color)


func _draw_stars() -> void:
	for i in range(unit.star):
		_px(36 - i * 5, 11, 3, 3, Color8(244, 211, 94))


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
