extends Node

# Private Variables
var _player_dict = { }
var _player_index: int
var _is_listening: bool = false

#region Events

func _ready() -> void:
	# Add default device for Player 1
	_player_dict[1] = 0
	
	# Setup Signal
	Input.joy_connection_changed.connect(on_joy_connection_changed)

func _input(event: InputEvent) -> void:
	# Checks
	if (!_is_listening):
		return;
	
	if (Input.is_action_just_pressed("player_action_1") != true
		&& Input.is_action_just_pressed("player_action_2") != true
		&& Input.is_action_just_pressed("player_action_3") != true
		&& Input.is_action_just_pressed("player_action_4") != true
		&& Input.is_action_just_pressed("player_action_5") != true
		&& Input.is_action_just_pressed("player_action_6") != true
		&& Input.is_action_just_pressed("player_action_7") != true
		&& Input.is_action_just_pressed("player_action_8") != true):
		return
	
	# Assign Device to Player
	_player_dict[_player_index] = event.device
	
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

#region Getters

## Get player id from device
func get_player_from_device(device: int):
	return _player_dict.find_key(device)

## Get the device id assigned to the player. 
func get_device_from_player(player: int):
	if (_player_dict.has(player)):
		return _player_dict[player]
	return -1 

#endregion
