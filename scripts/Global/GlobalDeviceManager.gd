extends Node

# Private Variables
var _player_dict = { }
var _player_index: int
var _is_listening: bool = false

@onready var icon_mapping: IconMapping = load("res://resources/icon_mapping.tres")

#region Events

func _ready() -> void:
	# Setup default devices
	if (Input.get_connected_joypads().size() > 1):
		_player_dict[1] = 0 
		_player_dict[2] = 1 
	elif (Input.get_connected_joypads().size() == 1):
		_player_dict[1] = -2 
		_player_dict[2] = 0 
	else:
		_player_dict[1] = -2 
	
	# Setup Signal
	Input.joy_connection_changed.connect(on_joy_connection_changed)

func _input(event: InputEvent) -> void:
	# Checks
	if (!_is_listening):
		return;
	
	if (Input.get_connected_joypads().is_empty()):
		return
	
	if (Input.is_action_just_pressed("player_action_1") != true
		&& Input.is_action_just_pressed("player_action_2") != true
		&& Input.is_action_just_pressed("player_action_3") != true
		&& Input.is_action_just_pressed("player_action_4") != true
		&& Input.is_action_just_pressed("player_action_5") != true
		&& Input.is_action_just_pressed("player_action_6") != true
		&& Input.is_action_just_pressed("player_action_7") != true
		&& Input.is_action_just_pressed("player_action_8") != true
		&& Input.is_action_just_pressed("player_action_9") != true
		&& Input.is_action_just_pressed("player_action_10") != true
		&& Input.is_action_just_pressed("player_action_11") != true
		&& Input.is_action_just_pressed("player_action_12") != true):
		return
	
	# Get Device based on Event
	var deviceId = get_actual_device_id(event)
	
	# Unassign device if already assigned
	if (get_player_from_device(deviceId) != null):
		_player_dict[get_player_from_device(deviceId)] = -1
	
	# Assign Device to Player
	_player_dict[_player_index] = deviceId
	
	# Emit Signal
	GlobalSignals.device_connected.emit(_player_index)
	
	# Stop Listening
	_player_index = 0
	_is_listening = false

func on_joy_connection_changed(device: int, connected: bool):
	# Check
	if (connected == true):
		if (_player_dict.has(1) != true):
			_player_dict[1] = device
		elif (_player_dict.has(2) != true):
			_player_dict[2] = device
	else:
		if (_player_dict.values().has(device)):
			_player_dict.erase(get_player_from_device(device))

#endregion

#region Operations

## Start listening for a device to assign to the provided player. 
func listen_for_device(player: int):
	_player_index = player
	_is_listening = true
	
#endregion

#region Functions

## Get player id from device
func get_player_from_device(device: int):
	return _player_dict.find_key(device)

func get_player_from_event(event: InputEvent):
	return _player_dict.find_key(get_actual_device_id(event))

## Get the device id assigned to the player. 
func get_device_from_player(player: int):
	if (_player_dict.has(player)):
		return _player_dict[player]
	return -1 

func get_actual_device_id(event: InputEvent):
	# Check if was Mouse + Keyboard
	if (event is InputEventKey ||
		event is InputEventMouseButton ||
		event is InputEventMouseMotion):
		return -2
	return event.device

func get_device_name(device: int):
	if (device == -1):
		return "Missing"
	elif (device == -2):
		return "Mouse + Keyboard"
	return "%s %s" % [Input.get_joy_name(device), (device + 1)]

func get_controller_icon(device: int):
	# Setup
	var device_name = get_device_name(device)
	var controller_type = icon_mapping.get_controller_type(device_name)
	
	# Check
	if (device_name == "Missing"):
		return null
	
	# Result
	return icon_mapping.controller_icon[controller_type]

func get_action_icon(device: int, action: String):
	# Setup
	var device_name = get_device_name(device)
	var controller_type = icon_mapping.get_controller_type(device_name)
	
	# Result
	match action:
		"player_action_1":
			return icon_mapping.input_action_1_icon[controller_type]
		"player_action_2":
			return icon_mapping.input_action_2_icon[controller_type]
		"player_action_3":
			return icon_mapping.input_action_3_icon[controller_type]
		"player_action_4":
			return icon_mapping.input_action_4_icon[controller_type]
		"player_action_5":
			return icon_mapping.input_action_5_icon[controller_type]
		"player_action_6":
			return icon_mapping.input_action_6_icon[controller_type]
		"player_action_7":
			return icon_mapping.input_action_7_icon[controller_type]
		"player_action_8":
			return icon_mapping.input_action_8_icon[controller_type]
		"player_action_9":
			return icon_mapping.input_action_9_icon[controller_type]
		"player_action_10":
			return icon_mapping.input_action_10_icon[controller_type]
		"player_action_11":
			return icon_mapping.input_action_11_icon[controller_type]
		"player_action_12":
			return icon_mapping.input_action_12_icon[controller_type]

#endregion
