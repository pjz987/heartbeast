extends Node2D

@onready var animation_player = $AnimationPlayer
@onready var launch_button = $LaunchButton
@onready var rocket_flare = $Rocket/RocketFlare

func _on_texture_button_button_down():
	animation_player.play('launch')
	rocket_flare.show()
	launch_button.hide()
