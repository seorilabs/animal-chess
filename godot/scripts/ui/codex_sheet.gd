## 기물 도감. 해금한 기물의 설계값과 스킬을 보여준다.
##
## 해금은 런에서 그 기물을 실제로 보유했을 때 이루어진다.
class_name CodexSheet
extends PanelContainer

signal closed

const COLUMNS := 2
const LOCKED_TEXT := "?"

var _summary: Label
var _grid: GridContainer


func _init() -> void:
	visible = false
	custom_minimum_size = Vector2(660, 0)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	add_child(box)

	var title := Label.new()
	title.text = "도감"
	title.add_theme_font_size_override("font_size", 34)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	_summary = Label.new()
	_summary.add_theme_font_size_override("font_size", 20)
	_summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_summary)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 720)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)

	_grid = GridContainer.new()
	_grid.columns = COLUMNS
	_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_grid.add_theme_constant_override("h_separation", 8)
	_grid.add_theme_constant_override("v_separation", 8)
	scroll.add_child(_grid)

	var close_button := Button.new()
	close_button.text = "닫기"
	close_button.pressed.connect(_on_close)
	box.add_child(close_button)


func open(catalog: UnitCatalog, profile: Profile) -> void:
	for child in _grid.get_children():
		child.queue_free()

	var defs := catalog.defs()
	var unlocked := 0
	for unit_def in defs:
		var is_unlocked := profile.is_unlocked(unit_def.id)
		if is_unlocked:
			unlocked += 1
		_grid.add_child(_build_entry(unit_def, is_unlocked))

	_summary.text = "%d / %d 해금  ·  최고 %d라운드  ·  완주 %d회" % [
		unlocked, defs.size(), profile.best_round, profile.runs_won
	]
	visible = true


func _build_entry(unit_def: UnitDef, is_unlocked: bool) -> Control:
	var entry := PanelContainer.new()
	entry.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	entry.add_child(row)

	row.add_child(_build_portrait(unit_def, is_unlocked))

	var text := Label.new()
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.add_theme_font_size_override("font_size", 18)
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if is_unlocked:
		text.text = "%s  %s/%s\n체력 %d 공격 %d 사거리 %d\n[%s] %s" % [
			unit_def.display_name, unit_def.habitat_label(), unit_def.role_label(),
			unit_def.max_hp, unit_def.attack, unit_def.attack_range,
			unit_def.skill_name, unit_def.skill_text,
		]
	else:
		text.text = "미해금\n런에서 이 기물을 보유하면 열립니다."
		text.modulate = Color8(126, 142, 130)
	row.add_child(text)
	return entry


func _build_portrait(unit_def: UnitDef, is_unlocked: bool) -> Control:
	var holder := Control.new()
	holder.custom_minimum_size = Vector2(80, 80)

	if not is_unlocked:
		var locked := Label.new()
		locked.text = LOCKED_TEXT
		locked.add_theme_font_size_override("font_size", 44)
		locked.modulate = Color8(96, 112, 100)
		locked.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		locked.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		locked.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		holder.add_child(locked)
		return holder

	var view := UnitView.new()
	view.set_unit(UnitState.create(unit_def, UnitState.Team.PLAYER))
	view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	holder.add_child(view)
	return holder


func _on_close() -> void:
	visible = false
	closed.emit()
