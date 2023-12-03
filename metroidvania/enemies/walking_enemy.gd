extends CharacterBody2D

@export var speed = 30.0
@export var turns_at_ledges = true
var gravity = 200.0
var direction = 1.0

@onready var sprite_2d = $Sprite2D
@onready var floor_cast = $FloorCast
@onready var stats = $Stats

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if is_on_wall():
		turn_around()
	
	if is_at_ledge() and turns_at_ledges:
		turn_around()
	
	velocity.x = direction * speed

	move_and_slide()

func is_at_ledge():
	if is_on_floor() and not floor_cast.is_colliding():
		return true
	return false

func turn_around():
	direction *= -1
	sprite_2d.scale.x *= -1


func _on_hurtbox_hurt(_hitbox, damage):
	stats.health -= damage


func _on_stats_no_health():
	queue_free()
