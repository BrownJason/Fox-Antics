extends CharacterBody2D

class_name  Player

@onready var sprite_2d = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var debug_label = $DebugLabel
@onready var sound = $Sound


const GRAVITY: float = 1000.0
const SPEED = 120.0
const MAX_FALL: float = 400.0
const HURT_TIME: float = 0.3
const JUMP_VELOCITY = -400.0

enum PLAYER_STATE { IDLE, RUN, JUMP, FALL, HURT}

var _state: PLAYER_STATE = PLAYER_STATE.IDLE

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	get_input()
	move_and_slide()
	calculate_states()
	update_debug_label()

func update_debug_label() -> void:
	debug_label.text = "floor: %s\n%s\n%.0f\n%.0f" % [
		is_on_floor(),
		PLAYER_STATE.keys()[_state],
		velocity.x, velocity.y
	]

func get_input() -> void:
	velocity.x = 0
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		SoundManager.play_clip(sound, SoundManager.SOUND_JUMP)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
		if direction == -1:
			sprite_2d.flip_h = true
		else:
			sprite_2d.flip_h = false
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	velocity.y = clampf(velocity.y, JUMP_VELOCITY, MAX_FALL)

func calculate_states() -> void:
	if _state == PLAYER_STATE.HURT:
		return
	
	if is_on_floor():
		if velocity.x == 0:
			set_state(PLAYER_STATE.IDLE)
		else:
			set_state(PLAYER_STATE.RUN)
	else:
		if velocity.y > 0:
			set_state(PLAYER_STATE.FALL)
		else:
			set_state(PLAYER_STATE.JUMP)
			
func set_state(new_state: PLAYER_STATE) -> void:
	
	if new_state == _state:
		return
		
	if _state == PLAYER_STATE.FALL:
		if new_state == PLAYER_STATE.IDLE or new_state == PLAYER_STATE.RUN:
				SoundManager.play_clip(sound, SoundManager.SOUND_LAND)
		
	_state = new_state
	
	match _state:
		PLAYER_STATE.IDLE:
			animation_player.play("idle")
		PLAYER_STATE.RUN:
			animation_player.play("run")
		PLAYER_STATE.JUMP:
			animation_player.play("jump")
		PLAYER_STATE.FALL:
			animation_player.play("fall")
