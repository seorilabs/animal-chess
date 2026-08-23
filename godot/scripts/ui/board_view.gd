## 보드 표시. 칸은 직접 그리고 기물은 칸 위에 얹은 UnitView로 띄운다.
##
## 칸마다 컨테이너 노드를 두지 않기 때문에 갱신할 때 노드를 버리고 다시 만들 필요가 없다.
## 기물 뷰는 uid로 재사용되므로 전투 중에도 애니메이션이 끊기지 않는다.
class_name BoardView
extends Control

signal cell_pressed(cell: Vector2i)

## 처치와 스킬에 쓰는 파티클 종류. BurstEffect.Kind를 그대로 노출한다.
const BurstKind := BurstEffect.Kind

## 칸 대비 기물이 남기는 여백 비율.
const UNIT_INSET := 0.05

const COLOR_PLAYER_LIGHT := Color8(42, 63, 48)
const COLOR_PLAYER_DARK := Color8(36, 55, 43)
const COLOR_ENEMY_LIGHT := Color8(55, 46, 50)
const COLOR_ENEMY_DARK := Color8(48, 39, 44)
const COLOR_GRID := Color8(24, 36, 30)
const COLOR_PLAYER_EDGE := Color8(79, 142, 92)
const COLOR_SELECTED := Color8(244, 211, 94)

@export var board_size := Vector2i(8, 8)
@export var player_min_row := 4

var interactive := true
var selected_cell := Vector2i(-1, -1)

var _views: Dictionary = {}
var _shake := Vector2.ZERO
var _shake_amount := 0.0
var _shake_phase := 0.0
var _effect_seed := 1


## 흔들림이 몇 프레임 만에 잦아드는 속도.
const SHAKE_DECAY := 9.0
const SHAKE_FREQUENCY := 46.0


## 쓰러진 기물이 사라지기까지 걸리는 시간.
const DEATH_FADE := 0.35


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	# 피해 숫자가 보드 밖으로 튀어나가지 않게 한다.
	clip_contents = true
	set_process(true)


func _process(delta: float) -> void:
	if _shake_amount <= 0.01:
		if _shake != Vector2.ZERO:
			_shake = Vector2.ZERO
			layout_units()
			queue_redraw()
		return

	_shake_amount = maxf(0.0, _shake_amount - _shake_amount * SHAKE_DECAY * delta)
	_shake_phase += delta * SHAKE_FREQUENCY
	_shake = Vector2(sin(_shake_phase), cos(_shake_phase * 1.37)) * _shake_amount
	layout_units()
	queue_redraw()


## 화면을 짧게 흔든다. 값이 클수록 세게 흔들린다.
func shake(amount: float) -> void:
	_shake_amount = maxf(_shake_amount, amount)


func _notification(what: int) -> void:
	# 보드는 항상 정사각형을 유지한다.
	if what == NOTIFICATION_RESIZED and not is_equal_approx(custom_minimum_size.y, size.x):
		custom_minimum_size.y = size.x


func cell_size() -> Vector2:
	return Vector2(size.x / board_size.x, size.y / board_size.y)


func cell_rect(cell: Vector2i) -> Rect2:
	var unit_size := cell_size()
	return Rect2(Vector2(cell) * unit_size, unit_size)


func cell_at(point: Vector2) -> Vector2i:
	var unit_size := cell_size()
	if unit_size.x <= 0.0 or unit_size.y <= 0.0:
		return Vector2i(-1, -1)
	var cell := Vector2i(int(point.x / unit_size.x), int(point.y / unit_size.y))
	if cell.x < 0 or cell.x >= board_size.x or cell.y < 0 or cell.y >= board_size.y:
		return Vector2i(-1, -1)
	return cell


## 보여줄 기물 목록을 통째로 맞춘다. 사라진 기물의 뷰만 정리한다.
func sync(units: Array[UnitState]) -> void:
	var live_uids := {}
	for unit in units:
		live_uids[unit.uid] = true
		_view_for(unit).set_unit(unit)

	for uid in _views.keys():
		if not live_uids.has(uid):
			_fade_out(_views[uid])
			_views.erase(uid)

	layout_units()
	queue_redraw()


