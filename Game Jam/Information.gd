extends Control

@onready var possession_canvas = $Possession_Layer
@onready var tutorial_layer = $Tutorial_Layer

var shadows = {
	"Shade": "Normal shadow. Light damage is high. Remedy: 1 Bible, 1 Cross, and 1 Halo",
	"Poltergeist": "Inverted shadow. Light damage is high. Remedy: 1 Cross and 2 Halos",
	"Demon": "No shadow. Light damage is low. Remedy: 3 Crosses"
}

var tutorial = [
	"The Lord has given you the missions of ridding these people of their supernatural parasites.",
	"Their shadows will tell you what monster is infecting them, pay attention to their shape.",
	"Use the church's alchemy station and our exorcism equipment to remove these ghosts, and put them to rest.",
	"You must manipulate the shadows to solve your problems, grab them to create remedies.",
	"Each possession will take light damage, right click the mouse to turn the light on/off",
	"Press 'r' to find out the symptoms and solutions for each possession",
	"Grab the shadows of the Holy equipment and aim for the red target to add it to the cauldron",
	"If you get the potion wrong or their health drops to 0, you may end up failing to save your charge."
	]

func _ready():
	possession_canvas.hide()
	tutorial_layer.hide()
	populate_notebook()
	populate_tutorial()

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == Key.KEY_R:
			toggle_notebook()
		elif event.keycode == Key.KEY_T:
			toggle_tutorial()

func toggle_notebook():
	if possession_canvas.visible:
		possession_canvas.hide()
	else:
		possession_canvas.show()

func toggle_tutorial():
	if tutorial_layer.visible:
		tutorial_layer.hide()
	else:
		tutorial_layer.show()

func populate_notebook():
	var vbox_container = $Possession_Layer/Possession_Details
	
	for child in vbox_container.get_children():
		child.queue_free()

	for i in range(shadows.size()):
		var shadow_name = shadows.keys()[i]
		var shadow_details = shadows[shadow_name]

		var vbox = VBoxContainer.new()
		vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL

		var name_label = Label.new()
		name_label.text = shadow_name
		name_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		vbox.add_child(name_label)

		var details_array = shadow_details.split(". ", true, 0)
		for detail in details_array:
			var detail_label = Label.new()
			detail_label.text = detail.strip_edges(true, false)
			detail_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			vbox.add_child(detail_label)

		vbox_container.add_child(vbox)

func populate_tutorial():
	var vbox_container = $Tutorial_Layer/Tutorial
	
	for child in vbox_container.get_children():
		child.queue_free()

	for line in tutorial:
		var tutorial_label = Label.new()
		tutorial_label.text = line
		tutorial_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		vbox_container.add_child(tutorial_label)
