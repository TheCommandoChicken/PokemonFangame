extends CharacterBody3D
class_name Player

signal stepped(areas : Array[Area3D], encounter_factor : int, player : CharacterBody3D)

@export var walk_speed : float
@export var run_speed : float
@export var max_encounter_factor : int
@export var pokemon : Array[Pokemon]
@export var items : Array
@export var stacks : Array[int]
const tile_size : float = 24
var last_dir : Vector3
var distance : float = 0.0
var speed : float
var dir_list : Array = [""]
var encounter_factor : int
var delay_frames : int
var buffer_frames : int
var facing_dir : Vector3
var lock_control : bool

func _physics_process(_delta):
	if not lock_control:
		delay_frames -= 1 # Subtract from delay frames
		$DebugArrow.rotation.y = atan2(facing_dir.x, facing_dir.z) # Set direction of debug arrow
		
		if encounter_factor <= 0: # Reset encounter factor if it's too low
			encounter_factor = max_encounter_factor
		
		for dir in ["up", "down", "left", "right"]: # Check input
			if Input.is_action_just_pressed(dir): # Add direction to list if it's pressed
				dir_list.append(dir)
				if distance == 0.0: # Update facing direction if player isn't moving
					facing_dir = get_input_direction(dir)
					delay_frames = 7 # Set delay before allowing movement
			elif Input.is_action_just_released(dir): # Remove direction if it's no longer pressed
				dir_list.remove_at(dir_list.find(dir))
		
		if distance == 0.0:
			if (Input.is_action_pressed("secondary_button") and !Settings.autorun) or (!Input.is_action_pressed("secondary_button") and Settings.autorun): # Set the player's speed to the run speed if they're holding down the run button or have autorun enabled
				if speed != run_speed:
					speed = run_speed
					encounter_factor = max(encounter_factor - max_encounter_factor / 2, 0) # Reduce encounter factor to increase random encounters while running
			else:
				if speed != walk_speed:
					speed = walk_speed
					encounter_factor = min(encounter_factor + max_encounter_factor / 2, max_encounter_factor) # Increase encounter factor to reduce random encounters while walking
			
			if delay_frames <= 0: # If the movement delay is expired, begin moving
				last_dir = get_input_direction(dir_list[dir_list.size() - 1]) # Set last_dir to the most recent active direction
				
				if last_dir != Vector3.ZERO: # Move if the last_dir isn't zero
					distance = tile_size
					facing_dir = last_dir
		
		if distance > 0.0:
			velocity = last_dir * speed # Set velocity
			move_and_slide()
			distance -= speed # Reduce distance by speed
			if distance <= 0.0: # If the distance is now less than or equal to 0 we know the player has completed one step and can update our variables accordingly
				emit_signal("stepped", $Area.get_overlapping_areas(), encounter_factor, self)
				print("stepped")
				print(encounter_factor)
				encounter_factor -= 1
				distance = 0.0
	
func get_input_direction(dir : String) -> Vector3: # Takes in a string and outputs the corresponding Vector
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
