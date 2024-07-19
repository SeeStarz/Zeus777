extends Area2D
@onready var collision_shape_2d = $CollisionShape2D
@onready var collision_shape_2d_2 = $CollisionShape2D2
@onready var color_rect = $ColorRect

@export var LINGER_FRAMES = 6
var current_linger_frame = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	toggle(false)

func toggle(enabled: bool) -> void:
	collision_shape_2d.disabled = not enabled
	collision_shape_2d_2.disabled = not enabled
	if enabled:
		color_rect.visible = true
		current_linger_frame = LINGER_FRAMES
	elif current_linger_frame >= 0:
		current_linger_frame -= 1
		
	if (not enabled) and current_linger_frame == -1:
		color_rect.visible = false

func _on_player_hook_set(enabled: bool):
	toggle(enabled)
