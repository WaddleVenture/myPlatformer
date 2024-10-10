class_name LadderState
extends State

@export var actor: Player
@export var animator: AnimatedSprite2D


signal jump
signal fall
signal death


func _ready() -> void:
	set_physics_process(false)


func _enter(_from_state: State = null) -> void:
	set_physics_process(true)
	animator.play("jump")
	animator.scale = Vector2(1, 1)


func _exit() -> void:
	set_physics_process(false)


func _physics_process(_delta: float) -> void:
	actor.move_and_slide()
	
	
	
	if Input.is_action_pressed("move_up") and not actor.is_on_top_of_ladder:
		actor.velocity.y = -actor.movement_data.speed
	elif Input.is_action_pressed("move_down"):
		actor.velocity.y = actor.movement_data.speed
	else:
		actor.velocity.y = 0

	
	var input_axis := Input.get_axis("move_left", "move_right")
	actor.apply_ladder_movement(input_axis)
	actor.flip_sprite(input_axis)


	# CHANGING STATES
	if actor.ladder_count <= 0:
		fall.emit()
	
	if Input.is_action_just_pressed("jump"):
		jump.emit()


	
	if not actor.is_alive:
		death.emit()
