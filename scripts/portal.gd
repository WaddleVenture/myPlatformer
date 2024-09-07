extends Area2D

const FILE_BEGIN = "levels/level_"

func _on_body_entered(_body: Node2D) -> void:
	
	# Get current scene file path
	var current_scene_file = get_tree().current_scene.scene_file_path
	
	# Find any numbers and add 1 to it
	var next_level_number = current_scene_file.to_int() + 1
	
	# Create our next level path
	var next_level_path = FILE_BEGIN + str(next_level_number) + ".tscn"
	
	# Go to next level
	get_tree().change_scene_to_file.bind(next_level_path).call_deferred()
