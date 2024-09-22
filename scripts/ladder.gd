extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("add_ladder_count"): 
		body.add_ladder_count(self)


func _on_body_exited(body: Node2D) -> void:
	if body.has_method("remove_ladder_count"):
		body.remove_ladder_count(self)
		body.was_climbing = false
