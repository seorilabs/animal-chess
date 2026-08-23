## 준비/전투 화면의 표현 계층.
##
## 게임 규칙은 RunState와 CombatSim이 들고, 여기서는 입력을 규칙에 넘기고
## 결과를 화면에 반영하는 일만 한다.
extends Control

const COMBAT_TICK_SECONDS := 0.2
## 스킬과 처치 순간에 다음 틱을 늦추는 시간.
const HITSTOP_SKILL := 0.12
const HITSTOP_DEATH := 0.18

const ACTION_MESSAGES := {
	RunState.Action.NOT_ENOUGH_GOLD: "골드가 부족합니다.",
	RunState.Action.BENCH_FULL: "대기석이 가득 찼습니다.",
	RunState.Action.OWNED_CAP_REACHED: "보유 한도에 도달했습니다. 라운드가 진행되면 한도가 늘어납니다.",
	RunState.Action.DEPLOY_CAP_REACHED: "이번 라운드 배치 한도를 넘었습니다.",
	RunState.Action.INVALID: "지금은 할 수 없는 동작입니다.",
}

enum Selection { NONE, BENCH, BOARD }

var catalog: UnitCatalog
var profile: Profile
var settings: SettingsService
var audio: AudioService
var run: RunState
var sim := CombatSim.new()

var _selection: Selection = Selection.NONE
var _selected_bench := -1
var _selected_cell := Vector2i(-1, -1)
var _combat_running := false
var _wrapup_active := false

var _hud: Hud
var _message_label: Label
var _detail_panel: PanelContainer
var _detail_label: Label
var _synergy_panel: SynergyPanel
var _board: BoardView
var _bench_row: HBoxContainer
var _shop_row: HBoxContainer
var _fight_button: Button
var _reroll_button: Button
var _preview_button: Button
var _dimmer: ColorRect
var _wrapup: WrapupSheet
var _preview: PreviewSheet
var _codex: CodexSheet
var _settings_sheet: SettingsSheet
var _combat_timer: Timer

var _reward_choices: Array[Reward] = []
var _reward_picks_left := 0
var _ad_reward_used := false


func _ready() -> void:
	catalog = UnitCatalog.load_default()
	profile = SaveService.load_profile()
	settings = SettingsService.load_settings()

	audio = AudioService.new()
	add_child(audio)
	audio.set_volumes(settings.music_volume, settings.sfx_volume)

	_build_ui()
	_resume_or_start()


## 저장된 런이 있으면 이어서, 없으면 새로 시작한다.
func _resume_or_start() -> void:
	var saved := SaveService.load_run(catalog)
	if saved == null:
		new_run()
		return
	run = saved
	_enter_prep("%s 이어하기." % run.round_status())


## 새 런을 시작한다. 시드를 주면 같은 런을 그대로 재현한다.
func new_run(run_seed: int = 0) -> void:
	if run_seed == 0:
		run_seed = randi()
	SaveService.clear_run()
	run = RunState.create(catalog, run_seed)
	_enter_prep("기물을 사고 아래쪽 보드에 배치한 뒤 전투를 시작하세요.")


## 준비 단계로 들어가며 화면 상태를 정리한다.
func _enter_prep(message: String) -> void:
	sim = CombatSim.new()
	_combat_running = false
	_wrapup_active = false
	_wrapup.visible = false
	_preview.visible = false
	_reward_choices.clear()
	_reward_picks_left = 0
	_ad_reward_used = false
	_codex.visible = false
	_settings_sheet.visible = false
	_update_dimmer()
	audio.play_bgm(AudioService.Track.PREP)
	_clear_selection()
	_board.interactive = true
	_set_message(message)
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

	_build_overlays()

	_combat_timer = Timer.new()
	_combat_timer.wait_time = COMBAT_TICK_SECONDS
	_combat_timer.timeout.connect(_on_combat_tick)
	add_child(_combat_timer)


