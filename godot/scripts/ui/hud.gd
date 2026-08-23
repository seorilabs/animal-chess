## 라운드, 체력, 골드, 보유/배치 한도를 보여주는 상단 표시줄.
class_name Hud
extends HBoxContainer

const ICON_SIZE := Vector2(30, 30)
const HEALTH_ICON_PATH := "res://assets/art/icon_health.png"
const GOLD_ICON_PATH := "res://assets/art/icon_gold.png"

var _round_label: Label
var _health_label: Label
var _gold_label: Label
var _caps_label: Label


func _init() -> void:
	add_theme_constant_override("separation", 14)

	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", 2)
	add_child(left)

	_round_label = Label.new()
	_round_label.add_theme_font_size_override("font_size", 26)
	left.add_child(_round_label)

	_caps_label = Label.new()
	_caps_label.add_theme_font_size_override("font_size", 18)
	_caps_label.add_theme_color_override("font_color", Color8(147, 168, 151))
	left.add_child(_caps_label)

	var stats := VBoxContainer.new()
	stats.add_theme_constant_override("separation", 2)
	add_child(stats)

	_health_label = Label.new()
	_gold_label = Label.new()
	stats.add_child(_stat_row(HEALTH_ICON_PATH, _health_label, Color8(240, 160, 155)))
	stats.add_child(_stat_row(GOLD_ICON_PATH, _gold_label, Color8(244, 211, 94)))


func show_run(run: RunState) -> void:
	_round_label.text = run.round_status()
	_health_label.text = str(run.player_hp)
	_gold_label.text = str(run.gold)
	_caps_label.text = "보유 %d/%d   배치 %d/%d" % [
		run.owned_count(), run.owned_cap(), run.deployed_count(), run.deploy_cap()
	]


func _stat_row(icon_path: String, label: Label, color: Color) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row.alignment = BoxContainer.ALIGNMENT_END

	var icon := TextureRect.new()
	if ResourceLoader.exists(icon_path):
		icon.texture = load(icon_path)
	icon.custom_minimum_size = ICON_SIZE
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	row.add_child(icon)

	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", color)
	label.custom_minimum_size = Vector2(56, 0)
	row.add_child(label)
	return row
