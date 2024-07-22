extends Node3D

@onready var flashlight = $Flashlight
@onready var background_wall = $Background_Wall
@onready var shadow_object = $Cube_Shadow
@onready var actual_object = $Cube

var center_point = Vector3()

func _ready():
	# Set the center point to the actual object's position
	center_point = actual_object.global_transform.origin

func _process(delta):
	# Get the flashlight's position
	var initial_position = flashlight.global_transform.origin
	
	# Calculate the mirrored position relative to the center point
	var mirrored_position = 2 * center_point - initial_position
	print(mirrored_position)
	
	# Adjust the mirrored position to the background wall's Z position
	mirrored_position.z = background_wall.global_transform.origin.z + 6
	
	# Set the shadow object's position
	shadow_object.global_transform.origin = mirrored_position
	print(shadow_object.global_transform.origin)
