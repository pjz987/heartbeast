class_name HeroRollState
extends State

func enter() -> void:
	var hero := actor as Hero
	hero.play_animation("roll")
	await hero.animation_player.animation_finished
	finished.emit()
	

func physics_process(delta: float) -> void:
	var hero := actor as Hero
	CharacterMover.accelerate_in_direction(hero, hero.direction, hero.roll_movement_stats, delta)
	CharacterMover.move(hero)
