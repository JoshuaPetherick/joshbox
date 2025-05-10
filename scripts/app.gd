extends Node

@export var current: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalSignals.game_load.connect(on_game_load)
	GlobalSignals.game_started.connect(on_game_started)
	GlobalSignals.game_finished.connect(on_game_finished)

#region Events

func on_game_load():
	# Clear existing nodes
	current.remove_child(current.get_child(0))
	
	# Add new node
	current.add_child(GameProperties.game_scene.instantiate())

func on_game_started():
	pass
	
func on_game_finished(winner: int):
	pass

#endregion
