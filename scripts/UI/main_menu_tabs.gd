extends TabContainer

func _ready() -> void:
	# Select based on Game Type
	match GlobalGameProperties.game_type:
		GlobalGameProperties.GameTypes.VERSUS:
			current_tab = 5
		GlobalGameProperties.GameTypes.TOURNAMENT:
			current_tab = 5
		GlobalGameProperties.GameTypes.SINGLE:
			current_tab = 1
		_:
			current_tab = 0

func _on_game_selection_pressed() -> void:
	current_tab = 1

func _on_setup_pressed() -> void:
	current_tab = 3

func _on_settings_pressed() -> void:
	current_tab = 4

func _on_back_pressed() -> void:
	current_tab = 0
