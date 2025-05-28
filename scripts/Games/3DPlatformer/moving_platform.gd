extends Node3D

@export
var speed: float = 0.5
@export
var max_distance: float = 10.0

var _move_left = true
var starting_position : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	starting_position = global_position.x

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if (_move_left):
		# Move Left
		global_position.x += (speed * delta)
		
		# Check
		if (global_position.x >= max_distance):
			_move_left = false
	else:
		# Move Right
		global_position.x -= (speed * delta)
		
		# Check
		if (global_position.x <= -max_distance):
			_move_left = true
