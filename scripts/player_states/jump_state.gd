class_name JumpState
extends State

@export var actor: Player
@export var animator: AnimatedSprite2D

@onready var jump_sound: AudioStreamPlayer2D = $"../../JumpSound"

var jump_released: bool = false

signal idle
signal run

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
			
			
