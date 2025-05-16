extends Node

# Game Scenes
@export var menuScene: PackedScene

# Game Nodes
@export var current: Node

# Game Properties
var _nextScene # TODO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalSignals.game_load.connect(on_game_load)
	GlobalSignals.game_started.connect(on_game_started)
	GlobalSignals.game_finished.connect(on_game_finished)

#region Events

## This gets called when players have selected a game mode to start (i.e. Versus, Selection, Tournament, etc). 
## It will handle the prepartion and loading for each of these modes. 
func on_game_load():
	# Clear existing nodes
	current.remove_child(current.get_child(0))
	
	# Add new node
	current.add_child(GlobalGameProperties.game_scene.instantiate())

## This gets called once a game has started. It'll then prepare the next scene to load (game, main menu, etc). 
## It'll also update the Overlay to state player scores or who will be playing next in a tournament mode. 
func on_game_started():
	# Pass to Resource Loader for background loading
	ResourceLoader.load_threaded_request(menuScene.resource_path)

## This gets called once a game has been completed so it can handle the winners score and load the next scene (prepared by _on_game_started). 
func on_game_finished(winner: int):
	# Set Score
	if (!GlobalGameProperties.player_scores_dict.has(winner)):
		GlobalGameProperties.player_scores_dict[winner] = 1
	else:
		GlobalGameProperties.player_scores_dict[winner] += 1
	
	# Setup
	var sceneToLoad = ResourceLoader.load_threaded_get(menuScene.resource_path)
	
	# Remove Current
	current.remove_child(current.get_child(0))
	
	# Load Main Menu
	current.add_child(sceneToLoad.instantiate())

#endregion
