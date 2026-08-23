## 배경음과 효과음 재생. 씬 트리에 하나만 두고 쓴다.
##
## 볼륨은 SettingsService가 들고 있고 여기서는 재생만 맡는다.
class_name AudioService
extends Node

enum Track { NONE, TITLE, PREP, BATTLE }

const BGM_PATHS := {
	Track.TITLE: "res://assets/audio/bgm_title.ogg",
	Track.PREP: "res://assets/audio/bgm_prep.ogg",
	Track.BATTLE: "res://assets/audio/bgm_battle.ogg",
}

const SFX_DIR := "res://assets/audio/sfx"
const STING_WIN := "res://assets/audio/sting_win.wav"
const STING_LOSE := "res://assets/audio/sting_lose.wav"

## 같은 효과음이 한 틱에 몰릴 때 겹쳐 터지지 않도록 재생기를 돌려 쓴다.
const SFX_VOICES := 8
## 같은 효과음이 이 간격 안에 다시 오면 무시한다. 광역 스킬에서 소리가 뭉치는 것을 막는다.
const SFX_MIN_GAP_MS := 40
const BGM_FADE_SECONDS := 0.6

var _bgm_players: Array[AudioStreamPlayer] = []
var _bgm_active := 0
var _current_track: Track = Track.NONE

var _sfx_players: Array[AudioStreamPlayer] = []
var _sfx_next := 0
var _sfx_cache: Dictionary = {}
var _last_played_ms: Dictionary = {}

var _music_volume := 1.0
var _sfx_volume := 1.0
var _fade_tween: Tween
## headless에는 오디오 출력이 없다. 재생을 시도하면 종료 시 스트림이 정리되지 않는다.
var _enabled := true


func _ready() -> void:
	_enabled = DisplayServer.get_name() != "headless"
	for _i in range(2):
		var player := AudioStreamPlayer.new()
		add_child(player)
		_bgm_players.append(player)
	for _i in range(SFX_VOICES):
		var player := AudioStreamPlayer.new()
		add_child(player)
		_sfx_players.append(player)


## 종료할 때 스트림 참조를 놓아준다. 재생 중인 채로 트리가 끝나면
## Godot이 "resources still in use at exit" 오류를 남긴다.
func _exit_tree() -> void:
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	for player in _bgm_players + _sfx_players:
		player.stop()
		player.stream = null
	_sfx_cache.clear()
	_current_track = Track.NONE


func set_volumes(music: float, sfx: float) -> void:
	_music_volume = clampf(music, 0.0, 1.0)
	_sfx_volume = clampf(sfx, 0.0, 1.0)
	var current := _bgm_players[_bgm_active]
	if current.playing:
		current.volume_db = _linear_to_db(_music_volume)


## 이미 같은 곡이 흐르고 있으면 아무것도 하지 않는다.
func play_bgm(track: Track) -> void:
	if not _enabled or track == _current_track:
		return
	_current_track = track

	var previous := _bgm_players[_bgm_active]
	_bgm_active = 1 - _bgm_active
	var next := _bgm_players[_bgm_active]

	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	_fade_tween = create_tween().set_parallel(true)

	if previous.playing:
		_fade_tween.tween_property(previous, "volume_db", -60.0, BGM_FADE_SECONDS)
		_fade_tween.chain().tween_callback(previous.stop)

	var path: String = BGM_PATHS.get(track, "")
	if path.is_empty() or not ResourceLoader.exists(path):
		return
	next.stream = load(path)
	if next.stream is AudioStreamOggVorbis:
		(next.stream as AudioStreamOggVorbis).loop = true
	next.volume_db = -60.0
	next.play()
	_fade_tween.tween_property(next, "volume_db", _linear_to_db(_music_volume), BGM_FADE_SECONDS)


func stop_bgm() -> void:
	_current_track = Track.NONE
	for player in _bgm_players:
		player.stop()


## `sfx_tap` 같은 이름을 넘긴다. 없는 이름은 조용히 무시한다.
func play_sfx(name: String, pitch: float = 1.0) -> void:
	if not _enabled or _sfx_volume <= 0.0:
		return
	var now := Time.get_ticks_msec()
	if now - int(_last_played_ms.get(name, -SFX_MIN_GAP_MS)) < SFX_MIN_GAP_MS:
		return
	var stream := _sfx_stream(name)
	if stream == null:
		return
	_last_played_ms[name] = now

	var player := _sfx_players[_sfx_next]
	_sfx_next = (_sfx_next + 1) % _sfx_players.size()
	player.stream = stream
	player.pitch_scale = pitch
	player.volume_db = _linear_to_db(_sfx_volume)
	player.play()


func play_sting(won: bool) -> void:
	if not _enabled:
		return
	var path := STING_WIN if won else STING_LOSE
	if not ResourceLoader.exists(path):
		return
	var player := _sfx_players[_sfx_next]
	_sfx_next = (_sfx_next + 1) % _sfx_players.size()
	player.stream = load(path)
	player.pitch_scale = 1.0
	player.volume_db = _linear_to_db(_sfx_volume)
	player.play()


func _sfx_stream(name: String) -> AudioStream:
	if _sfx_cache.has(name):
		return _sfx_cache[name]
	var path := "%s/%s.wav" % [SFX_DIR, name]
	var stream: AudioStream = load(path) if ResourceLoader.exists(path) else null
	if stream == null:
		push_warning("효과음을 찾을 수 없습니다: %s" % path)
	_sfx_cache[name] = stream
	return stream


## 0이면 무음. linear_to_db(0)은 -inf라 그대로 쓰면 경고가 난다.
func _linear_to_db(value: float) -> float:
	return -60.0 if value <= 0.001 else linear_to_db(value)
