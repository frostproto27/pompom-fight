extends CharacterBody3D

@export var speed = 3.5
@export var airspeed = 0
@export var jump_vel = 7
@export var max_airjumps = 1

var input_dir = Vector2(0.0,0.0)
var move_dir = int(0)
var face_dir = int(0)
var airjumps = int(0)

@onready var meshinstance = $MeshInstance3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func floatlerp(a, b, fac):
	return a + (b - a) * fac

func _get_local_input() -> Dictionary:
	var left = Input.is_action_pressed("left")
	var right = Input.is_action_pressed("right")
	var jump = Input.is_action_just_pressed("jump")
	var input := {}
	if left:
		input["left"] = true
	if right:
		input["right"] = true
	input["jump"] = jump
	print(input)
	return input


func _network_process(input: Dictionary) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= 25 * 0.01
	
	if is_on_floor():
		airjumps = 0
	
	# Handle jump.
	if input.get("jump", false):
		if is_on_floor():
			velocity.y = jump_vel
		elif airjumps < max_airjumps:
			velocity.y = jump_vel
			airjumps += 1
			velocity.z = input_dir.x * speed
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	input_dir.x = int(input.get("right", false))-int(input.get("left", false))
	
	if abs(input_dir.x) > 0:
		move_dir = sign(input_dir)
	
	#meshinstance.scale.z = move_dir
	
	if is_on_floor():
		velocity.z += speed * input_dir.x
	if is_on_floor():
		if abs(input_dir.x) > 0: 
			velocity.z *= 0.5
		else:
			velocity.z *= 0.8
	else:
		velocity.z *= 0.99
		
	
	move_and_slide()
	pass

func _save_state() -> Dictionary:
	return {
		position = position,
		input_dir = input_dir,
		move_dir = move_dir,
		face_dir = face_dir,
		airjumps = airjumps,
		velocity = velocity
	}

func _load_state(state:Dictionary)->void:
	position=state['position']
	input_dir=state['input_dir']
	move_dir=state['move_dir']
	face_dir=state['face_dir']
	airjumps=state['airjumps']
	velocity=state['velocity']
