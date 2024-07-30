extends Node3D

# Node References
@onready var camera = $Player_View
@onready var flashlight = $Flashlight
@onready var flashlight_collider = flashlight.get_child(0)
@onready var background_wall = $Background_Wall
@onready var cauldron = $Cauldron

# Flashlight Variables
var dragging = false
var dragged_object = null
var offset = Vector3()
var radius = 0.0

# Shadow Variables
var target_object = null
var target_object_rigid = null
var shadow_object = null
var shadow_object_rigid = null
var shadow_z_position = 0.0
var shadow_scale = 1.0
var shadow_shrunk_scale = 0.3
var dropped_into_cauldron = false
var is_dragging_shadow = false
var object_start_position = Vector3()
var cauldron_position = Vector3(-2, -3, -5)

#For user targeting
var temp_object = null
var temp_object_rigid = null

func _ready():
	# Set up initial positions and objects
	if CustomerSpawn.customer:
		CustomerSpawn.customer.position = Vector3(0, 0, 10)

	object_start_position = background_wall.global_transform.origin
	shadow_z_position = background_wall.global_transform.origin.z + background_wall.scale.z / 2 + 0.2
	object_start_position.z = shadow_z_position / 2
	cauldron.global_transform.origin = cauldron_position

	# Instantiate target object
	if not target_object:
		target_object = instance_target()

	# Instantiate shadow object
	if not shadow_object:
		shadow_object = instance_shadow()

	var center_point = target_object.global_transform.origin
	radius = abs(global_transform.origin.z - center_point.z) - 1

	var initial_position = flashlight.global_transform.origin
	var mirrored_position = 2 * center_point - initial_position
	mirrored_position.z = shadow_z_position
	var flashlight_to_wall = (flashlight.global_transform.origin - background_wall.global_transform.origin).length()
	shadow_scale = flashlight_to_wall * ObjectControl.shadow_size_adjust
	shadow_object.global_transform.origin = mirrored_position
	shadow_object.scale = Vector3(shadow_scale, shadow_scale, shadow_scale)

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
					dropped_into_cauldron = false
					is_dragging_shadow = false
					shadow_object_rigid.freeze = true
					check_shadow_dropped_into_cauldron()
	elif event is InputEventMouseMotion:
		if dragging or is_dragging_shadow:
			update_position(event.position)

func shoot_ray():
	var mouse_pos = camera.get_viewport().get_mouse_position()
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
		if collider == flashlight_collider:
			shadow_object_rigid.freeze = true
			dragging = true
			offset = flashlight.global_transform.origin - raycast_result.position
			radius = (flashlight.global_transform.origin - target_object.global_transform.origin).length()
		elif collider == shadow_object_rigid or collider == shadow_object_rigid.get_child(0):
			is_dragging_shadow = true
			offset = shadow_object.global_transform.origin - raycast_result.position
			radius = (shadow_object.global_transform.origin - target_object.global_transform.origin).length()
			if not temp_object:
				temp_object = instance_aiming_shadow()

func update_position(mouse_position: Vector2):
	var from = camera.project_ray_origin(mouse_position)
	var to = from + camera.project_ray_normal(mouse_position) * 1000
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	var raycast_result = space.intersect_ray(ray_query)

	if raycast_result:
		if dragging and raycast_result.collider == flashlight_collider:
			var new_position = raycast_result.position + offset
			var direction = (new_position - target_object.global_transform.origin).normalized()
			flashlight.global_transform.origin = target_object.global_transform.origin + direction * radius
			update_shadow_object_position()
		elif is_dragging_shadow and (raycast_result.collider == shadow_object_rigid or raycast_result.collider == shadow_object_rigid.get_child(0)):
			dropped_into_cauldron = false
			shadow_object_rigid.freeze = true
			shadow_object.global_transform.origin = raycast_result.position + offset
			shadow_object.global_transform.origin.z = shadow_z_position

func instance_target():
	target_object = ObjectControl.object_create()
	if target_object:
		add_child(target_object)
		target_object_rigid = target_object.get_child(0)
		target_object_rigid.freeze = true
		target_object.global_transform.origin = object_start_position
	return target_object

func instance_shadow():
	shadow_object = ObjectControl.object_create()
	if shadow_object:
		add_child(shadow_object)
		shadow_object_rigid = shadow_object.get_child(0)
		shadow_object_rigid.freeze = true
		dropped_into_cauldron = false
		update_shadow_object_position()
		for child in shadow_object_rigid.get_children():
			if child is MeshInstance3D:
				var material = child.material_override
				if material == null:
					material = StandardMaterial3D.new()
					material.albedo_color = Color(0, 0, 0)
					child.material_override = material
			else:
				for sub_child in child.get_children():
					if sub_child is MeshInstance3D:
						var sub_material = sub_child.material_override
						if sub_material == null:
							sub_material = StandardMaterial3D.new()
							sub_material.albedo_color = Color(0, 0, 0)
							sub_child.material_override = sub_material
	return shadow_object

