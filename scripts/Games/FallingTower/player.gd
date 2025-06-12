extends AnimatableBody2D

@export var player_id: int = 1
@export var box_scene: PackedScene
@export var cooldown_timer: Timer

@onready var box_parent_node: Node2D = %Boxes

# Runtime Variables
var can_spawn_box: bool = false

func _ready() -> void:
	# Setup Signal
	cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)

func _input(event: InputEvent) -> void:
	# Check
	if (not can_spawn_box):
		return
	
	# Setup
	var player = GlobalDeviceManager.get_player_from_event(event)
	
	# Checks
	if (player == null):
		return
	
	if (player != player_id):
		return
	
	# Get Actions
	if (event.is_action_pressed("player_action_8")):
		_spawn_box()

func _spawn_box():
	# Spawn Box
	var box = box_scene.instantiate()
	box.global_position = global_position
	box_parent_node.add_child(box)
	
	# Disable Spawning
	can_spawn_box = false
	
	# Apply Cooldown
	cooldown_timer.start()

func _on_cooldown_timer_timeout():
	can_spawn_box = true
