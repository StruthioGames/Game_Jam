extends Camera3D

@export var customer_position: Node3D
@export var bell: StaticBody3D
@onready var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	CustomerSpawn.customer.position = customer_position.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	if not CustomerSpawn.is_customer_visible():
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed:
					shoot_ray()

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
		if collider == bell:
			_on_bell_clicked()

func _on_bell_clicked():
	CustomerSpawn.spawn_customer()
