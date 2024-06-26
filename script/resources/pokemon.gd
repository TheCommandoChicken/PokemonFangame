@tool
extends Resource
class_name Pokemon

@export var base : BasePokemon
@export var nickname : String
@export var shiny : bool
@export var gender : Enums.Gender
@export var ability : Enums.Ability
@export var nature : Enums.Nature
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
@export var ball : Enums.Pokeball
@export var region : Enums.Region
@export var route : int
@export var fateful : bool
@export var exp : int
@export var level : int
@export var friendship : int
@export var affection : int
@export var moves : Array[Enums.Moves]
@export var current_pp : Dictionary = {}
@export_category("Debug")
@export var debug_update_current_pp : String
@export var pp_up : Array[int]
@export var non_volatile_status : Enums.NonVolatileStatus
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

func _on_button_pressed(text: String):
	if text == "UPDATE CURRENT PP":
		_update_current_pp()

func _update_current_pp():
	for move in moves:
		current_pp[str(move)] = load(Data.new().load_move(move)).max_pp

func _init(init_base: BasePokemon = load("res://resource/pokemon/bulbasaur.tres"), init_ivs: Dictionary = {"hp": 0, "atk": 0, "def": 0, "spa": 0, "spd": 0, "spe": 0}, init_level: int = 10, init_moves: Array[Enums.Moves] = [], init_nickname: String = "", init_shiny: bool = false, init_gender: Enums.Gender = Enums.Gender.NONE) -> void:
	base = init_base
	nickname = init_nickname
	shiny = init_shiny
	gender = init_gender
	ivs = init_ivs
	level = init_level
	moves = init_moves if init_moves != [] else get_moveset()
	update_stats()

func update_stats():
	stats["max_hp"] = health_stat(base.base_stats.hp, ivs.hp, evs.hp)
	
	for i in ["atk", "def", "spa", "spd", "spe"]:
		stats[i] = stat(base.base_stats[i], ivs[i], evs[i])
	
	print(stats)
	print(level)

func stat(base_stat: int, iv: int, ev: int) -> int:
	return int((((2 * base_stat + iv + (ev / 4)) * level) / 100) + 5)

func health_stat(base_hp: int, iv: int, ev: int):
	return (((2 * base_hp + iv + (ev / 4)) * level) / 100) + level + 10

func get_moveset() -> Array[Enums.Moves]:
	var moveset : Array[Enums.Moves] = []
	var i : int = base.learnset.size() - 1
	while moveset.size() < 4:
		if base.move_levels[i] <= level:
			moveset.append(base.learnset[i])
		
		i -= 1
		
		if i < 0:
			while moveset.size() < 4:
				moveset.append(Enums.Moves.NONE)
	return moveset
