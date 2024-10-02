class_name RunState
extends State

@export var actor: Player
@export var animator: AnimatedSprite2D

signal idle
signal jump
signal fall

func _ready() -> void:
	set_physics_process(false)
	

func _enter(from_state: State = null) -> void:
	set_physics_process(true)
	if from_state is JumpState or FallState:
		animator.scale = Vector2(1.3,0.7)

func _exit() -> void:
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	actor.move_and_slide()
	animator.play("run")

	var input_axis := Input.get_axis("move_left", "move_right")
	actor.flip_sprite(input_axis)
	actor.apply_friction(input_axis, delta)
	actor.apply_acceleration(input_axis, delta)
	actor.apply_air_resistance(input_axis, delta)
	actor.apply_air_acceleration(input_axis, delta)
	actor.cancel_squash_and_stretch(delta)
	actor.handle_drop()
	
	# CHANGING STATES
	if not Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left"):
		idle.emit()
	
	if Input.is_action_pressed("jump") or actor.jump_buffer_timer.time_left > 0:
		actor.jump_buffer_timer.stop()
		jump.emit()

	if not actor.is_on_floor() and actor.coyote_timer.is_stopped():
		actor.coyote_timer.start()
		fall.emit()
