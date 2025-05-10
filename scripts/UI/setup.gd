extends Control

@export var device_info_p1: Label
@export var device_icon_p1: TextureRect
@export var device_info_p2: Label
@export var device_icon_p2: TextureRect

func _ready() -> void:
	GlobalSignals.device_connected.connect(_on_device_connected)

func _exit_tree() -> void:
	GlobalSignals.device_connected.disconnect(_on_device_connected)

#region Events

func _on_device_connected(player: int):
	# Setup
	var device = GlobalDeviceManager.get_device_from_player(player)
	
	# Update UI
	match player:
		1:
			device_info_p1.text = Input.get_joy_name(device)
		2:
			device_info_p2.text = Input.get_joy_name(device)

func _on_connect_player_1_pressed() -> void:
	GlobalDeviceManager.listen_for_device(1)

func _on_connect_player_2_pressed() -> void:
	GlobalDeviceManager.listen_for_device(2)

#endregion
