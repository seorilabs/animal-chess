## 기물 한 종의 고정 설계값.
##
## 런 중에 변하는 값은 UnitState가 들고, 이 리소스는 읽기 전용 기준값만 담는다.
## 실제 데이터는 res://data/units/*.tres에 있다.
class_name UnitDef
extends Resource

## 기획서 §23의 시너지 첫 축.
enum Habitat { FOREST, GRASSLAND, SWAMP, POLAR, SKY, DESERT }

## 기획서 §22의 시너지 둘째 축. 보드 위 전열/후열 후보를 결정한다.
enum Role { DEFENDER, CHARGER, HUNTER, TRICKSTER, SHAMAN, SUPPORT }

const HABITAT_LABELS := {
	Habitat.FOREST: "숲",
	Habitat.GRASSLAND: "초원",
	Habitat.SWAMP: "늪",
	Habitat.POLAR: "극지",
	Habitat.SKY: "하늘",
	Habitat.DESERT: "사막",
}

const ROLE_LABELS := {
	Role.DEFENDER: "방어",
	Role.CHARGER: "돌격",
	Role.HUNTER: "사냥꾼",
	Role.TRICKSTER: "교란",
	Role.SHAMAN: "주술",
	Role.SUPPORT: "지원",
}

@export var id: String = ""
@export var display_name: String = ""
@export var habitat: Habitat = Habitat.FOREST
@export var role: Role = Role.DEFENDER
@export_range(1, 5) var cost: int = 1
@export var max_hp: int = 20
@export var attack: int = 4
@export_range(1, 8) var attack_range: int = 1
@export_range(1, 8) var speed: int = 2
@export var skill_name: String = ""
@export var skill_text: String = ""
## 스킬 발동에 필요한 마나. 공격할 때와 맞을 때 쌓인다.
@export_range(4, 20) var max_mana: int = 10
@export var trait_text: String = ""


func habitat_label() -> String:
	return HABITAT_LABELS.get(habitat, "")


func role_label() -> String:
	return ROLE_LABELS.get(role, "")
