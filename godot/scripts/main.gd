extends Control

const UnitPieceScene := preload("res://scripts/unit_piece.gd")

const BOARD_W := 8
const BOARD_H := 8
const SHOP_SIZE := 5
const BENCH_SIZE := 8
const PLAYER_MIN_ROW := 4
const MAX_COMBAT_TICKS := 180
const COMBAT_TICK_SECONDS := 0.34
const ATTACK_ANIM_MS := 300
const HIT_ANIM_MS := 260
const STEP_ANIM_MS := 280

var catalog: Dictionary = {}
var unit_ids: Array = []
var shop_offers: Array = []
var bench: Array = []
var player_board: Dictionary = {}
var battle_units: Array = []
var combat_tick_count := 0

var round_number := 1
var player_hp := 20
var gold := 10
var next_uid := 1
var selected_source := ""
var selected_index := -1
var selected_key := ""
var combat_running := false
var wrapup_active := false

var status_label: Label
var message_label: Label
var result_panel: PanelContainer
var result_title_label: Label
var result_body_label: Label
var result_continue_button: Button
var detail_panel: PanelContainer
var detail_label: Label
var board_grid: GridContainer
var bench_grid: GridContainer
var shop_box: HBoxContainer
var fight_button: Button
var reroll_button: Button
var ad_button: Button
var board_cells: Array = []
var bench_cells: Array = []
var combat_timer: Timer


func _ready() -> void:
	randomize()
	_apply_korean_theme()
	_build_catalog()
	_build_ui()
	_new_run()


func _apply_korean_theme() -> void:
	var korean_font := SystemFont.new()
	korean_font.font_names = PackedStringArray([
		"Apple SD Gothic Neo",
		"Noto Sans CJK KR",
		"Noto Sans KR",
		"Malgun Gothic",
		"Arial Unicode MS"
	])
	var korean_theme := Theme.new()
	korean_theme.default_font = korean_font
	theme = korean_theme


