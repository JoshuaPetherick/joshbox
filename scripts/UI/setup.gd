extends Control

@export var device_info_p1: Label
@export var device_icon_p1: TextureRect
@export var device_info_p2: Label
@export var device_icon_p2: TextureRect

func _ready() -> void:
	update_ui()
	GlobalSignals.device_connected.connect(_on_device_connected)

func _exit_tree() -> void:
	GlobalSignals.device_connected.disconnect(_on_device_connected)

#region Events

func _on_device_connected(_player: int):
	update_ui()

func _on_connect_player_1_pressed() -> void:
	GlobalDeviceManager.listen_for_device(1)

func _on_connect_player_2_pressed() -> void:
	GlobalDeviceManager.listen_for_device(2)

#endregion

#region Operations

func update_ui():
	# Iterate 
	for i in range(1, 3):
		# Setup
		var device = GlobalDeviceManager.get_device_from_player(i)
		
		# Update UI
		match i:
			1:
				device_info_p1.text = GlobalDeviceManager.get_device_name(device)
				device_icon_p1.texture = GlobalDeviceManager.get_controller_icon(device)
			2:
				device_info_p2.text = GlobalDeviceManager.get_device_name(device)
				device_icon_p2.texture = GlobalDeviceManager.get_controller_icon(device)

#endregion
