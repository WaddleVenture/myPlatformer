class_name DashState
extends State

@export var actor: Player
@export var animator: AnimatedSprite2D


signal idle
signal fall
signal run


func _ready() -> void:
	set_physics_process(false)


func _enter(_from_state: State = null) -> void:
	set_physics_process(true)
	animator.scale = Vector2(1, 1)
	actor.collision_shape_2d.disabled = false


func _exit() -> void:
	set_physics_process(false)
	actor.velocity = actor.dash_direction * actor.movement_data.speed


func _physics_process(_delta: float) -> void:
	actor.move_and_slide()


	actor.velocity = actor.dash_direction * actor.movement_data.dash_speed


	# CHANGING STATES
	if actor.dash_timer.is_stopped():
		if not actor.is_on_floor():
			fall.emit()
		else:
			if Input.get_axis("move_left", "move_right") != 0:
				run.emit()
			else:
				idle.emit()
