extends Node

@export var health_bar : ProgressBar

func get_buttons() -> Array[Node]:
	return $MoveButtons.get_children()
