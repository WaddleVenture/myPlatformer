class_name FallState
extends State

@export var actor: Player
@export var animator: AnimatedSprite2D

signal run
signal idle

func _ready() -> void:
	set_physics_process(false)

func _enter(from_state: State = null) -> void:
	set_physics_process(true)
	animator.play("jump")


func _exit() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	actor.move_and_slide()
	actor.apply_gravity(delta)
	actor.apply_air_resistance(0, delta)
	var input_axis := Input.get_axis("move_left", "move_right")
	actor.flip_sprite(input_axis)
	actor.apply_air_resistance(input_axis, delta)
	actor.apply_air_acceleration(input_axis, delta)
	
	if actor.is_on_floor():
		idle.emit()