func _build_catalog() -> void:
	catalog = {
		"turtle": {
			"name": "거북",
			"habitat": "늪",
			"role": "방어",
			"cost": 1,
			"hp": 34,
			"atk": 4,
			"range": 1,
			"speed": 1,
			"skill": "등껍질 보호막",
			"trait": "전열에서 오래 버티며 아군 후열이 공격할 시간을 벌어줍니다."
		},
		"rabbit": {
			"name": "토끼",
			"habitat": "초원",
			"role": "지원",
			"cost": 1,
			"hp": 20,
			"atk": 3,
			"range": 2,
			"speed": 3,
			"skill": "당근 응원",
			"trait": "아군 공격 속도를 끌어올리는 초반 지원 기물입니다."
		},
		"sparrow": {
			"name": "참새",
			"habitat": "하늘",
			"role": "사냥꾼",
			"cost": 1,
			"hp": 18,
			"atk": 5,
			"range": 3,
			"speed": 3,
			"skill": "빠른 쪼기",
			"trait": "후열에서 안정적으로 피해를 누적하는 원거리 딜러입니다."
		},
		"frog": {
			"name": "개구리",
			"habitat": "늪",
			"role": "주술",
			"cost": 1,
			"hp": 22,
			"atk": 3,
			"range": 2,
			"speed": 2,
			"skill": "독 방울",
			"trait": "독으로 체력이 높은 적을 천천히 깎는 주술 기물입니다."
		},
		"fox": {
			"name": "여우",
			"habitat": "숲",
			"role": "교란",
			"cost": 2,
			"hp": 24,
			"atk": 7,
			"range": 1,
			"speed": 4,
			"skill": "후방 기습",
			"trait": "체력이 낮은 적을 노리기 쉬운 교란형 근접 기물입니다."
		},
		"wolf": {
			"name": "늑대",
			"habitat": "초원",
			"role": "돌격",
			"cost": 2,
			"hp": 30,
			"atk": 6,
			"range": 1,
			"speed": 3,
			"skill": "무리 물기",
			"trait": "초원/늑대 조합에서 공격력이 살아나는 돌격 기물입니다."
		},
		"penguin": {
			"name": "펭귄",
			"habitat": "극지",
			"role": "주술",
			"cost": 2,
			"hp": 24,
			"atk": 4,
			"range": 2,
			"speed": 2,
			"skill": "빙판",
			"trait": "적 행동을 늦춰 전투 흐름을 제어하는 극지 주술 기물입니다."
		},
		"bear": {
			"name": "곰",
			"habitat": "숲",
			"role": "돌격",
			"cost": 3,
			"hp": 44,
			"atk": 8,
			"range": 1,
			"speed": 1,
			"skill": "앞발 휩쓸기",
			"trait": "느리지만 전열을 크게 흔드는 광역 돌격 기물입니다."
		}
	}
	unit_ids = catalog.keys()


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color8(21, 31, 28)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 8)
	margin.add_child(root)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	root.add_child(header)

	status_label = Label.new()
	status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_label.add_theme_font_size_override("font_size", 14)
	header.add_child(status_label)

	var new_button := Button.new()
	new_button.text = "새 게임"
	new_button.pressed.connect(_new_run)
	header.add_child(new_button)

	message_label = Label.new()
	message_label.add_theme_font_size_override("font_size", 13)
	message_label.modulate = Color8(229, 220, 186)
	root.add_child(message_label)

	result_panel = PanelContainer.new()
	result_panel.visible = false
	result_panel.add_theme_stylebox_override("panel", _panel_style(Color8(48, 55, 50), Color8(244, 211, 94)))
	root.add_child(result_panel)

	var result_box := VBoxContainer.new()
	result_box.add_theme_constant_override("separation", 5)
	result_panel.add_child(result_box)

	result_title_label = Label.new()
	result_title_label.add_theme_font_size_override("font_size", 18)
	result_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_box.add_child(result_title_label)

	result_body_label = Label.new()
	result_body_label.add_theme_font_size_override("font_size", 13)
	result_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_box.add_child(result_body_label)

	result_continue_button = Button.new()
	result_continue_button.text = "다음 턴"
	result_continue_button.pressed.connect(_on_wrapup_continue)
	result_box.add_child(result_continue_button)

	detail_panel = PanelContainer.new()
	detail_panel.add_theme_stylebox_override("panel", _panel_style(Color8(31, 42, 37), Color8(80, 104, 91)))
	root.add_child(detail_panel)

	detail_label = Label.new()
	detail_label.add_theme_font_size_override("font_size", 12)
	detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_panel.add_child(detail_label)

	board_grid = GridContainer.new()
	board_grid.columns = BOARD_W
	board_grid.add_theme_constant_override("h_separation", 2)
	board_grid.add_theme_constant_override("v_separation", 2)
	board_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(board_grid)

	for y in range(BOARD_H):
		for x in range(BOARD_W):
			var cell := PanelContainer.new()
			cell.custom_minimum_size = Vector2(52, 52)
			cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			cell.size_flags_vertical = Control.SIZE_EXPAND_FILL
			cell.gui_input.connect(_on_board_cell_input.bind(x, y))
			board_grid.add_child(cell)
			board_cells.append(cell)

	var controls := HBoxContainer.new()
	controls.add_theme_constant_override("separation", 8)
	root.add_child(controls)

	fight_button = Button.new()
	fight_button.text = "전투 시작"
	fight_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fight_button.pressed.connect(_start_combat)
	controls.add_child(fight_button)

	reroll_button = Button.new()
	reroll_button.text = "새로고침 -2"
	reroll_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reroll_button.pressed.connect(_reroll_shop)
	controls.add_child(reroll_button)

	ad_button = Button.new()
	ad_button.text = "광고 보상"
	ad_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ad_button.pressed.connect(_mock_rewarded_ad)
	controls.add_child(ad_button)

	var bench_label := Label.new()
	bench_label.text = "대기석"
	bench_label.add_theme_font_size_override("font_size", 14)
	root.add_child(bench_label)

	bench_grid = GridContainer.new()
	bench_grid.columns = BENCH_SIZE
	bench_grid.add_theme_constant_override("h_separation", 2)
	bench_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(bench_grid)

	for i in range(BENCH_SIZE):
		var slot := PanelContainer.new()
		slot.custom_minimum_size = Vector2(52, 52)
		slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slot.gui_input.connect(_on_bench_input.bind(i))
		bench_grid.add_child(slot)
		bench_cells.append(slot)

	var shop_label := Label.new()
	shop_label.text = "상점"
	shop_label.add_theme_font_size_override("font_size", 14)
	root.add_child(shop_label)

	shop_box = HBoxContainer.new()
	shop_box.add_theme_constant_override("separation", 4)
	shop_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(shop_box)

	combat_timer = Timer.new()
	combat_timer.wait_time = COMBAT_TICK_SECONDS
	combat_timer.timeout.connect(_combat_tick)
	add_child(combat_timer)


