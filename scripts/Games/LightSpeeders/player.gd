extends CharacterBody2D
class_name Player

const SPEED = 100.0

enum DIRECTIONS { NORTH, SOUTH, EAST, WEST }

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
var trail_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	spawn_trail()

func _physics_process(delta: float) -> void:
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
	
	# Update Trail THIS IS BROKEN PLS FIX!
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
	var newTrail: bool = false
	var player = GlobalDeviceManager.get_player_from_event(event)
	
	# Checks
	if (player == null):
		return
	
	if (player != player_id):
		return
	
	# Get Movement Action
	if (event.is_action_pressed("player_action_1") && direction != DIRECTIONS.EAST && direction != DIRECTIONS.WEST):
		trail_offset = calculate_offset(direction, DIRECTIONS.WEST)
		direction = DIRECTIONS.WEST
		rotation_degrees = 0
		newTrail = true
		
	if (event.is_action_pressed("player_action_2") && direction != DIRECTIONS.NORTH && direction != DIRECTIONS.SOUTH):
		trail_offset = calculate_offset(direction, DIRECTIONS.NORTH)
		direction = DIRECTIONS.NORTH
		rotation_degrees = 270
		newTrail = true
		
	if (event.is_action_pressed("player_action_3") && direction != DIRECTIONS.WEST && direction != DIRECTIONS.EAST):
		trail_offset = calculate_offset(direction, DIRECTIONS.EAST)
		direction = DIRECTIONS.EAST
		rotation_degrees = 180
		newTrail = true
		
	if (event.is_action_pressed("player_action_4") && direction != DIRECTIONS.SOUTH && direction != DIRECTIONS.NORTH):
		trail_offset = calculate_offset(direction, DIRECTIONS.SOUTH)
		direction = DIRECTIONS.SOUTH
		rotation_degrees = 90
		newTrail = true
	
	# New Trail Check
	if (newTrail):
		# Enable Current Trail
		# TODO
		
		# Spawn New Trail
		spawn_trail()

func spawn_trail():
	# Setup
	current_trail = trail.instantiate()
	current_trail.name = name + "_Trail"
	current_trail.modulate = trail_colour
	current_trail.global_position = (global_position + trail_offset)
	trail_parent.add_child(current_trail)

# TODO: AT SOME POINT
func calculate_offset(old_direction: DIRECTIONS, new_direction: DIRECTIONS):
	match new_direction:
		DIRECTIONS.NORTH:
			if (old_direction == DIRECTIONS.WEST):
				return Vector2(0, 10)
			else:
				return Vector2(0, 0)
		DIRECTIONS.EAST:
			if (old_direction == DIRECTIONS.SOUTH):
				return Vector2(10, 0)
			else:
				return Vector2(0, 0)
			
	
	return Vector2.ZERO
