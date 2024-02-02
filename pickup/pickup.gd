extends Area2D

@onready var life_timer = $LifeTimer
@onready var animatable_body_2d = $AnimatableBody2D

const FRUITS = ["melon","banana","cherry","kiwi"]
const GRAVITY: float = 60.0
const JUMP: float = -32.0
const POINTS: int = 2

var _start_y: float
var _speed_y: float = JUMP
var _stopped: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	_start_y = global_position.y
	animatable_body_2d.play(FRUITS.pick_random())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _stopped:
		return
		
	position.y += _speed_y * delta
	_speed_y += GRAVITY * delta
	
	if global_position.y > _start_y:
		_stopped = true

func _on_area_entered(area):
	SignalManager.on_pickup_hit.emit(POINTS)
	kill_me()

func kill_me() -> void:
	set_process(false)
	hide()
	queue_free()

func _on_life_timer_timeout():
	pass

func pick_random():
	animatable_body_2d
