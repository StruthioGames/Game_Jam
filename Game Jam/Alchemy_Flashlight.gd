extends Camera3D

#Shapes necessary
@onready var flashlight = get_node("../Flashlight")
@onready var flashlight_collider = get_node("../Flashlight/StaticBody3D")
@onready var background_wall = get_node("../Background_Wall")
@onready var target_shape = get_node("../Cube")
@onready var shadow_surface = get_node("../Cube_Shadow")

# Flashlight variables
var dragging = false
var dragged_object = null
var offset = Vector3()
var center_point = Vector3()
var radius = Vector3()

# Shadow variables
var is_dragging_shadow = false
var drag_start_position = Vector2()

func _ready():
	center_point = target_shape.global_transform.origin
	radius = int(abs(global_transform.origin.z - center_point.z)) - 1
	#target_shape.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON

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
		if dragging or is_dragging_shadow:
			update_position(event.position)

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
		if collider and collider.get_path() == flashlight_collider.get_path():
			dragging = true
			dragged_object = collider
			offset = dragged_object.global_transform.origin - raycast_result.position
			radius = (dragged_object.global_transform.origin - center_point).length()
		elif collider == shadow_surface:
			is_dragging_shadow = true

func update_position(mouse_position: Vector2):
	var from = project_ray_origin(mouse_position)
	var to = from + project_ray_normal(mouse_position) * 1000
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	var raycast_result = space.intersect_ray(ray_query)

	if raycast_result:
		if dragging and raycast_result.collider.get_path() != background_wall.get_path():
			var new_position = raycast_result.position + offset
			var direction = (new_position - center_point).normalized()
			dragged_object.global_transform.origin = center_point + direction * radius
		elif is_dragging_shadow:
			target_shape.translation = raycast_result.position
