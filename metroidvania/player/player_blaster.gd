extends Node2D

@onready var blaster_sprite = $BlasterSprite
@onready var muzzle = $BlasterSprite/Muzzle

const BulletScene = preload("res://player/bullet.tscn")

func _process(_delta):
	blaster_sprite.rotation = get_local_mouse_position().angle()

func fire_bullet():
	var bullet = Utils.instantiate_scene_on_world(BulletScene, muzzle.global_position)
	bullet.rotation = blaster_sprite.rotation
	bullet.update_velocity()
