class_name State
extends Node

signal state_finished

# Méthode appelée lors de l'entrée dans l'état
func _enter(from_state: State = null) -> void:
	pass

# Méthode appelée lors de la sortie de l'état
func _exit() -> void:
	pass
