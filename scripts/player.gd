extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -600.0
@onready var animated_sprite_2d = $AnimatedSprite2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED/10)

	move_and_slide()
	
	
	if not is_on_floor():
		if (velocity.y < 0):
			animated_sprite_2d.animation = "jumping"
		else:
			animated_sprite_2d.animation = "falling"
	elif (abs(velocity.x) > 1):
		animated_sprite_2d.animation = "running"
	else:
		animated_sprite_2d.animation = "idling"
		
	if (velocity.x > 1):
		animated_sprite_2d.flip_h = false
	elif (velocity.x < -1):
		animated_sprite_2d.flip_h = true
