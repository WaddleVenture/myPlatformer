class_name IdleState
extends State

@export var actor: Player
@export var animator: AnimatedSprite2D

signal run
signal jump

func _ready() -> void:
	set_physics_process(false)

func _enter(from_state: State = null) -> void:
	set_physics_process(true)
	animator.play("idle")
	if from_state is JumpState:
		animator.scale = Vector2(1.3,0.7)

func _exit() -> void:
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	actor.move_and_slide()
	
	actor.apply_friction(0, delta)
	actor.apply_gravity(delta)
	actor.apply_air_resistance(0, delta)
	
	if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
		run.emit()
	
	if Input.is_action_just_pressed("jump"):
		jump.emit()
	
	actor.cancel_squash_and_stretch(delta)
