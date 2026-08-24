## 첫 화면. 런을 시작하거나 이어가고, 도감과 설정으로 들어간다.
class_name TitleScreen
extends Control

signal start_requested(resume: bool)
signal codex_requested
signal settings_requested

const BACKGROUND_PATH := "res://assets/art/bg_title.png"
const MASCOT_PATH := "res://assets/art/unit_turtle.png"
const TITLE_TEXT := "픽셀 동물전장"
const SUBTITLE_TEXT := "동물을 모아 배치하고 자동 전투로 겨루는 픽셀 전략"
## 마스코트가 위아래로 떠 있는 폭과 주기.
const BOB_PIXELS := 10.0
const BOB_SECONDS := 2.4

var _mascot: TextureRect
var _resume_button: Button
var _record_label: Label
var _elapsed := 0.0


func _init() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var background := TextureRect.new()
	if ResourceLoader.exists(BACKGROUND_PATH):
		background.texture = load(BACKGROUND_PATH)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	# 아래쪽을 어둡게 깔아 버튼 위 글자가 배경에 묻히지 않게 한다.
	var scrim := ColorRect.new()
	scrim.color = Color(0.043, 0.078, 0.063, 0.55)
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(scrim)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["margin_left", "margin_right"]:
		margin.add_theme_constant_override(side, 64)
	margin.add_theme_constant_override("margin_top", 96)
	margin.add_theme_constant_override("margin_bottom", 96)
	add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 18)
	margin.add_child(column)

	column.add_child(_title_label(TITLE_TEXT, 68, Color8(244, 232, 196)))
	column.add_child(_title_label(SUBTITLE_TEXT, 21, Color8(178, 200, 182)))

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(spacer)

	# 컨테이너가 자리를 잡는 홀더 안에서만 마스코트를 움직인다.
	# TextureRect를 컨테이너에 직접 넣고 position을 만지면 배치가 어긋난다.
	var mascot_holder := Control.new()
	mascot_holder.custom_minimum_size = Vector2(0, 220)
	mascot_holder.clip_contents = false
	column.add_child(mascot_holder)

	_mascot = TextureRect.new()
	if ResourceLoader.exists(MASCOT_PATH):
		_mascot.texture = load(MASCOT_PATH)
	_mascot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_mascot.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_mascot.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mascot_holder.add_child(_mascot)

	var spacer_bottom := Control.new()
	spacer_bottom.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(spacer_bottom)

	_record_label = Label.new()
	_record_label.add_theme_font_size_override("font_size", 20)
	_record_label.add_theme_color_override("font_color", Color8(178, 200, 182))
	_record_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(_record_label)

	_resume_button = _menu_button(column, "이어하기", 34)
	_resume_button.pressed.connect(func() -> void: start_requested.emit(true))

	var new_button := _menu_button(column, "새 게임", 30)
	new_button.pressed.connect(func() -> void: start_requested.emit(false))

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	column.add_child(row)

	var codex_button := _menu_button(row, "도감", 26)
	codex_button.pressed.connect(func() -> void: codex_requested.emit())
	var settings_button := _menu_button(row, "설정", 26)
	settings_button.pressed.connect(func() -> void: settings_requested.emit())


func show_profile(profile: Profile, has_saved_run: bool) -> void:
	_resume_button.visible = has_saved_run
	if profile.runs_played == 0:
		_record_label.text = "첫 런을 시작해 보세요."
		return
	_record_label.text = "최고 %d라운드  ·  완주 %d회  ·  해금 %d종" % [
		profile.best_round, profile.runs_won, profile.unlocked.size()
	]


func _process(delta: float) -> void:
	_elapsed += delta
	_mascot.offset_top = sin(_elapsed * TAU / BOB_SECONDS) * BOB_PIXELS
	_mascot.offset_bottom = _mascot.offset_top


func _title_label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color8(10, 18, 15))
	label.add_theme_constant_override("outline_size", 8)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label


func _menu_button(parent: Control, text: String, font_size: int) -> Button:
	var button := Button.new()
	button.text = text
	button.add_theme_font_size_override("font_size", font_size)
	button.custom_minimum_size = Vector2(0, 72)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(button)
	return button
