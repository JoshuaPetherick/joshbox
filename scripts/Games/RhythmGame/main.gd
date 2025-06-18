extends Node2D

const GAME_START_TICK = 4
const MISSED_POINT_SCORE = -50

@export var note_scene: PackedScene

@onready var header_label: Label = %Header
@onready var player_1_score_label: Label = %Player_1_Score
@onready var player_2_score_label: Label = %Player_2_Score

@onready var notes_parent_node: Node2D = %Notes

@onready var player_1: RhythmPlayer = %Player_1
@onready var player_2: RhythmPlayer = %Player_2

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
	
	# Fade out music
	GlobalMusicManager.fade_song()
	
	# Set Default Text
	header_label.text = "Game Starting!"
	player_1_score_label.text = ""
	player_2_score_label.text = ""
	
	# Connect to Signals
	gamestart_timer.timeout.connect(_on_gamestart_timer_timeout)
	gameend_timer.timeout.connect(_on_gameend_timer_timeout)
	player_1.note_hit.connect(_on_player_1_note_hit)
	player_2.note_hit.connect(_on_player_2_note_hit)
	player_1.note_missed.connect(_on_player_1_note_missed)
	player_2.note_missed.connect(_on_player_2_note_missed)
	
	# Spawn Note
	spawn_notes(1, "player_action_5")

#region Events

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
			# Set Game Label
			header_label.text = "GO!"
			player_1_score_label.text = "0"
			player_2_score_label.text = "0"
			
			# Play SFX
			game_start_sfx.play()
		
		_:
			# Set Countdown text
			header_label.text = str(GAME_START_TICK - game_tick)
			
			# Play SFX
			game_tick_sfx.play()

func _on_gameend_timer_timeout() -> void:
	GlobalSignals.game_finished.emit(winner)

func _on_player_1_note_hit(points: int):
	# Update Score
	player1Score += points
	
	# Update Label
	player_1_score_label.text = str(player1Score)

func _on_player_2_note_hit(points: int):
	# Update Score
	player2Score += points
	
	# Update Label
	player_2_score_label.text = str(player2Score)

func _on_player_1_note_missed():
	# Update Score
	player1Score -= MISSED_POINT_SCORE
	
	# Update Label
	player_1_score_label.text = str(player1Score)

func _on_player_2_note_missed():
	# Update Score
	player2Score += MISSED_POINT_SCORE
	
	# Update Label
	player_2_score_label.text = str(player2Score)

#endregion

#region Operations

func spawn_notes(lane_id: int, input: String):
	# Setup
	var spawn_1: Vector2 = player_1.get_lane_spawn_position(lane_id)
	var spawn_2: Vector2 = player_2.get_lane_spawn_position(lane_id)
	
	# Create Notes
	var note_1 = note_scene.instantiate()
	var note_2 = note_scene.instantiate()
	
	# Set Spawn Positions
	note_1.global_position = spawn_1
	note_2.global_position = spawn_2
	
	# Add Notes to Scene
	notes_parent_node.add_child(note_1)
	notes_parent_node.add_child(note_2)
	
	# Setup Notes
	note_1.setup(1, input)
	note_2.setup(2, input)

#endregion
