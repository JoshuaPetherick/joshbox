extends "res://scripts/Generics/minigame.gd"

const MAX_SCORE = 2

enum Actions { NONE, ROCK, PAPER, SCISSORS }

var hasRoundStarted: bool = false
var player1Action = Actions.NONE
var player2Action = Actions.NONE

var player1Score: int = 0
var player2Score: int = 0
var winner: int = -1

@export var game_music: AudioStreamWAV
@export var header_label: Label
@export var point_sfx: AudioStreamPlayer

@export var no_point_icon: Texture
@export var point_icon: Texture

@export var point_1_icon_P1: TextureRect
@export var point_2_icon_P1: TextureRect

@export var point_1_icon_P2: TextureRect
@export var point_2_icon_P2: TextureRect

@onready var lhand: Sprite2D = %LHand
@onready var rhand: Sprite2D = %RHand
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var endgame_timer: Timer = $EndGameTimer

func _ready() -> void:
	# Load Textures
	point_1_icon_P1.texture = no_point_icon
	point_1_icon_P2.texture = no_point_icon
	
	point_2_icon_P1.texture = no_point_icon
	point_2_icon_P2.texture = no_point_icon
	
	# Connect to Signal
	endgame_timer.timeout.connect(_on_endgame_timer_timeout)
	
	# Game Started
	GlobalSignals.game_started.emit()
	GlobalMusicManager.play_song(game_music)

func _input(event: InputEvent) -> void:
	# Checks
	if (hasRoundStarted == true):
		return
	
	# Setup
	var player = GlobalDeviceManager.get_player_from_event(event)
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

#region Events

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	finish_round()

func _on_endgame_timer_timeout():
	GlobalSignals.game_finished.emit(winner)

#endregion

#region Game Operations

func start_round():
	# Set Params
	hasRoundStarted = true
	
	# Play Animation
	animation_player.play("Start")
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
		
		# Play SFX
		point_sfx.play()
	
	# Set Point Icons
	match player1Score:
		1:
			point_1_icon_P1.texture = point_icon
		2:
			point_1_icon_P1.texture = point_icon
			point_2_icon_P1.texture = point_icon
	
	match player2Score:
		1:
			point_1_icon_P2.texture = point_icon
		2:
			point_1_icon_P2.texture = point_icon
			point_2_icon_P2.texture = point_icon
	
	# Player 1 Wins
	if (player1Score >= MAX_SCORE):
		winner = 1
		endgame_timer.start()
		header_label.text = "Player 1 Wins!"
		
	# Player 2 Wins!
	elif (player2Score >= MAX_SCORE):
		winner = 2
		endgame_timer.start()
		header_label.text = "Player 2 Wins!"
		
	# Restart Round
	else:
		player1Action = Actions.NONE
		player2Action = Actions.NONE
		hasRoundStarted = false

func set_player_sprites():
	lhand.frame = get_sprite_frame(player1Action)
	rhand.frame = get_sprite_frame(player2Action)
	
#endregion

#region Functions

func get_sprite_frame(action: Actions):
	match action:
		Actions.PAPER:
			return 0
		Actions.SCISSORS:
			return 1
		_:
			return 2

#endregion
