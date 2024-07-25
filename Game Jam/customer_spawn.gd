extends Node3D

@export var customer: Node3D
@onready var rng = RandomNumberGenerator.new()

var customer_state = false
var customer_properties = {}
var type_number = null
var list_types = []
var customer_type = null

func _ready():
	customer.visible = false
	list_types = ["Demon", "Poltergiest", "Shade"]
	type_number = rng.randi_range(0, list_types.size() - 1)
	customer_type = list_types[type_number]
	customer_properties = {"type": customer_type}
	print(customer_type)

func is_customer_visible():
	if customer.visible:
		return true
	else:
		return false

func spawn_customer():
	if not customer.visible:
		customer.visible = true

func show_customer():
	if customer and not customer.visible:
		customer.visible = true
		set_customer_properties()

func set_customer_properties():
	if "color" in customer_properties:
		if customer.has_method("set_color"):
			customer.set_color(customer_properties["color"])
	if "type" in customer_properties:
		print(customer_properties["type"])