func _new_run() -> void:
	round_number = 1
	player_hp = 20
	gold = 10
	next_uid = 1
	selected_source = ""
	selected_index = -1
	selected_key = ""
	combat_running = false
	wrapup_active = false
	if result_panel != null:
		result_panel.visible = false
	player_board.clear()
	battle_units.clear()
	bench.clear()
	for _i in range(BENCH_SIZE):
		bench.append({})
	_roll_shop_free()
	_set_message("기물을 사고 아래쪽 보드에 배치한 뒤 전투를 시작하세요.")
	_refresh_all()


func _make_unit(id: String, team: String) -> Dictionary:
	var base: Dictionary = catalog[id]
	var unit := {
		"uid": next_uid,
		"id": id,
		"team": team,
		"name": base["name"],
		"habitat": base["habitat"],
		"role": base["role"],
		"cost": base["cost"],
		"star": 1,
		"max_hp": base["hp"],
		"hp": base["hp"],
		"atk": base["atk"],
		"range": base["range"],
		"speed": base["speed"],
		"cooldown": 0,
		"x": 0,
		"y": 0,
		"status": {},
		"anim_kind": "",
		"anim_start_ms": 0,
		"anim_duration_ms": 1,
		"anim_dx": 0,
		"anim_dy": 0
	}
	next_uid += 1
	return unit


func _clone_unit(source: Dictionary) -> Dictionary:
	var clone := source.duplicate(true)
	clone["hp"] = clone["max_hp"]
	clone["cooldown"] = 0
	clone["status"] = {}
	_clear_unit_anim(clone)
	return clone


func _roll_shop_free() -> void:
	shop_offers.clear()
	for _i in range(SHOP_SIZE):
		shop_offers.append(_random_shop_unit())


func _random_shop_unit() -> String:
	var pool: Array = ["turtle", "rabbit", "sparrow", "frog"]
	if round_number >= 2:
		pool.append_array(["fox", "wolf", "penguin"])
	if round_number >= 4:
		pool.append("bear")
	return str(pool[randi() % pool.size()])


func _reroll_shop() -> void:
	if combat_running or wrapup_active:
		return
	if gold < 2:
		_set_message("골드가 부족합니다.")
		return
	gold -= 2
	_roll_shop_free()
	_set_message("상점을 새로고침했습니다.")
	_refresh_all()


func _mock_rewarded_ad() -> void:
	if combat_running or wrapup_active:
		return
	gold += 3
	_set_message("광고 보상 mock: 골드 +3.")
	_refresh_all()


