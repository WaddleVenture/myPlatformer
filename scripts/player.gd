class_name Player
extends CharacterBody2D

# EXPORT
@export var movement_data: PlayerMovementData 


# STATES
@onready var fsm: FiniteStateMachine = $FiniteStateMachine
@onready var idle_state: IdleState = $FiniteStateMachine/IdleState
@onready var run_state: RunState = $FiniteStateMachine/RunState
@onready var jump_state: JumpState = $FiniteStateMachine/JumpState
@onready var fall_state: FallState = $FiniteStateMachine/FallState
@onready var double_jump_state: DoubleJumpState = $FiniteStateMachine/DoubleJumpState
@onready var wall_jump_state: WallJumpState = $FiniteStateMachine/WallJumpState
@onready var roll_state: RollState = $FiniteStateMachine/RollState
@onready var death_state: DeathState = $FiniteStateMachine/DeathState
@onready var ladder_state: LadderState = $FiniteStateMachine/LadderState
@onready var dash_state: DashState = $FiniteStateMachine/DashState


# TIMER
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_buffer_timer: Timer = $JumpBufferTimer
@onready var wall_jump_timer: Timer = $WallJumpTimer
@onready var dash_timer: Timer = $DashTimer


# OTHER IMPORTS
@onready var platform_raycast: RayCast2D = $RayCast2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_label: Label = $StateLabel


# VARIABLES
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_alive: bool = true
var facing_direction: int = 1


## Wall jump
var was_on_wall: bool
var was_wall_normal = Vector2.ZERO
var wall_normal = Vector2.ZERO

## Ladder 
var on_ladder: Area2D = null
var ladder_count: int = 0
var is_on_top_of_ladder: bool = false

## Roll
var is_rolling: bool = false

## Dash
var can_dash: bool = false 
var dash_direction: Vector2 = Vector2.ZERO


func update_state_label(current_state: State) -> void:
	state_label.text = current_state.name


