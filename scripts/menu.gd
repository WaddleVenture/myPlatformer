extends Control

@onready var continue_button: Button = $VBoxContainer/ContinueButton

func _ready() -> void:
	$VBoxContainer/StartButton.grab_focus()
	check_save_file()
	

func _on_start_button_pressed() -> void:
	PlayerPowers.reset_powers()
	SaveManager.reset_save()
	get_tree().change_scene_to_file("res://levels/level_0.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
	

# Check if a save file exists
func check_save_file() -> void:
	if FileAccess.file_exists(SaveManager.save_path):
		continue_button.disabled = false
		continue_button.modulate = Color(1, 1, 1, 1)
	else:
		continue_button.disabled = true
		continue_button.modulate = Color(1, 1, 1, 0.8)


func _on_continue_button_pressed() -> void:
	var save_data = SaveManager.load_game()
	if save_data.has("level"):
		var level_path = "res://levels/level_%d.tscn" % save_data["level"]
		get_tree().change_scene_to_file(level_path)
	else:
		print("No valid save data found.")
