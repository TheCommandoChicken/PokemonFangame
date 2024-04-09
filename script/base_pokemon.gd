extends Node

@export var pokemon_table: Dictionary

func _ready() -> void:
	var path = "res://resource/pokemon.json"
	pokemon_table = DataManager.generic_json_read(path)
