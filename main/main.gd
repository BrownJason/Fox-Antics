extends CanvasLayer
@onready var highscore_label = $VBoxContainer/HighscoreLabel


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = false
	highscore_label.text = "Highscore: %s" % ScoreManager.get_high_score()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if Input.is_action_just_pressed("jump"):
		GameManager.load_next_level_scene()
