extends Node
class_name BattleParticipant

@export var items : Array
@export var pokemon : Array[Pokemon]
@export var active_pokemon : Array[Pokemon]
@export var selected_pokemon : Pokemon
@export var type : Enums.BattleParticipant

func _init(init_pokemon : Array[Pokemon]) -> void:
	pokemon = init_pokemon
	active_pokemon = pokemon.slice(0, 1)
	selected_pokemon = active_pokemon[0]

func faint_pokemon(index : int) -> bool:
	for i in pokemon:
		if i.stats.current_hp > 0:
			active_pokemon[index] = i
			selected_pokemon = active_pokemon[0]
			return true
	return false

func switch_pokemon(first : int, second : int) -> void:
	active_pokemon[first] = pokemon[second]
