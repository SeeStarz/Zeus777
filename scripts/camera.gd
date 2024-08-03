extends Camera2D

@onready var ray_cast_2d = $RayCast2D
var border_positions: Array[Vector2] = []
var border_sizes: Array[Vector2] = []

func calculate_limits():
	assert(border_positions.size() == border_sizes.size())
	const limit_max = 10000000
	limit_bottom = limit_max
	limit_top = -limit_max
	limit_right = limit_max
	limit_left = -limit_max
	
	for i in range(border_positions.size()):
		var border_position = border_positions[i]
		var border_shape = border_sizes[i]
		
		if limit_bottom < border_position.y + border_shape.y / 2 or limit_bottom == limit_max:
			limit_bottom = border_position.y + border_shape.y / 2
		if limit_top > border_position.y - border_shape.y / 2 or limit_top == -limit_max:
			limit_top = border_position.y - border_shape.y / 2
		if limit_right < border_position.x + border_shape.x / 2 or limit_right == limit_max:
			limit_right = border_position.x + border_shape.x / 2
		if limit_left > border_position.x - border_shape.x / 2 or limit_left == -limit_max:
			limit_left = border_position.x - border_shape.x / 2
	
	print("limit left: ", limit_left)
	print("limit right: ", limit_right)

func _on_area_2d_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int):
	var collision_shape := area.shape_owner_get_owner(area.shape_find_owner(area_shape_index)) as CollisionShape2D
	if collision_shape == null:
		push_warning("Found non collision shape in camera collider")
		return
		
	var rectangle_shape := collision_shape.shape as RectangleShape2D
	if rectangle_shape == null:
		push_warning("Found non rectangle shape in camera collider")
		return
	
	border_positions.append(collision_shape.global_position)
	border_sizes.append(rectangle_shape.size)
	
	calculate_limits()

func _on_area_2d_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int):
	var collision_shape := area.shape_owner_get_owner(area.shape_find_owner(area_shape_index)) as CollisionShape2D
	if collision_shape == null:
		push_warning("Found non collision shape in camera collider")
		return
		
	var rectangle_shape := collision_shape.shape as RectangleShape2D
	if rectangle_shape == null:
		push_warning("Found non rectangle shape in camera collider")
		return
	
	border_positions.erase(collision_shape.global_position)
	border_sizes.erase(rectangle_shape.size)
	
	calculate_limits()
