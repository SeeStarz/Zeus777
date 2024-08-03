extends CharacterBody2D

signal hook_set(enabled: bool)

@onready var sprite = $Sprite
@onready var hook = $Hook
@onready var collision_shape_2d = $Hook/CollisionShape2D
@onready var collision_shape_2d2 = $Hook/CollisionShape2D2

# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 1
@export var SPEED: float = 300.0
@export var JUMP_VELOCITY: float = 900.0
@export var FALL_SPEED: float = 900.0
@export var GRAVITY: float = 980.0 * 2.5
@export var COYOTE_FRAMES: int = 4
@export var HOOK_FRAMES: int = 300
@export var ACCELERATE_FRAMES: int = 3
@export var DECCELERATE_FRAMES: int = 6
@export var HOOK_LATCH_SPEED: float = 1200.0

var current_coyote_frame: int = -1
var current_hook_frame: int = -1
var jump_cancellable: bool = false
var latched_to: Vector2 = Vector2.ZERO

func tick_coyote() -> void:
	if is_on_floor():
		current_coyote_frame = COYOTE_FRAMES
		jump_cancellable = false
	else:
		if current_coyote_frame >= 0:
			current_coyote_frame -= 1
	
func tick_hook() -> void:
	if latched_to:
		current_hook_frame -= 1
		if Input.is_action_just_released("hook") or current_hook_frame < 0:
			latched_to = Vector2.ZERO
	else:
		current_hook_frame = -1

func apply_hook(delta: float) -> void:
	if latched_to:
		var distance = latched_to - global_position
		if distance.length() < HOOK_LATCH_SPEED * delta:
			velocity = distance / delta
		else:
			velocity = distance.normalized() * HOOK_LATCH_SPEED

func apply_gravity(delta: float) -> void:
	if is_on_floor():
		return
	velocity.y += GRAVITY * delta

func can_jump() -> bool:
	return current_coyote_frame >= 0
	
func can_add_velocity() -> bool:
	return current_hook_frame == -1
	
func do_hook():
	var horizontal: float = Input.get_axis("left", "right")
	var vertical: float = Input.get_axis("up", "down")
	
	var angle: float
	if (not vertical) and (not horizontal):
		angle = 0 if not sprite.flip_h else PI
	elif not horizontal:
		angle = -PI * (1 + vertical/2)
	elif not vertical:
		angle = -PI * (1 - horizontal)/2
	else:
		angle = -PI/4 * ( 2*(vertical + 1) + (vertical*horizontal + 1) + 1)
		
	hook.rotation = angle
	current_hook_frame = HOOK_FRAMES
	hook_set.emit(true)

func _physics_process(delta: float) -> void:
	# Tick hook and then apply if still attached
	tick_hook()
	apply_hook(delta)
	
	if Input.is_action_just_pressed("hook"):
		do_hook()
	else:
		hook_set.emit(false)
	
	# Jump check first then do jump
	tick_coyote()
	if Input.is_action_just_pressed("jump") and can_jump():
		velocity.y = -JUMP_VELOCITY
		jump_cancellable = true
	
	# Cancel jump, immediatly stop all vertical momentum
	if Input.is_action_just_released("jump") and velocity.y < 0 and jump_cancellable:
		velocity.y = 0
		jump_cancellable = false
	
	# Apply gravity
	apply_gravity(delta)
	
	# Limit fall speed
	if velocity.y > FALL_SPEED and can_add_velocity():
		velocity.y = move_toward(velocity.y, FALL_SPEED, SPEED/6)

	# Accelerate and deccelerate
	# Going the opposite direction counts as acceleration
	var direction = Input.get_axis("left", "right")
	if direction and velocity.x * direction < SPEED and can_add_velocity():
		velocity.x = move_toward(velocity.x, SPEED*direction, SPEED/ACCELERATE_FRAMES)
	elif can_add_velocity():
		velocity.x = move_toward(velocity.x, 0, SPEED/DECCELERATE_FRAMES)

	# Apply acceleration and velocity
	move_and_slide()

	# Update animation
	if not is_on_floor():
		if (velocity.y < 0 and not latched_to):
			sprite.animation = "jumping"
		else:
			sprite.animation = "falling"
	elif (abs(velocity.x) > 1):
		sprite.animation = "running"
	else:
		sprite.animation = "idling"

	if Input.is_action_just_pressed("right"):
		sprite.flip_h = false
	elif Input.is_action_just_pressed("left"):
		sprite.flip_h = true

func _on_hook_body_shape_entered(body_rid:RID, body: Node2D, _body_shape_index:int,
	_local_shape_index:int) -> void:
	var tilemap := body as TileMap
	latched_to = tilemap.to_global(tilemap.map_to_local(
		tilemap.get_coords_for_body_rid(body_rid)))
	if not latched_to: # Is zero
		push_warning("Latching to vector zero, is this intended?")
		latched_to = Vector2(0.1, 0.1)
	jump_cancellable = false
