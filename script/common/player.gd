extends CharacterBody3D

signal stepped(areas : Array[Area3D], encounter_factor : int, player : CharacterBody3D)

@export var walk_speed : float
@export var run_speed : float
@export var max_encounter_factor : int
const tile_size : float = 24
var last_dir : Vector3
var distance : float = 0.0
var speed : float
var dir_list : Array = [""]
var encounter_factor : int
var delay_frames : int
var buffer_frames : int
var facing_dir : Vector3

func _physics_process(_delta):
	delay_frames -= 1
	$DebugArrow.rotation.y = atan2(facing_dir.x, facing_dir.z)
	
	if encounter_factor <= 0:
		encounter_factor = max_encounter_factor
	
	for dir in ["up", "down", "left", "right"]:
		if Input.is_action_just_pressed(dir):
			dir_list.append(dir)
			delay_frames = 7
		elif Input.is_action_just_released(dir):
			dir_list.remove_at(dir_list.find(dir))
	
	if distance == 0.0:
		if (Input.is_action_pressed("secondary_button") and !Settings.autorun) or (!Input.is_action_pressed("secondary_button") and Settings.autorun):
			if speed != run_speed:
				speed = run_speed
				encounter_factor = max(encounter_factor - max_encounter_factor / 2, 0)
		else:
			if speed != walk_speed:
				speed = walk_speed
				encounter_factor = min(encounter_factor + max_encounter_factor / 2, max_encounter_factor)
		
		if delay_frames <= 0:
			last_dir = get_input_direction(dir_list[dir_list.size() - 1])
			
			if last_dir != Vector3.ZERO:
				distance = tile_size
				facing_dir = last_dir
	
	if distance > 0.0:
		velocity = last_dir * speed
		move_and_slide()
		distance -= speed
		if distance <= 0.0:
			emit_signal("stepped", $Area.get_overlapping_areas(), encounter_factor, self)
			print("stepped")
			print(encounter_factor)
			encounter_factor -= 1
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
