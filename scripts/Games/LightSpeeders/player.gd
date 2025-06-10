extends CharacterBody2D
class_name LSPlayer

const SPEED = 100.0

enum DIRECTIONS { NORTH, SOUTH, EAST, WEST }

signal player_collision(player: int)

# Trail Scene
@export_group("Trail Settings")
@export var trail: PackedScene
@export var trail_colour: Color = Color(1.0, 1.0, 1.0, 0.8)
@export var trail_parent: Node

# Player Variables
@export_group("Player Settings")
@export var player_id: int = 1
@export var direction: DIRECTIONS = DIRECTIONS.EAST

# Runtime Vars
var current_trail: Trail
var can_move: bool = false

func _ready() -> void:
	# Setup
	spawn_trail()
	rotation_degrees = get_player_rotation()

func _physics_process(_delta: float) -> void:
	# Checks
	if (not can_move):
		return
	
	# Setup
	var old_position = global_position
	
	# Reset
	velocity = Vector2.ZERO
	
	# Apply Direction
	match direction:
		DIRECTIONS.NORTH:
			velocity.y = -SPEED
		DIRECTIONS.SOUTH:
			velocity.y = SPEED
		DIRECTIONS.EAST:
			velocity.x = SPEED
		DIRECTIONS.WEST:
			velocity.x = -SPEED
	
	# Move Player
	move_and_slide()
	
	# Update Trail 
	var adjustment = 0
	match direction:
		DIRECTIONS.NORTH:
			adjustment = (global_position.y - old_position.y) 
			current_trail.scale.y += adjustment
			current_trail.global_position.y += (adjustment / 2)
		DIRECTIONS.SOUTH:
			adjustment = (global_position.y - old_position.y) 
			current_trail.scale.y += adjustment
			current_trail.global_position.y += (adjustment / 2)
		_:
			adjustment = (global_position.x - old_position.x)
			current_trail.scale.x += adjustment
			current_trail.global_position.x += (adjustment / 2)

func _input(event: InputEvent) -> void:
	# Setup
	var player = GlobalDeviceManager.get_player_from_event(event)
	
	# Checks
	if (player == null):
		return
	
	if (player != player_id):
		return
	
	# Get Movement Action
	if (event.is_action_pressed("player_action_1") && direction != DIRECTIONS.EAST && direction != DIRECTIONS.WEST):
		# Set Params
		direction = DIRECTIONS.WEST
		
		# Adjust Player
		global_position.x += 10
		rotation_degrees = get_player_rotation()
		
		# Spawn Trail
		spawn_trail()
		
	if (event.is_action_pressed("player_action_2") && direction != DIRECTIONS.NORTH && direction != DIRECTIONS.SOUTH):
		# Set Params
		direction = DIRECTIONS.NORTH
		
		# Adjust Player
		global_position.y += 10
		rotation_degrees = get_player_rotation()
		
		# Spawn Trail
		spawn_trail()
		
	if (event.is_action_pressed("player_action_3") && direction != DIRECTIONS.WEST && direction != DIRECTIONS.EAST):
		# Set Params
		direction = DIRECTIONS.EAST
		
		# Adjust Player
		rotation_degrees = get_player_rotation()
		
		# Spawn Trail
		spawn_trail()
		
	if (event.is_action_pressed("player_action_4") && direction != DIRECTIONS.SOUTH && direction != DIRECTIONS.NORTH):
		# Set Params
		direction = DIRECTIONS.SOUTH
		
		# Adjust Player
		rotation_degrees = get_player_rotation()
		
		# Spawn Trail
		spawn_trail()

func spawn_trail():
	# Setup
	current_trail = trail.instantiate()
	current_trail.name = name + "_Trail"
	current_trail.modulate = trail_colour
	current_trail.global_position = global_position
	current_trail.player_collision.connect(_on_player_collision)
	trail_parent.add_child(current_trail)

func get_player_rotation() -> float:
	match direction:
		DIRECTIONS.WEST: return 0
		DIRECTIONS.NORTH: return 90
		DIRECTIONS.EAST: return 180
		DIRECTIONS.SOUTH: return 270
		_: return 0

func _on_player_collision(player: int):
	player_collision.emit(player)
