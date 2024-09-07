extends Area2D

@onready var level_manager: Node = %LevelManager
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func elevated_coin():
	var tween = create_tween()
	tween.tween_property(self, "position", position + Vector2(0, -15), 0.3)
	tween.tween_property(self, "modulate:a", 0, 0.3)
	tween.tween_callback(self.queue_free)
	

func _on_body_entered(_body: Node2D) -> void:
	level_manager.add_point()
	animation_player.play("pickup")
