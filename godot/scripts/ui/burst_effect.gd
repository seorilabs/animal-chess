## 스킬 발동과 처치 순간에 터지는 짧은 파티클.
##
## 텍스처를 쓰지 않고 직접 그린다. 스프라이트 팔레트와 색을 맞추기 쉽다.
class_name BurstEffect
extends Control

enum Kind { SKILL, DEATH }

const PARTICLE_COUNT := 10
const DURATION := 0.45
const SPREAD := 42.0

const COLORS := {
	Kind.SKILL: Color8(244, 224, 120),
	Kind.DEATH: Color8(214, 226, 240),
}

var _kind: Kind = Kind.SKILL
var _progress := 0.0
var _directions: Array[Vector2] = []


static func create(kind: Kind, seed_value: int) -> BurstEffect:
	var burst := BurstEffect.new()
	burst._kind = kind
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for index in range(PARTICLE_COUNT):
		var angle := rng.randf_range(0.0, TAU)
		var speed := rng.randf_range(0.55, 1.0)
		burst._directions.append(Vector2.RIGHT.rotated(angle) * speed)
	return burst


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tween := create_tween()
	tween.tween_method(_set_progress, 0.0, 1.0, DURATION)
	tween.tween_callback(queue_free)


func _set_progress(value: float) -> void:
	_progress = value
	queue_redraw()


func _draw() -> void:
	var color: Color = COLORS[_kind]
	color.a = 1.0 - _progress

	if _kind == Kind.SKILL:
		# 발밑에서 퍼지는 고리.
		draw_arc(Vector2.ZERO, SPREAD * _progress, 0.0, TAU, 24, color, 3.0)

	var radius := 5.0 * (1.0 - _progress) + 1.0
	for direction in _directions:
		draw_circle(direction * SPREAD * _progress, radius, color)
