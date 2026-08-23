## 준비/전투 화면의 표현 계층.
##
## 게임 규칙은 RunState와 CombatSim이 들고, 여기서는 입력을 규칙에 넘기고
## 결과를 화면에 반영하는 일만 한다.
extends Control

const COMBAT_TICK_SECONDS := 0.2

const ACTION_MESSAGES := {
	RunState.Action.NOT_ENOUGH_GOLD: "골드가 부족합니다.",
	RunState.Action.BENCH_FULL: "대기석이 가득 찼습니다.",
	RunState.Action.OWNED_CAP_REACHED: "보유 한도에 도달했습니다. 라운드가 진행되면 한도가 늘어납니다.",
	RunState.Action.DEPLOY_CAP_REACHED: "이번 라운드 배치 한도를 넘었습니다.",
	RunState.Action.INVALID: "지금은 할 수 없는 동작입니다.",
}

enum Selection { NONE, BENCH, BOARD }

var catalog: UnitCatalog
var run: RunState
var sim := CombatSim.new()

var _selection: Selection = Selection.NONE
var _selected_bench := -1
var _selected_cell := Vector2i(-1, -1)
var _combat_running := false
var _wrapup_active := false

var _status_label: Label
var _message_label: Label
var _detail_panel: PanelContainer
var _detail_label: Label
var _synergy_panel: SynergyPanel
var _board: BoardView
var _bench_row: HBoxContainer
var _shop_row: HBoxContainer
var _fight_button: Button
var _reroll_button: Button
var _ad_button: Button
var _result_panel: PanelContainer
var _result_title: Label
var _result_body: Label
var _result_button: Button
var _combat_timer: Timer


func _ready() -> void:
	catalog = UnitCatalog.load_default()
	_build_ui()
	new_run()


## 새 런을 시작한다. 시드를 주면 같은 런을 그대로 재현한다.
func new_run(run_seed: int = 0) -> void:
	if run_seed == 0:
		run_seed = randi()
	run = RunState.create(catalog, run_seed)
	sim = CombatSim.new()
	_combat_running = false
	_wrapup_active = false
	_result_panel.visible = false
	_clear_selection()
	_board.interactive = true
	_set_message("기물을 사고 아래쪽 보드에 배치한 뒤 전투를 시작하세요.")
	_refresh_all()


# --- UI 구성 ------------------------------------------------------------

func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color8(14, 23, 20)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["margin_left", "margin_right"]:
		margin.add_theme_constant_override(side, 16)
	for side in ["margin_top", "margin_bottom"]:
		margin.add_theme_constant_override(side, 14)
	add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 10)
	margin.add_child(root)

	root.add_child(_build_header())

	_message_label = Label.new()
	_message_label.add_theme_font_size_override("font_size", 22)
	_message_label.modulate = Color8(229, 220, 186)
	root.add_child(_message_label)

	_synergy_panel = SynergyPanel.new()
	root.add_child(_synergy_panel)

	root.add_child(_build_detail_panel())

	_board = BoardView.new()
	_board.board_size = RunState.BOARD
	_board.player_min_row = RunState.PLAYER_MIN_ROW
	_board.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_board.cell_pressed.connect(_on_board_cell_pressed)
	root.add_child(_board)

	root.add_child(_build_controls())
	root.add_child(_section_label("대기석"))

	_bench_row = HBoxContainer.new()
	_bench_row.add_theme_constant_override("separation", 4)
	root.add_child(_bench_row)

	root.add_child(_section_label("상점"))

	_shop_row = HBoxContainer.new()
	_shop_row.add_theme_constant_override("separation", 6)
	_shop_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(_shop_row)

	_build_result_overlay()

	_combat_timer = Timer.new()
	_combat_timer.wait_time = COMBAT_TICK_SECONDS
	_combat_timer.timeout.connect(_on_combat_tick)
	add_child(_combat_timer)


func _build_header() -> Control:
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)

	_status_label = Label.new()
	_status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_status_label.add_theme_font_size_override("font_size", 24)
	header.add_child(_status_label)

	var new_button := Button.new()
	new_button.text = "새 게임"
	new_button.pressed.connect(func() -> void: new_run())
	header.add_child(new_button)
	return header


