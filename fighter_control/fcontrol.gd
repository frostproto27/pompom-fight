extends CharacterBody3D

@export var speed = 3.5 # the speed, completely arbitrary
@export var airspeed = 0 # keep at 0 for no air control
@export var jump_vel = 7 # how much the character will go into the air when jumping
@export var max_airjumps = 1 # dictates how many jumps you get in the air. completely arbitrary
@export var gravity = 0.15 # defines the gravity. this is in m/s^2. i dont care if its inaccurate to real life fucko.

var input_dir = Vector2(0.0,0.0)
var move_dir = int(0)
var face_dir = int(0)
var airjumps = int(0)

@onready var meshinstance = $MeshInstance3D #ununused at the moment

# just some functions
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
	
	if not is_on_floor(): # gravity
		velocity.y -= gravity
	
	if is_on_floor(): # refreshes doublejump when you touch the ground
		airjumps = 0
	
	# Handle jump.
	if input.get("jump", false):
		if is_on_floor():
			velocity.y = jump_vel
		elif airjumps < max_airjumps: # handles double jump, making sure you dont do it more than the maximum air jumps
			velocity.y = jump_vel 
			airjumps += 1
			velocity.z = input_dir.x * speed # allows the switching of directions midair while doublejumping
	if is_on_wall():
		velocity.z = input_dir.x * speed
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	input_dir.x = int(input.get("right", false))-int(input.get("left", false))
	
	if abs(input_dir.x) > 0:
		move_dir = sign(input_dir) #handles which way the character is moving/facing (different from face direction)
	
	#meshinstance.scale.z = move_dir
	
	if is_on_floor():
		velocity.z += speed * input_dir.x # moves the character. kinda important
	if is_on_floor():
		if abs(input_dir.x) > 0: # you slow down faster than you speed up. kinda wierd with controller input but its fine yknow
			velocity.z *= 0.5
		else:
			velocity.z *= 0.8
	else:
		velocity.z *= 0.99 #slows down the character just a tad in the air :> set to 1 if we dont want that
	
	position.z = 0
	move_and_slide()
	print(position.z)
	
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