func instance_aiming_shadow():
	temp_object = ObjectControl.object_create()
	if temp_object:
		add_child(temp_object)
		temp_object_rigid = temp_object.get_child(0)
		temp_object_rigid.freeze = true
		temp_object.global_transform.origin = Vector3(-2, 1, shadow_z_position-.1)
		temp_object.scale = shadow_object.scale
		for child in temp_object_rigid.get_children():
			if child is MeshInstance3D:
				var material = child.material_override
				if material == null:
					material = StandardMaterial3D.new()
					material.albedo_color = Color(1, 0, 0)
					child.material_override = material
			else:
				for sub_child in child.get_children():
					if sub_child is MeshInstance3D:
						var sub_material = sub_child.material_override
						if sub_material == null:
							sub_material = StandardMaterial3D.new()
							sub_material.albedo_color = Color(1, 0, 0)
							sub_child.material_override = sub_material
	return temp_object_rigid

func _on_prev_item_pressed():
	reset_objects()
	ObjectControl.object_index = (ObjectControl.object_index - 1) % ObjectControl.object_list.size()
	target_object = instance_target()
	shadow_object = instance_shadow()

func _on_next_item_pressed():
	reset_objects()
	ObjectControl.object_index = (ObjectControl.object_index + 1) % ObjectControl.object_list.size()
	target_object = instance_target()
	shadow_object = instance_shadow()

func update_shadow_object_position():
	var initial_position = flashlight.global_transform.origin
	var mirrored_position = 2 * target_object.global_transform.origin - initial_position
	mirrored_position.z = shadow_z_position
	shadow_object.global_transform.origin = mirrored_position
	shadow_object.scale = Vector3(shadow_scale, shadow_scale, shadow_scale)

func check_shadow_dropped_into_cauldron():
	var cauldron_max = cauldron.global_transform.origin.x + cauldron.scale.x / 2 + 0.3
	var cauldron_min = cauldron.global_transform.origin.x - cauldron.scale.x / 2 - 0.3
	if shadow_object.global_transform.origin.x >= cauldron_min and shadow_object.global_transform.origin.x <= cauldron_max:
		dropped_into_cauldron = true
		shadow_object_rigid.freeze = false
		shadow_object.global_transform.origin.z = cauldron_position.z + 0.5
		temp_object.queue_free()
		temp_object_rigid.queue_free()
		for child in shadow_object_rigid.get_children():
			if target_object.scale < child.scale * shadow_shrunk_scale:
				child.scale = child.scale * shadow_shrunk_scale
			if child.name == "Text":
				child.queue_free()

func reset_objects():
	if is_instance_valid(target_object):
		target_object.queue_free()
	if is_instance_valid(shadow_object):
		shadow_object.queue_free()

func _on_area_3d_body_entered(body):
	if shadow_object_rigid == body:
		var current_scene = ObjectControl.object_list[ObjectControl.object_index]
		ObjectControl.added_object_list.append(current_scene)
		
		# Increment the corresponding count in object_counts
		if current_scene == ObjectControl.bible:
			ObjectControl.object_counts["Bible"] += 1
		elif current_scene == ObjectControl.cross:
			ObjectControl.object_counts["Cross"] += 1
		elif current_scene == ObjectControl.halo:
			ObjectControl.object_counts["Halo"] += 1
		
		shadow_object.queue_free()
		shadow_object = instance_shadow()
		print(ObjectControl.added_object_list)
		information_display()
		update_shadow_object_position()
		
func information_display():
	var vbox_container = $Control/CanvasLayer/VBoxContainer
	
	if vbox_container.get_children():
		for textbox in vbox_container.get_children():
			textbox.queue_free()
			
	for scene_name in ObjectControl.object_counts.keys():
		var count = ObjectControl.object_counts[scene_name]
		if count > 0:
			var vbox = VBoxContainer.new()
			vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
			
			var name_label = Label.new()
			name_label.text = str(count) + "x " + scene_name
			name_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			vbox.add_child(name_label)
			
			vbox_container.add_child(vbox)
	print(ObjectControl.added_object_list)
	print(CustomerSpawn.customer_remedy)

func _on_empty_cauldron_pressed():
	ObjectControl.added_object_list = []
	ObjectControl.object_counts = {
		"Bible": 0,
		"Cross": 0,
		"Halo": 0
	}
	information_display()
