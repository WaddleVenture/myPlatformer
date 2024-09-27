class_name FallState
extends State

@export var actor: Player
@export var animator: AnimatedSprite2D

signal run
signal jump

func _ready() -> void:
	set_physics_process(false)

func _enter(from_state: State = null) -> void:
	set_physics_process(true)
	animator.play("jump")


func _exit() -> void:
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	pass
