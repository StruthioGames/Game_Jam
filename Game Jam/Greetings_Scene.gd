extends Node3D

@export var customer_position: Node3D
@export var spawn_bell: StaticBody3D
@export var delete_bell: StaticBody3D

@onready var camera = $Camera3D
@onready var spawn_audio = $BellSpawnAudio
@onready var delete_audio = $BellDeleteAudio

func _ready():
	if CustomerSpawn.customer:
		CustomerSpawn.customer.position = customer_position.position

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		shoot_ray()

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
		if collider == spawn_bell:
			_on_spawn_clicked()
		elif collider == delete_bell:
			_on_delete_clicked()

func _on_spawn_clicked():
	CustomerSpawn.show_customer()
	CustomerSpawn.customer.position = customer_position.position
	spawn_audio.play()
	
func _on_delete_clicked():
	CustomerSpawn.hide_customer()
	delete_audio.play()
	
