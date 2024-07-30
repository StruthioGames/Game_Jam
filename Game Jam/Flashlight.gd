extends Node3D

@onready var camera = $Player_View
@onready var flashlight = $Flashlight
@onready var flashlight_light = $Flashlight/StaticBody3D/Flashlight
@onready var flashlight_collider = $Flashlight/StaticBody3D
@onready var customer_position = $Customer
@onready var customer_shadow = $Customer_Shadow
@onready var customer_shadow_material = $Customer/MeshInstance3D
@onready var background_wall =  $Background_Wall

@onready var health_bar = $Control/CanvasLayer/ProgressBar
@onready var potion_box = $Control/CanvasLayer/Give_Potion

@onready var flash_click = $Flashlight_Click
@onready var success_noise = $Successful
@onready var fail_noise = $Failure

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

# Light exposure tracking
var light_on = false
var light_on_duration = 0.0

func _ready():
	if CustomerSpawn.flashlight_on:
		flashlight_light.visible = true
		customer_shadow.visible = true
	else:
		flashlight_light.visible = false
		customer_shadow.visible = false
		
	if ObjectControl.added_object_list.size() == 0 or not CustomerSpawn.customer:
		potion_box.visible = false
		
	if CustomerSpawn.is_customer_visible() and CustomerSpawn.customer:
		CustomerSpawn.customer.position = customer_position.position
		center_point = customer_position.transform.origin 
		radius = int(abs(global_transform.origin.z - center_point.z)) - 1
		var initial_position = flashlight.global_transform.origin
		var mirrored_position = 2 * center_point - initial_position
		if CustomerSpawn.customer_properties["type"] == "Demon":
			customer_shadow.visible = false
		elif CustomerSpawn.customer_properties["type"] == "Poltergiest":
			mirrored_position.x = initial_position.x
			mirrored_position.y = initial_position.y
			
		var flashlight_to_wall = (flashlight.global_transform.origin - background_wall.global_transform.origin).length()
		var shadow_scale = flashlight_to_wall * shadow_size_factor
		mirrored_position.z = background_wall.global_transform.origin.z + background_wall.scale.z / 2
		customer_shadow.global_transform.origin = mirrored_position
		customer_shadow.scale = Vector3(shadow_scale, shadow_scale, .1)
		if customer_shadow_material:
			var mesh = customer_shadow_material.mesh
			if mesh:
				var material = customer_shadow_material.get_surface_override_material(0)
				if material == null:
					material = StandardMaterial3D.new()
					material.albedo_color = Color(CustomerSpawn.customer_properties["shadow_color"])
					customer_shadow_material.set_surface_override_material(0, material)
	else:
		customer_shadow.visible = false
		
	if health_bar and CustomerSpawn.customer:
		health_bar.value = CustomerSpawn.customer_health
	else:
		health_bar.value = 100
		
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
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			flash_click.play()
			if CustomerSpawn.flashlight_on:
				CustomerSpawn.flashlight_on = false
				flashlight_light.visible = false
				customer_shadow.visible = false
			else:
				CustomerSpawn.flashlight_on = true
				flashlight_light.visible = true
				if CustomerSpawn.customer:
					if CustomerSpawn.customer_properties["type"] != "Demon":
						customer_shadow.visible = true

func shoot_ray():
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 1000
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
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
	if flashlight_light.visible:
		apply_light_damage(delta)

	if dragging and dragged_object:
		var mouse_pos = get_viewport().get_mouse_position()
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * 1000
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
					if CustomerSpawn.customer:
						if CustomerSpawn.customer_properties["type"] == "Demon":
							customer_shadow.visible = false
						elif CustomerSpawn.customer_properties["type"] == "Poltergiest":
							mirrored_position.x = initial_position.x
							mirrored_position.y = initial_position.y
						
					var flashlight_to_wall = (flashlight.global_transform.origin - background_wall.global_transform.origin).length()
					var shadow_scale = flashlight_to_wall * shadow_size_factor
					mirrored_position.z = background_wall.global_transform.origin.z + background_wall.scale.z / 2
					customer_shadow.global_transform.origin = mirrored_position
					customer_shadow.scale = Vector3(shadow_scale, shadow_scale, .1)

func apply_light_damage(delta):
	if CustomerSpawn.customer:
		var damage = delta * CustomerSpawn.customer_properties["light_damage_multiplier"]
		apply_damage(damage)

func apply_damage(amount):
	if CustomerSpawn.customer:
		CustomerSpawn.customer_health -= amount
		CustomerSpawn.customer_health = clamp(CustomerSpawn.customer_health, 0, 100)
		update_health_bar()

func update_health_bar():
	if health_bar:
		health_bar.value = CustomerSpawn.customer_health
	if health_bar.value <= 0:
		SceneChangeOverlay.update_wrong()
		free_customer()
		fail_noise.play()

func free_customer():
	if CustomerSpawn.customer:
		CustomerSpawn.customer.queue_free()
		CustomerSpawn.customer = null
		customer_shadow.visible = false

func _on_give_potion_pressed():
	if ObjectControl.added_object_list.size() != CustomerSpawn.customer_remedy.size():
		apply_incorrect_potion()
		return
	
	for object in ObjectControl.added_object_list:
		if object in CustomerSpawn.customer_remedy:
			CustomerSpawn.customer_remedy.erase(object)
		else:
			apply_incorrect_potion()
			return
			
	if CustomerSpawn.customer_remedy.size() == 0:
		apply_correct_potion()

func apply_incorrect_potion():
	apply_damage(75)
	reset_potion_state()

func apply_correct_potion():
	SceneChangeOverlay.update_right()
	free_customer()
	reset_potion_state()
	success_noise.play()

func reset_potion_state():
	ObjectControl.added_object_list = []
	ObjectControl.object_counts = {
		"Bible": 0,
		"Cross": 0,
		"Halo": 0
	}
	potion_box.visible = false
