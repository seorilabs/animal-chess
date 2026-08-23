## 대기석 한 칸. 탭 선택과 드래그&드롭을 모두 받는다.
class_name BenchSlot
extends PanelContainer

signal slot_pressed(index: int)
signal unit_dropped(payload: Dictionary, index: int)

const COLOR_EMPTY_BG := Color8(31, 42, 37)
const COLOR_EMPTY_BORDER := Color8(58, 76, 63)
const COLOR_SELECTED_BORDER := Color8(244, 211, 94)

var index := 0
var unit: UnitState = null


func _init(slot_index: int) -> void:
	index = slot_index
	custom_minimum_size = Vector2(0, 88)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_STOP


func show_unit(value: UnitState, selected: bool) -> void:
	unit = value
	for child in get_children():
		child.queue_free()
	add_theme_stylebox_override("panel", _style(selected))
	if unit == null:
		return

	var view := UnitView.new()
	view.set_unit(unit)
	view.set_selected(selected)
	view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(view)


func _gui_input(event: InputEvent) -> void:
	if BoardView.is_primary_press(event):
		slot_pressed.emit(index)
		accept_event()


func _get_drag_data(_at_position: Vector2) -> Variant:
	if unit == null:
		return null
	set_drag_preview(_drag_preview())
	return {"source": "bench", "index": index}


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.has("source")


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	unit_dropped.emit(data, index)


func _drag_preview() -> Control:
	var holder := Control.new()
	var view := UnitView.new()
	view.set_unit(unit)
	view.idle_bob = false
	view.size = Vector2(96, 96)
	view.position = Vector2(-48, -48)
	holder.add_child(view)
	return holder


func _style(selected: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_EMPTY_BG
	style.border_color = COLOR_SELECTED_BORDER if selected else COLOR_EMPTY_BORDER
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	return style
