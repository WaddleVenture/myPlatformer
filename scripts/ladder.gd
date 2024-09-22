extends Area2D

@onready var ray_cast_up: RayCast2D = $RayCastUp

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("add_ladder_count"): 
		body.add_ladder_count(self)


func _on_body_exited(body: Node2D) -> void:
	if body.has_method("remove_ladder_count"):
		body.remove_ladder_count(self)


func is_ladder_above() -> bool:
	ray_cast_up.enabled = true 
	if ray_cast_up.is_colliding():
		return false
	return true
	

func _on_top_ladder_body_entered(body: Node2D) -> void:
	if is_ladder_above():
		body.is_on_top_of_ladder = true


func _on_top_ladder_body_exited(body: Node2D) -> void:
	body.is_on_top_of_ladder = false
