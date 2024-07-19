extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var area_2d = $Area2D
@onready var collision_shape_2d = $Area2D/CollisionShape2D
@onready var collision_shape_2d2 = $Area2D/CollisionShape2D2

# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 1
@export var SPEED = 300.0
@export var JUMP_VELOCITY = -900.0
@export var HOOK_SPEED = 1400
@export var FALL_SPEED = 900
@export var GRAVITY = 980 * 2.5
@export var COYOTE_FRAMES = 3
@export var HOOK_FRAMES = 30

var current_coyote_frame = 0
var hook_frame = HOOK_FRAMES
var cancellable = false

func _physics_process(delta):
	# Add the gravity.
	if is_on_floor():
		current_coyote_frame = COYOTE_FRAMES
		cancellable = false
	else:
		velocity.y += GRAVITY * delta
		if current_coyote_frame > 0:
			current_coyote_frame -= 1
	
	if Input.is_action_just_pressed("jump") and current_coyote_frame > 0:
		velocity.y = JUMP_VELOCITY
		cancellable = true
		
	if not Input.is_action_pressed("jump") and velocity.y < 0 and cancellable:
		velocity.y = 0
		cancellable = false
		
	if velocity.y > FALL_SPEED:
		velocity.y = FALL_SPEED

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	if direction and abs(velocity.x) < SPEED:
		velocity.x = move_toward(velocity.x, SPEED*direction, SPEED/3)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED/6)

	move_and_slide()
	
	if Input.is_action_just_pressed("hook"):
		if not Input.is_action_pressed("up"):
			if not animated_sprite_2d.flip_h:
				area_2d.rotation = 0
			else:
				area_2d.rotation = -PI
		elif direction == 1:
			area_2d.rotation = -PI/4
		elif direction == -1:
			area_2d.rotation = -3*PI/4
		else:
			area_2d.rotation = -PI/2 
				
		collision_shape_2d.disabled = false
		collision_shape_2d2.disabled = false
	else:
		collision_shape_2d.disabled = true
		collision_shape_2d2.disabled = true
	
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


func _on_area_2d_body_entered(body: Node2D) -> void:
	velocity = Vector2(HOOK_SPEED, 0).rotated(area_2d.rotation)
	cancellable = false
