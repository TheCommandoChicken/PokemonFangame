@tool
extends Resource
class_name Move

signal prompt_player_choose_target()

@export var id : Enums.Moves
@export var category := Enums.Category.PHYSICAL:
	set(value):
		category = value
		notify_property_list_changed()
@export var type : Types.Type
@export var power : int
@export_range(0.0, 1.0) var accuracy : float
@export_range(1, 64) var max_pp : int
@export var contact : bool
@export_range(-6, 6) var priority : int
@export_range(0, 2) var range : int
@export var hit_friends : bool
@export var hit_enemies : bool
@export var hit_all : bool
@export var effects : Array[MoveEffect]

func _validate_property(property: Dictionary):
	if property.name in ["power", "accuracy"] and category == Enums.Category.STATUS:
		property.usage = PROPERTY_USAGE_NO_EDITOR

func get_targets(active_pokemon: Array[Pokemon], battle_type: Enums.BattleType, user_index: int) -> Array[Pokemon]:
	if hit_all: 
		return active_pokemon.slice(max(user_index - (range + 2), 0), min(user_index + range + 2, active_pokemon.size() - 1))
	else: 
		return active_pokemon # This is a placeholder until I implement prompting the player to choose a target
