extends Control
@onready var color_rect = $ColorRect
@onready var vb_level_complete = $VB_LevelComplete
@onready var vb_game_over = $VB_GameOver
@onready var hb_hearts = $MC/HB/HBHearts
@onready var score_label = $MC/HB/ScoreLabel

var _hearts: Array

# Called when the node enters the scene tree for the first time.
func _ready():
	_hearts = hb_hearts.get_children()
	SignalManager.on_level_complete.connect(on_level_complete)
	SignalManager.on_game_over.connect(on_game_over)
	SignalManager.on_player_hit.connect(on_player_hit)
	SignalManager.on_score_updated.connect(on_score_updated)
	score_label.text = str(ScoreManager.get_score()).lpad(5, "0")


func show_hud() -> void:
	get_tree().paused = true
	color_rect.visible = true
	
func on_level_complete() -> void:
	show_hud()
	vb_level_complete.visible = true

func on_game_over() -> void:
	show_hud()
	vb_game_over.visible = true

func on_player_hit(lives: int) -> void:
	for l in range(_hearts.size()):
		_hearts[l].visible = lives > l

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if vb_level_complete.visible:
		if Input.is_action_just_pressed("jump"):
			GameManager.load_next_level_scene()
			
	if vb_game_over.visible:
		if Input.is_action_just_pressed("jump"):
			GameManager.load_main_scene()

func on_score_updated() -> void:
	score_label.text = str(ScoreManager.get_score()).lpad(5, "0")