func _build_detail_panel() -> Control:
	_detail_panel = PanelContainer.new()
	_detail_panel.visible = false
	_detail_label = Label.new()
	_detail_label.add_theme_font_size_override("font_size", 20)
	_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_panel.add_child(_detail_label)
	return _detail_panel


func _build_controls() -> Control:
	var controls := HBoxContainer.new()
	controls.add_theme_constant_override("separation", 8)

	_fight_button = Button.new()
	_fight_button.text = "전투 시작"
	_fight_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_fight_button.pressed.connect(_start_combat)
	controls.add_child(_fight_button)

	_reroll_button = Button.new()
	_reroll_button.text = "새로고침 -%d" % Shop.REROLL_COST
	_reroll_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_reroll_button.pressed.connect(_on_reroll)
	controls.add_child(_reroll_button)

	_ad_button = Button.new()
	_ad_button.text = "광고 보상"
	_ad_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_ad_button.pressed.connect(_on_ad_reward)
	controls.add_child(_ad_button)
	return controls


func _section_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 22)
	return label


func _build_result_overlay() -> void:
	var overlay := CenterContainer.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)

	_result_panel = PanelContainer.new()
	_result_panel.visible = false
	_result_panel.custom_minimum_size = Vector2(560, 0)
	overlay.add_child(_result_panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	_result_panel.add_child(box)

	_result_title = Label.new()
	_result_title.add_theme_font_size_override("font_size", 40)
	_result_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_result_title)

	_result_body = Label.new()
	_result_body.add_theme_font_size_override("font_size", 22)
	_result_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_result_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_result_body)

	_result_button = Button.new()
	_result_button.text = "다음 턴"
	_result_button.pressed.connect(_on_wrapup_continue)
	box.add_child(_result_button)


# --- 준비 단계 입력 -----------------------------------------------------

func _is_prep() -> bool:
	return not _combat_running and not _wrapup_active and not run.is_over()


func _on_board_cell_pressed(cell: Vector2i) -> void:
	if not _is_prep():
		return

	if not run.is_player_cell(cell):
		_set_message("아래쪽 절반에만 배치할 수 있습니다.")
		return

	match _selection:
		Selection.BENCH:
			_report(run.deploy(_selected_bench, cell), "배치했습니다.")
			_clear_selection()
		Selection.BOARD:
			_report(run.relocate(_selected_cell, cell), "이동했습니다.")
			_clear_selection()
		_:
			if run.board.has(cell):
				_selection = Selection.BOARD
				_selected_cell = cell
				_selected_bench = -1
				_set_message("%s 선택." % (run.board[cell] as UnitState).def.display_name)
	_refresh_all()


func _on_bench_slot_pressed(index: int) -> void:
	if not _is_prep():
		return

	if _selection == Selection.BOARD:
		_report(run.recall(_selected_cell, index), "대기석으로 옮겼습니다.")
		_clear_selection()
		_refresh_all()
		return

	if run.bench[index] == null:
		_clear_selection()
		_refresh_all()
		return

	_selection = Selection.BENCH
	_selected_bench = index
	_selected_cell = Vector2i(-1, -1)
	_set_message("%s 선택." % run.bench[index].def.display_name)
	_refresh_all()


func _on_buy(offer_index: int) -> void:
	if not _is_prep():
		return
	var unit_name := catalog.get_def(run.shop_offers[offer_index]).display_name
	var action := run.buy(offer_index)
	if action == RunState.Action.OK and not run.last_merges.is_empty():
		var merged: Dictionary = run.last_merges[-1]
		_set_message("%s 합성! ★%d가 되었습니다." % [merged["display_name"], merged["star"]])
	else:
		_report(action, "%s 구매." % unit_name)
	_refresh_all()


func _on_reroll() -> void:
	if not _is_prep():
		return
	_report(run.reroll(), "상점을 새로고침했습니다.")
	_refresh_all()