func _buy_offer(index: int) -> void:
	if combat_running or wrapup_active or index < 0 or index >= shop_offers.size():
		return
	if _owned_count() >= _owned_cap():
		_set_message("보유 한도에 도달했습니다. 라운드가 진행되면 한도가 늘어납니다.")
		return
	var id := str(shop_offers[index])
	var cost := int(catalog[id]["cost"])
	if gold < cost:
		_set_message("골드가 부족합니다.")
		return
	var slot := _first_empty_bench_slot()
	if slot == -1:
		_set_message("대기석이 가득 찼습니다.")
		return
	gold -= cost
	bench[slot] = _make_unit(id, "player")
	shop_offers[index] = _random_shop_unit()
	_set_message("%s 구매." % catalog[id]["name"])
	_refresh_all()


func _first_empty_bench_slot() -> int:
	for i in range(bench.size()):
		if Dictionary(bench[i]).is_empty():
			return i
	return -1


func _on_bench_input(event: InputEvent, index: int) -> void:
	if not _is_primary_click(event) or combat_running or wrapup_active:
		return
	if selected_source == "board" and Dictionary(bench[index]).is_empty():
		bench[index] = player_board[selected_key]
		player_board.erase(selected_key)
		_clear_selection()
		_set_message("기물을 대기석으로 옮겼습니다.")
		_refresh_all()
		return
	if Dictionary(bench[index]).is_empty():
		_clear_selection()
		_refresh_all()
		return
	selected_source = "bench"
	selected_index = index
	selected_key = ""
	_set_message("%s 선택." % bench[index]["name"])
	_refresh_all()


func _on_board_cell_input(event: InputEvent, x: int, y: int) -> void:
	if not _is_primary_click(event) or combat_running or wrapup_active:
		return
	var key := _cell_key(x, y)
	if y < PLAYER_MIN_ROW:
		_set_message("아래쪽 절반에만 배치할 수 있습니다.")
		return
	if selected_source == "bench":
		if Dictionary(bench[selected_index]).is_empty():
			_clear_selection()
			_refresh_all()
			return
		if not player_board.has(key) and _deployed_count() >= _deploy_cap():
			_set_message("이번 라운드 배치 한도는 %d마리입니다." % _deploy_cap())
			return
		var unit: Dictionary = bench[selected_index]
		if player_board.has(key):
			bench[selected_index] = player_board[key]
		else:
			bench[selected_index] = {}
		unit["x"] = x
		unit["y"] = y
		player_board[key] = unit
		_clear_selection()
		_set_message("%s 배치." % unit["name"])
		_refresh_all()
		return
	if selected_source == "board":
		if not player_board.has(selected_key):
			_clear_selection()
			_refresh_all()
			return
		var moving: Dictionary = player_board[selected_key]
		player_board.erase(selected_key)
		if player_board.has(key):
			var swapped: Dictionary = player_board[key]
			swapped["x"] = int(selected_key.split(",")[0])
			swapped["y"] = int(selected_key.split(",")[1])
			player_board[selected_key] = swapped
		moving["x"] = x
		moving["y"] = y
		player_board[key] = moving
		_clear_selection()
		_set_message("%s 이동." % moving["name"])
		_refresh_all()
		return
	if player_board.has(key):
		selected_source = "board"
		selected_key = key
		selected_index = -1
		_set_message("%s 선택." % player_board[key]["name"])
		_refresh_all()


func _is_primary_click(event: InputEvent) -> bool:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		return mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT
	if event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		return touch_event.pressed
	return false


func _start_combat() -> void:
	if combat_running:
		return
	if wrapup_active:
		_set_message("라운드 결과를 확인한 뒤 다음 턴으로 진행하세요.")
		return
	if player_hp <= 0:
		_set_message("게임이 끝났습니다. 새 게임을 시작하세요.")
		return
	if player_board.is_empty():
		_set_message("최소 1마리를 배치해야 합니다.")
		return
	combat_running = true
	_clear_selection()
	combat_tick_count = 0
	battle_units.clear()
	for key in player_board.keys():
		var unit := _clone_unit(player_board[key])
		unit["team"] = "player"
		battle_units.append(unit)
	for enemy in _generate_ai_wave():
		battle_units.append(enemy)
	_apply_team_bonuses()
	_set_message("%d라운드 전투 시작." % round_number)
	_refresh_all()
	combat_timer.start()


