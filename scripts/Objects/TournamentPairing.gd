class_name TournamentPairing

var player_1_id: int
var player_2_id: int
var game_scene: PackedScene

func _init(p1: int, p2: int, scene: PackedScene) -> void:
	player_1_id = p1
	player_2_id = p2
	game_scene = scene
