extends Control

## Player selected Versus mode. Should start a session with five randomly selected games. 
func _on_versus_pressed() -> void:
	# Set Game Type
	GlobalGameProperties.game_type = GlobalGameProperties.GameTypes.VERSUS
	
	# Fire Signal
	GlobalSignals.game_load.emit()

## Exit the Game
func _on_exit_pressed() -> void:
	get_tree().quit()
