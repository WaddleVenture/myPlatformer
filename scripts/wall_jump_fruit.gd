extends Area2D

# Power to unlock
enum Power {
	WALL_JUMP,
	DOUBLE_JUMP
}

@export var power_to_unlock: Power

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func elevated_animation():
	var tween = create_tween()
	tween.tween_property(self, "position", position + Vector2(0, -20), 0.2)
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.15)
	tween.tween_property(self, "modulate:a", 0, 0.25)
	tween.tween_callback(self.queue_free)


func _on_body_entered(_body: Node2D) -> void:
	animation_player.play("power_up_animation")
	unlock_power(power_to_unlock)
	

# Function to unlock the power
func unlock_power(power: Power) -> void:
	match power:
		Power.WALL_JUMP:
			PlayerPowers.unlock_wall_jump()
		Power.DOUBLE_JUMP:
			PlayerPowers.unlock_double_jump()
		_:
			print("Unknown power: " + str(power))
