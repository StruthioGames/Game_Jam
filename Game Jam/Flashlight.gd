extends Camera3D

@onready var flashlight = get_node("../Flashlight")
@onready var flashlight_collider = get_node("../Flashlight/StaticBody3D")
@onready var customer_position = get_node("../Customer")
@onready var customer_shadow = get_node("../Customer_Shadow")
@onready var customer_shadow_material = get_node("../Customer_Shadow/MeshInstance3D")
@onready var background_wall =  get_node("../Background_Wall")

# Flashlight variables
var dragging = false
var dragged_object = null
var offset = Vector3()
var center_point = Vector3()
var radius = Vector3()

# Shadow variables
var shadow_size_factor = .337
var is_dragging_shadow = false
var drag_start_position = Vector2()

func _ready():
	CustomerSpawn.customer.position = customer_position.position
	if CustomerSpawn.is_customer_visible():
		customer_shadow.visible = true
		center_point = customer_position.transform.origin 
		radius = int(abs(global_transform.origin.z - center_point.z)) - 1
		var initial_position = flashlight.global_transform.origin
		var mirrored_position = 2 * center_point - initial_position
		mirrored_position.z = background_wall.global_transform.origin.z + background_wall.scale.z / 2
		var flashlight_to_wall = (flashlight.global_transform.origin - background_wall.global_transform.origin).length()
		var shadow_scale = flashlight_to_wall * shadow_size_factor
		customer_shadow.global_transform.origin = mirrored_position
		customer_shadow.scale = Vector3(shadow_scale, shadow_scale, .1)
		if customer_shadow_material:
			var material = customer_shadow_material.material_override
			if material == null:
				material = StandardMaterial3D.new()
				material.albedo_color = Color(0,0,0)
				customer_shadow_material.material_override = material
	else:
		customer_shadow.visible = false
	
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
		if collider and collider == flashlight_collider:
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
			if dragging and raycast_result.collider != background_wall:
				var new_position = raycast_result.position + offset
				var direction = (new_position - center_point).normalized()
				dragged_object.global_transform.origin = center_point + direction * radius
				if raycast_result.collider == flashlight_collider:
					var initial_position = dragged_object.global_transform.origin
					var mirrored_position = 2 * center_point - initial_position
					mirrored_position.z = background_wall.global_transform.origin.z + background_wall.scale.z / 2
					var flashlight_to_wall = (flashlight.global_transform.origin - background_wall.global_transform.origin).length()
					var shadow_scale = flashlight_to_wall * shadow_size_factor
					customer_shadow.global_transform.origin = mirrored_position
					customer_shadow.scale = Vector3(shadow_scale, shadow_scale, .1)
