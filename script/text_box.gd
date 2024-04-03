extends Node

@export var path: String
@export var text_speed: float
@export var move_names: Dictionary

var pokemon: String
var move: String
var target: String
var text_playing: bool

var text: Array

func _ready() -> void:
	$Timer.wait_time = text_speed
	var move_path = "res://resource/moves_en.json"
	if not FileAccess.file_exists(move_path):
		assert("File does not exist at the provided path.")
	var file = FileAccess.open(move_path, FileAccess.READ)
	var test_json_conv = JSON.new()
	test_json_conv.parse(file.get_as_text())
	move_names = test_json_conv.get_data()
	text_playing = false

func _process(delta: float) -> void:
	if text.size() > 0 && !text_playing:
		nextPhrase()

func getText(key) -> void:
	if not FileAccess.file_exists(path):
		assert("File does not exist at the provided path.")
	var file = FileAccess.open(path, FileAccess.READ)
	var test_json_conv = JSON.new()
	test_json_conv.parse(file.get_as_text())[key]
	text.append(String(test_json_conv.get_data()))

func nextPhrase():
	var phrase = text[0].replace("@@POKEMON@@", pokemon)
	phrase = phrase.replace("@@MOVE@@", move)
	phrase = phrase.replace("@@TARGET@@", target)
	$Text.text = phrase
	
	$Text.visible_characters = 0
	
	text_playing = true
	
	while $Text.visible_characters < len($Text.text):
		$Text.visible_characters += 1
		$Timer.start()
		await $Timer.timeout
	
	text.remove_at(0)
	
	text_playing = false

func _on_BattleManager_queue_text(key, init_pokemon, init_move, init_target) -> void:
	pokemon = init_pokemon
	move = move_names[String(init_move)]
	target = init_target
	getText(key)
