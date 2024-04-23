extends Node
class_name BattleParticipant

@export var items : Array
@export var pokemon : Array[Pokemon]
@export var active_pokemon : Array[Pokemon]
@export var selected_pokemon : Pokemon

func _init(init_pokemon : Array[Pokemon]) -> void:
	pokemon = init_pokemon
	active_pokemon = pokemon.slice(0, 1)
	selected_pokemon = active_pokemon[0]
