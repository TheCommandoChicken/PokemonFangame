extends Resource
class_name Pokemon

enum Gender {NONE, MALE, FEMALE}

@export_category("Basic Info")
@export var base : BasePokemon
@export var nickname : String
@export var shiny : bool
@export var gender : Gender
@export var ability : Abilities.Ability
@export var nature : Natures.Nature
@export var ivs = {
	"hp": 0,
	"atk": 0,
	"def": 0,
	"spa": 0,
	"spd": 0,
	"spe": 0
}
@export_category("Catch")
@export var trainer : String
@export var trainer_id : int
@export var ball : Pokeballs.Pokeball
@export var region : int
@export var route : int
@export var fateful : bool
@export_category("Variables")
@export var exp : int
@export var level : int
@export var friendship : int
@export var affection : int
@export var moves : Array[Move]
@export var non_volatile_status : Statuses.Status
@export var stats = {
	"max_hp": 0,
	"current_hp": 0,
	"atk": 0,
	"def": 0,
	"spa": 0,
	"spd": 0,
	"spe": 0
}
@export var evs = {
	"hp": 0,
	"atk": 0,
	"def": 0,
	"spa": 0,
	"spd": 0,
	"spe": 0
}
@export var held_item : int
@export_category("Battle")
@export var volatile_status : Array[int]
@export var stages = {
	"atk": 0,
	"def": 0,
	"spa": 0,
	"spd": 0,
	"spe": 0,
	"eva": 0,
	"acc": 0,
	"crt": 0
}
@export var invulnerable : bool
@export var last_move : int

func stat(stat: int, iv: int, ev: int) -> int:
	return int((((2 * stat + iv + (ev / 4)) * level) / 100) + 5)
