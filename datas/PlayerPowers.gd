extends Node

var can_wall_jump = false
var can_double_jump = false

var temp_can_wall_jump = false
var temp_can_double_jump = false


# Functions to unlock powers temporarily
func unlock_wall_jump_temp():
	temp_can_wall_jump = true

func unlock_double_jump_temp():
	temp_can_double_jump = true


# Functions to unlock powers
func unlock_wall_jump():
	can_wall_jump = true

func unlock_double_jump():
	can_double_jump = true

# Get powers from a dictionary
func get_power_data() -> Dictionary:
	return {
		"can_wall_jump": can_wall_jump,
		"can_double_jump": can_double_jump
	}

# Set powers
func set_power_data(data: Dictionary) -> void:
	can_wall_jump = data.get("can_wall_jump", false)
	can_double_jump = data.get("can_double_jump", false)

# Reset powers
func reset_powers():
	can_wall_jump = false
	can_double_jump = false

# Reset temporary powers
func reset_temp_powers():
	temp_can_wall_jump = false
	temp_can_double_jump = false

# Apply temporary powers if confirmed
func apply_temp_powers():
	if temp_can_wall_jump:
		unlock_wall_jump()
	if temp_can_double_jump:
		unlock_double_jump()

	# Reset temporary powers
	temp_can_wall_jump = false
	temp_can_double_jump = false
