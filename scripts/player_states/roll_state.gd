class_name RollState
extends State

@export var actor: Player
@export var animator: AnimatedSprite2D

signal idle
signal run
signal jump
signal fall

func _ready() -> void:
	set_physics_process(false)

func _enter(from_state: State = null) -> void:
	set_physics_process(true)
	animator.play("roll")
	animator.scale = Vector2(1, 1)
	

func _exit() -> void:
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	actor.move_and_slide()
	actor.handle_drop()
	
	if animator.flip_h:
		actor.velocity.x = -actor.movement_data.roll_speed
	else:
		actor.velocity.x = actor.movement_data.roll_speed


	# CHANGING STATES
	if not animator.is_playing():
		if actor.is_on_floor():
			if Input.get_axis("move_left", "move_right") != 0:
				run.emit()
			else:
				idle.emit()
	
	if Input.is_action_pressed("jump") or actor.jump_buffer_timer.time_left > 0:
		actor.jump_buffer_timer.stop()
		jump.emit()


	if not actor.is_on_floor() and actor.coyote_timer.is_stopped():
		actor.coyote_timer.start()
		fall.emit()
