extends Node

@export var text_speed: float
@export var move_names: Dictionary

var text_playing: bool

var text: Array

func _ready() -> void:
	$Timer.wait_time = text_speed
	text_playing = false

func _process(delta: float) -> void:
	if text.size() > 0 && !text_playing:
		next_phrase()

func next_phrase():
	var phrase = TextManager.get_message(text[0][0], Settings.current_language).replace("@@POKEMON@@", text[0][1])
	phrase = phrase.replace("@@MOVE@@", text[0][2])
	phrase = phrase.replace("@@TARGET@@", text[0][3])
	$Text.text = phrase
	print(phrase)
	
	$Text.visible_characters = 0
	
	text_playing = true
	
	while $Text.visible_characters < len($Text.text):
		$Text.visible_characters += 1
		$Timer.start()
		await $Timer.timeout
	
	text.remove_at(0)
	
	text_playing = false

func _on_battle_manager_queue_text(key : String, pokemon : String, move : int, target : String) -> void:
	text.append([key, pokemon, TextManager.get_move_name(str(move), Settings.current_language), target])
