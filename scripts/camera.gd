extends Camera2D

@onready var ray_cast_2d = $RayCast2D
var lower_borders = []

func _physics_process(delta):
	if lower_borders.size() > 0 && (global_position.y + 300) > lower_borders.min():
		offset.y = lower_borders.min() - global_position.y - 300
	else:
		offset.y = 0 

func _on_area_2d_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int):
	var node2d := area.shape_owner_get_owner(area.shape_find_owner(area_shape_index)) as Node2D
	lower_borders.append(node2d.global_position.y)

func _on_area_2d_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int):
	var node2d := area.shape_owner_get_owner(area.shape_find_owner(area_shape_index)) as Node2D
	lower_borders.pop_at(lower_borders.find(node2d.global_position.y))
