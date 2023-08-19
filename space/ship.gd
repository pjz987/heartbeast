extends Area2D

const LASER_SCENE = preload("res://laser.tscn")
@onready var collision_polygon_2d = $CollisionPolygon2D

signal ship_destroyed

@export var speed = 100

func _process(delta):
	if Input.is_action_pressed('ui_up'):
		position.y -= speed * delta
		if position.y < 8: position.y = 8
	if Input.is_action_pressed('ui_down'):
		position.y += speed * delta
		if position.y > 172: position.y = 172
	if Input.is_action_just_pressed('ui_accept'):
		var laser = LASER_SCENE.instantiate()
		var world = get_tree().current_scene
		world.add_child(laser)
		laser.position = position


func _on_area_entered(area):
	queue_free()
	area.queue_free()
	ship_destroyed.emit()
