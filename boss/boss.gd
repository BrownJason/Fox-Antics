extends Node2D

const TRIGGER_CONDITION: String = "parameters/conditions/on_trigger"
const HIT_CONDITION: String = "parameters/conditions/on_hit"

@onready var hit_box = $Visual/HitBox
@onready var animation_tree = $AnimationTree
@onready var visual = $Visual

@export var lives: int = 2
@export var points: int = 10

var _invincible: bool = false
var _has_triggered: bool = false


func _ready():
	pass

func take_damage() -> void:
	if !_has_triggered:
		return
		
	if _invincible:
		return

	set_invincible(true)
	tween_hit()
	reduce_lives()

func set_invincible(v: bool) -> void:
	_invincible = v
	animation_tree[HIT_CONDITION] = v

func tween_hit() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(visual, "position", Vector2.ZERO, 0.1)

func reduce_lives() -> void:
	lives -= 1
	if lives <= 0:
		SignalManager.on_boss_kill.emit(points)
		set_process(false)
		queue_free()
		
func _on_trigger_area_entered(area):
	if !animation_tree[TRIGGER_CONDITION]:
		animation_tree[TRIGGER_CONDITION] = true
		_has_triggered = true
		hit_box.collision_layer = 4
		

func _on_hit_box_area_entered(area):
	take_damage()
