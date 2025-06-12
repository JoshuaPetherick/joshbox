extends Node2D

const GAME_START_TICK = 4

@export var game_music: AudioStreamWAV

@onready var header: Label = %Header
@onready var animation_player: AnimationPlayer = %AnimationPlayer

@onready var player_1: AnimatableBody2D = %Player_1
@onready var player_2: AnimatableBody2D = %Player_2

@onready var goal_1: Area2D = %Goal_1
@onready var goal_2: Area2D = %Goal_2

@onready var game_tick_sfx: AudioStreamPlayer = %ImpactLow
@onready var game_start_sfx: AudioStreamPlayer = %ImpactHigh

@onready var gamestart_timer: Timer = %GameStartTimer
@onready var gameend_timer: Timer = %GameEndTimer

# Game Properties
var game_tick: int = 0
var winner: int = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Game Started
	GlobalSignals.game_started.emit()
	GlobalMusicManager.play_song(game_music)
	
	# Set Default Text
	header.text = "Game Starting!"
	
	# Connect to Signals
	goal_1.body_entered.connect(_on_goal_1_body_entered)
	goal_2.body_entered.connect(_on_goal_2_body_entered)
	gamestart_timer.timeout.connect(_on_gamestart_timer_timeout)
	gameend_timer.timeout.connect(_on_gameend_timer_timeout)

#region Events

func _on_goal_1_body_entered(_body: Node2D) -> void:
	# Set Winner
	winner = 1
	
	# Disable Gameplay
	animation_player.pause()
	player_1.can_spawn_box = false
	player_2.can_spawn_box = false
	
	# Update UI
	header.text = GlobalGameProperties.get_player_name(1) + " Wins!"
	
	# Start Timer
	gameend_timer.start()

func _on_goal_2_body_entered(_body: Node2D) -> void:
	# Set Winner
	winner = 2
	
	# Disable Gameplay
	animation_player.pause()
	player_1.can_spawn_box = false
	player_2.can_spawn_box = false
	
	# Update UI
	header.text = GlobalGameProperties.get_player_name(2) + " Wins!"
	
	# Start Timer
	gameend_timer.start()

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
			player_1.can_spawn_box = true
			player_2.can_spawn_box = true
			
			# Set Game Label
			header.text = "GO!"
			
			# Play SFX
			game_start_sfx.play()
			
			# Play Animation
			animation_player.play("default")
		_:
			# Set Countdown text
			header.text = str(GAME_START_TICK - game_tick)
			
			# Play SFX
			game_tick_sfx.play()

func _on_gameend_timer_timeout() -> void:
	GlobalSignals.game_finished.emit(winner)
