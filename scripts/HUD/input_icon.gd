extends TextureRect

@export
var player: int = 1
@export
var input: String

func _ready() -> void:
	var device = GlobalDeviceManager.get_device_from_player(player)
	texture = GlobalDeviceManager.get_action_icon(device, input)
