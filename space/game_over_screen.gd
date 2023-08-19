extends ColorRect

@onready var highscore_label = $HighscoreLabel

func _ready():
	var highscore = SaveAndLoad.load_high_score()
	if highscore == null: return
	print('no high score')
	highscore_label.text = 'Highscore : ' + str(highscore)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed('ui_cancel'):
		get_tree().change_scene_to_file('res://start_menu.tscn')
	
