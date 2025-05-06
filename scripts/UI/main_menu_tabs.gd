extends TabContainer

func _ready() -> void:
	current_tab = 0

func _on_game_selection_pressed() -> void:
	current_tab = 1

func _on_back_pressed() -> void:
	current_tab = 0
