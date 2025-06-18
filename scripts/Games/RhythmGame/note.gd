extends AnimatableBody2D
class_name RhythmNote

const SPEED: float = 200
const CUT_OFF_POSITION: float = 600

@onready var icon: Sprite2D = %Icon

var expected_input: String

func setup(player: int, input: String) -> void:
	# Setup
	var device = GlobalDeviceManager.get_device_from_player(player)
	icon.texture = GlobalDeviceManager.get_action_icon(device, input)
	
	# Assign Params
	expected_input = input

func _physics_process(delta: float) -> void:
	# Check
	if (global_position.y >= CUT_OFF_POSITION):
		queue_free()
		return
	
	# Move Down
	var movement: Vector2 = Vector2(0, SPEED * delta)
	global_position += movement
