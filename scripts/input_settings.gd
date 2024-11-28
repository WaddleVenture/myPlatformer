extends Control

@onready var action_list: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ActionList
const input_button_scene = preload("res://scenes/input_settings/input_button.tscn")

var is_remapping: bool = false
var action_to_remap = null
var remapping_button: Button = null

var input_actions = {
	"move_up": "Move up",
	"move_down": "Move down",
	"move_left": "Move left",
	"move_right": "Move right",
	"jump": "Jump",
	"dash": "Dash",
	"roll": "Roll",
}

func _ready() -> void:
	create_action_list()

func create_action_list():
	# Load the default input settings
	InputMap.load_from_project_settings()

	# Clear the action list
	for item in action_list.get_children():
		item.queue_free()

	# Populate the list
	for action in input_actions:
		var button = input_button_scene.instantiate()
		var action_label = button.find_child("LabelAction")
		var input_label = button.find_child("LabelInput")

		action_label.text = input_actions[action]

		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			input_label.text = events[0].as_text().trim_suffix(" (Physical)")
		else:
			input_label.text = ""

		action_list.add_child(button)
		button.pressed.connect(on_input_button_pressed.bind(button, action))

func on_input_button_pressed(button, action):
	if !is_remapping:
		is_remapping = true
		action_to_remap = action
		remapping_button = button
		button.find_child("LabelInput").text = "Press any key..."

func _input(event: InputEvent) -> void:
	if is_remapping and event is InputEventKey and event.is_pressed():
		# Update the action mapping
		InputMap.action_erase_events(action_to_remap)
		InputMap.action_add_event(action_to_remap, event)

		# Update the button's label
		update_action_list(remapping_button, event)

		# Reset remapping state
		is_remapping = false
		action_to_remap = null
		remapping_button = null

		# Mark the event as handled
		accept_event()

func update_action_list(button, event: InputEventKey):
	# Update the button's label with the key name
	button.find_child("LabelInput").text = event.as_text().trim_suffix(" (Physical)")


func _on_reset_button_pressed() -> void:
	create_action_list()
