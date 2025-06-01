extends Node

const VERSUS_GAME_COUNT: int = 5

# Game Scenes
@export var menuScene: PackedScene
@export var game_mapping: GameMapping

# Game Nodes
@export var current: Node
@export var scores_label: Label
@export var schedule_label: Label

# Game Properties
var _nextScene: String
var _gameScenes: Array[PackedScene]
var rng: RandomNumberGenerator

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Setup Params
	rng = RandomNumberGenerator.new()
	
	# Setup Labels
	scores_label.text = ""
	schedule_label.text = ""
	
	# Setup Signals
	GlobalSignals.game_load.connect(on_game_load)
	GlobalSignals.game_started.connect(on_game_started)
	GlobalSignals.game_finished.connect(on_game_finished)

#region Events

## This gets called when players have selected a game mode to start (i.e. Versus, Selection, Tournament, etc). 
## It will handle the prepartion and loading for each of these modes. 
func on_game_load():
	# Clear existing nodes
	current.remove_child(current.get_child(0))
	
	# Generate based on Game Type
	match GlobalGameProperties.game_type:
		GlobalGameProperties.GameTypes.VERSUS:
			# Reset Params
			_gameScenes.clear()
			GlobalGameProperties.player_scores_dict = {1: 0, 2: 0}
			
			# Generate Versus Game Listing
			var max_game_count = VERSUS_GAME_COUNT
			if (game_mapping.minigames.size() < VERSUS_GAME_COUNT):
				max_game_count = game_mapping.minigames.size()

			while _gameScenes.size() < max_game_count:
				# Setup
				var minigame_index = rng.randi_range(0, game_mapping.minigames.size() - 1)
				var minigame_scene = game_mapping.minigames.values()[minigame_index]
				
				if (not _gameScenes.has(minigame_scene)):
					_gameScenes.append(minigame_scene)
			
			# Queue Next Game
			_nextScene = _gameScenes[1].resource_path
			
			# Load First Game
			current.add_child(_gameScenes[0].instantiate())
			
			# Remove First Record
			_gameScenes.remove_at(0)
		
		GlobalGameProperties.GameTypes.TOURNAMENT:
			pass # Future TODO
		
		GlobalGameProperties.GameTypes.SINGLE:
			# Set Main Menu as Next Scene
			_nextScene = menuScene.resource_path
			
			# Load Game
			current.add_child(GlobalGameProperties.game_scene.instantiate())

## This gets called once a game has started. It'll then prepare the next scene to load (game, main menu, etc). 
## It'll also update the Overlay to state player scores or who will be playing next in a tournament mode. 
func on_game_started():
	# Pass to Resource Loader for background loading
	ResourceLoader.load_threaded_request(_nextScene)
	
	# Setup Labels
	match GlobalGameProperties.game_type:
		GlobalGameProperties.GameTypes.VERSUS:
			scores_label.text = "%s vs %s\n%s : %s" % [GlobalGameProperties.player_1_name, GlobalGameProperties.player_2_name, GlobalGameProperties.player_scores_dict[1], + GlobalGameProperties.player_scores_dict[2]]
		
		GlobalGameProperties.GameTypes.TOURNAMENT:
			pass # Future TODO

## This gets called once a game has been completed so it can handle the winners score and load the next scene (prepared by _on_game_started). 
func on_game_finished(winner: int):
	# Set Score
	if (!GlobalGameProperties.player_scores_dict.has(winner)):
		GlobalGameProperties.player_scores_dict[winner] = 1
	else:
		GlobalGameProperties.player_scores_dict[winner] += 1
	
	# Setup
	var sceneToLoad = ResourceLoader.load_threaded_get(_nextScene)
	
	# Remove Current
	current.remove_child(current.get_child(0))
	
	# Prepare Next Scene
	match GlobalGameProperties.game_type:
		GlobalGameProperties.GameTypes.VERSUS:
			# Main Menu check
			if (_gameScenes.size() == 0):
				scores_label.text = ""
			else:
				# Next Game Check
				if (_gameScenes.size() > 1):
					_nextScene = _gameScenes[1].resource_path
				else:
					_nextScene = menuScene.resource_path
			
				# Remove First Record
				_gameScenes.remove_at(0)
	
	# Load Next Scene
	current.add_child(sceneToLoad.instantiate())

#endregion
