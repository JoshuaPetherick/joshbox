extends Node3D

const GAME_START_TICK = 4

@export var game_music: AudioStreamWAV
@export var cards: Dictionary[Texture, int]
@export var card_scene: PackedScene

@onready var header: Label = %Header
@onready var deck: Node3D = %CardDeck

@onready var game_tick_sfx: AudioStreamPlayer = %ImpactLow
@onready var game_start_sfx: AudioStreamPlayer = %ImpactHigh

@onready var gamestart_timer: Timer = %GameStartTimer
@onready var gameend_timer: Timer = %GameEndTimer
@onready var carddrop_timer: Timer = %CardDropTimer
@onready var player_1_delay_timer: Timer = %Player1DelayTimer
@onready var player_2_delay_timer: Timer = %Player2DelayTimer

# Game Properties
var winner: int = -1
var game_tick: int = 0
var game_started: bool = false
var rng = RandomNumberGenerator.new()

var player_1_delayed: bool = false
var player_2_delayed: bool = false

var awaiting_snap: bool = false
var current_card: int = 0
var previous_card_value: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Game Started
	GlobalSignals.game_started.emit()
	GlobalMusicManager.play_song(game_music)
	
	# Set Default Text
	header.text = "Game Starting!"
	
	# Connect to Signals
	gamestart_timer.timeout.connect(_on_gamestart_timer_timeout)
	gameend_timer.timeout.connect(_on_gameend_timer_timeout)
	carddrop_timer.timeout.connect(_on_carddrop_timer_timeout)
	player_1_delay_timer.timeout.connect(_on_player_1_delay_timer_timeout)
	player_2_delay_timer.timeout.connect(_on_player_2_delay_timer_timeout)
	
	# Setup
	var card_deck = _get_card_deck()
	
	# Populate
	for i in card_deck.size():
		var card = card_scene.instantiate()
		card.setup(card_deck.keys()[i], card_deck.values()[i])
		card.name = "card_" + str(i)
		card.position = Vector3(0, 0.25 * i, 0)
		deck.add_child(card)

func _physics_process(delta: float) -> void:
	# Check
	if (not game_started):
		return

#region Events

func _input(event: InputEvent) -> void:	
	# Action Check
	if (not event.is_action("player_action_8")):
		return
	
	# Setup
	var player = GlobalDeviceManager.get_player_from_event(event)
	if (player == null):
		return
	
	# If Player is delayed
	if (player == 1 && player_1_delayed):
		return
	elif (player == 2 && player_2_delayed):
		return
	
	# No Snap! Add small delay
	if (not awaiting_snap):
		if (player == 1):
			player_1_delayed = true
			player_1_delay_timer.start()
		elif (player == 2):
			player_2_delayed = true
			player_2_delay_timer.start()
		return
	
	# Set Winner
	winner = player
	
	# Update UI
	header.text = GlobalGameProperties.get_player_name(player) + " Wins!"
	
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
			# Set Game Label
			header.text = "GO!"
			
			# Play SFX
			game_start_sfx.play()
			
			# Drop First Card
			_on_carddrop_timer_timeout()
			
			# Start Card Drop Timer
			carddrop_timer.start()
		_:
			# Set Countdown text
			header.text = str(GAME_START_TICK - game_tick)
			
			# Play SFX
			game_tick_sfx.play()

func _on_gameend_timer_timeout() -> void:
	GlobalSignals.game_finished.emit(winner)

func _on_carddrop_timer_timeout() -> void:
	# Check
	if (awaiting_snap):
		return
	
	# Get Card
	var card: RigidBody3D = deck.get_child(current_card)
	
	# Rotate Card
	card.rotation.z = rng.randf_range(0, 360)
	
	# Unfreeze Card
	card.freeze = false
	
	# Compare Value
	if (card.card_value == previous_card_value):
		awaiting_snap = true
	else:
		previous_card_value = card.card_value
	
	# Update Param
	current_card += 1
	
	# Speed up Timer
	carddrop_timer.wait_time = 2 - (0.025 * current_card)

func _on_player_1_delay_timer_timeout() -> void:
	player_1_delayed = false

func _on_player_2_delay_timer_timeout() -> void:
	player_2_delayed = false

#endregion

#region Operations

func _get_card_deck() -> Dictionary[Texture, int]:
	# Setup
	var result: Dictionary[Texture, int]
	
	# Append
	while (result.size() < cards.size()):
		# Duplicate Deck
		var validated: bool = false
		var previous_value: int = 0
		var cards_dup = cards.duplicate()
		
		# Add Cards to Result
		while (result.size() < cards.size()):
			# Setup
			var index = rng.randi_range(1, cards_dup.size()) - 1
			var key = cards_dup.keys()[index]
			var value = cards_dup.values()[index]
			
			# Append
			result[key] = value
			
			# Remove
			cards_dup.erase(key)
		
		# Check if snap is possible
		for i in result:
			# Check
			if (result[i] == previous_value):
				validated = true
			
			# Store Prev Value
			previous_value = result[i]
		
		# Quick Game Check
		if (result.values()[0] == result.values()[1]):
			validated = false
		
		# Validation Check
		if (not validated):
			result.clear()
	
	# Result
	return result

#endregion
