class_name EnemyChaseState
extends State

var navigation_agent: NavigationAgent2D: set = set_navigation_agent

func set_navigation_agent(value: NavigationAgent2D) -> EnemyChaseState:
	navigation_agent = value
	return self

func physics_process(delta: float) -> void:
	var enemy := actor as Enemy
	var hero := MainInstances.hero as Hero
	if hero is not Hero: return
	
	var map_rid := navigation_agent.get_navigation_map()
	if NavigationServer2D.map_get_iteration_id(map_rid) == 0: return
	
	navigation_agent.target_position = hero.global_position
	var next_point = navigation_agent.get_next_path_position()
	var direction := enemy.global_position.direction_to(next_point)
	
	if direction.x != 0:
		enemy.animation_player.play("move")
		enemy.sprite_2d.scale.x = sign(direction.x)
	
	CharacterMover.accelerate_in_direction(enemy, direction, enemy.movement_stats, delta)
	CharacterMover.move(enemy)
