## 전투가 끝난 뒤 결과와 보상 선택을 보여주는 시트.
##
## 승리하면 세 가지 보상 중 하나를 고르고, 보상형 광고로 한 번 더 고를 수 있다.
class_name WrapupSheet
extends PanelContainer

signal reward_chosen(index: int)
signal ad_requested
signal continue_pressed

var _title: Label
var _body: Label
var _reward_row: HBoxContainer
var _ad_button: Button
var _continue_button: Button


func _init() -> void:
	visible = false
	custom_minimum_size = Vector2(640, 0)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	add_child(box)

	_title = Label.new()
	_title.add_theme_font_size_override("font_size", 40)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_title)

	_body = Label.new()
	_body.add_theme_font_size_override("font_size", 22)
	_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_body)

	_reward_row = HBoxContainer.new()
	_reward_row.add_theme_constant_override("separation", 8)
	box.add_child(_reward_row)

	_ad_button = Button.new()
	_ad_button.text = "광고 보고 하나 더 받기"
	_ad_button.pressed.connect(func() -> void: ad_requested.emit())
	box.add_child(_ad_button)

	_continue_button = Button.new()
	_continue_button.pressed.connect(func() -> void: continue_pressed.emit())
	box.add_child(_continue_button)


func show_result(title: String, body: String, continue_text: String) -> void:
	_title.text = title
	_body.text = body
	_continue_button.text = continue_text
	visible = true


## 고를 수 있는 보상을 채운다. 비우면 보상 영역과 광고 버튼이 사라진다.
func show_rewards(choices: Array[Reward], ad_available: bool) -> void:
	for child in _reward_row.get_children():
		child.queue_free()

	_reward_row.visible = not choices.is_empty()
	_ad_button.visible = ad_available
	if choices.is_empty():
		return

	for index in range(choices.size()):
		var reward := choices[index]
		var button := Button.new()
		button.text = "%s\n%s" % [reward.label, reward.description]
		button.add_theme_font_size_override("font_size", 18)
		button.custom_minimum_size = Vector2(0, 130)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.pressed.connect(func() -> void: reward_chosen.emit(index))
		_reward_row.add_child(button)


func set_body(text: String) -> void:
	_body.text = text
