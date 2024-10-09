class_name DeathState
extends State

@export var actor: Player
@export var animator: AnimatedSprite2D


func _ready() -> void:
	set_physics_process(false)


func _enter(_from_state: State = null) -> void:
	set_physics_process(true)
	actor.velocity = Vector2.ZERO 
	actor.animated_sprite.play("death")
	animator.scale = Vector2(1, 1)
	PlayerPowers.reset_temp_powers()


func _exit() -> void:
	set_physics_process(false)


func _physics_process(_delta: float) -> void:
	return
