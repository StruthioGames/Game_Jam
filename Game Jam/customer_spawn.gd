extends Node3D

@export var customer_spawn_scene: PackedScene
@onready var rng = RandomNumberGenerator.new()

var customer: Node3D = null
var customer_state = false
var flashlight_on = false
var customer_health = null
var customer_remedy = []
var customer_properties = {}
var customer_properties_dict = {
	"Demon": {
		"type": "Demon",
		"shadow_color": Color(0, 0, 0),
		"shadow_behavior": "none",
		"light_damage_multiplier": 10.0
	},
	"Poltergiest": {
		"type": "Poltergiest",
		"shadow_color": Color(0, 0, 0),  
		"shadow_behavior": "inverted",
		"light_damage_multiplier": 20.0
	},
	"Shade": {
		"type": "Shade",
		"shadow_color": Color(0, 0, 0),
		"shadow_behavior": "translucent",
		"light_damage_multiplier": 20.0
	}
}
var type_number = null
var list_types = ["Demon", "Poltergiest", "Shade"]
var customer_type = null

func is_customer_visible() -> bool:
	return customer and customer.visible

func spawn_customer():
	if not customer:
		customer_health = 100
		type_number = rng.randi_range(0, list_types.size() - 1)
		customer_type = list_types[type_number]
		customer_properties = customer_properties_dict[customer_type]
		customer_remedy = ObjectControl.get_remedy()
		customer = customer_spawn_scene.instantiate()
		add_child(customer)
		var red = rng.randf_range(0,1)
		var green = rng.randf_range(0,1)
		var blue = rng.randf_range(0,1)
		if customer.get_child(0):
			var material = customer.get_child(0).material_override
			if material == null:
				material = StandardMaterial3D.new()
				material.albedo_color = Color(red, green, blue)
				customer.get_child(0).material_override = material
		customer.visible = false

func show_customer():
	if customer and not customer.visible:
		customer.visible = true
		set_customer_properties()
	elif not customer:
		spawn_customer()
		show_customer()

func hide_customer():
	if customer and customer.visible:
		customer.visible = false
	if customer:
		customer.queue_free()
		customer = null

func set_customer_properties():
	if "type" in customer_properties:
		print("Remedy: ", customer_remedy)
		print(customer_properties["type"])
		print("Shadow Color: ", customer_properties["shadow_color"])
		print("Shadow Behavior: ", customer_properties["shadow_behavior"])
		print("Light Damage Multiplier: ", customer_properties["light_damage_multiplier"])
