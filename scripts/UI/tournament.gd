extends Control

const MINIMUM_PLAYER_COUNT: int = 3

@export var player_listing: VBoxContainer
@export var start_button: Button
@export var add_player_button: Button
@export var remove_player_button: Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Setup Signals
	start_button.pressed.connect(_on_start_button_pressed)
	add_player_button.pressed.connect(_on_add_player_button_pressed)
	remove_player_button.pressed.connect(_on_remove_player_button_pressed)

#region Events

func _on_start_button_pressed() -> void:
	# Set Game Properties
	GlobalGameProperties.tournament_names = get_tournament_player_names()
	GlobalGameProperties.game_type = GlobalGameProperties.GameTypes.TOURNAMENT
	
	# Fire Signal
	GlobalSignals.game_load.emit()

func _on_add_player_button_pressed() -> void:
	# Add New Line Edit
	var player_line_edit: LineEdit = LineEdit.new()
	
	# Customise
	player_line_edit.text = "Player %s" % str(player_listing.get_child_count() + 1)
	player_line_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Append
	player_listing.add_child(player_line_edit)
	
	# Removal Check
	if (player_listing.get_child_count() > MINIMUM_PLAYER_COUNT):
		remove_player_button.disabled = false
	else:
		remove_player_button.disabled = true

func _on_remove_player_button_pressed() -> void:
	# Remove Player
	var player_line_edit = player_listing.get_child(player_listing.get_child_count() - 1)
	player_listing.remove_child(player_line_edit)
	player_line_edit.queue_free()
	
	# Removal Check
	if (player_listing.get_child_count() > MINIMUM_PLAYER_COUNT):
		remove_player_button.disabled = false
	else:
		remove_player_button.disabled = true

#endregion

#region Functions

func get_tournament_player_names() -> Array:
	# Setup
	var results: Array
	
	# Iterate
	for n: LineEdit in player_listing.get_children():
		results.append(n.text)
	
	return results

#endregion
