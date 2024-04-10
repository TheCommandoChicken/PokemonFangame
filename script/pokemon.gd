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
@export var current_pp : Array[int]
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

func _init(info: Dictionary) -> void:
	base = info.base
	nickname = info.nickname
	shiny = info.shiny
	gender = info.gender
	ability = info.ability
	nature = info.nature
	ivs = info.ivs
	level = info.level
	moves = info.moves

func update_stats():
	stats[0] = health_stat(base.base_stats.hp, ivs.hp, evs.hp)
	
	for i in range (1, 5):
		stats[i + 1] = stat(base.base_stats[i], ivs[i], evs[i])

func stat(stat: int, iv: int, ev: int) -> int:
	return int((((2 * stat + iv + (ev / 4)) * level) / 100) + 5)

func health_stat(base: int, iv: int, ev: int):
	return (((2 * base + iv + (ev / 4)) * level) / 100) + level + 10
