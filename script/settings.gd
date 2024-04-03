extends Node

@export var move: int
@export var text_speed: float

func updateMove():
	move = get_node("/root/Main/MoveSlider/").value
