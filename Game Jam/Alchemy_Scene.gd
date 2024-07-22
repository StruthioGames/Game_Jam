extends Node3D

@export var shape: MeshInstance3D
@export var shadow_surface: MeshInstance3D
@export var camera: Camera3D

var is_dragging = false
var drag_start_position = Vector2()

func _ready():
	shape.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				drag_start_position = event.position
			else:
				is_dragging = false
	elif event is InputEventMouseMotion and is_dragging:
		update_shape_position(event.position)

func update_shape_position(mouse_position: Vector2):
	var ray_length = 1000
	var from = project_ray_origin(mouse_position)
	var to = from + project_ray_normal(mouse_position) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	var raycast_result = space.intersect_ray(ray_query)

	if raycast_result:
		shape.translation = raycast_result.position
