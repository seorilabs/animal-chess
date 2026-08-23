## 진행 중인 런과 누적 기록을 로컬에 보관한다.
##
## 임시 파일에 먼저 쓰고 이름을 바꾸므로, 쓰는 도중 앱이 죽어도
## 기존 저장이 반쯤 덮어써진 상태로 남지 않는다.
class_name SaveService
extends RefCounted

const RUN_PATH := "user://run.json"
const PROFILE_PATH := "user://profile.json"
const TEMP_SUFFIX := ".tmp"


static func save_run(run: RunState) -> bool:
	return _write(RUN_PATH, run.to_dict())


## 저장된 런이 없거나 읽을 수 없으면 null.
static func load_run(catalog: UnitCatalog) -> RunState:
	if not has_run():
		return null
	var run := RunState.from_dict(catalog, _read(RUN_PATH))
	if run == null:
		# 읽을 수 없는 저장은 버린다. 남겨두면 실행할 때마다 같은 오류가 난다.
		clear_run()
	return run


static func has_run() -> bool:
	return FileAccess.file_exists(RUN_PATH)


static func clear_run() -> void:
	if FileAccess.file_exists(RUN_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(RUN_PATH))


static func save_profile(profile: Profile) -> bool:
	return _write(PROFILE_PATH, profile.to_dict())


static func load_profile() -> Profile:
	return Profile.from_dict(_read(PROFILE_PATH))


## 저장 데이터를 모두 지운다. 설정 화면의 초기화가 쓴다.
static func clear_all() -> void:
	clear_run()
	if FileAccess.file_exists(PROFILE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(PROFILE_PATH))


static func _write(path: String, data: Dictionary) -> bool:
	var temp_path := path + TEMP_SUFFIX
	var file := FileAccess.open(temp_path, FileAccess.WRITE)
	if file == null:
		push_error("저장 실패: %s (오류 %d)" % [temp_path, FileAccess.get_open_error()])
		return false
	file.store_string(JSON.stringify(data))
	file.close()

	var error := DirAccess.rename_absolute(
		ProjectSettings.globalize_path(temp_path), ProjectSettings.globalize_path(path)
	)
	if error != OK:
		push_error("저장 파일 교체 실패: %s (오류 %d)" % [path, error])
		return false
	return true


## 읽을 수 없으면 빈 사전. 손상된 저장은 오류가 아니라 없는 것으로 취급한다.
## JSON.parse_string 대신 인스턴스 parse를 쓰는 이유는 파싱 실패가 엔진 오류
## 로그를 남기지 않게 하기 위해서다.
static func _read(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(path)) != OK:
		push_warning("저장 파일을 읽을 수 없어 버립니다: %s" % path)
		return {}
	if json.data is Dictionary:
		return json.data
	push_warning("저장 파일 형식이 올바르지 않습니다: %s" % path)
	return {}