func _generate_ai_wave() -> Array:
	var enemies: Array = []
	var count: int = _deployed_count()
	if count < 1:
		count = 1
	if count > _deploy_cap():
		count = _deploy_cap()
	var pool: Array = ["turtle", "sparrow", "frog"]
	if round_number >= 2:
		pool.append_array(["wolf", "penguin"])
	if round_number >= 3:
		pool.append("fox")
	if round_number >= 5:
		pool.append("bear")

	for i in range(count):
		var id := str(pool[(i + round_number + randi()) % pool.size()])
		var enemy := _make_unit(id, "enemy")
		enemy["x"] = (i * 2 + round_number) % BOARD_W
		enemy["y"] = int(i / 4)
		if int(enemy["y"]) > 3:
			enemy["y"] = 3
		enemies.append(enemy)
	return enemies


func _apply_team_bonuses() -> void:
	for team in ["player", "enemy"]:
		var habitats := {}
		var wolves := 0
		var rabbits := 0
		for unit in battle_units:
			if unit["team"] != team:
				continue
			var habitat := str(unit["habitat"])
			habitats[habitat] = int(habitats.get(habitat, 0)) + 1
			if unit["id"] == "wolf":
				wolves += 1
			if unit["id"] == "rabbit":
				rabbits += 1

		for unit in battle_units:
			if unit["team"] != team:
				continue
			if int(habitats.get(str(unit["habitat"]), 0)) >= 2:
				unit["atk"] = int(unit["atk"]) + 1
			if unit["id"] == "turtle":
				unit["max_hp"] = int(unit["max_hp"]) + 6
				unit["hp"] = int(unit["hp"]) + 6
			if unit["id"] == "wolf" and wolves >= 2:
				unit["atk"] = int(unit["atk"]) + 2
			if rabbits > 0 and unit["id"] != "rabbit":
				unit["speed"] = int(unit["speed"]) + 1


func _combat_tick() -> void:
	combat_tick_count += 1
	_apply_dot_damage()
	for unit in battle_units:
		if int(unit["hp"]) <= 0:
			continue
		if int(unit["cooldown"]) > 0:
			unit["cooldown"] = int(unit["cooldown"]) - 1
			continue
		var target := _choose_target(unit)
		if target.is_empty():
			continue
		var dist := _distance(unit, target)
		if dist <= int(unit["range"]):
			_attack(unit, target)
			unit["cooldown"] = max(2, 6 - int(unit["speed"]))
		else:
			_move_toward(unit, target)
			unit["cooldown"] = max(1, 4 - int(unit["speed"] / 2))
	_cleanup_dead_units()
	_refresh_board()
	if _combat_has_ended() or combat_tick_count >= MAX_COMBAT_TICKS:
		_finish_combat()


func _apply_dot_damage() -> void:
	for unit in battle_units:
		if int(unit["hp"]) <= 0:
			continue
		var status: Dictionary = unit["status"]
		var poison := int(status.get("poison", 0))
		if poison > 0:
			unit["hp"] = int(unit["hp"]) - 1
			status["poison"] = poison - 1
			_set_anim(unit, "hit", 0, 0, HIT_ANIM_MS)


func _choose_target(unit: Dictionary) -> Dictionary:
	var best := {}
	var best_score := 9999
	for target in battle_units:
		if int(target["hp"]) <= 0 or target["team"] == unit["team"]:
			continue
		var score := _distance(unit, target) * 10 + int(target["hp"])
		if unit["id"] == "fox":
			score = int(target["hp"]) * 3 + _distance(unit, target)
		if score < best_score:
			best_score = score
			best = target
	return best


func _distance(a: Dictionary, b: Dictionary) -> int:
	return abs(int(a["x"]) - int(b["x"])) + abs(int(a["y"]) - int(b["y"]))


