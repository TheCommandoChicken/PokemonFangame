extends Node

@export var text_speed: float
@export var move_names: Dictionary

var pokemon: String
var move: String
var target: String
var text_playing: bool

var text: Array

func _ready() -> void:
	$Timer.wait_time = text_speed
	text_playing = false

func _process(delta: float) -> void:
	if text.size() > 0 && !text_playing:
		next_phrase()

func next_phrase():
	var phrase = text[0].replace("@@POKEMON@@", pokemon)
	phrase = phrase.replace("@@MOVE@@", move)
	phrase = phrase.replace("@@TARGET@@", target)
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

func _on_battle_manager_queue_text(key, init_pokemon, init_move, init_target) -> void:
	pokemon = init_pokemon
	move = TextManager.get_move_name(str(init_move), Settings.current_language)
	target = init_target
	text.append(TextManager.get_message(key, Settings.current_language))
