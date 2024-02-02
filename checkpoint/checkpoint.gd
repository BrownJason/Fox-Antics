extends Area2D

const TRIGGER_CONDITION: String = "parameters/conditions/on_trigger"

@onready var sound = $Sound
@onready var animation_tree = $AnimationTree


# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.on_boss_kill.connect(on_boss_kill)

func on_boss_kill(_p: int) -> void:
	animation_tree[TRIGGER_CONDITION] = true
	monitoring = true
	SoundManager.play_clip(sound, SoundManager.SOUND_WIN)

func _on_area_entered(area):
	SignalManager.on_level_complete.emit()
	
