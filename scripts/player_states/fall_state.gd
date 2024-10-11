class_name FallState
extends State

@export var actor: Player
@export var animator: AnimatedSprite2D

signal run
signal idle
signal jump
signal wall_jump
signal death
signal ladder
signal dash

func _ready() -> void:
	set_physics_process(false)


func _enter(from_state: State = null) -> void:
	set_physics_process(true)
	animator.scale = Vector2(1, 1)
	if from_state is not RollState:
		animator.play("jump")


func _exit() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	actor.store_wall_jump_normal()
	actor.move_and_slide()
	actor.start_wall_jump_timer()
	actor.apply_gravity(delta)
	actor.apply_air_resistance(0, delta)
	var input_axis := Input.get_axis("move_left", "move_right")
	actor.flip_sprite(input_axis)
	actor.apply_air_resistance(input_axis, delta)
	actor.apply_air_acceleration(input_axis, delta)
	
	if not actor.platform_raycast.is_colliding():
		actor.collision_shape_2d.disabled = false
	
	if Input.is_action_just_pressed("jump"):
		actor.jump_buffer_timer.start()


	# CHANGING STATES
	var is_climbing = actor.on_ladder and (Input.is_action_pressed("move_up") or Input.is_action_pressed("move_down"))
	if is_climbing and actor.ladder_count > 0:
		ladder.emit()

	if Input.is_action_just_pressed("jump") and actor.coyote_timer.time_left > 0:
		jump.emit()
		actor.coyote_timer.stop()


	if actor.is_on_floor():
		if Input.get_axis("move_left", "move_right") != 0:
			run.emit()
		else:
			idle.emit()


	if Input.is_action_just_pressed("dash") and actor.can_dash and not actor.platform_raycast.is_colliding():
		var input_x := Input.get_axis("move_left", "move_right")
		var input_y := Input.get_axis("move_up", "move_down")
		actor.dash_timer.start()
		actor.detect_dash_direction(input_x, input_y)
		actor.can_dash = false
		dash.emit()


	if PlayerPowers.can_wall_jump or PlayerPowers.temp_can_wall_jump: 
		if not actor.is_on_wall_only() and actor.wall_jump_timer.time_left <= 0.0 : return
		actor.wall_normal = actor.get_wall_normal()
		if actor.wall_jump_timer.time_left > 0.0: 
			actor.wall_normal = actor.was_wall_normal
		
		if Input.is_action_just_pressed("jump"):
			wall_jump.emit()


	if not actor.is_alive:
		death.emit()
