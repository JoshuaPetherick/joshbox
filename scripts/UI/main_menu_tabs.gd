extends TabContainer

@export var tab_1_default_focus: Button
@export var tab_2_default_focus: Button
@export var tab_3_default_focus: Button
@export var tab_4_default_focus: Button
@export var tab_5_default_focus: Button
@export var tab_6_default_focus: Button

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
	
	# Apply Button Focus
	_on_tab_change(current_tab)
	
	# Setup Signal
	tab_changed.connect(_on_tab_change)

func _on_game_selection_pressed() -> void:
	current_tab = 1

func _on_tournament_pressed() -> void:
	current_tab = 2

func _on_setup_pressed() -> void:
	current_tab = 3

func _on_settings_pressed() -> void:
	current_tab = 4

func _on_back_pressed() -> void:
	current_tab = 0

func _on_tab_change(tab: int) -> void:
	match tab:
		0: tab_1_default_focus.grab_focus()
		1: tab_2_default_focus.grab_focus()
		2: tab_3_default_focus.grab_focus()
		3: tab_4_default_focus.grab_focus()
		4: tab_5_default_focus.grab_focus()
		5: tab_6_default_focus.grab_focus()
