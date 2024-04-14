extends Area3D

signal triggered_encounter(pokemon : BasePokemon, level : int, player : CharacterBody3D)

@export var encounters : EncounterTable
@export_range(0, 255) var encounter_rate : int

func _on_player_entered_tile(player : CharacterBody3D):
	if overlaps_body(player) and randi_range(1, 255) <= encounter_rate:
		var id = get_encounter()
		emit_signal("triggered_encounter", encounters.pokemon[id], encounters.levels[id], player)

func get_encounter() -> int:
	var sum_weights : int
	
	for i in encounters.weights:
		sum_weights += i
	
	var rand = randi_range(0, sum_weights)
	
	for i in encounters.pokemon.size():
		if rand < encounters.weights[i]:
			return i
		rand -= encounters.weights[i]
	
	return 0
