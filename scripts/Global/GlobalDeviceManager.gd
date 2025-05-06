extends Node

# Private Variables
var _player_dict = { }
var _player_index: int
var _is_listening: bool = false

#region Events

func _input(event: InputEvent) -> void:
	# Checks
	if (!_is_listening):
		return;
		
	# Assign Device to Player
	_player_dict[_player_index] = event.device
	
	# Stop Listening
	_player_index = 0
	_is_listening = false

#endregion

#region Operations

## Start listening for a device to assign to the provided player. 
func listen_for_device(player: int):
	_player_index = player
	_is_listening = true
	
#endregion

#region Getters

## Get the device id assigned to the player. 
func get_device_for_player(player: int):
	if (_player_dict.has(player)):
		return _player_dict[player]
	return -1 

#endregion
