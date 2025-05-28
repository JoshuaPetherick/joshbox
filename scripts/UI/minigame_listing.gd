extends VBoxContainer

@export
var game_mapping: GameMapping

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Clear Existing
	while get_child_count() > 0:
		remove_child(get_child(0))
	
	# Append New
	for minigame in game_mapping.minigames:
		var button = MinigameButton.new()
		button.text = minigame
		button.game_scene = game_mapping.minigames[minigame]
		add_child(button)