func _ready() -> void:
	
	# Idle State
	idle_state.run.connect(fsm.change_state.bind(run_state, idle_state))
	idle_state.jump.connect(fsm.change_state.bind(jump_state, idle_state))
	idle_state.fall.connect(fsm.change_state.bind(fall_state, idle_state))
	idle_state.roll.connect(fsm.change_state.bind(roll_state, idle_state))
	idle_state.death.connect(fsm.change_state.bind(death_state, idle_state))
	idle_state.dash.connect(fsm.change_state.bind(dash_state, idle_state))


	# Run State
	run_state.idle.connect(fsm.change_state.bind(idle_state, run_state))
	run_state.jump.connect(fsm.change_state.bind(jump_state, run_state))
	run_state.fall.connect(fsm.change_state.bind(fall_state, run_state))
	run_state.roll.connect(fsm.change_state.bind(roll_state, run_state))
	run_state.death.connect(fsm.change_state.bind(death_state, run_state))
	run_state.dash.connect(fsm.change_state.bind(dash_state, run_state))


	# Jump State
	jump_state.idle.connect(fsm.change_state.bind(idle_state, jump_state))
	jump_state.run.connect(fsm.change_state.bind(run_state, jump_state))
	jump_state.double_jump.connect(fsm.change_state.bind(double_jump_state, jump_state))
	jump_state.wall_jump.connect(fsm.change_state.bind(wall_jump_state, jump_state))
	jump_state.death.connect(fsm.change_state.bind(death_state, jump_state))
	jump_state.ladder.connect(fsm.change_state.bind(ladder_state, jump_state))
	jump_state.dash.connect(fsm.change_state.bind(dash_state, jump_state))


	# Fall State
	fall_state.idle.connect(fsm.change_state.bind(idle_state, fall_state))
	fall_state.run.connect(fsm.change_state.bind(run_state, fall_state))
	fall_state.jump.connect(fsm.change_state.bind(jump_state, fall_state))
	fall_state.wall_jump.connect(fsm.change_state.bind(wall_jump_state, fall_state))
	fall_state.death.connect(fsm.change_state.bind(death_state, fall_state))
	fall_state.ladder.connect(fsm.change_state.bind(ladder_state, fall_state))
	fall_state.dash.connect(fsm.change_state.bind(dash_state, fall_state))


	# Double Jump State
	double_jump_state.idle.connect(fsm.change_state.bind(idle_state, double_jump_state))
	double_jump_state.run.connect(fsm.change_state.bind(run_state, double_jump_state))
	double_jump_state.wall_jump.connect(fsm.change_state.bind(wall_jump_state, double_jump_state))
	double_jump_state.death.connect(fsm.change_state.bind(death_state, double_jump_state))
	double_jump_state.ladder.connect(fsm.change_state.bind(ladder_state, double_jump_state))
	double_jump_state.dash.connect(fsm.change_state.bind(dash_state, double_jump_state))


	# Wall Jump State
	wall_jump_state.idle.connect(fsm.change_state.bind(idle_state, wall_jump_state))
	wall_jump_state.run.connect(fsm.change_state.bind(run_state, wall_jump_state))
	wall_jump_state.wall_jump.connect(fsm.change_state.bind(wall_jump_state, wall_jump_state))
	wall_jump_state.death.connect(fsm.change_state.bind(death_state, wall_jump_state))
	wall_jump_state.ladder.connect(fsm.change_state.bind(ladder_state, wall_jump_state))
	wall_jump_state.dash.connect(fsm.change_state.bind(dash_state, wall_jump_state))


	# Roll State
	roll_state.idle.connect(fsm.change_state.bind(idle_state, roll_state))
	roll_state.run.connect(fsm.change_state.bind(run_state, roll_state))
	roll_state.jump.connect(fsm.change_state.bind(jump_state, roll_state))
	roll_state.fall.connect(fsm.change_state.bind(fall_state, roll_state))


	# Ladder State
	ladder_state.fall.connect(fsm.change_state.bind(fall_state, ladder_state))
	ladder_state.jump.connect(fsm.change_state.bind(jump_state, ladder_state))
	ladder_state.death.connect(fsm.change_state.bind(death_state, ladder_state))


	# Dash State
	dash_state.idle.connect(fsm.change_state.bind(idle_state, dash_state))
	dash_state.run.connect(fsm.change_state.bind(run_state, dash_state))
	dash_state.fall.connect(fsm.change_state.bind(fall_state, dash_state))



func _process(_delta: float) -> void:
	update_state_label(fsm.state)
	#print('JUMP BUFFER ',dash_timer.time_left)
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
		facing_direction = 1
		
	elif direction < 0:
		animated_sprite.flip_h = true
		facing_direction = -1


func cancel_squash_and_stretch(delta: float) -> void:
	animated_sprite.scale.x = move_toward(animated_sprite.scale.x, 1, 2 * delta)
	animated_sprite.scale.y = move_toward(animated_sprite.scale.y, 1, 2 * delta)


func store_wall_jump_normal() -> void:
	# Detect wall position
	was_on_wall = is_on_wall_only()
	
	# Storing the wall normal
	if was_on_wall:
		was_wall_normal = get_wall_normal()


func start_wall_jump_timer() -> void:
	# Check if the player just left the wall to start a timer
	var just_left_wall = was_on_wall and not is_on_wall()
	if just_left_wall:
		wall_jump_timer.start()


func add_ladder_count(ladder: Area2D) -> void:
	ladder_count += 1
	on_ladder = ladder


func remove_ladder_count(_ladder: Area2D) -> void:
	if ladder_count > 0:
		ladder_count -= 1
	if ladder_count == 0:
		on_ladder = null


func apply_ladder_movement(input_axis: float) -> void:
	if input_axis:
		velocity.x = input_axis * movement_data.speed / 3
	else:
		velocity.x = move_toward(velocity.x, 0, movement_data.speed / 3)


func detect_dash_direction(input_x, input_y) -> void:
	if input_x == 0 and input_y == 0:
		dash_direction = Vector2(facing_direction, 0)
	else:
		dash_direction = Vector2(input_x, input_y).normalized()