func _build_header() -> Control:
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)

	_hud = Hud.new()
	_hud.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(_hud)

	var codex_button := Button.new()
	codex_button.text = "도감"
	codex_button.pressed.connect(_on_codex)
	header.add_child(codex_button)

	var settings_button := Button.new()
	settings_button.text = "설정"
	settings_button.pressed.connect(_on_settings)
	header.add_child(settings_button)

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

	_preview_button = Button.new()
	_preview_button.text = "상대 보기"
	_preview_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_preview_button.pressed.connect(_on_preview)
	controls.add_child(_preview_button)

	_reroll_button = Button.new()
	_reroll_button.text = "새로고침 -%d" % Shop.REROLL_COST
	_reroll_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_reroll_button.pressed.connect(_on_reroll)
	controls.add_child(_reroll_button)
	return controls


func _section_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 22)
	return label


func _build_overlays() -> void:
	_dimmer = ColorRect.new()
	_dimmer.color = Color(0, 0, 0, 0.6)
	_dimmer.visible = false
	_dimmer.mouse_filter = Control.MOUSE_FILTER_STOP
	_dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_dimmer)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	_wrapup = WrapupSheet.new()
	_wrapup.reward_chosen.connect(_on_reward_chosen)
	_wrapup.ad_requested.connect(_on_reward_ad)
	_wrapup.continue_pressed.connect(_on_wrapup_continue)
	center.add_child(_wrapup)

	_preview = PreviewSheet.new()
	_preview.closed.connect(_update_dimmer)
	center.add_child(_preview)

	_codex = CodexSheet.new()
	_codex.closed.connect(_update_dimmer)
	center.add_child(_codex)

	_settings_sheet = SettingsSheet.new()
	_settings_sheet.volumes_changed.connect(_on_volumes_changed)
	_settings_sheet.reset_requested.connect(_on_reset_data)
	_settings_sheet.closed.connect(_update_dimmer)
	center.add_child(_settings_sheet)


func _update_dimmer() -> void:
	_dimmer.visible = (
		_wrapup.visible or _preview.visible or _codex.visible or _settings_sheet.visible
	)


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
			_report(run.deploy(_selected_bench, cell), "배치했습니다.", "sfx_place")
			_clear_selection()
		Selection.BOARD:
			_report(run.relocate(_selected_cell, cell), "이동했습니다.", "sfx_place")
			_clear_selection()
		_:
			if run.board.has(cell):
				_selection = Selection.BOARD
				_selected_cell = cell
				_selected_bench = -1
				audio.play_sfx("sfx_tap")
				_set_message("%s 선택." % (run.board[cell] as UnitState).def.display_name)
	_refresh_all()


func _on_bench_slot_pressed(index: int) -> void:
	if not _is_prep():
		return

	if _selection == Selection.BOARD:
		_report(run.recall(_selected_cell, index), "대기석으로 옮겼습니다.", "sfx_place")
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
	audio.play_sfx("sfx_tap")
	_set_message("%s 선택." % run.bench[index].def.display_name)
	_refresh_all()


func _on_buy(offer_index: int) -> void:
	if not _is_prep():
		return
	var unit_name := catalog.get_def(run.shop_offers[offer_index]).display_name
	var action := run.buy(offer_index)
	if action == RunState.Action.OK and not run.last_merges.is_empty():
		var merged: Dictionary = run.last_merges[-1]
		audio.play_sfx("sfx_merge")
		_board.shake(6.0)
		_set_message("%s 합성! ★%d가 되었습니다." % [merged["display_name"], merged["star"]])
	else:
		_report(action, "%s 구매." % unit_name, "sfx_buy")
	_refresh_all()


func _on_reroll() -> void:
	if not _is_prep():
		return
	_report(run.reroll(), "상점을 새로고침했습니다.", "sfx_reroll")
	_refresh_all()


func _on_codex() -> void:
	audio.play_sfx("sfx_tap")
	_codex.open(catalog, profile)
	_update_dimmer()


func _on_settings() -> void:
	audio.play_sfx("sfx_tap")
	_settings_sheet.open(settings)
	_update_dimmer()