func _on_ad_reward() -> void:
	if not _is_prep():
		return
	run.watch_ad_reward()
	_set_message("광고 보상 mock: 골드 +%d." % RunState.AD_REWARD_GOLD)
	_refresh_all()


func _report(action: RunState.Action, success_message: String) -> void:
	if action == RunState.Action.OK:
		_set_message(success_message)
		return
	_set_message(str(ACTION_MESSAGES.get(action, "")))


func _clear_selection() -> void:
	_selection = Selection.NONE
	_selected_bench = -1
	_selected_cell = Vector2i(-1, -1)


func selected_unit() -> UnitState:
	match _selection:
		Selection.BENCH:
			return run.bench[_selected_bench]
		Selection.BOARD:
			return run.board.get(_selected_cell)
		_:
			return null


# --- 전투 --------------------------------------------------------------

func _start_combat() -> void:
	if not _is_prep():
		return
	if run.board.is_empty():
		_set_message("최소 1마리를 배치해야 합니다.")
		return

	var wave := AIDirector.build_wave(
		catalog, run.round_number, run.deployed_count(), RunState.BOARD, run.rng
	)
	sim = CombatSim.new()
	sim.setup(run.deployed_units(), wave, RunState.BOARD)

	_combat_running = true
	_board.interactive = false
	_clear_selection()
	_set_message("%d라운드 전투 시작." % run.round_number)
	_refresh_all()
	_combat_timer.start()


func _on_combat_tick() -> void:
	var events := sim.tick()
	_apply_events(events)
	_board.sync(_alive_units())

	if sim.is_running():
		return
	_combat_timer.stop()
	_finish_combat()


func _alive_units() -> Array[UnitState]:
	var alive: Array[UnitState] = []
	for unit in sim.units:
		if unit.is_alive():
			alive.append(unit)
	return alive


func _apply_events(events: Array[CombatEvent]) -> void:
	for event in events:
		match event.kind:
			CombatEvent.Kind.MOVE:
				_play(event.actor_uid, UnitView.Motion.STEP, event.to - event.from)
			CombatEvent.Kind.ATTACK:
				_play(event.actor_uid, UnitView.Motion.ATTACK, event.to - event.from)
			CombatEvent.Kind.DAMAGE:
				_play(event.target_uid, UnitView.Motion.HIT, Vector2i.ZERO)
			_:
				pass


func _play(uid: int, motion: UnitView.Motion, direction: Vector2i) -> void:
	var view := _board.view_for_uid(uid)
	if view != null:
		view.play(motion, direction)


func _finish_combat() -> void:
	var enemy_alive := sim.alive_count(UnitState.Team.ENEMY)
	var player_alive := sim.alive_count(UnitState.Team.PLAYER)
	var result := sim.result()
	var finished_round := run.round_number
	var rewards := run.apply_result(result, enemy_alive)

	_combat_running = false
	_show_wrapup(finished_round, result, player_alive, enemy_alive, rewards)
	_refresh_all()


func _show_wrapup(
	finished_round: int,
	result: CombatSim.Result,
	player_alive: int,
	enemy_alive: int,
	rewards: Dictionary
) -> void:
	_wrapup_active = true
	_result_panel.visible = true
	_result_title.text = _result_title_text(result)
	_result_button.text = "새 게임" if run.is_over() else "다음 턴"

	var lines: PackedStringArray = [
		"%d라운드 결과" % finished_round,
		"남은 아군 %d마리 / 남은 적 %d마리" % [player_alive, enemy_alive],
	]
	if int(rewards["gold_gain"]) > 0:
		lines.append("획득 골드 +%d" % int(rewards["gold_gain"]))
	if int(rewards["hp_loss"]) > 0:
		lines.append("체력 피해 -%d" % int(rewards["hp_loss"]))
	if run.is_over():
		lines.append("체력이 0이 되어 런이 종료되었습니다.")
	else:
		lines.append("다음 라운드: 보유 %d마리, 배치 %d마리" % [run.owned_cap(), run.deploy_cap()])
	_result_body.text = "\n".join(lines)


