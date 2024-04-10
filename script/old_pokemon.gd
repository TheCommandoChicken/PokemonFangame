extends Node

# These variables probably shouldn't be exposed like this, consider making getter and setter functions

@export var species: int
@export var nickname: String
@export var shiny: bool
@export var gender: int
@export var trainer: String

@export var stats = {
	"max_health": 0,
	"current_health": 0,
	"attack": 1,
	"defense": 1,
	"sp_attack": 1,
	"sp_defense": 1,
	"speed": 0
}

@export var ivs = {
	"health": 0,
	"attack": 0,
	"defense": 0,
	"sp_attack": 0,
	"sp_defense": 0,
	"speed": 0
}

@export var evs = {
	"health": 0,
	"attack": 100,
	"defense": 0,
	"sp_attack": 0,
	"sp_defense": 0,
	"speed": 0
}

@export var stages = {
	"attack": 2,
	"defense": 6,
	"sp_attack": 0,
	"sp_defense": 2,
	"speed": 0,
	"evasiveness": 0,
	"accuracy": 6,
	"crit": 0
}

@export var experience: int
@export var level: int

@export var friendship: int
@export var affection: int

@export var ability: String
@export var nature: String

@export var status = "NONE"

@export var pokeball: int
@export var met_region: String
@export var met_route: String
@export var fateful: bool

@export var moves = {}

@export var invulnerable : int
@export var using_move : int

func _init(info: Dictionary) -> void:
	nickname = info.nickname
	species = info.species
	level = info.level
	ivs = info.ivs
	moves = info.moves
	update_stats()
	stats.current_health = stats.max_health

func update_stats(): # This is stupid and does work
	stats = {
		"max_health": health_stat(BasePokemon.pokemon_table[str(species)].base_stats.health, ivs.health, evs.health),
		"current_health": stats.current_health,
		"attack": stat(BasePokemon.pokemon_table[str(species)].base_stats.attack, ivs.attack, evs.attack),
		"defense": stat(BasePokemon.pokemon_table[str(species)].base_stats.defense, ivs.defense, evs.defense),
		"sp_attack": stat(BasePokemon.pokemon_table[str(species)].base_stats.sp_attack, ivs.sp_attack, evs.sp_attack),
		"sp_defense": stat(BasePokemon.pokemon_table[str(species)].base_stats.sp_defense, ivs.sp_defense, evs.sp_defense),
		"speed": stat(BasePokemon.pokemon_table[str(species)].base_stats.speed, ivs.speed, evs.speed)
	}
	
	print(stats)

func stat(base: int, iv: int, ev: int):
# warning-ignore:integer_division
# warning-ignore:integer_division
	return (((2 * base + iv + (ev / 4)) * level) / 100) + 5

func health_stat(base: int, iv: int, ev: int):
# warning-ignore:integer_division
# warning-ignore:integer_division
	return (((2 * base + iv + (ev / 4)) * level) / 100) + level + 10

func get_types() -> Array:
	var pokemon_info = BasePokemon.pokemon_table[str(species)]
	return [pokemon_info["type_1"], pokemon_info["type_2"]]
