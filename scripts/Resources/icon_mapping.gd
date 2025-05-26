class_name IconMapping
extends Resource

enum ControllerTypes { KeyboardMouse, NintendoSwitch, Playstation, SteamDeck, Unknown, Xbox }

@export var controller_icon: Dictionary[ControllerTypes, Texture]

@export var input_action_1_icon: Dictionary[ControllerTypes, Texture]
@export var input_action_2_icon: Dictionary[ControllerTypes, Texture]
@export var input_action_3_icon: Dictionary[ControllerTypes, Texture]
@export var input_action_4_icon: Dictionary[ControllerTypes, Texture]
@export var input_action_5_icon: Dictionary[ControllerTypes, Texture]
@export var input_action_6_icon: Dictionary[ControllerTypes, Texture]
@export var input_action_7_icon: Dictionary[ControllerTypes, Texture]
@export var input_action_8_icon: Dictionary[ControllerTypes, Texture]
@export var input_action_9_icon: Dictionary[ControllerTypes, Texture]
@export var input_action_10_icon: Dictionary[ControllerTypes, Texture]
@export var input_action_11_icon: Dictionary[ControllerTypes, Texture]
@export var input_action_12_icon: Dictionary[ControllerTypes, Texture]

func get_controller_type(device_name: String):
	var device_check_name = device_name.to_upper()
	if (device_check_name.contains("MOUSE + KEYBOARD")):
		return ControllerTypes.KeyboardMouse
	elif (device_check_name.contains("NINTENDO")):
		return ControllerTypes.NintendoSwitch
	elif (device_check_name.to_upper().contains("PLAYSTATION") 
		|| device_check_name.contains("PS")):
		return ControllerTypes.Playstation
	elif (device_check_name.contains("STEAM")):
		return ControllerTypes.SteamDeck
	elif (device_check_name.contains("XBOX")):
		return ControllerTypes.Xbox
	else:
		return ControllerTypes.Unknown
