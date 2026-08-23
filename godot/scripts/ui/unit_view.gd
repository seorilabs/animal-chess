## 보드와 대기석에 올라가는 기물 한 마리의 표시.
##
## 스프라이트는 정적 이미지 한 장이고 움직임은 전부 코드에서 만든다.
## 애니메이션 상태는 데이터가 아니라 이 뷰가 들고 있으며 CombatEvent가 촉발한다.
class_name UnitView
extends Control

enum Motion { NONE, ATTACK, HIT, STEP }

## 그리기 좌표계. 실제 크기와 무관하게 이 격자 위에서 계산한다.
const CANVAS := 48.0
const ATTACK_MS := 300
const HIT_MS := 260
const STEP_MS := 280

const SPRITE_DIR := "res://assets/art"
const STAR_TEXTURE_PATH := "res://assets/art/icon_star.png"

## 스프라이트가 차지하는 영역. 위는 체력/마나 바, 아래는 팀 링 자리로 비운다.
const SPRITE_RECT := Rect2(3, 9, 42, 33)
## 체력/마나 바의 가로 위치와 너비.
const BAR_X := 10.0
const BAR_W := 28.0

static var _sprite_cache: Dictionary = {}
static var _star_texture: Texture2D = null

var unit: UnitState = null
var selected := false

## 준비 단계에서 위아래로 살짝 떠 있는 폭과 속도.
const IDLE_BOB_PIXELS := 0.7
const IDLE_BOB_SPEED := 2.2

## 같은 칸의 기물이 한 몸처럼 흔들리지 않도록 uid로 위상을 어긋나게 한다.
var idle_bob := true

var _motion: Motion = Motion.NONE
var _motion_direction := Vector2.ZERO
var _motion_start_ms := 0
var _motion_duration_ms := 1
var _draw_offset := Vector2.ZERO


static func sprite_for(id: String) -> Texture2D:
	if _sprite_cache.has(id):
		return _sprite_cache[id]
	var path := "%s/unit_%s.png" % [SPRITE_DIR, id]
	var texture: Texture2D = load(path) if ResourceLoader.exists(path) else null
	if texture == null:
		push_error("기물 스프라이트를 찾을 수 없습니다: %s" % path)
	_sprite_cache[id] = texture
	return texture


static func star_texture() -> Texture2D:
	if _star_texture == null and ResourceLoader.exists(STAR_TEXTURE_PATH):
		_star_texture = load(STAR_TEXTURE_PATH)
	return _star_texture


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


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	pivot_offset = size * 0.5


func _process(_delta: float) -> void:
	pivot_offset = size * 0.5
	if _motion == Motion.NONE:
		if idle_bob:
			queue_redraw()
		return
	if _progress() >= 1.0:
		_motion = Motion.NONE
	queue_redraw()


func _draw() -> void:
	if unit == null:
		return

	_draw_offset = _current_offset()

	_draw_shadow()
	_draw_sprite()
	_draw_team_ring()
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


## 48 격자 좌표를 실제 화면 사각형으로 옮긴다.
func _rect(x: float, y: float, w: float, h: float) -> Rect2:
	var scale := _scale()
	return Rect2(_origin() + (Vector2(x, y) + _draw_offset) * scale, Vector2(w, h) * scale)


func _px(x: int, y: int, w: int, h: int, color: Color) -> void:
	draw_rect(_rect(x, y, w, h), color)


func _progress() -> float:
	if _motion == Motion.NONE:
		return 1.0
	var elapsed := Time.get_ticks_msec() - _motion_start_ms
	return clampf(float(elapsed) / float(maxi(1, _motion_duration_ms)), 0.0, 1.0)


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


func _current_offset() -> Vector2:
	var progress := _progress()
	if _motion == Motion.NONE or progress >= 1.0:
		return _idle_offset()

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


## 가만히 있을 때도 살짝 떠 있게 해 화면이 굳어 보이지 않게 한다.
## 위상을 uid로 어긋내 여러 기물이 한 몸처럼 움직이지 않게 한다.
func _idle_offset() -> Vector2:
	if not idle_bob or unit == null:
		return Vector2.ZERO
	var phase := Time.get_ticks_msec() / 1000.0 * IDLE_BOB_SPEED + unit.uid * 0.7
	return Vector2(0.0, sin(phase) * IDLE_BOB_PIXELS)


func _draw_sprite() -> void:
	var texture := sprite_for(unit.def.id)
	if texture == null:
		return
	# 공격할 때 살짝 눌러 앞으로 뻗는 느낌을 준다.
	var squash := 0.0
	if _motion == Motion.ATTACK:
		squash = sin(_progress() * PI) * 2.0
	draw_texture_rect(
		texture,
		_rect(
			SPRITE_RECT.position.x - squash * 0.5,
			SPRITE_RECT.position.y + squash,
			SPRITE_RECT.size.x + squash,
			SPRITE_RECT.size.y - squash
		),
		false
	)


func _draw_hit_flash() -> void:
	if _motion != Motion.HIT:
		return
	var progress := _progress()
	if progress >= 1.0:
		return
	var texture := sprite_for(unit.def.id)
	if texture == null:
		return
	# 스프라이트 실루엣만 하얗게 번쩍이게 한다.
	draw_texture_rect(
		texture,
		_rect(SPRITE_RECT.position.x, SPRITE_RECT.position.y, SPRITE_RECT.size.x, SPRITE_RECT.size.y),
		false,
		Color(1.0, 1.0, 1.0, 0.75 * (1.0 - progress))
	)


func _draw_shadow() -> void:
	_px(14, 41, 20, 3, Color8(0, 0, 0, 90))


func _draw_team_ring() -> void:
	var color := Color8(83, 164, 255) if unit.team == UnitState.Team.PLAYER else Color8(239, 91, 91)
	_px(11, 44, 26, 2, color)


func _draw_hp_bar() -> void:
	draw_rect(_rect(BAR_X, 2.0, BAR_W, 3.0), Color8(16, 20, 18, 220))
	var ratio := clampf(float(unit.hp) / float(maxi(1, unit.max_hp)), 0.0, 1.0)
	draw_rect(_rect(BAR_X + 0.5, 2.5, (BAR_W - 1.0) * ratio, 2.0), Color8(88, 214, 116))
	if unit.shield > 0:
		var shield_ratio := clampf(float(unit.shield) / float(maxi(1, unit.max_hp)), 0.0, 1.0)
		draw_rect(
			_rect(BAR_X + 0.5, 2.5, (BAR_W - 1.0) * shield_ratio, 2.0), Color8(214, 226, 240)
		)


func _draw_mana_bar() -> void:
	if unit.max_mana <= 0:
		return
	draw_rect(_rect(BAR_X, 5.5, BAR_W, 2.0), Color8(14, 18, 26, 220))
	var ratio := clampf(float(unit.mana) / float(unit.max_mana), 0.0, 1.0)
	var color := Color8(244, 224, 120) if unit.is_skill_ready() else Color8(110, 200, 232)
	draw_rect(_rect(BAR_X + 0.5, 5.9, (BAR_W - 1.0) * ratio, 1.2), color)


func _draw_stars() -> void:
	var texture := star_texture()
	for index in range(unit.star):
		var rect := _rect(37 - index * 6, 9, 6, 6)
		if texture == null:
			draw_rect(rect, Color8(244, 211, 94))
		else:
			draw_texture_rect(texture, rect, false)
