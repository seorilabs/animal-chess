## 볼륨과 데이터 초기화를 다루는 설정 시트.
class_name SettingsSheet
extends PanelContainer

signal volumes_changed(music: float, sfx: float)
signal reset_requested
signal closed

const RESET_LABEL := "저장 데이터 초기화"
const RESET_CONFIRM_LABEL := "정말 지웁니다"

var _music_slider: HSlider
var _sfx_slider: HSlider
var _reset_button: Button
var _reset_armed := false


func _init() -> void:
	visible = false
	custom_minimum_size = Vector2(600, 0)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	add_child(box)

	var title := Label.new()
	title.text = "설정"
	title.add_theme_font_size_override("font_size", 34)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	_music_slider = _add_slider(box, "배경음")
	_sfx_slider = _add_slider(box, "효과음")

	_reset_button = Button.new()
	_reset_button.text = RESET_LABEL
	_reset_button.pressed.connect(_on_reset_pressed)
	box.add_child(_reset_button)

	var close_button := Button.new()
	close_button.text = "닫기"
	close_button.pressed.connect(_on_close)
	box.add_child(close_button)


func open(settings: SettingsService) -> void:
	_music_slider.set_value_no_signal(settings.music_volume)
	_sfx_slider.set_value_no_signal(settings.sfx_volume)
	_disarm_reset()
	visible = true


func _add_slider(parent: Control, label_text: String) -> HSlider:
	var row := VBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	parent.add_child(row)

	var label := Label.new()
	label.text = label_text
	label.add_theme_font_size_override("font_size", 22)
	row.add_child(label)

	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.custom_minimum_size = Vector2(0, 40)
	slider.value_changed.connect(_on_volume_changed)
	row.add_child(slider)
	return slider


func _on_volume_changed(_value: float) -> void:
	volumes_changed.emit(_music_slider.value, _sfx_slider.value)


## 한 번 더 눌러야 실제로 지운다. 되돌릴 수 없는 동작이라 확인을 받는다.
func _on_reset_pressed() -> void:
	if not _reset_armed:
		_reset_armed = true
		_reset_button.text = RESET_CONFIRM_LABEL
		_reset_button.add_theme_color_override("font_color", Color8(229, 97, 91))
		return
	_disarm_reset()
	reset_requested.emit()


func _disarm_reset() -> void:
	_reset_armed = false
	_reset_button.text = RESET_LABEL
	_reset_button.remove_theme_color_override("font_color")


func _on_close() -> void:
	visible = false
	closed.emit()
