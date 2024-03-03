extends CharacterBody3D

@export var speed = 3.5 # the speed, completely arbitrary
@export var airspeed = 0 # keep at 0 for no air control
@export var jump_vel = 7 # how much the character will go into the air when jumping
@export var max_airjumps = 1 # dictates how many jumps you get in the air. completely arbitrary
@export var gravity = 25 # defines the gravity. this is in m/s^2. i dont care if its inaccurate to real life fucko.

var input_dir = Vector2(0.0,0.0)
var move_dir = int(0)
var face_dir = int(0)
var airjumps = int(0)

@onready var meshinstance = $MeshInstance3D #ununused at the moment

# just some functions
func floatlerp(a, b, fac): 
	return a + (b - a) * fac

func directioninput():
	return clamp(Input.get_axis("left","right"), -1, 1) #handles horizontal input control. should work identically with controller and kb

# main physics process
func _physics_process(delta):
	
	if not is_on_floor(): # gravity
		velocity.y -= gravity * delta
	
	if is_on_floor(): # refreshes doublejump when you touch the ground
		airjumps = 0
	
	if Input.is_action_just_pressed("jump"): # handles jumps
		if is_on_floor():
			velocity.y = jump_vel
		elif airjumps < max_airjumps: # handles double jump, making sure you dont do it more than the maximum air jumps
			velocity.y = jump_vel 
			airjumps += 1
			velocity.z = input_dir.x * speed # allows the switching of directions midair while doublejumping
		

	input_dir.x = directioninput() #this is basically useless, and i should change this but im not bothered
	
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
		
	
	move_and_slide()
