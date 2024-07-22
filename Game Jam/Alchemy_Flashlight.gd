extends Camera3D

# Flashlight variables
var dragging = false
var dragged_object = null
var offset = Vector3()
var center_point = Vector3(0, 0, -4)
var radius = 0

# Shadow variables
var is_dragging_shadow = false
var drag_start_position = Vector2()

var flashlight
var shape
var shadow_surface

func _ready():
	flashlight = get_node("../Flashlight")  # Adjust the path to your flashlight node
	shape = get_node("../Cube")
	shadow_surface = get_node("../Background_Wall")
	shape.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if not dragging and not is_dragging_shadow:
					shoot_ray()
			else:
				if dragging:
					dragging = false
					dragged_object = null
				if is_dragging_shadow:
					is_dragging_shadow = false
	elif event is InputEventMouseMotion:
		if dragging:
			update_dragged_object_position(event.position)
		elif is_dragging_shadow:
			update_shadow_position(event.position)

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
		elif collider == shadow_surface:
			is_dragging_shadow = true

func update_dragged_object_position(mouse_position: Vector2):
	var from = project_ray_origin(mouse_position)
	var to = from + project_ray_normal(mouse_position) * 1000
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	var raycast_result = space.intersect_ray(ray_query)

	if raycast_result:
		var new_position = raycast_result.position + offset
		var direction = (new_position - center_point).normalized()
		dragged_object.global_transform.origin = center_point + direction * radius

func update_shadow_position(mouse_position: Vector2):
	var from = project_ray_origin(mouse_position)
	var to = from + project_ray_normal(mouse_position) * 1000
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	var raycast_result = space.intersect_ray(ray_query)

	if raycast_result:
		shape.translation = raycast_result.position
