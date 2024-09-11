extends Node

# Path to save the file
var save_path = "user://savegame.json"

# Function to save the game
func save_game(level: int):
	# Saving the current level and the player powers
	var save_data = {
		"level": level,
		"player_powers": PlayerPowers.get_power_data() 
	}


	# Open the file for writing
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		print("Game saved!")


# Function to load the game
func load_game() -> Dictionary:
	if not FileAccess.file_exists(save_path):
		print("No save file found!")
		return {}
	
	# Open the file for reading
	var file = FileAccess.open(save_path, FileAccess.READ)
	if file:
		# Create a json for parsing
		var json = file.get_as_text()
		var saved_data = JSON.parse_string(json)
		
		print(saved_data)
		file.close()
		
		# Load power
		PlayerPowers.set_power_data(saved_data["player_powers"])
		print("Game loaded!")
		return saved_data
	return {}


# Function to reset the save
func reset_save():
	PlayerPowers.reset_powers()
	DirAccess.remove_absolute(save_path)
	print("Save reset!")