func _attack(attacker: Dictionary, target: Dictionary) -> void:
	var damage := int(attacker["atk"]) + int(attacker["star"]) - 1
	var dx := signi(int(target["x"]) - int(attacker["x"]))
	var dy := signi(int(target["y"]) - int(attacker["y"]))
	_set_anim(attacker, "attack", dx, dy, ATTACK_ANIM_MS)
	target["hp"] = int(target["hp"]) - damage
	_set_anim(target, "hit", dx, dy, HIT_ANIM_MS)

	match str(attacker["id"]):
		"frog":
			var status: Dictionary = target["status"]
			status["poison"] = max(int(status.get("poison", 0)), 3)
		"penguin":
			target["cooldown"] = int(target["cooldown"]) + 1
		"bear":
			var splash_damage: int = int(damage / 2)
			if splash_damage < 1:
				splash_damage = 1
			_splash_damage(attacker, target, splash_damage)


func _splash_damage(attacker: Dictionary, target: Dictionary, amount: int) -> void:
	for other in battle_units:
		if int(other["hp"]) <= 0 or other["team"] == attacker["team"] or other == target:
			continue
		if _distance(target, other) <= 1:
			other["hp"] = int(other["hp"]) - amount
			var dx := signi(int(other["x"]) - int(attacker["x"]))
			var dy := signi(int(other["y"]) - int(attacker["y"]))
			_set_anim(other, "hit", dx, dy, HIT_ANIM_MS)


func _move_toward(unit: Dictionary, target: Dictionary) -> void:
	var dx := signi(int(target["x"]) - int(unit["x"]))
	var dy := signi(int(target["y"]) - int(unit["y"]))
	var options: Array = []
	if abs(int(target["x"]) - int(unit["x"])) >= abs(int(target["y"]) - int(unit["y"])):
		options.append(Vector2i(int(unit["x"]) + dx, int(unit["y"])))
		options.append(Vector2i(int(unit["x"]), int(unit["y"]) + dy))
	else:
		options.append(Vector2i(int(unit["x"]), int(unit["y"]) + dy))
		options.append(Vector2i(int(unit["x"]) + dx, int(unit["y"])))

	for pos in options:
		if _is_board_pos_free(pos.x, pos.y):
			var step_dx: int = pos.x - int(unit["x"])
			var step_dy: int = pos.y - int(unit["y"])
			unit["x"] = pos.x
			unit["y"] = pos.y
			_set_anim(unit, "step", step_dx, step_dy, STEP_ANIM_MS)
			return


func _is_board_pos_free(x: int, y: int) -> bool:
	if x < 0 or x >= BOARD_W or y < 0 or y >= BOARD_H:
		return false
	for unit in battle_units:
		if int(unit["hp"]) > 0 and int(unit["x"]) == x and int(unit["y"]) == y:
			return false
	return true


func _cleanup_dead_units() -> void:
	for unit in battle_units:
		if int(unit["hp"]) < 0:
			unit["hp"] = 0


func _combat_has_ended() -> bool:
	return _count_alive("player") == 0 or _count_alive("enemy") == 0


func _finish_combat() -> void:
	combat_timer.stop()
	var finished_round := round_number
	var player_alive := _count_alive("player")
	var enemy_alive := _count_alive("enemy")
	var won := player_alive >= enemy_alive
	var gold_gain := 0
	var hp_loss := 0
	if won:
		gold_gain = 5 + min(4, round_number)
		gold += gold_gain
		round_number += 1
		_set_message("승리. 골드를 획득했습니다.")
	else:
		var damage: int = enemy_alive
		if damage < 2:
			damage = 2
		hp_loss = damage
		player_hp -= hp_loss
		round_number += 1
		if player_hp <= 0:
			player_hp = 0
			_set_message("패배. 게임 종료.")
		else:
			_set_message("패배. 체력 %d 감소." % hp_loss)
	combat_running = false
	battle_units.clear()
	_show_round_wrapup(finished_round, won, player_alive, enemy_alive, gold_gain, hp_loss)
	_refresh_all()


