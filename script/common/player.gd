extends CharacterBody3D

@export var walk_speed : float
@export var run_speed : float
const tile_size : float = 24
var last_dir : Vector3
var distance : float = 0.0
var speed : float
var dir_list : Array = [""]

func _physics_process(delta):
	for dir in ["up", "down", "left", "right"]:
		if Input.is_action_just_pressed(dir):
			dir_list.append(dir)
		elif Input.is_action_just_released(dir):
			dir_list.remove_at(dir_list.find(dir))
	
	if distance == 0.0:
		if Input.is_action_pressed("secondary_button"):
			speed = run_speed
		else:
			speed = walk_speed
	
		last_dir = get_input_direction(dir_list[dir_list.size() - 1])
		
		if last_dir != Vector3.ZERO:
			distance = tile_size
	
	if distance > 0.0:
		velocity = last_dir * speed
		move_and_slide()
		distance -= speed
	
	if distance < 0.0:
		distance = 0.0
	
func get_input_direction(dir : String) -> Vector3:
	match dir:
		"up":
			return Vector3.FORWARD
		"down":
			return Vector3.BACK
		"left":
			return Vector3.LEFT
		"right":
			return Vector3.RIGHT
		"":
			return Vector3.ZERO
	
	return last_dir
