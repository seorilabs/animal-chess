## 피해나 회복 수치가 위로 떠오르며 사라지는 표시.
class_name DamagePopup
extends Label

const RISE_PIXELS := 46.0
const DURATION := 0.75
const COLOR_PLAYER_HIT := Color8(255, 138, 128)
const COLOR_ENEMY_HIT := Color8(255, 233, 168)
const COLOR_HEAL := Color8(126, 226, 148)


static func damage(amount: int, on_player: bool) -> DamagePopup:
	var popup := DamagePopup.new()
	popup.text = str(amount)
	popup._color = COLOR_PLAYER_HIT if on_player else COLOR_ENEMY_HIT
	popup._font_size = 26 if amount >= 12 else 22
	return popup


static func heal(amount: int) -> DamagePopup:
	var popup := DamagePopup.new()
	popup.text = "+%d" % amount
	popup._color = COLOR_HEAL
	popup._font_size = 22
	return popup


var _color := Color.WHITE
var _font_size := 22


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_theme_font_size_override("font_size", _font_size)
	add_theme_color_override("font_color", _color)
	add_theme_color_override("font_outline_color", Color8(12, 16, 14))
	add_theme_constant_override("outline_size", 6)

	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "position:y", position.y - RISE_PIXELS, DURATION) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate:a", 0.0, DURATION).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(queue_free)
