## 화면 라우터.
##
## 카탈로그, 누적 기록, 설정, 오디오처럼 화면을 넘나드는 것들을 여기서 하나만 만들고
## 각 화면에 넘겨준다. 게임 규칙은 전혀 다루지 않는다.
extends Control

const FADE_SECONDS := 0.25

var catalog: UnitCatalog
var profile: Profile
var settings: SettingsService
var audio: AudioService

var title: TitleScreen
var game: GameScreen

var _fade: ColorRect
var _codex: CodexSheet
var _settings_sheet: SettingsSheet
var _dimmer: ColorRect


func _ready() -> void:
	catalog = UnitCatalog.load_default()
	profile = SaveService.load_profile()
	settings = SettingsService.load_settings()

	audio = AudioService.new()
	add_child(audio)
	audio.set_volumes(settings.music_volume, settings.sfx_volume)

	_build_overlays()
	show_title()


# --- 화면 전환 ----------------------------------------------------------

func show_title() -> void:
	_close_sheets()
	if game != null:
		game.queue_free()
		game = null

	if title == null:
		title = TitleScreen.new()
		title.start_requested.connect(_on_start)
		title.codex_requested.connect(_open_codex)
		title.settings_requested.connect(_open_settings)
		add_child(title)
		move_child(title, 0)

	title.show_profile(profile, SaveService.has_run())
	title.visible = true
	audio.play_bgm(AudioService.Track.TITLE)
	_fade_in()


func show_game(resume: bool) -> void:
	_close_sheets()
	if title != null:
		title.visible = false

	game = GameScreen.new()
	game.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	game.home_requested.connect(_on_home)
	add_child(game)
	move_child(game, 0)
	game.setup(catalog, profile, settings, audio, resume)
	_fade_in()


func _on_start(resume: bool) -> void:
	audio.play_sfx("sfx_tap")
	show_game(resume)


func _on_home() -> void:
	# 홈으로 나가도 진행 중인 런은 저장되어 있으므로 이어할 수 있다.
	profile = SaveService.load_profile()
	show_title()


# --- 공용 시트 ----------------------------------------------------------

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

	_codex = CodexSheet.new()
	_codex.closed.connect(_update_dimmer)
	center.add_child(_codex)

	_settings_sheet = SettingsSheet.new()
	_settings_sheet.volumes_changed.connect(_on_volumes_changed)
	_settings_sheet.reset_requested.connect(_on_reset_data)
	_settings_sheet.closed.connect(_update_dimmer)
	center.add_child(_settings_sheet)

	_fade = ColorRect.new()
	_fade.color = Color(0.043, 0.078, 0.063, 0.0)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_fade)


func _open_codex() -> void:
	audio.play_sfx("sfx_tap")
	_codex.open(catalog, profile)
	_update_dimmer()


func _open_settings() -> void:
	audio.play_sfx("sfx_tap")
	_settings_sheet.open(settings)
	_update_dimmer()


func _close_sheets() -> void:
	if _codex != null:
		_codex.visible = false
	if _settings_sheet != null:
		_settings_sheet.visible = false
	_update_dimmer()


func _update_dimmer() -> void:
	_dimmer.visible = _codex.visible or _settings_sheet.visible


func _on_volumes_changed(music: float, sfx: float) -> void:
	settings.music_volume = music
	settings.sfx_volume = sfx
	settings.save()
	audio.set_volumes(music, sfx)
	audio.play_sfx("sfx_tap")


## 저장된 런과 도감 기록을 모두 지우고 첫 화면으로 돌아간다.
func _on_reset_data() -> void:
	SaveService.clear_all()
	profile = SaveService.load_profile()
	show_title()


func _fade_in() -> void:
	_fade.color.a = 1.0
	create_tween().tween_property(_fade, "color:a", 0.0, FADE_SECONDS)
