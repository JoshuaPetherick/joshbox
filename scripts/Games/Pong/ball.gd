extends Area2D
class_name PongBall

const STARTING_SPEED: float = 150
const SPEED_INCREMENT: float = 25

# Movement Vars
var move_up: bool
var move_left: bool
var speed: float = STARTING_SPEED
var can_move: bool = false

func _ready() -> void:
	# Setup
	var rng = RandomNumberGenerator.new()
	
	# Get move directions
	match rng.randi_range(0, 1):
		0:
			move_up = true
		_:
			move_up = false
	
	match rng.randi_range(0, 1):
		0:
			move_left = true
		_:
			move_left = false
	
	# Setup Signals
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	# Check
	if not can_move:
		return
	
	# Setup
	var velocity_x = 0
	var velocity_y = 0
	
	# Get Velocity
	if (move_left):
		velocity_x = -1
	else:
		velocity_x = 1
	
	if (move_up):
		velocity_y = -1
	else:
		velocity_y = 1
	
	# Calculate Position Offset
	var movement = Vector2(velocity_x * speed * delta, velocity_y * speed * delta)
	
	# Move Character
	global_position += movement

func _on_body_entered(body: Node2D) -> void:
	# Checks
	match body.name:
		"Top":
			move_up = false
		"Bottom":
			move_up = true
		"Player1":
			move_left = false
			speed += SPEED_INCREMENT
		"Player2":
			move_left = true
			speed += SPEED_INCREMENT
