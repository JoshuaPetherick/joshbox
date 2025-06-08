extends Area2D
class_name PongBall

const STARTING_SPEED: float = 150
const SPEED_INCREMENT: float = 25

# Game Components
@onready var hit_sfx: AudioStreamPlayer = %Ping

# Movement Vars
var move_up: bool
var move_left: bool
var speed: float = STARTING_SPEED
var can_move: bool = false

# Game Variables
var rng: RandomNumberGenerator

func _ready() -> void:
	# Setup
	rng = RandomNumberGenerator.new()
	
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
			play_sfx()
			move_up = false
		"Bottom":
			play_sfx()
			move_up = true
		"Player1":
			play_sfx()
			move_left = false
			speed += SPEED_INCREMENT
		"Player2":
			play_sfx()
			move_left = true
			speed += SPEED_INCREMENT

func play_sfx() -> void:
	hit_sfx.pitch_scale = 1.0 + rng.randf_range(-0.1, 0.1)
	hit_sfx.play()
