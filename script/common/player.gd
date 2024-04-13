extends CharacterBody3D

@export var walk_speed : float
@export var run_speed : float

func _physics_process(delta):
	move_and_slide()
