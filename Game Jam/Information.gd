extends Control

@onready var canvas = $CanvasLayer

var shadows = {
	"Shade": "Discolored shadow. Light damage is high. Remedy: 1 cross, 1 bible, and 1 halo",
	"Poltergeist": "Inverted shadow. Light damage is high. Remedy: 1 cross and 2 halos",
	"Demon": "No shadow. Light damage is low. Remedy: 3 crosses"
}

func _ready():
	canvas.hide()
	populate_notebook()

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == Key.KEY_R:
		toggle_notebook()

func toggle_notebook():
	if canvas.visible:
		canvas.hide()
	else:
		canvas.show()

func populate_notebook():
	var vbox_container = $CanvasLayer/VBoxContainer
	
	for child in vbox_container.get_children():
		child.queue_free()

	for i in range(min(shadows.size(), 3)):
		var shadow_name = shadows.keys()[i]
		var shadow_details = shadows[shadow_name]

		var vbox = VBoxContainer.new()
		vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL

		var spacer_top = Control.new()
		spacer_top.size_flags_vertical = Control.SIZE_EXPAND
		spacer_top.size_flags_horizontal = Control.SIZE_EXPAND
		vbox.add_child(spacer_top)

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

		var spacer_bottom = Control.new()
		spacer_bottom.size_flags_vertical = Control.SIZE_EXPAND
		spacer_bottom.size_flags_horizontal = Control.SIZE_EXPAND
		vbox.add_child(spacer_bottom)

		vbox_container.add_child(vbox)
