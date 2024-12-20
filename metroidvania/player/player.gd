extends CharacterBody2D

const DUST_EFFECT_SECENE = preload("res://effects/dust_effect.tscn")
const JUMP_EFFECT_SCENE = preload('res://effects/jump_effect.tscn')

@export var acceleration = 512
@export var max_velocity = 64
@export var friction = 256
@export var gravity = 200
@export var jump_force = 128
@export var max_fall_velocity = 128
@export var wall_slide_speed = 42
@export var max_wall_slide_speed = 128

var air_jump = false
var state = move_state

@onready var player_blaster = $PlayerBlaster
@onready var animation_player = $AnimationPlayer
@onready var sprite_2d = $Sprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var fire_rate_timer = $FireRateTimer
@onready var drop_timer = $DropTimer
@onready var camera_2d = $Camera2D
@onready var hurtbox = $Hurtbox
@onready var blinking_animation_player = $BlinkingAnimationPlayer

func _ready():
	PlayerStats.no_health.connect(die)

func _physics_process(delta):
	state.call(delta)
	
	if Input.is_action_pressed("fire") and fire_rate_timer.time_left == 0:
		fire_rate_timer.start()
		player_blaster.fire_bullet()

func move_state(delta):
	apply_gravity(delta)
	var input_axis = Input.get_axis('move_left', 'move_right')
	if is_moving(input_axis):
		apply_horizontal_force(delta, input_axis)
	else:
		apply_friction(delta)
	jump_check()
	update_animations(input_axis)

	if Input.is_action_just_pressed("crouch"):
		set_collision_mask_value(2, false)
		drop_timer.start()
	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_left_edge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_edge:
		coyote_jump_timer.start()
	wall_check()

func wall_slide_state(delta):
	var wall_normal = get_wall_normal()
	animation_player.play('wall_slide')
	sprite_2d.scale.x = sign(wall_normal.x)
	wall_jump_check(wall_normal.x)
	apply_wall_slide_gravity(delta)
	move_and_slide()
	wall_detach(delta)

func wall_check():
	if not is_on_floor() and is_on_wall():
		state = wall_slide_state
		air_jump = true
		create_dust_effect()

func wall_detach(delta):
	if Input.is_action_just_pressed('move_right'):
		velocity.x = acceleration * delta
		state = move_state
	if Input.is_action_just_pressed('move_left'):
		velocity.x = -acceleration * delta
		state = move_state
	
	if not is_on_wall() or is_on_floor():
		state = move_state

func wall_jump_check(wall_axis):
	if Input.is_action_just_pressed('jump'):
		velocity.x = wall_axis * max_velocity
		state = move_state
		jump(jump_force * 0.75)

func apply_wall_slide_gravity(delta):
	var slide_speed = wall_slide_speed
	if Input.is_action_pressed("crouch"):
		slide_speed = max_wall_slide_speed
	velocity.y = move_toward(velocity.y, slide_speed, gravity * delta)
		

func create_dust_effect():
	Utils.instantiate_scene_on_world(DUST_EFFECT_SECENE, global_position)

func is_moving(input_axis):
	return input_axis != 0

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y = move_toward(velocity.y, max_fall_velocity, gravity * delta)

func apply_horizontal_force(delta, input_axis):
	velocity.x = move_toward(
		velocity.x, input_axis * max_velocity, acceleration * delta)

func apply_friction(delta):
	velocity.x = move_toward(velocity.x, 0, friction * delta)

func jump_check():
	if is_on_floor(): air_jump = true
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed('jump'):
			jump(jump_force)
	if not is_on_floor():
		if (Input.is_action_just_released('jump')
			and velocity.y < -jump_force / 2):
			velocity.y = -jump_force / 2
		if (Input.is_action_just_pressed('jump')
			and air_jump):
				jump(jump_force * 0.75)
				air_jump = false

func jump(force):
	velocity.y = -force
	Utils.instantiate_scene_on_world(JUMP_EFFECT_SCENE, global_position)

func update_animations(input_axis):
	if get_local_mouse_position().x != 0:
		sprite_2d.scale.x = sign(get_local_mouse_position().x)
	
	if is_moving(input_axis):
		animation_player.play('run')
		animation_player.speed_scale = input_axis * sprite_2d.scale.x
	else:
		animation_player.play('idle')
	
	if not is_on_floor():
		animation_player.play('jump')

func die():
	camera_2d.reparent(get_tree().current_scene)
	queue_free()


func _on_drop_timer_timeout():
	set_collision_mask_value(2, true)


func _on_hurtbox_hurt(hitbox, damage):
	Events.add_screenshake.emit(0.5, 0.125)
	PlayerStats.health -= 1
	hurtbox.is_invincible = true
	blinking_animation_player.play('blink')
	await blinking_animation_player.animation_finished
	hurtbox.is_invincible = false
