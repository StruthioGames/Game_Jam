extends Node3D

@onready var flashlight = $Flashlight
@onready var shadow_object = $Cube_Shadow
@onready var background_wall = $Background_Wall
@onready var actual_object = $Cube

var center_point = Vector3()

func _ready():
	# Set the center point to the actual object's position
	center_point = actual_object.global_transform.origin

func _process(delta):
	# Get the flashlight's position with full precision
	var initial_position = flashlight.global_transform.origin
	
	# Print the position to the console with extra decimal places
	print("Flashlight Position: ", format_vector3(initial_position))
	
	# Calculate the mirrored position relative to the center point
	var mirrored_position = 2 * center_point - initial_position
	
	# Adjust the mirrored position to the background wall's Z position
	mirrored_position.z = background_wall.global_transform.origin.z + 6
	
	# Set the shadow object's position
	shadow_object.global_transform.origin = mirrored_position

	# Optionally print the shadow object's position to verify
	print("Shadow Object Position: ", format_vector3(shadow_object.global_transform.origin))

func format_vector3(vec):
	return "(" + str(vec.x) + ", " + str(vec.y) + ", " + str(vec.z) + ")"