## 각 기물 뷰를 자기 칸 위로 옮긴다.
func layout_units() -> void:
	var unit_size := cell_size()
	var inset := unit_size * UNIT_INSET
	for uid in _views:
		var view: UnitView = _views[uid]
		if view.unit == null:
			continue
		view.position = Vector2(view.unit.position()) * unit_size + inset + _shake
		view.size = unit_size - inset * 2.0


## 사라진 기물은 바로 지우지 않고 잠깐 흐려지며 빠진다.
func _fade_out(view: UnitView) -> void:
	view.set_process(false)
	var tween := view.create_tween().set_parallel(true)
	tween.tween_property(view, "modulate:a", 0.0, DEATH_FADE)
	tween.tween_property(view, "scale", Vector2(0.7, 0.7), DEATH_FADE)
	tween.chain().tween_callback(view.queue_free)


func view_for_uid(uid: int) -> UnitView:
	return _views.get(uid)


func set_selected_cell(cell: Vector2i) -> void:
	if selected_cell == cell:
		return
	selected_cell = cell
	for uid in _views:
		var view: UnitView = _views[uid]
		view.set_selected(view.unit != null and view.unit.position() == cell)
	queue_redraw()


func clear() -> void:
	for uid in _views:
		(_views[uid] as UnitView).queue_free()
	_views.clear()
	queue_redraw()



func _view_for(unit: UnitState) -> UnitView:
	var view: UnitView = _views.get(unit.uid)
	if view != null:
		return view
	view = UnitView.new()
	_views[unit.uid] = view
	add_child(view)
	return view


## 칸 한가운데의 화면 좌표.
func cell_center(cell: Vector2i) -> Vector2:
	var unit_size := cell_size()
	return (Vector2(cell) + Vector2(0.5, 0.5)) * unit_size


func popup_damage(cell: Vector2i, amount: int, on_player: bool) -> void:
	_add_popup(DamagePopup.damage(amount, on_player), cell)


func popup_heal(cell: Vector2i, amount: int) -> void:
	_add_popup(DamagePopup.heal(amount), cell)


func burst(cell: Vector2i, kind: BurstEffect.Kind) -> void:
	_effect_seed += 1
	var effect := BurstEffect.create(kind, _effect_seed)
	effect.position = cell_center(cell)
	add_child(effect)


func _add_popup(popup: DamagePopup, cell: Vector2i) -> void:
	var center := cell_center(cell)
	popup.size = Vector2(cell_size().x, 0)
	popup.position = center - Vector2(cell_size().x * 0.5, cell_size().y * 0.55)
	add_child(popup)


func _draw() -> void:
	draw_set_transform(_shake)
	var unit_size := cell_size()
	for y in range(board_size.y):
		for x in range(board_size.x):
			var rect := Rect2(Vector2(x, y) * unit_size, unit_size)
			draw_rect(rect, _cell_color(x, y))
			draw_rect(rect, COLOR_GRID, false, 1.0)

	# 배치 가능 영역의 경계선.
	if player_min_row > 0 and player_min_row < board_size.y:
		var edge_y := player_min_row * unit_size.y
		draw_line(Vector2(0, edge_y), Vector2(size.x, edge_y), COLOR_PLAYER_EDGE, 2.0)

	if selected_cell.x >= 0:
		draw_rect(cell_rect(selected_cell), COLOR_SELECTED, false, 3.0)


func _cell_color(x: int, y: int) -> Color:
	var light := (x + y) % 2 == 0
	if y < player_min_row:
		return COLOR_ENEMY_LIGHT if light else COLOR_ENEMY_DARK
	return COLOR_PLAYER_LIGHT if light else COLOR_PLAYER_DARK


func _gui_input(event: InputEvent) -> void:
	if not interactive or not _is_primary_press(event):
		return
	var cell := cell_at(event.position)
	if cell.x >= 0:
		cell_pressed.emit(cell)
		accept_event()


static func _is_primary_press(event: InputEvent) -> bool:
	if event is InputEventMouseButton:
		return event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	if event is InputEventScreenTouch:
		return event.pressed
	return false
