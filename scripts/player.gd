class_name Player
extends CharacterBody2D

@export var movement_data: PlayerMovementData 
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


@onready var fsm: FiniteStateMachine = $FiniteStateMachine
@onready var idle_state: IdleState = $FiniteStateMachine/IdleState
@onready var run_state: RunState = $FiniteStateMachine/RunState
@onready var jump_state: JumpState = $FiniteStateMachine/JumpState
@onready var fall_state: FallState = $FiniteStateMachine/FallState

@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_buffer_timer: Timer = $JumpBufferTimer
@onready var platform_raycast: RayCast2D = $RayCast2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


@onready var state_label: Label = $StateLabel

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

func update_state_label(current_state: State) -> void:
	state_label.text = current_state.name

func _ready() -> void:
	
	# Idle State
	idle_state.run.connect(fsm.change_state.bind(run_state, idle_state))
	idle_state.jump.connect(fsm.change_state.bind(jump_state, idle_state))
	idle_state.fall.connect(fsm.change_state.bind(fall_state, idle_state))


	# Run State
	run_state.idle.connect(fsm.change_state.bind(idle_state, run_state))
	run_state.jump.connect(fsm.change_state.bind(jump_state, run_state))
	run_state.fall.connect(fsm.change_state.bind(fall_state, run_state))


	# Jump State
	jump_state.idle.connect(fsm.change_state.bind(idle_state, jump_state))
	jump_state.run.connect(fsm.change_state.bind(run_state, jump_state))


	# Fall State
	fall_state.idle.connect(fsm.change_state.bind(idle_state, fall_state))
	fall_state.run.connect(fsm.change_state.bind(run_state, fall_state))
	fall_state.jump.connect(fsm.change_state.bind(jump_state, fall_state))

	update_state_label(fsm.state)



func _process(delta: float) -> void:
	update_state_label(fsm.state)
	#print('JUMP BUFFER ',jump_buffer_timer.time_left)
	pass



func update_animation(animation: String) -> void:
	animated_sprite.play(animation)


func apply_acceleration(input_axis: float, delta : float) -> void:
	if not is_on_floor(): return
	if input_axis:
		velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.acceleration * delta)


func apply_air_acceleration(input_axis: float, delta : float) -> void:
	if is_on_floor(): return
	if input_axis:
		velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.air_acceleration * delta)


func apply_friction(input_axis: float, delta: float) -> void:
	if input_axis == 0:
		velocity.x = move_toward(velocity.x, 0, movement_data.friction * delta)

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta


func apply_air_resistance(direction, delta: float) -> void:
	if direction == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.air_resistance * delta)


func handle_drop() -> void:
	if Input.is_action_just_pressed("move_down") and is_on_floor() and platform_raycast.is_colliding():
		collision_shape_2d.disabled = true
		position.y += 2


func flip_sprite(direction: float) -> void:
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true


func cancel_squash_and_stretch(delta: float) -> void:
	animated_sprite.scale.x = move_toward(animated_sprite.scale.x, 1, 2 * delta)
	animated_sprite.scale.y = move_toward(animated_sprite.scale.y, 1, 2 * delta)


#var is_alive: bool = true
#var is_rolling: bool = false
#var was_on_air: bool = false
#var air_jump: bool = false
#var just_wall_jumped: bool = false
#var was_wall_normal = Vector2.ZERO
#var on_ladder: Area2D = null
#var ladder_count: int = 0
#var is_climbing: bool = false 
#var was_climbing: bool = false
#var is_on_top_of_ladder: bool = false
#var is_jumping: bool = false
#
#var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
#
#@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
#@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
#@onready var coyote_timer: Timer = $CoyoteTimer
#@onready var jump_buffer_timer: Timer = $JumpBufferTimer
#@onready var wall_jump_timer: Timer = $WallJumpTimer
#
#
#
#func death() -> void:
	#is_alive = false
	#velocity = Vector2.ZERO 
	#animated_sprite.play("death")
	#PlayerPowers.reset_temp_powers()
#
#
#func start_roll() -> void:
	#if Input.is_action_just_pressed("roll") and is_on_floor() and not is_rolling:
		#is_rolling = true
		#animated_sprite.play("roll")
#
#
## Handle vertical movement while on the ladder
#func climb_ladder() -> void:
	#if Input.is_action_pressed("move_up") and not is_on_top_of_ladder:
		#velocity.y = -movement_data.speed
	#elif Input.is_action_pressed("move_down"):
		#velocity.y = movement_data.speed
	#else:
		#velocity.y = 0
	#was_climbing = true
