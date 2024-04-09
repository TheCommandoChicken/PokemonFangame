extends Node

@export var move: int
@export var text_speed: float
@export var current_language = "en"

func update_move():
	move = get_node("/root/Main/UI/MoveSlider/").value
