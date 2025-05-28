extends "res://scripts/Generics/minigame.gd"

const MAX_SCORE = 2

enum Actions { NONE, ROCK, PAPER, SCISSORS }

var hasRoundStarted = false
var player1Action = Actions.NONE
var player2Action = Actions.NONE

var player1Score = 0
var player2Score = 0

@export var no_point_icon: Texture
@export var point_icon: Texture

@export var point_1_icon_P1: TextureRect
@export var point_2_icon_P1: TextureRect

@export var point_1_icon_P2: TextureRect
@export var point_2_icon_P2: TextureRect

@export var action_1_icon_P1: TextureRect
@export var action_2_icon_P1: TextureRect
@export var action_3_icon_P1: TextureRect

@export var action_1_icon_P2: TextureRect
@export var action_2_icon_P2: TextureRect
@export var action_3_icon_P2: TextureRect

@onready var lhand: Sprite2D = %LHand
@onready var rhand: Sprite2D = %RHand
@onready var animation_player: AnimationPlayer = %AnimationPlayer

func _ready() -> void:
	# Setup
	var device_p1 = GlobalDeviceManager.get_device_from_player(1)
	var device_p2 = GlobalDeviceManager.get_device_from_player(2)
	
	# Load Textures
	point_1_icon_P1.texture = no_point_icon
	point_1_icon_P2.texture = no_point_icon
	
	point_2_icon_P1.texture = no_point_icon
	point_2_icon_P2.texture = no_point_icon
	
	action_1_icon_P1.texture = GlobalDeviceManager.get_action_icon(device_p1, "player_action_1")
	action_2_icon_P1.texture = GlobalDeviceManager.get_action_icon(device_p1, "player_action_2")
	action_3_icon_P1.texture = GlobalDeviceManager.get_action_icon(device_p1, "player_action_3")
	
	action_1_icon_P2.texture = GlobalDeviceManager.get_action_icon(device_p2, "player_action_1")
	action_2_icon_P2.texture = GlobalDeviceManager.get_action_icon(device_p2, "player_action_2")
	action_3_icon_P2.texture = GlobalDeviceManager.get_action_icon(device_p2, "player_action_3")
	
	# Game Started
	GlobalSignals.game_started.emit()

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
		GlobalSignals.game_finished.emit(1)
		print("Player 1 Wins!")
		
	# Player 2 Wins!
	elif (player2Score >= MAX_SCORE):
		GlobalSignals.game_finished.emit(2)
		print("Player 2 Wins!")
		
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
