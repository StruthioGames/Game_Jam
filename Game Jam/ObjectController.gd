extends Control

@export var bible: PackedScene
@export var cross: PackedScene
@export var halo: PackedScene

var object_list = []
var shadow_size_adjust = .15
var added_object_list = []
var object_index = 0
var object_counts = {
	"Bible": 0,
	"Cross": 0,
	"Halo": 0
}

# Called when the node enters the scene tree for the first time.
func _ready():
	object_list = [bible, cross, halo]

func object_create():
	return object_list[object_index].instantiate()

func get_remedy():
	var remedy_list = []
	if CustomerSpawn.customer_properties["type"] == "Demon":
		remedy_list = [cross, cross, cross]
	elif CustomerSpawn.customer_properties["type"] == "Poltergiest":
		remedy_list = [cross, halo, halo]
	elif CustomerSpawn.customer_properties["type"] == "Shade":
		remedy_list = [bible, cross, halo]
	
	return remedy_list
