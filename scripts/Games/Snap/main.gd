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

# Game Properties
var winner: int = -1
var game_tick: int = 0
var game_started: bool = false

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
	
	# Setup
	var card_deck = _get_card_deck()
	
	# Populate
	for i in card_deck.size():
		var card = card_scene.instantiate()
		card.setup(card_deck.keys()[i], card_deck.values()[i])
		deck.add_child(card)

func _physics_process(delta: float) -> void:
	# Check
	if (not game_started):
		return

#region Events

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
		_:
			# Set Countdown text
			header.text = str(GAME_START_TICK - game_tick)
			
			# Play SFX
			game_tick_sfx.play()

func _on_gameend_timer_timeout() -> void:
	GlobalSignals.game_finished.emit(winner)

#endregion

#region Operations

func _get_card_deck() -> Dictionary[Texture, int]:
	# Setup
	var rng = RandomNumberGenerator.new()
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
