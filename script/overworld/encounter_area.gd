extends Area3D

signal triggered_encounter(pokemon : BasePokemon, level : int, player : CharacterBody3D)

@export var encounters : EncounterTable
@export_range(0, 255) var encounter_rate : int
@export var player : CharacterBody3D

func _ready():
	player.connect("stepped", Callable(self, "_on_player_stepped"))

func _on_player_stepped(areas : Array[Area3D], encounter_factor : int, player : CharacterBody3D):
	if self in areas and randi_range(1, 255) + encounter_factor <= encounter_rate:
		print("these nutes")
		var id = get_encounter()
		player.encounter_factor = 0
		emit_signal("triggered_encounter", encounters.pokemon[id], encounters.levels[id])
		print("You would have an encounter with ", encounters.pokemon[id], " here, but I haven't added that yet!")

func get_encounter() -> int:
	var sum_weights : int = 0
	
	for i in encounters.weights:
		sum_weights += i
	
	var rand = randi_range(0, sum_weights)
	
	for i in encounters.pokemon.size():
		if rand < encounters.weights[i]:
			return i
		rand -= encounters.weights[i]
	
	return 0
