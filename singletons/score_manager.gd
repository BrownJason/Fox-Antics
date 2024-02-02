extends Node

const HS_FILE: String = "user://FOXY_ANTICS_SCORES.dat"
const HS_KEY: String = "highscore"

var _high_score: int = 0
var _score: int = 0

func _ready():
	load_highscore()
	SignalManager.on_boss_kill.connect(on_boss_kill)
	SignalManager.on_pickup_hit.connect(on_pickup_hit)
	SignalManager.on_enemy_hit.connect(on_enemy_hit)
	SignalManager.on_level_complete.connect(on_level_complete)
	SignalManager.on_game_over.connect(on_game_over)
	
func update_score(points: int) -> void:
	_score += points
	if _high_score < _score:
		_high_score = _score
	SignalManager.on_score_updated.emit()
		
func get_score() -> int:
	return _score
	
func get_high_score() -> int:
	return _high_score
	
func reset_score() -> void:
	_score = 0

func save_highscore() -> void:
	var file = FileAccess.open(HS_FILE, FileAccess.WRITE)
	var data = {
		HS_KEY: _high_score
	}
	file.store_string(JSON.stringify(data))
	

func load_highscore() -> void:
	if !FileAccess.file_exists(HS_FILE):
		return
		
	var file = FileAccess.open(HS_FILE, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	
	
	if HS_KEY in data:
		_high_score = data[HS_KEY]


	
func on_level_complete() -> void:
	save_highscore()
	
func on_game_over() -> void:
	save_highscore()
	
func on_enemy_hit(points: int, _v: Vector2) -> void:	
	update_score(points)
	
func on_pickup_hit(points: int) -> void:
	update_score(points)
	
func on_boss_kill(points: int) -> void:	
	update_score(points)
