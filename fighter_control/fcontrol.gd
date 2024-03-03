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

func directioninput():
	return clamp(Input.get_axis("left","right"), -1, 1)


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= 25 * delta
	
	if is_on_floor():
		airjumps = 0
	
	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = jump_vel
		elif airjumps < max_airjumps:
			velocity.y = jump_vel
			airjumps += 1
			velocity.z = input_dir.x * speed
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	input_dir.x = directioninput()
	
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
