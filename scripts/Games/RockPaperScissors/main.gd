extends "res://scripts/Generics/minigame.gd"

const max_score = 2

enum Actions { NONE, ROCK, PAPER, SCISSORS }

var hasRoundStarted = false
var player1Action = Actions.NONE
var player2Action = Actions.NONE

var player1Score = 0
var player2Score = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	# Checks
	if (hasRoundStarted == true):
		return
		
	# Setup
	var player = GlobalDeviceManager.get_player_from_device(event.device)
	if (player == null):
		return
	
	match player:
		1:
			if (event.is_action("player_action_1")):
				player1Action = Actions.ROCK
			elif (event.is_action("player_action_2")):
				player1Action = Actions.PAPER
			elif (event.is_action("player_action_3")):
				player1Action = Actions.SCISSORS
		
		2:
			if (event.is_action("player_action_1")):
				player2Action = Actions.ROCK
			elif (event.is_action("player_action_2")):
				player2Action = Actions.PAPER
			elif (event.is_action("player_action_3")):
				player2Action = Actions.SCISSORS
	
	# Round Checks
	if (player1Action == Actions.NONE):
		return
	
	if (player2Action == Actions.NONE):
		return	
	
	# Start Round
	start_round()

#region Game Operations

func start_round():
	# Set Params
	hasRoundStarted = true
	
	# Play Animation
	# TODO
	pass
	
func finish_round():
	# Calculate Round Winner
	if (player1Action != player2Action):
		if (player1Action == Actions.ROCK && player2Action == Actions.SCISSORS):
			player1Score += 1
		elif (player1Action == Actions.PAPER && player2Action == Actions.ROCK):
			player1Score += 1
		elif (player1Action == Actions.SCISSORS && player2Action == Actions.PAPER):
			player1Score += 1
			
		elif (player2Action == Actions.ROCK && player1Action == Actions.SCISSORS):
			player2Score += 1
		elif (player2Action == Actions.PAPER && player1Action == Actions.ROCK):
			player2Score += 1
		elif (player2Action == Actions.SCISSORS && player1Action == Actions.PAPER):
			player2Score += 1
	
	# Player 1 Wins
	if (player1Score >= max_score):
		GlobalSignals.game_finished.emit(1)
		
	# Player 2 Wins!
	elif (player2Score >= max_score):
		GlobalSignals.game_finished.emit(2)
		
	# Restart Round
	else:
		player1Action = Actions.NONE
		player2Action = Actions.NONE
		hasRoundStarted = false
	
#endregion