#
#
#func add_ladder_count(ladder: Area2D) -> void:
	#ladder_count += 1
	#on_ladder = ladder
#
#func remove_ladder_count(_ladder: Area2D) -> void:
	#if ladder_count > 0:
		#ladder_count -= 1
	#if ladder_count == 0:
		#on_ladder = null
#
#func apply_gravity(delta: float) -> void:
	#if (is_climbing or was_climbing) and ladder_count > 0:
		#return
	#else:
		#if not is_on_floor():
			#velocity.y += gravity * delta

#
#
#func handle_jump() -> void:
#
	## Handle jump for ladder
	#if (is_climbing or was_climbing) and ladder_count > 0:
		#if Input.is_action_just_pressed("jump"):
			#on_ladder = null
			#velocity.y = movement_data.jump_velocity 
			#jump_sound.play()
			#was_climbing = false
			#return
#
	#if is_on_floor(): 
		#air_jump = true
#
	## Regular jump
	#if (is_on_floor() or coyote_timer.time_left > 0.0) and jump_buffer_timer.time_left > 0:
		#animated_sprite.scale = Vector2(0.7, 1.3)
		#velocity.y = movement_data.jump_velocity
		#jump_sound.play()
		#jump_buffer_timer.stop()
		#is_jumping = true
#
	#
	## Double jump
	#elif not is_on_floor() and (PlayerPowers.can_double_jump or PlayerPowers.temp_can_double_jump):
		#if Input.is_action_just_pressed("jump") and air_jump and not just_wall_jumped:
			#velocity.y = movement_data.jump_velocity * 0.8
			#jump_sound.play()
			#air_jump = false
#
	##Jump variation
	#if Input.is_action_just_released("jump") and is_jumping:
		#velocity.y *= 0.4
		#is_jumping = false

#
## Handle wall jump
#func handle_wall_jump() -> void:
	#if PlayerPowers.can_wall_jump or PlayerPowers.temp_can_wall_jump: 
		#if not is_on_wall_only() and wall_jump_timer.time_left <= 0.0 : return
		#var wall_normal = get_wall_normal()
		#if wall_jump_timer.time_left > 0.0: 
			#wall_normal = was_wall_normal
		#
		#if Input.is_action_just_pressed("jump"):
			#velocity.x = wall_normal.x * movement_data.speed
			#velocity.y = movement_data.jump_velocity 
			#just_wall_jumped = true
#
#
#func handle_squash_and_stretch() -> void:
	#if is_on_floor():
		#if was_on_air: 
			#was_on_air = false
			#animated_sprite.scale = Vector2(1.3,0.7)
	#else:
		#was_on_air = true
#
#
#
#func handle_rolling() -> void:
	#if is_rolling:
		#if animated_sprite.flip_h:
			#velocity.x = -movement_data.roll_speed
		#else:
			#velocity.x = movement_data.roll_speed
			#
		#if not animated_sprite.is_playing():
			#is_rolling = false

#
#
#
#func _physics_process(delta: float) -> void:
#
	#if not is_alive:
		## Prevent any movement or action after death
		#return
#
	#var was_on_floor = is_on_floor()
	#var was_on_wall = is_on_wall_only()
	#
	#is_climbing = on_ladder and (Input.is_action_pressed("move_up") or Input.is_action_pressed("move_down"))
#
	#if (is_climbing or was_climbing) and ladder_count > 0:
		#climb_ladder()
	#
	#
	#if ladder_count == 0 and not is_on_top_of_ladder:
		#was_climbing = false
#
#
	## Storing the wall normal
	#if was_on_wall:
		#was_wall_normal = get_wall_normal()
	#
	#move_and_slide()
	#
	## Handle coyote time
	#var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	#
	#var just_left_wall = was_on_wall and not is_on_wall()
	#
	#if just_left_wall:
		#wall_jump_timer.start()
#
	#if just_left_ledge:
		#coyote_timer.start()
#
	## Handle jump buffer
	#if Input.is_action_just_pressed("jump"):
		#jump_buffer_timer.start()
#
#
	#handle_squash_and_stretch()
	#
	#handle_wall_jump()
	#handle_jump()
	#start_roll()
	#handle_rolling()
#
#
	#var input_axis := Input.get_axis("move_left", "move_right")
#
	#just_wall_jumped = false
