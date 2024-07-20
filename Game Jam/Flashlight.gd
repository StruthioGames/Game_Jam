extends Camera3D

var dragging = false
var dragged_object = null
var offset = Vector3()
var center_point = Vector3()
var radius = 0

func _ready():
	var flashlight = get_node("../Flashlight")  # Adjust the path to your flashlight node
	var target = get_node("../Customer")  # Adjust the path to your target node
	center_point = target.transform.origin 
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if not dragging:
					shoot_ray()
			else:
				if dragging:
					dragging = false
					dragged_object = null

func shoot_ray():
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 1000
	var from = project_ray_origin(mouse_pos)
	var to = from + project_ray_normal(mouse_pos) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	var raycast_result = space.intersect_ray(ray_query)
	
	if raycast_result:
		var collider = raycast_result.collider
		if collider and (collider is RigidBody3D or StaticBody3D):
			dragging = true
			dragged_object = collider
			offset = dragged_object.global_transform.origin - raycast_result.position
			radius = (dragged_object.global_transform.origin - center_point).length()

func _process(delta):
	if dragging and dragged_object:
		var mouse_pos = get_viewport().get_mouse_position()
		var from = project_ray_origin(mouse_pos)
		var to = from + project_ray_normal(mouse_pos) * 1000
		var space = get_world_3d().direct_space_state
		var ray_query = PhysicsRayQueryParameters3D.new()
		ray_query.from = from
		ray_query.to = to
		var raycast_result = space.intersect_ray(ray_query)
		
		if raycast_result:
			var new_position = raycast_result.position + offset
			var direction = (new_position - center_point).normalized()
			dragged_object.global_transform.origin = center_point + direction * radius
