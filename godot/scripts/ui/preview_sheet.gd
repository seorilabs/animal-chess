## 전투 전에 상대 조합을 확인하는 시트.
##
## 기획서 §7의 "AI 상대 미리보기" 화면이다. 배치를 조정할 근거를 준다.
class_name PreviewSheet
extends PanelContainer

signal closed

const BOARD_SIZE := 520.0

var _title: Label
var _board: BoardView
var _synergy: SynergyPanel


func _init() -> void:
	visible = false
	custom_minimum_size = Vector2(620, 0)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	add_child(box)

	_title = Label.new()
	_title.add_theme_font_size_override("font_size", 30)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_title)

	var board_holder := CenterContainer.new()
	box.add_child(board_holder)

	_board = BoardView.new()
	_board.board_size = RunState.BOARD
	_board.player_min_row = RunState.PLAYER_MIN_ROW
	_board.interactive = false
	_board.custom_minimum_size = Vector2(BOARD_SIZE, BOARD_SIZE)
	board_holder.add_child(_board)

	_synergy = SynergyPanel.new()
	box.add_child(_synergy)

	var close_button := Button.new()
	close_button.text = "닫기"
	close_button.pressed.connect(_on_close)
	box.add_child(close_button)


func open(run: RunState) -> void:
	_title.text = "%s 조합" % run.round_label()
	_board.clear()
	_board.sync(run.next_wave)
	_synergy.show_for(run.next_wave)
	visible = true


func _on_close() -> void:
	visible = false
	closed.emit()
