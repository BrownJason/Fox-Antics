extends CharacterBody2D

class_name  Player

@onready var sprite_2d = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var animation_player_invincible = $AnimationPlayerInvincible
@onready var debug_label = $DebugLabel
@onready var sound = $Sound
@onready var shooter = $Shooter
@onready var invincible_timer = $InvincibleTimer
@onready var hurt_timer = $HurtTimer
@onready var hit_box = $HitBox


const GRAVITY: float = 1000.0
const SPEED = 240.0
const MAX_FALL: float = 400.0
const HURT_TIME: float = 0.3
const JUMP_VELOCITY = -400.0
const HURT_JUMP_VELOCITY: Vector2 = Vector2(0.0,-150.0)
const FALLEN_OFF: float = 100.0


enum PLAYER_STATE { IDLE, RUN, JUMP, FALL, HURT}

var _state: PLAYER_STATE = PLAYER_STATE.IDLE
var _invincible: bool = false
var _lives: int = 5

func _ready():
	SignalManager.on_player_hit.emit(_lives)

func _physics_process(delta):
	fallen_off()
	# Add the gravity.
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	get_input()
	move_and_slide()
	calculate_states()
	update_debug_label()
	
	if Input.is_action_just_pressed("shoot"):
		shoot()

func update_debug_label() -> void:
	debug_label.text = "lives: %s" % _lives

func fallen_off() -> void:
	if global_position.y < FALLEN_OFF:
		return
		
	_lives = 1
	reduce_lives()

func shoot() -> void:
	if sprite_2d.flip_h:
		shooter.shoot(Vector2.LEFT)
	else:
		shooter.shoot(Vector2.RIGHT)

func get_input() -> void:
	
	if _state == PLAYER_STATE.HURT:
		return
	
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
		PLAYER_STATE.HURT:
			apply_hurt_jump()

func apply_hurt_jump() -> void:
	animation_player.play("hurt")
	velocity = HURT_JUMP_VELOCITY
	hurt_timer.start()

func go_invincible() -> void:
	_invincible = true
	animation_player_invincible.play("invincible")
	invincible_timer.start()

func reduce_lives() -> bool:
	_lives -= 1
	SignalManager.on_player_hit.emit(_lives)
	
	if _lives <= 0:
		SignalManager.on_game_over.emit()
		set_physics_process(false)
		return false
	return true

func apply_hit() -> void:
	if _invincible:
		return
	
	if !reduce_lives():
		return
	
	go_invincible()
	set_state(PLAYER_STATE.HURT)
	SoundManager.play_clip(sound, SoundManager.SOUND_IMPACT)

func retake_damage() -> void:
	for area in hit_box.get_overlapping_areas():
		if area.is_in_group("Dangers"):
			apply_hit()
			return
	return

func _on_hit_box_area_entered(area):
	apply_hit()

func _on_invincible_timer_timeout():
	_invincible = false
	animation_player_invincible.stop()
	retake_damage()

func _on_hurt_timer_timeout():
	set_state(PLAYER_STATE.IDLE)
