class_name WallJumpState
extends State

@export var actor: Player
@export var animator: AnimatedSprite2D

@onready var jump_sound: AudioStreamPlayer2D = $"../../JumpSound"


signal idle
signal run
signal wall_jump
signal death


func _ready() -> void:
	set_physics_process(false)

func _enter(_from_state: State = null) -> void:
	set_physics_process(true)
	jump_sound.play()
	animator.scale = Vector2(0.9, 1.1)
	
	if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
		actor.velocity.x = actor.wall_normal.x * actor.movement_data.speed
		actor.velocity.y = actor.movement_data.jump_velocity 
	else:
		actor.velocity.x = actor.wall_normal.x * actor.movement_data.wall_jump_neutral_speed
		actor.velocity.y = actor.movement_data.jump_velocity 

func _exit() -> void:
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	actor.store_wall_jump_normal()

	actor.move_and_slide()
	
	actor.start_wall_jump_timer()
	
	actor.velocity.y += actor.gravity * delta
	
	var input_axis := Input.get_axis("move_left", "move_right")
	actor.apply_air_acceleration(input_axis, delta)
	actor.apply_air_resistance(input_axis, delta)
	actor.flip_sprite(input_axis)
	animator.play("jump")


	# Jump buffer
	if Input.is_action_just_pressed("jump"):
		actor.jump_buffer_timer.start()


	# CHANGING STATES
	if actor.is_on_floor():
		if Input.get_axis("move_left", "move_right") != 0:
			run.emit()
		else:
			idle.emit()


	if not actor.is_on_wall_only() and actor.wall_jump_timer.time_left <= 0.0 : return
	actor.wall_normal = actor.get_wall_normal()
	if actor.wall_jump_timer.time_left > 0.0: 
		actor.wall_normal = actor.was_wall_normal
	
	if Input.is_action_just_pressed("jump"):
		wall_jump.emit()
	
	if not actor.is_alive:
		death.emit()