func _on_volumes_changed(music: float, sfx: float) -> void:
	settings.music_volume = music
	settings.sfx_volume = sfx
	settings.save()
	audio.set_volumes(music, sfx)
	audio.play_sfx("sfx_tap")


## 저장된 런과 도감 기록을 모두 지우고 새로 시작한다.
func _on_reset_data() -> void:
	SaveService.clear_all()
	profile = SaveService.load_profile()
	_settings_sheet.visible = false
	new_run()
	_set_message("저장 데이터를 초기화했습니다.")


func _on_preview() -> void:
	if _combat_running or _wrapup_active:
		return
	audio.play_sfx("sfx_tap")
	_preview.open(run)
	_update_dimmer()


func _report(
	action: RunState.Action, success_message: String, success_sfx: String = "sfx_tap"
) -> void:
	if action == RunState.Action.OK:
		audio.play_sfx(success_sfx)
		_set_message(success_message)
		return
	audio.play_sfx("sfx_denied")
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

	sim = CombatSim.new()
	sim.setup(run.deployed_units(), run.next_wave, RunState.BOARD)

	_combat_running = true
	_board.interactive = false
	audio.play_bgm(AudioService.Track.BATTLE)
	_preview.visible = false
	_update_dimmer()
	_clear_selection()
	_set_message("%s 전투 시작." % run.round_label())
	_refresh_all()
	_combat_timer.start()


func _on_combat_tick() -> void:
	# 직전 틱에서 히트스톱으로 늘려둔 간격을 되돌린다.
	_combat_timer.wait_time = COMBAT_TICK_SECONDS
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


## 시뮬레이션이 뱉은 사건을 애니메이션과 소리로 옮긴다.
## 사건 하나가 끝나기를 기다리지 않고 같은 틱에 전부 반영한다.
func _apply_events(events: Array[CombatEvent]) -> void:
	var hitstop := 0.0
	for event in events:
		match event.kind:
			CombatEvent.Kind.MOVE:
				_play(event.actor_uid, UnitView.Motion.STEP, event.to - event.from)
			CombatEvent.Kind.ATTACK:
				_play(event.actor_uid, UnitView.Motion.ATTACK, event.to - event.from)
				audio.play_sfx(_attack_sfx(event.actor_uid))
			CombatEvent.Kind.DAMAGE:
				_play(event.target_uid, UnitView.Motion.HIT, Vector2i.ZERO)
				_board.popup_damage(event.to, event.amount, _is_player(event.target_uid))
			CombatEvent.Kind.HEAL:
				_board.popup_heal(event.to, event.amount)
			CombatEvent.Kind.SKILL:
				audio.play_sfx("sfx_skill")
				_board.burst(event.to, BoardView.BurstKind.SKILL)
				_board.shake(5.0)
				hitstop = maxf(hitstop, HITSTOP_SKILL)
			CombatEvent.Kind.DEATH:
				audio.play_sfx("sfx_death")
				_board.burst(event.to, BoardView.BurstKind.DEATH)
				_board.shake(8.0)
				hitstop = maxf(hitstop, HITSTOP_DEATH)
			_:
				pass
	if hitstop > 0.0:
		# 다음 틱을 잠깐 늦춰 타격이 눈에 남게 한다.
		_combat_timer.start(COMBAT_TICK_SECONDS + hitstop)


func _is_player(uid: int) -> bool:
	var unit := sim.unit_by_uid(uid)
	return unit != null and unit.team == UnitState.Team.PLAYER


