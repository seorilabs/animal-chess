## 볼륨 같은 사용자 설정. 런과 별개로 보관한다.
class_name SettingsService
extends RefCounted

const PATH := "user://settings.json"

var music_volume := 0.7
var sfx_volume := 0.9


static func load_settings() -> SettingsService:
	var settings := SettingsService.new()
	if not FileAccess.file_exists(PATH):
		return settings
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(PATH)) != OK or not json.data is Dictionary:
		push_warning("설정 파일을 읽을 수 없어 기본값을 씁니다.")
		return settings
	var data: Dictionary = json.data
	settings.music_volume = clampf(float(data.get("music_volume", settings.music_volume)), 0.0, 1.0)
	settings.sfx_volume = clampf(float(data.get("sfx_volume", settings.sfx_volume)), 0.0, 1.0)
	return settings


func save() -> void:
	var file := FileAccess.open(PATH, FileAccess.WRITE)
	if file == null:
		push_warning("설정을 저장할 수 없습니다.")
		return
	file.store_string(JSON.stringify({"music_volume": music_volume, "sfx_volume": sfx_volume}))
	file.close()
