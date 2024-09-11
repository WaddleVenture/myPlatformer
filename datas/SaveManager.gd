extends Node

# Path to save the file
var save_path = "user://savegame.tres"

# Function to save the game
func save_game(level: int):
	var saved_game: SavedGame = SavedGame.new()
	
	saved_game.level = level
	saved_game.player_powers = PlayerPowers.get_power_data() 

	ResourceSaver.save(saved_game, save_path)


# Function to load the game
func load_game() -> SavedGame:
	var saved_game:SavedGame = load(save_path)
	PlayerPowers.set_power_data(saved_game.player_powers)
	return saved_game


# Function to reset the save
func reset_save():
	PlayerPowers.reset_powers()
	DirAccess.remove_absolute(save_path)
	print("Save reset!")