func _show_round_wrapup(finished_round: int, won: bool, player_alive: int, enemy_alive: int, gold_gain: int, hp_loss: int) -> void:
	wrapup_active = true
	result_panel.visible = true
	result_title_label.text = "승리" if won else "패배"
	result_continue_button.text = "새 게임" if player_hp <= 0 else "다음 턴"

	var lines: Array = []
	lines.append("%d라운드 결과" % finished_round)
	lines.append("남은 아군 %d마리 / 남은 적 %d마리" % [player_alive, enemy_alive])
	if won:
		lines.append("획득 골드 +%d" % gold_gain)
	else:
		lines.append("체력 피해 -%d" % hp_loss)
	if player_hp > 0:
		lines.append("다음 라운드: 보유 %d마리, 배치 %d마리" % [_owned_cap(), _deploy_cap()])
	else:
		lines.append("체력이 0이 되어 런이 종료되었습니다.")
	result_body_label.text = "\n".join(lines)


func _on_wrapup_continue() -> void:
	if player_hp <= 0:
		_new_run()
		return
	wrapup_active = false
	result_panel.visible = false
	_roll_shop_free()
	_clear_selection()
	_set_message("%d라운드 준비. AI도 배치 수는 동일하게 시작합니다." % round_number)
	_refresh_all()


func _count_alive(team: String) -> int:
	var count := 0
	for unit in battle_units:
		if unit["team"] == team and int(unit["hp"]) > 0:
			count += 1
	return count


func _refresh_all() -> void:
	_refresh_status()
	_refresh_detail()
	_refresh_board()
	_refresh_bench()
	_refresh_shop()
	_refresh_buttons()


func _refresh_status() -> void:
	status_label.text = "%d라운드  체력 %d  골드 %d\n보유 %d/%d  배치 %d/%d" % [
		round_number,
		player_hp,
		gold,
		_owned_count(),
		_owned_cap(),
		_deployed_count(),
		_deploy_cap()
	]


func _refresh_detail() -> void:
	var unit := _selected_unit()
	if unit.is_empty():
		detail_label.text = "선택 정보\n없음"
		return
	detail_label.text = _format_unit_detail(unit)


func _selected_unit() -> Dictionary:
	if selected_source == "bench" and selected_index >= 0 and selected_index < bench.size():
		if not Dictionary(bench[selected_index]).is_empty():
			return bench[selected_index]
	if selected_source == "board" and player_board.has(selected_key):
		return player_board[selected_key]
	return {}


func _format_unit_detail(unit: Dictionary) -> String:
	return "%s  ★%d\n%s / %s  비용 %d\n체력 %d  공격 %d  사거리 %d  속도 %d\n기술: %s\n특성: %s" % [
		unit["name"],
		unit["star"],
		unit["habitat"],
		unit["role"],
		unit["cost"],
		unit["max_hp"],
		unit["atk"],
		unit["range"],
		unit["speed"],
		unit["skill"],
		unit.get("trait", "")
	]


func _refresh_buttons() -> void:
	fight_button.disabled = combat_running or wrapup_active or player_hp <= 0
	reroll_button.disabled = combat_running or wrapup_active or gold < 2
	ad_button.disabled = combat_running or wrapup_active


func _refresh_board() -> void:
	for y in range(BOARD_H):
		for x in range(BOARD_W):
			var idx := y * BOARD_W + x
			var cell: PanelContainer = board_cells[idx]
			for child in cell.get_children():
				child.queue_free()
			cell.add_theme_stylebox_override("panel", _cell_style(x, y))
			var unit := _unit_at_board_pos(x, y)
			if not unit.is_empty():
				var piece = UnitPieceScene.new()
				piece.set_unit(unit)
				piece.set_selected((selected_source == "board" and selected_key == _cell_key(x, y)) and not combat_running)
				piece.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
				cell.add_child(piece)


