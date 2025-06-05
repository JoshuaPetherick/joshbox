extends Node2D

const GAME_START_TICK = 4
const GAME_MAX_POINTS = 3

@export var game_music: AudioStreamWAV
@export var header_label: Label

@export var point_icon: Texture
@export var no_point_icon: Texture

@export var point_1_icon_P1: TextureRect
@export var point_2_icon_P1: TextureRect
@export var point_3_icon_P1: TextureRect

@export var point_1_icon_P2: TextureRect
@export var point_2_icon_P2: TextureRect
@export var point_3_icon_P2: TextureRect

@onready var ball: Area2D = %Ball
@onready var goal_1: Area2D = %Goal1
@onready var goal_2: Area2D = %Goal2
@onready var player_1: CharacterBody2D = %Player1
@onready var player_2: CharacterBody2D = %Player2

@onready var game_tick_sfx: AudioStreamPlayer = %ImpactLow
@onready var game_start_sfx: AudioStreamPlayer = %ImpactHigh

@onready var gamestart_timer: Timer = %GameStartTimer
@onready var gameend_timer: Timer = %GameEndTimer

# Game Properties
var game_tick: int = 0
var winner: int = -1
var player1Score: int = 0
var player2Score: int = 0

func _ready() -> void:
	# Game Started
	GlobalSignals.game_started.emit()
	GlobalMusicManager.play_song(game_music)
	
	# Load Textures
	point_1_icon_P1.texture = no_point_icon
	point_2_icon_P1.texture = no_point_icon
	point_3_icon_P1.texture = no_point_icon
	
	point_1_icon_P2.texture = no_point_icon
	point_2_icon_P2.texture = no_point_icon
	point_3_icon_P2.texture = no_point_icon
	
	# Set Default Text
	header_label.text = "Game Starting!"
	
	# Connect to Signals
	goal_1.area_entered.connect(_on_goal_1_area_entered)
	goal_2.area_entered.connect(_on_goal_2_area_entered)
	gamestart_timer.timeout.connect(_on_gamestart_timer_timeout)
	gameend_timer.timeout.connect(_on_gameend_timer_timeout)

#region Events

func _on_goal_1_area_entered(area: Area2D) -> void:
	# Add Point
	player2Score += 1
	
	# Update UI
	match player2Score:
		1: point_1_icon_P2.texture = point_icon
		2: point_2_icon_P2.texture = point_icon
		3: point_3_icon_P2.texture = point_icon
	
	# Check if game over
	if player2Score >= GAME_MAX_POINTS:
		# Set Winner
		winner = 2
		
		# Disable Ball
		ball.can_move = false
		
		# Update UI
		header_label.text = GlobalGameProperties.get_player_name(2) + " Wins!"
		
		# Start Timer
		gameend_timer.start()
	
	# Reset Ball
	ball.speed = ball.STARTING_SPEED
	ball.global_position = Vector2(0,0)

func _on_goal_2_area_entered(area: Area2D) -> void:
	# Add Point
	player1Score += 1
	
	# Update UI
	match player1Score:
		1: point_1_icon_P1.texture = point_icon
		2: point_2_icon_P1.texture = point_icon
		3: point_3_icon_P1.texture = point_icon
	
	# Check if game over
	if player1Score >= GAME_MAX_POINTS:
		# Set Winner
		winner = 1
		
		# Disable Ball
		ball.can_move = false
		
		# Update UI
		header_label.text = GlobalGameProperties.get_player_name(1) + " Wins!"
		
		# Start Timer
		gameend_timer.start()
	
	# Reset Ball
	ball.speed = ball.STARTING_SPEED
	ball.global_position = Vector2(0,0)

func _on_gamestart_timer_timeout() -> void:
	# Increment Game Tick
	game_tick += 1
	
	# Next
	match game_tick:
		GAME_START_TICK + 2:
			# Hide Label and Stop Timer
			header_label.text = ""
			gamestart_timer.stop()
			
		GAME_START_TICK + 1: 
			pass
			
		GAME_START_TICK:
			# Enable Players
			ball.can_move = true
			player_1.can_move = true
			player_2.can_move = true
			
			# Set Game Label
			header_label.text = "GO!"
			
			# Play SFX
			game_start_sfx.play()
		_:
			# Set Countdown text
			header_label.text = str(GAME_START_TICK - game_tick)
			
			# Play SFX
			game_tick_sfx.play()

func _on_gameend_timer_timeout() -> void:
	GlobalSignals.game_finished.emit(winner)

#endregion
