extends Node

# Variables
var can_wall_jump = false
var can_double_jump = false


# Functions to unlock powers
func unlock_wall_jump():
	can_wall_jump = true


func unlock_double_jump():
	can_double_jump = true


# Reset powers to initial state
func reset_temporary_powers():
	can_wall_jump = false
	can_double_jump = false
	# TODO : Add load_powers() or juste change it to load saved state

# TODO : Add save state and load state
