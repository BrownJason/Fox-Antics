extends Node2D

@onready var player_cam = $PlayerCam
@onready var player = $Player

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = false

func _process(delta):
	player_cam.position =  player.position
	
	if Input.is_action_just_pressed("quit"):
		GameManager.load_main_scene()

