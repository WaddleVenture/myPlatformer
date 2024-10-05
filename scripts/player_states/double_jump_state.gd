class_name DoubleJumpState
extends State

@export var actor: Player
@export var animator: AnimatedSprite2D

@onready var jump_sound: AudioStreamPlayer2D = $"../../JumpSound"

signal idle
signal run
signal wall_jump

func _ready() -> void:
	set_physics_process(false)

func _enter(from_state: State = null) -> void:
	set_physics_process(true)
	jump_sound.play()
	animator.scale = Vector2(0.9, 1.1)
	actor.velocity.y = actor.movement_data.jump_velocity * 0.8


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
	
	if Input.is_action_just_pressed("jump"):
		actor.jump_buffer_timer.start()

	# CHANGING STATES
	if actor.is_on_floor():
		if Input.get_axis("move_left", "move_right") != 0:
			run.emit()
		else:
			idle.emit()


	if PlayerPowers.can_wall_jump or PlayerPowers.temp_can_wall_jump: 
		if not actor.is_on_wall_only() and actor.wall_jump_timer.time_left <= 0.0 : return
		actor.wall_normal = actor.get_wall_normal()
		if actor.wall_jump_timer.time_left > 0.0: 
			actor.wall_normal = actor.was_wall_normal
		
		if Input.is_action_just_pressed("jump"):
			wall_jump.emit()
