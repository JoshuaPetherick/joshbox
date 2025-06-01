extends Control

@export var player_name_p1: LineEdit
@export var device_info_p1: Label
@export var device_icon_p1: TextureRect
@export var device_listen_p1: Button

@export var player_name_p2: LineEdit
@export var device_info_p2: Label
@export var device_icon_p2: TextureRect
@export var device_listen_p2: Button

func _ready() -> void:
	# Set Player Names
	player_name_p1.text = GlobalGameProperties.player_1_name
	player_name_p2.text = GlobalGameProperties.player_2_name
	
	# Update Device UI
	update_ui()
	
	# Setup Signals
	player_name_p1.text_changed.connect(_on_player_name_p1_text_changed)
	player_name_p2.text_changed.connect(_on_player_name_p2_text_changed)
	GlobalSignals.device_connected.connect(_on_device_connected)

func _exit_tree() -> void:
	GlobalSignals.device_connected.disconnect(_on_device_connected)

#region Events

func _on_device_connected(_player: int):
	update_ui()

func _on_connect_player_1_pressed() -> void:
	device_listen_p1.text = "Listening..."
	GlobalDeviceManager.listen_for_device(1)

func _on_connect_player_2_pressed() -> void:
	device_listen_p2.text = "Listening..."
	GlobalDeviceManager.listen_for_device(2)

func _on_player_name_p1_text_changed(new_text: String):
	GlobalGameProperties.player_1_name = new_text

func _on_player_name_p2_text_changed(new_text: String):
	GlobalGameProperties.player_2_name = new_text

#endregion

#region Operations

func update_ui():
	# Reset Text
	device_listen_p1.text = "Connect"
	device_listen_p2.text = "Connect"
	
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
