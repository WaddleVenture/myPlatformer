class_name IdleState
extends State

@export var actor: Player
@export var animator: AnimatedSprite2D

signal run
signal jump
signal fall
signal roll
signal death
signal dash

var squash_states = [JumpState, FallState, DoubleJumpState]

func _ready() -> void:
	set_physics_process(false)


func _enter(from_state: State = null) -> void:
	set_physics_process(true)
	animator.play("idle")
	for state in squash_states:
		if is_instance_of(from_state, state):
			animator.scale = Vector2(1.3,0.7)
	actor.can_dash = true


func _exit() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	actor.move_and_slide()
	actor.apply_friction(0, delta)
	actor.handle_drop()


	# CHANGING STATES
	if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
		run.emit()


	if Input.is_action_just_pressed("jump") or actor.jump_buffer_timer.time_left > 0:
		actor.jump_buffer_timer.stop()
		jump.emit()


	if not actor.is_on_floor():
		fall.emit()


	if Input.is_action_just_pressed("roll") and actor.is_on_floor():
		roll.emit()


	if Input.is_action_just_pressed("dash") and actor.is_on_floor():
		var input_x := Input.get_axis("move_left", "move_right")
		var input_y := Input.get_axis("move_up", "move_down")
		actor.dash_timer.start()
		actor.detect_dash_direction(input_x, input_y)
		dash.emit()


	if not actor.is_alive:
		death.emit()


	actor.cancel_squash_and_stretch(delta)
