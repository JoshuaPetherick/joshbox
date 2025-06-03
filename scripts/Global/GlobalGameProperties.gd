extends Node

enum GameTypes { NONE, VERSUS, SINGLE, TOURNAMENT }

# Game Management Variables
var game_type: GameTypes = GameTypes.NONE
var game_scene: PackedScene

# Player Variables
var player_1_name: String = "Player 1"
var player_2_name: String = "Player 2"
var tournament_names: Array = []

# Playtime Variables
var player_scores_dict: Dictionary = {}
