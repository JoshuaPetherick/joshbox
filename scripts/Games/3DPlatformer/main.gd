extends Node3D

const GAME_START_TICK = 4

@export
var player_1: Player
@export
var player_2: Player

@export
var game_goal: Area3D
@export
var game_label: Label
@export
var game_start_timer: Timer

var game_tick: int = 0

func _ready() -> void:
	# Game Started
	GlobalSignals.game_started.emit()
	
	# Setup Signals
	game_goal.body_entered.connect(_on_body_entered)
	game_start_timer.timeout.connect(_on_game_start_timer_timeout)
	
	# Disable Players
	player_1.can_move = false
	player_2.can_move = false
	
	# Set Default Text
	game_label.text = "Game Starting!"
	
	# Start Timer
	game_start_timer.start()

func _on_body_entered(body: Node3D) -> void:
	# Check
	if game_label.text.contains("Wins"):
		return
	
	# Get Winner
	if (body is Player):
		# Get Winner
		if (body.name == "Player_1"):
			game_label.text = "Player 1 Wins!"
		else:
			game_label.text = "Player 2 Wins!"

func _on_game_start_timer_timeout():
	# Increment Game Tick
	game_tick += 1
	
	# Next
	match game_tick:
		GAME_START_TICK + 2:
			# Hide Label and Stop Timer
			game_label.text = ""
			game_start_timer.stop()
			
		GAME_START_TICK + 1: 
			pass
			
		GAME_START_TICK:
			# Enable Players
			player_1.can_move = true
			player_2.can_move = true
			
			# Set Game Label
			game_label.text = "GO!"
		_:
			# Set Countdown text
			game_label.text = str(GAME_START_TICK - game_tick)
