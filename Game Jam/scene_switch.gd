extends Control

@export var greetings: PackedScene
@export var investigation: PackedScene
@export var alchemy: PackedScene

@onready var back_button = $CanvasLayer/Backward
@onready var forward_button = $CanvasLayer/Forward

var scene_list = []
var current_scene_index = 0

func _ready():
	scene_list = [greetings, investigation, alchemy]
	update_buttons()

func _on_backward_pressed():
	move_to_previous_scene()

func _on_forward_pressed():
	move_to_next_scene()

func move_to_previous_scene():
	if current_scene_index > 0:
		current_scene_index -= 1
		SceneSwitcher.switch_scene(scene_list[current_scene_index].get_path())
		update_buttons()

func move_to_next_scene():
	if current_scene_index < scene_list.size() - 1:
		current_scene_index += 1
		SceneSwitcher.switch_scene(scene_list[current_scene_index].get_path())
		update_buttons()

func update_buttons():
	if current_scene_index > 0:
		back_button.show()
		var text_name = scene_name(scene_list[current_scene_index - 1])
		back_button.text = text_name
	else:
		back_button.hide()

	if current_scene_index < scene_list.size() - 1:
		forward_button.show()
		var text_name = scene_name(scene_list[current_scene_index + 1])
		forward_button.text = text_name
	else:
		forward_button.hide()
		
func scene_name(current_scene):
	var file_name = current_scene.get_path().get_file()
	var underscore_location = file_name.find("_")
	var text_name = file_name.substr(0, underscore_location)
	return text_name
