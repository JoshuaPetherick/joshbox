extends Button

@export var game_scene : PackedScene

func _pressed() -> void:
	# Set Game Scene
	GlobalGameProperties.game_scene = game_scene
	
	# Fire Signal
	GlobalSignals.game_load.emit()
