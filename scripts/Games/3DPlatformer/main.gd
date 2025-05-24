extends Node3D

func _ready() -> void:
	# Game Started
	GlobalSignals.game_started.emit()
