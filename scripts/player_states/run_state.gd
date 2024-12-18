class_name RunState
extends State

@export var actor: Player
@export var animator: AnimatedSprite2D

signal idle
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
	for state in squash_states:
		if is_instance_of(from_state, state):
			animator.scale = Vector2(1.3,0.7)
	actor.can_dash = true


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
