extends CharacterBody2D

const SPEED: float = 300.0

@export var player_id: int = 1

# Game Variables
var can_move: bool = false

# Movement Variables
var up_strength: float 
var down_strength: float 

func _physics_process(delta: float) -> void:
	# Check
	if not can_move:
		return
	
	var direction = Vector2(0, -up_strength + down_strength)
	if direction:
		velocity.y = direction.y * SPEED
	else:
		velocity.y = move_toward(velocity.x, 0, SPEED)
	
	# Move Player Character
	# Note: delta is not needed since it's applied internally by move_and_slide()
	move_and_slide()

func _input(event: InputEvent) -> void:
	# Setup
	var player = GlobalDeviceManager.get_player_from_event(event)
	
	# Checks
	if (player == null):
		return
	
	if (player != player_id):
		return
	
	# Get Movement Actions
	if (event.is_action_pressed("player_action_10")):
		up_strength = event.get_action_strength("player_action_10")
	elif (event.is_action_released("player_action_10")):
		up_strength = 0
		
	if (event.is_action_pressed("player_action_12")):
		down_strength = event.get_action_strength("player_action_12")
	elif (event.is_action_released("player_action_12")):
		down_strength = 0