func _refresh_bench() -> void:
	for i in range(BENCH_SIZE):
		var slot: PanelContainer = bench_cells[i]
		for child in slot.get_children():
			child.queue_free()
		var selected := selected_source == "bench" and selected_index == i
		slot.add_theme_stylebox_override("panel", _panel_style(Color8(39, 48, 43), Color8(244, 211, 94) if selected else Color8(80, 96, 84)))
		if not Dictionary(bench[i]).is_empty():
			var bench_piece = UnitPieceScene.new()
			bench_piece.set_unit(bench[i])
			bench_piece.set_selected(selected)
			bench_piece.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			slot.add_child(bench_piece)


func _refresh_shop() -> void:
	for child in shop_box.get_children():
		child.queue_free()
	for i in range(shop_offers.size()):
		var id := str(shop_offers[i])
		var base: Dictionary = catalog[id]
		var button := Button.new()
		button.text = "%s\n%s/%s\n%d골드" % [base["name"], base["habitat"], base["role"], base["cost"]]
		button.custom_minimum_size = Vector2(84, 68)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.disabled = combat_running or wrapup_active or gold < int(base["cost"]) or _owned_count() >= _owned_cap()
		button.pressed.connect(_buy_offer.bind(i))
		shop_box.add_child(button)


func _unit_at_board_pos(x: int, y: int) -> Dictionary:
	if combat_running:
		for unit in battle_units:
			if int(unit["hp"]) > 0 and int(unit["x"]) == x and int(unit["y"]) == y:
				return unit
		return {}
	var key := _cell_key(x, y)
	if player_board.has(key):
		return player_board[key]
	return {}


func _cell_style(x: int, y: int) -> StyleBoxFlat:
	var base := Color8(42, 63, 48) if (x + y) % 2 == 0 else Color8(36, 55, 43)
	if y < PLAYER_MIN_ROW:
		base = Color8(55, 46, 50) if (x + y) % 2 == 0 else Color8(48, 39, 44)
	var border := Color8(72, 91, 72)
	if not combat_running and y >= PLAYER_MIN_ROW:
		border = Color8(79, 142, 92)
	return _panel_style(base, border)


func _panel_style(bg: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(1)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	return style


func _cell_key(x: int, y: int) -> String:
	return "%d,%d" % [x, y]


func _set_anim(unit: Dictionary, kind: String, dx: int, dy: int, duration_ms: int) -> void:
	unit["anim_kind"] = kind
	unit["anim_start_ms"] = Time.get_ticks_msec()
	unit["anim_duration_ms"] = duration_ms
	unit["anim_dx"] = dx
	unit["anim_dy"] = dy


func _clear_unit_anim(unit: Dictionary) -> void:
	unit["anim_kind"] = ""
	unit["anim_start_ms"] = 0
	unit["anim_duration_ms"] = 1
	unit["anim_dx"] = 0
	unit["anim_dy"] = 0


func _owned_count() -> int:
	var count := _deployed_count()
	for unit in bench:
		if not Dictionary(unit).is_empty():
			count += 1
	return count


func _deployed_count() -> int:
	return player_board.size()


func _owned_cap() -> int:
	if round_number <= 1:
		return 4
	if round_number == 2:
		return 5
	if round_number == 3:
		return 6
	if round_number <= 4:
		return 7
	if round_number <= 6:
		return 8
	if round_number <= 8:
		return 10
	return 12


func _deploy_cap() -> int:
	if round_number <= 1:
		return 2
	if round_number == 2:
		return 3
	if round_number == 3:
		return 4
	if round_number <= 5:
		return 5
	if round_number <= 7:
		return 6
	if round_number <= 9:
		return 7
	return 8


func _clear_selection() -> void:
	selected_source = ""
	selected_index = -1
	selected_key = ""


func _set_message(value: String) -> void:
	message_label.text = value


func signi(value: int) -> int:
	if value < 0:
		return -1
	if value > 0:
		return 1
	return 0