func _result_title_text(result: CombatSim.Result) -> String:
	match result:
		CombatSim.Result.PLAYER_WIN:
			return "승리"
		CombatSim.Result.ENEMY_WIN:
			return "패배"
		_:
			return "무승부"


func _on_wrapup_continue() -> void:
	if run.is_over():
		new_run()
		return
	_wrapup_active = false
	_result_panel.visible = false
	_board.interactive = true
	run.roll_shop()
	_clear_selection()
	_set_message("%d라운드 준비." % run.round_number)
	_refresh_all()


# --- 화면 갱신 ----------------------------------------------------------

func _refresh_all() -> void:
	_refresh_status()
	_refresh_synergy()
	_refresh_detail()
	_refresh_board()
	_refresh_bench()
	_refresh_shop()
	_refresh_buttons()


func _refresh_status() -> void:
	_status_label.text = "%d라운드  체력 %d  골드 %d\n보유 %d/%d  배치 %d/%d" % [
		run.round_number, run.player_hp, run.gold,
		run.owned_count(), run.owned_cap(),
		run.deployed_count(), run.deploy_cap(),
	]


func _refresh_detail() -> void:
	var unit := selected_unit()
	_detail_panel.visible = unit != null
	if unit == null:
		return
	_detail_label.text = "%s  ★%d   %s / %s   비용 %d\n체력 %d  공격 %d  사거리 %d  속도 %d  마나 %d\n[%s] %s\n%s" % [
		unit.def.display_name, unit.star,
		unit.def.habitat_label(), unit.def.role_label(), unit.def.cost,
		unit.max_hp, unit.attack, unit.attack_range, unit.speed, unit.max_mana,
		unit.def.skill_name, unit.def.skill_text, unit.def.trait_text,
	]


func _refresh_synergy() -> void:
	if _combat_running:
		_synergy_panel.show_for(Synergy.members_of(sim.units, UnitState.Team.PLAYER))
		return
	_synergy_panel.show_for(run.deployed_units())


func _refresh_board() -> void:
	if _combat_running:
		_board.sync(_alive_units())
		_board.set_selected_cell(Vector2i(-1, -1))
		return
	_board.sync(run.deployed_units())
	_board.set_selected_cell(_selected_cell if _selection == Selection.BOARD else Vector2i(-1, -1))


func _refresh_bench() -> void:
	for child in _bench_row.get_children():
		child.queue_free()

	for index in range(RunState.BENCH_SIZE):
		var slot := PanelContainer.new()
		slot.custom_minimum_size = Vector2(0, 84)
		slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slot.gui_input.connect(_on_bench_input.bind(index))
		_bench_row.add_child(slot)

		var unit: UnitState = run.bench[index]
		if unit == null:
			continue
		var view := UnitView.new()
		view.set_unit(unit)
		view.set_selected(_selection == Selection.BENCH and _selected_bench == index)
		view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		slot.add_child(view)


func _on_bench_input(event: InputEvent, index: int) -> void:
	if BoardView._is_primary_press(event):
		_on_bench_slot_pressed(index)


func _refresh_shop() -> void:
	for child in _shop_row.get_children():
		child.queue_free()

	for index in range(run.shop_offers.size()):
		var unit_def := catalog.get_def(run.shop_offers[index])
		var button := Button.new()
		button.text = "%s\n%s/%s\n%d골드" % [
			unit_def.display_name, unit_def.habitat_label(), unit_def.role_label(), unit_def.cost
		]
		button.add_theme_font_size_override("font_size", 20)
		button.custom_minimum_size = Vector2(0, 116)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.disabled = not _is_prep() or run.gold < unit_def.cost \
			or run.owned_count() >= run.owned_cap()
		button.pressed.connect(_on_buy.bind(index))
		_shop_row.add_child(button)


func _refresh_buttons() -> void:
	_fight_button.disabled = not _is_prep()
	_reroll_button.disabled = not _is_prep() or run.gold < Shop.REROLL_COST
	_ad_button.disabled = not _is_prep()


func _set_message(value: String) -> void:
	_message_label.text = value
