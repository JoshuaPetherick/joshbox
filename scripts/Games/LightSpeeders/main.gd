extends Node2D

const GAME_START_TICK = 4

@export var game_music: AudioStreamWAV

@onready var header: Label = %Header
@onready var player_1: LSPlayer = %Player1
@onready var player_2: LSPlayer = %Player2

@onready var game_tick_sfx: AudioStreamPlayer = %ImpactLow
@onready var game_start_sfx: AudioStreamPlayer = %ImpactHigh

@onready var gamestart_timer: Timer = %GameStartTimer
@onready var gameend_timer: Timer = %GameEndTimer

# Game Properties
var game_tick: int = 0
var winner: int = -1

func _ready() -> void:
	# Game Started
	GlobalSignals.game_started.emit()
	GlobalMusicManager.play_song(game_music)
	
	# Set Default Text
	header.text = "Game Starting!"
	
	# Connect to Signals
	player_1.player_collision.connect(_on_player_collision_1)
	player_2.player_collision.connect(_on_player_collision_2)
	gamestart_timer.timeout.connect(_on_gamestart_timer_timeout)
	gameend_timer.timeout.connect(_on_gameend_timer_timeout)

func _on_player_collision_1(player: int):
	_on_player_collision(player)

func _on_player_collision_2(player: int):
	_on_player_collision(player)

func _on_gamestart_timer_timeout() -> void:
	# Increment Game Tick
	game_tick += 1
	
	# Next
	match game_tick:
		GAME_START_TICK + 2:
			# Hide Label and Stop Timer
			header.text = ""
			gamestart_timer.stop()
			
		GAME_START_TICK + 1: 
			pass
			
		GAME_START_TICK:
			# Enable Players
			player_1.can_move = true
			player_2.can_move = true
			
			# Set Game Label
			header.text = "GO!"
			
			# Play SFX
			game_start_sfx.play()
		_:
			# Set Countdown text
			header.text = str(GAME_START_TICK - game_tick)
			
			# Play SFX
			game_tick_sfx.play()

func _on_gameend_timer_timeout() -> void:
	GlobalSignals.game_finished.emit(winner)

func _on_player_collision(player: int):
	# Get Winner
	match player:
		1: winner = 2
		2: winner = 1
	
	# Stop Movement
	player_1.can_move = false
	player_2.can_move = false
	
	# Update UI
	header.text = GlobalGameProperties.get_player_name(winner) + " Wins!"
	
	# Start Timer
	gameend_timer.start()
