extends CharacterBody2D

@export var movement_data: PlayerMovementData 

var is_alive: bool = true
var is_rolling: bool = false
var was_on_air: bool = false
var air_jump: bool = false
var just_wall_jumped: bool = false
var was_wall_normal = Vector2.ZERO

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

# 
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_buffer_timer: Timer = $JumpBufferTimer
@onready var wall_jump_timer: Timer = $WallJumpTimer


func death() -> void:
	is_alive = false
	velocity = Vector2.ZERO 
	animated_sprite.play("death")


func start_roll() -> void:
	if Input.is_action_just_pressed("roll") and is_on_floor() and not is_rolling:
		is_rolling = true
		animated_sprite.play("roll")


func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta


func apply_air_resistance(direction, delta: float) -> void:
	if direction == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.air_resistance * delta)


func handle_drop() -> void:
	if Input.is_action_just_pressed("move_down") and is_on_floor():
		position.y += 2


func handle_jump() -> void:
	if is_on_floor(): 
		air_jump = true

	if (is_on_floor() or coyote_timer.time_left > 0.0) and jump_buffer_timer.time_left > 0:
		animated_sprite.scale = Vector2(0.7, 1.3)
		velocity.y = movement_data.jump_velocity
		jump_sound.play()
		jump_buffer_timer.stop()
	
	# Double jump
	elif not is_on_floor():
		if Input.is_action_just_pressed("jump") and air_jump and not just_wall_jumped:
			velocity.y = movement_data.jump_velocity * 0.8
			jump_sound.play()
			air_jump = false

	#Jump variation
	if Input.is_action_just_released("jump"):
		velocity.y *= 0.4

# Handle wall jump
func handle_wall_jump() -> void:
	if not is_on_wall_only() and wall_jump_timer.time_left <= 0.0 : return
	var wall_normal = get_wall_normal()
	if wall_jump_timer.time_left > 0.0: 
		wall_normal = was_wall_normal
	
	if Input.is_action_just_pressed("jump"):
		velocity.x = wall_normal.x * movement_data.speed
		velocity.y = movement_data.jump_velocity 
		just_wall_jumped = true


func handle_squash_and_stretch() -> void:
	if is_on_floor():
		if was_on_air: 
			was_on_air = false
			animated_sprite.scale = Vector2(1.3,0.7)
	else:
		was_on_air = true


func cancel_squash_and_stretch(delta: float) -> void:
	animated_sprite.scale.x = move_toward(animated_sprite.scale.x, 1, 2 * delta)
	animated_sprite.scale.y = move_toward(animated_sprite.scale.y, 1, 2 * delta)


func handle_rolling() -> void:
	if is_rolling:
		if animated_sprite.flip_h:
			velocity.x = -movement_data.roll_speed
		else:
			velocity.x = movement_data.roll_speed
			
		if not animated_sprite.is_playing():
			is_rolling = false


func flip_sprite(direction: float) -> void:
	if not is_rolling:
		if direction > 0:
			animated_sprite.flip_h = false
		elif direction < 0:
			animated_sprite.flip_h = true


func update_animation(direction: float) -> void:
	if not is_rolling:
		if is_on_floor():
			if direction == 0: 
				animated_sprite.play("idle")
			else:
				animated_sprite.play("run")
		else:
			animated_sprite.play("jump")


func apply_acceleration(input_axis: float, delta : float) -> void:
	if not is_on_floor(): return
	if not is_rolling: 
		if input_axis:
			velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.acceleration * delta)


func apply_air_acceleration(input_axis: float, delta : float) -> void:
	if is_on_floor(): return
	if not is_rolling: 
		if input_axis:
			velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.air_acceleration * delta)


func apply_friction(input_axis: float, delta: float) -> void:
	if not is_rolling:
		if input_axis == 0:
			velocity.x = move_toward(velocity.x, 0, movement_data.friction * delta)


func _physics_process(delta: float) -> void:

	if not is_alive:
		# Prevent any movement or action after death
		return

	var was_on_floor = is_on_floor()
	var was_on_wall = is_on_wall_only()
	
	# Storing the wall normal
	if was_on_wall:
		was_wall_normal = get_wall_normal()
	
	move_and_slide()
	
	# Handle coyote time
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	
	var just_left_wall = was_on_wall and not is_on_wall()
	
	if just_left_wall:
		wall_jump_timer.start()

	if just_left_ledge:
		coyote_timer.start()

	# Handle jump buffer
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer.start()


	handle_squash_and_stretch()
	apply_gravity(delta)
	handle_wall_jump()
	handle_jump()
	handle_drop()
	start_roll()
	handle_rolling()


	var input_axis := Input.get_axis("move_left", "move_right")
	flip_sprite(input_axis)
	update_animation(input_axis)
	apply_friction(input_axis, delta)
	apply_acceleration(input_axis, delta)
	apply_air_acceleration(input_axis, delta)
	apply_air_resistance(input_axis, delta)

	cancel_squash_and_stretch(delta)

	just_wall_jumped = false
