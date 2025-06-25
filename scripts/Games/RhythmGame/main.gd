extends Node2D

const GAME_START_TICK = 4
const MISSED_POINT_SCORE = -50

@export var note_scene: PackedScene
@export var music_levels: Array[MusicLevel]

@onready var header_label: Label = %Header
@onready var player_1_score_label: Label = %Player_1_Score
@onready var player_2_score_label: Label = %Player_2_Score

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var music_player: AudioStreamPlayer = %MusicPlayer
@onready var notes_parent_node: Node2D = %Notes

@onready var player_1: RhythmPlayer = %Player_1
@onready var player_2: RhythmPlayer = %Player_2

@onready var game_tick_sfx: AudioStreamPlayer = %ImpactLow
@onready var game_start_sfx: AudioStreamPlayer = %ImpactHigh

@onready var gamestart_timer: Timer = %GameStartTimer
@onready var gameend_timer: Timer = %GameEndTimer

# Game Properties
var game_tick: int = 0
var game_time: float = 0
var winner: int = -1
var player1Score: int = 0
var player2Score: int = 0

var lane_1_action: String
var lane_1_notes: Array[float]

var lane_2_action: String
var lane_2_notes: Array[float]

var lane_3_action: String
var lane_3_notes: Array[float]

func _ready() -> void:
	# Game Started
	GlobalSignals.game_started.emit()
	
	# Fade out music
	GlobalMusicManager.fade_song()
	
	# Set Default Text
	header_label.text = "Game Starting!"
	player_1_score_label.text = ""
	player_2_score_label.text = ""
	
	# Randomly Select Song (TODO)
	music_player.stream = music_levels[0].game_music
	lane_1_action = music_levels[0].action_1
	lane_2_action = music_levels[0].action_2
	lane_3_action = music_levels[0].action_3
	
	lane_1_notes = music_levels[0].timestamps_1.duplicate()
	lane_2_notes = music_levels[0].timestamps_2.duplicate()
	lane_3_notes = music_levels[0].timestamps_3.duplicate()
	
	# Connect to Signals
	gamestart_timer.timeout.connect(_on_gamestart_timer_timeout)
	gameend_timer.timeout.connect(_on_gameend_timer_timeout)
	player_1.note_hit.connect(_on_player_1_note_hit)
	player_2.note_hit.connect(_on_player_2_note_hit)
	player_1.note_missed.connect(_on_player_1_note_missed)
	player_2.note_missed.connect(_on_player_2_note_missed)
	music_player.finished.connect(_on_music_player_finished)
	
	# Spawn
	_check_notes(0)

func _process(delta: float) -> void:
	_check_notes(delta)

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
			# Start Animation
			animation_player.play("start")
			
			# Play Music
			music_player.play()
		
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

func _on_music_player_finished():
	if (player1Score > player2Score):
		winner = 1
		header_label.text = GlobalGameProperties.get_player_name(1) + " Wins!"
	elif (player2Score > player1Score):
		winner = 2
		header_label.text = GlobalGameProperties.get_player_name(2) + " Wins!"
	else:
		winner = 0
		header_label.text = "Draw!"
	
	# Start Timer
	gameend_timer.start()

#endregion

#region Operations

func _check_notes(delta: float):
	# Check
	if (lane_1_notes.size() < 1 &&
		lane_2_notes.size() < 1 &&
		lane_3_notes.size() < 1):
		return
	
	# Setup
	var new_game_time = game_time + delta
	
	# Check Lanes
	_check_lane(1, lane_1_action, lane_1_notes, new_game_time)
	_check_lane(2, lane_2_action, lane_2_notes, new_game_time)
	_check_lane(3, lane_3_action, lane_3_notes, new_game_time)
	
	# Update Game Time
	game_time = new_game_time

func _check_lane(lane: int, action: String, lane_notes: Array[float], new_game_time: float):
	# Check
	if (lane_notes.size() < 1):
		return
	
	# Iterate over array
	for i in lane_notes.size():
		var note: float = lane_notes[i]
		
		# Spawn Note
		if (note >= game_time && note <= new_game_time):
			_spawn_notes(lane, action)
			lane_notes.remove_at(i)
			return

func _spawn_notes(lane_id: int, input: String):
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
