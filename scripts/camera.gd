extends Camera2D

@onready var ray_cast_2d = $RayCast2D
var lower_borders = []

func _physics_process(delta):
	var camera_y = global_position.y + ProjectSettings.get_setting("display/window/size/viewport_height")/(2 * zoom.y)
	if lower_borders.size() > 0 and camera_y > lower_borders.min():
		offset.y = lower_borders.min() - camera_y
	else:
		offset.y = 0 

func _on_area_2d_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int):
	var node2d := area.shape_owner_get_owner(area.shape_find_owner(area_shape_index)) as Node2D
	lower_borders.append(node2d.global_position.y)

func _on_area_2d_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int):
	var node2d := area.shape_owner_get_owner(area.shape_find_owner(area_shape_index)) as Node2D
	lower_borders.pop_at(lower_borders.find(node2d.global_position.y))
