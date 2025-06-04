extends Node

enum GameTypes { NONE, VERSUS, SINGLE, TOURNAMENT }

# Game Management Variables
var game_type: GameTypes = GameTypes.NONE
var game_scene: PackedScene

# Player Variables
var player_1_name: String = "Player 1"
var player_2_name: String = "Player 2"
var tournament_names: Array = []
var tournament_player_1_name: String
var tournament_player_2_name: String

# Playtime Variables
var player_scores_dict: Dictionary = {}

# Functions
func get_player_name(index: int) -> String:
	match game_type:
		GameTypes.TOURNAMENT:
			if (index == 1):
				return tournament_player_1_name
			else:
				return tournament_player_2_name
		_:
			if (index == 1):
				return player_1_name
			else:
				return player_2_name