func _attack_sfx(uid: int) -> String:
	var unit := sim.unit_by_uid(uid)
	if unit != null and unit.attack_range > 1:
		return "sfx_arrow"
	return "sfx_attack"


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
	audio.play_sting(result == CombatSim.Result.PLAYER_WIN)
	if run.is_over():
		profile.record_run_end(run.outcome == RunState.Outcome.VICTORY)
		SaveService.save_profile(profile)
		SaveService.clear_run()
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

	var lines: PackedStringArray = [
		"%d라운드 결과" % finished_round,
		"남은 아군 %d마리 / 남은 적 %d마리" % [player_alive, enemy_alive],
	]
	if int(rewards["gold_gain"]) > 0:
		lines.append("획득 골드 +%d" % int(rewards["gold_gain"]))
	if int(rewards["hp_loss"]) > 0:
		lines.append("체력 피해 -%d" % int(rewards["hp_loss"]))

	_reward_choices = []
	if result == CombatSim.Result.PLAYER_WIN and not run.is_over():
		_reward_choices = Reward.roll_choices(run)
	_reward_picks_left = 1 if not _reward_choices.is_empty() else 0
	_ad_reward_used = false

	if run.is_over():
		lines.append(_run_end_text())
	else:
		lines.append("다음 라운드: 보유 %d마리, 배치 %d마리" % [run.owned_cap(), run.deploy_cap()])

	_wrapup.show_result(
		_result_title_text(result, run.outcome),
		"\n".join(lines),
		"새 게임" if run.is_over() else "다음 턴"
	)
	_wrapup.show_rewards(_reward_choices, false)
	_update_dimmer()


func _run_end_text() -> String:
	if run.outcome == RunState.Outcome.VICTORY:
		return "최종 상대를 꺾고 런을 완주했습니다."
	return "체력이 0이 되어 런이 종료되었습니다."


func _on_reward_chosen(index: int) -> void:
	if _reward_picks_left <= 0 or index < 0 or index >= _reward_choices.size():
		return
	audio.play_sfx("sfx_levelup")
	var reward := _reward_choices[index]
	if not reward.grant(run):
		_wrapup.set_body("대기석이 가득 차 기물을 받을 수 없습니다. 다른 보상을 고르세요.")
		return

	_reward_picks_left -= 1
	_reward_choices.remove_at(index)
	var remaining: Array[Reward] = []
	if _reward_picks_left > 0:
		remaining = _reward_choices
	_wrapup.show_rewards(remaining, not _ad_reward_used and not _reward_choices.is_empty())
	_wrapup.set_body("%s 을(를) 받았습니다." % reward.label)
	_refresh_all()


## 보상형 광고 mock. 실제 광고 SDK는 아직 붙어 있지 않다.
func _on_reward_ad() -> void:
	if _ad_reward_used or _reward_choices.is_empty():
		return
	_ad_reward_used = true
	_reward_picks_left += 1
	_wrapup.show_rewards(_reward_choices, false)
	_wrapup.set_body("광고 보상 mock: 하나 더 고르세요.")


func _result_title_text(result: CombatSim.Result, outcome: RunState.Outcome) -> String:
	if outcome == RunState.Outcome.VICTORY:
		return "런 완주"
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
	run.prepare_round()
	_enter_prep("%s 준비." % run.round_status())


# --- 화면 갱신 ----------------------------------------------------------

func _refresh_all() -> void:
	_sync_profile()
	_refresh_status()
	_refresh_synergy()
	_refresh_detail()
	_refresh_board()
	_refresh_bench()
	_refresh_shop()
	_refresh_buttons()


## 보유한 기물을 도감에 해금하고, 준비 단계라면 진행 상황을 저장한다.
func _sync_profile() -> void:
	var changed := false
	for unit in run.owned_units():
		if profile.unlock(unit.def.id):
			changed = true
	if run.round_number > profile.best_round:
		profile.record_round(run.round_number)
		changed = true
	if changed:
		SaveService.save_profile(profile)

	if not _combat_running and not run.is_over():
		SaveService.save_run(run)


func _refresh_status() -> void:
	_hud.show_run(run)


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
		var card := ShopCard.new(unit_def)
		card.disabled = not _is_prep() or run.gold < unit_def.cost \
			or run.owned_count() >= run.owned_cap()
		card.pressed.connect(_on_buy.bind(index))
		_shop_row.add_child(card)


func _refresh_buttons() -> void:
	_fight_button.disabled = not _is_prep()
	_preview_button.disabled = _combat_running or _wrapup_active
	_reroll_button.disabled = not _is_prep() or run.gold < Shop.REROLL_COST


func _set_message(value: String) -> void:
	_message_label.text = value
