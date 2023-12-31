extends CharacterBody2D

@export var movement_data : PlayerMovimentData

# Get the gravity from the project settings to be synced with RigidBody nodes.
var air_jump = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_jump_timer =$CoyoteJumpTimer
@onready var stating_position = global_position

func _physics_process(delta):
	apply_gravity(delta)
	handle_jump()
	var input_axis = Input.get_axis("ui_left", "ui_right")
	handle_acceleration(input_axis, delta)
	apply_friction(input_axis, delta)
	apply_air_resistence(input_axis, delta)
	updated_animations(input_axis)
	var was_on_floor=is_on_floor()
	move_and_slide()
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyote_jump_timer.start()
	#if Input.is_action_just_pressed("ui_accept"):
	#	movement_data = load("res://FasterPlayerMovementData.tres")
	
func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

func  handle_wall_jump():
	if not is_on_wall(): return
	var wall_normal = get_wall_normal()
	if Input.is_action_just_pressed("ui_left") and wall_normal == Vector2.LEFT:
		velocity.x = wall_normal.x * movement_data.SPEED
		velocity.y = movement_data.JUMP_VELOCITY
	if Input.is_action_just_pressed("ui_right") and wall_normal == Vector2.LEFT:
		velocity.x = wall_normal.x * movement_data.SPEED
		velocity.y = movement_data.JUMP_VELOCITY
	
		
func  handle_jump():
	if is_on_floor(): air_jump = true
		
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("ui_up"):
			velocity.y = movement_data.JUMP_VELOCITY 
	if not is_on_floor() :
		if Input.is_action_just_released("ui_up") and velocity.y < movement_data.JUMP_VELOCITY / 2:
			velocity.y = movement_data.JUMP_VELOCITY / 2
		if Input.is_action_just_pressed("ui_up") and air_jump:
			velocity.y = movement_data.JUMP_VELOCITY * 0.8
			air_jump = false
		
func  handle_acceleration(input_axis, delta):
		if input_axis != 0:
			velocity.x = move_toward(velocity.x, movement_data.SPEED * input_axis, movement_data.ACCELERATION * delta)
		
func apply_friction(input_axis, delta):
	if input_axis == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.FRICTION * delta)
		
func  apply_air_resistence(input_axis, delta):
	if input_axis == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.AIR_RESISTENCE * delta)
		
func updated_animations(input_axis):
	if input_axis !=0:
		animated_sprite_2d.flip_h = (input_axis < 0)
		animated_sprite_2d.play("run")
	else :
		animated_sprite_2d.play("idle")
		
	if  not is_on_floor():
		animated_sprite_2d.play("jump")



func _on_hazard_detect_area_entered(area):
	global_position = stating_position
