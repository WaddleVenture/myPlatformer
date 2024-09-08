extends Area2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func elevated_coin():
	var tween = create_tween()
	tween.tween_property(self, "position", position + Vector2(0, -20), 0.2)
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.15)
	tween.tween_property(self, "modulate:a", 0, 0.25)
	tween.tween_callback(self.queue_free)

func _on_body_entered(body: Node2D) -> void:
	PlayerPowers.unlock_wall_jump()
	animation_player.play("power_up_animation")
