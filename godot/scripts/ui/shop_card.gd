## 상점에 놓이는 기물 카드 한 장.
##
## 스프라이트, 이름, 서식지/역할, 비용을 한 장에 담는다.
class_name ShopCard
extends Button

const COLOR_NAME := Color8(237, 231, 214)
const COLOR_META := Color8(147, 168, 151)
const COLOR_COST := Color8(244, 211, 94)
const GOLD_ICON_PATH := "res://assets/art/icon_gold.png"

static var _gold_icon: Texture2D = null


static func gold_icon() -> Texture2D:
	if _gold_icon == null and ResourceLoader.exists(GOLD_ICON_PATH):
		_gold_icon = load(GOLD_ICON_PATH)
	return _gold_icon


func _init(unit_def: UnitDef) -> void:
	custom_minimum_size = Vector2(0, 150)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	clip_contents = true

	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", 2)
	add_child(box)

	var portrait := TextureRect.new()
	portrait.texture = UnitView.sprite_for(unit_def.id)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.custom_minimum_size = Vector2(0, 64)
	portrait.size_flags_vertical = Control.SIZE_EXPAND_FILL
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(portrait)

	box.add_child(_label(unit_def.display_name, 20, COLOR_NAME))
	box.add_child(
		_label("%s/%s" % [unit_def.habitat_label(), unit_def.role_label()], 16, COLOR_META)
	)
	box.add_child(_cost_row(unit_def.cost))


func _label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _cost_row(cost: int) -> Control:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 4)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var icon := TextureRect.new()
	icon.texture = gold_icon()
	icon.custom_minimum_size = Vector2(20, 20)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(icon)

	row.add_child(_label(str(cost), 19, COLOR_COST))
	return row
