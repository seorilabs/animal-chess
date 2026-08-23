## 배치한 조합의 서식지/역할 시너지를 칩으로 보여준다.
##
## 발동한 시너지는 밝게, 아직 모자란 시너지는 어둡게 표시하고
## 아래 한 줄에 가장 크게 발동한 시너지의 설명을 붙인다.
class_name SynergyPanel
extends PanelContainer

const COLOR_ACTIVE_BG := Color8(46, 89, 60)
const COLOR_ACTIVE_BORDER := Color8(112, 190, 128)
const COLOR_IDLE_BG := Color8(30, 41, 35)
const COLOR_IDLE_BORDER := Color8(58, 76, 63)
const COLOR_ACTIVE_TEXT := Color8(226, 245, 224)
const COLOR_IDLE_TEXT := Color8(132, 152, 136)

var _chips: HBoxContainer
var _description: Label


func _init() -> void:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	add_child(box)

	_chips = HBoxContainer.new()
	_chips.add_theme_constant_override("separation", 6)
	box.add_child(_chips)

	_description = Label.new()
	_description.add_theme_font_size_override("font_size", 19)
	_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_description)


func show_for(units: Array[UnitState]) -> void:
	for child in _chips.get_children():
		child.queue_free()

	if units.is_empty():
		_description.text = "기물을 배치하면 시너지가 표시됩니다."
		_description.modulate = COLOR_IDLE_TEXT
		return

	var actives := Synergy.evaluate(units)
	var best: Synergy.Active = null
	for active in actives:
		_chips.add_child(_build_chip(active))
		if active.is_active() and (best == null or active.count > best.count):
			best = active

	if best == null:
		var closest: Synergy.Active = actives[0]
		_description.text = "%s 시너지까지 %d마리 남았습니다." % [closest.label, closest.next_required]
		_description.modulate = COLOR_IDLE_TEXT
		return

	_description.text = "%s %d — %s" % [best.label, best.count, best.description]
	_description.modulate = COLOR_ACTIVE_TEXT


func _build_chip(active: Synergy.Active) -> Control:
	var chip := PanelContainer.new()
	chip.add_theme_stylebox_override("panel", _chip_style(active.is_active()))

	var label := Label.new()
	label.text = "%s %d" % [active.label, active.count]
	label.add_theme_font_size_override("font_size", 19)
	label.add_theme_color_override(
		"font_color", COLOR_ACTIVE_TEXT if active.is_active() else COLOR_IDLE_TEXT
	)
	chip.add_child(label)

	if active.next_required > 0:
		chip.tooltip_text = "%s 다음 단계까지 %d마리" % [active.label, active.next_required]
	return chip


func _chip_style(active: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_ACTIVE_BG if active else COLOR_IDLE_BG
	style.border_color = COLOR_ACTIVE_BORDER if active else COLOR_IDLE_BORDER
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.content_margin_left = 10.0
	style.content_margin_right = 10.0
	style.content_margin_top = 4.0
	style.content_margin_bottom = 4.0
	return style
