extends Node
class_name Pokemon

enum Gender {NONE, MALE, FEMALE}

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
@export var trainer : String
@export var trainer_id : int
@export var ball : Pokeballs.Pokeball
@export var region : int
@export var route : int
@export var fateful : bool
@export var exp : int
@export var level : int
@export var friendship : int
@export var affection : int
@export var moves : Array[Move]
@export var current_pp : Array[int] = [10, 10, 10, 10]
@export var pp_up : Array[int]
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

func _init(init_base: BasePokemon, init_ivs: Dictionary, init_level: int, init_moves: Array[Move], init_nickname: String = "", init_shiny: bool = false, init_gender: Gender = Gender.NONE) -> void:
	base = init_base
	nickname = init_nickname
	shiny = init_shiny
	gender = init_gender
	ivs = init_ivs
	level = init_level
	moves = init_moves
	update_stats()

func update_stats():
	stats["max_hp"] = health_stat(base.base_stats.hp, ivs.hp, evs.hp)
	
	for i in ["atk", "def", "spa", "spd", "spe"]:
		stats[i] = stat(base.base_stats[i], ivs[i], evs[i])
	
	print(stats)

func stat(stat: int, iv: int, ev: int) -> int:
	return int((((2 * stat + iv + (ev / 4)) * level) / 100) + 5)

func health_stat(base: int, iv: int, ev: int):
	return (((2 * base + iv + (ev / 4)) * level) / 100) + level + 10
