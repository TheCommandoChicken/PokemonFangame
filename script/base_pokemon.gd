extends Node

@export var pokemon_table: Dictionary

func _ready() -> void:
	var path = "res://resource/pokemon.json"
	if not FileAccess.file_exists(path):
		return
	var file = FileAccess.open(path, FileAccess.READ)
	var test_json_conv = JSON.new()
	test_json_conv.parse(file.get_as_text())
	pokemon_table = test_json_conv.get_data()
