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
