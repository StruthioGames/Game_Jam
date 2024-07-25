extends Node3D

# Export variables to adjust in the editor
@onready var raycast_length: float = 1000.0

# Reference to the RayCast3D node
@onready var raycast = $ShadowShapeRayCast

# The cube that will be displayed on the wall
@onready var display_cube = get_node("../Cube_Shadow")

func _ready():
	raycast.target_position = Vector3(0, 0, -raycast_length) # Adjust direction as needed
	raycast.enabled = true

func _process(delta):
	update_light_trace()

func update_light_trace():
	# Set the target_position direction based on the SpotLight3D's orientation
	raycast.target_position = -global_transform.basis.z * raycast_length
	if raycast.is_colliding():
		var collision_point = raycast.get_collision_point()
		display_cube.global_transform.origin = collision_point
		display_cube.visible = true
	else:
		display_cube.visible = false
