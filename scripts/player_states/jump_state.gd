class_name JumpState
extends State

@export var actor: Player
@export var animator: AnimatedSprite2D

@onready var jump_sound: AudioStreamPlayer2D = $"../../JumpSound"

var jump_released: bool = false

signal idle
signal run
signal double_jump
signal wall_jump

func _ready() -> void:
	set_physics_process(false)

func _enter(from_state: State = null) -> void:
	set_physics_process(true)
	animator.scale = Vector2(0.9, 1.1)
	actor.velocity.y = actor.movement_data.jump_velocity
	jump_sound.play()
	jump_released = false

func _exit() -> void:
	set_physics_process(false)

func _physics_process(delta: float) -> void:

	actor.move_and_slide()
	
	## Detect wall position
	#actor.was_on_wall = actor.is_on_wall_only()
	#
	## Storing the wall normal
	#if actor.was_on_wall:
		#actor.was_wall_normal = actor.get_wall_normal()
	#
	## Check if the player just left the wall to start a timer
	#var just_left_wall = actor.was_on_wall and not actor.is_on_wall()
	#if just_left_wall:
		#actor.wall_jump_timer.start()
	
	
	actor.velocity.y += actor.gravity * delta
	
	var input_axis := Input.get_axis("move_left", "move_right")
	actor.apply_air_acceleration(input_axis, delta)
	actor.apply_air_resistance(input_axis, delta)
	actor.flip_sprite(input_axis)
	
	
	animator.play("jump")
	
	# Jump variation
	if Input.is_action_just_released("jump") and not jump_released:
		actor.velocity.y *= 0.4
		jump_released = true
	
	# Jump buffer
	if Input.is_action_just_pressed("jump"):
		actor.jump_buffer_timer.start()

	# CHANGING STATES
	if actor.is_on_floor():
		if Input.get_axis("move_left", "move_right") != 0:
			run.emit()
		else:
			idle.emit()
	
	if (PlayerPowers.can_double_jump or PlayerPowers.temp_can_double_jump):
		if Input.is_action_just_pressed("jump"):
			double_jump.emit()
	
	if (PlayerPowers.can_wall_jump or PlayerPowers.temp_can_wall_jump):
		if Input.is_action_just_pressed("jump"):
			wall_jump.emit()
