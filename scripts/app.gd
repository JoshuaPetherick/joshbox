extends Node

const VERSUS_GAME_COUNT: int = 5

# Game Scenes
@export var menuScene: PackedScene
@export var game_mapping: GameMapping

# Game Nodes
@export var current: Node
@export var scores_label: Label
@export var schedule_label: Label
@export var header_label: Label
@export var versus_label: Label
@export var ready_player_1_label: Label
@export var ready_player_1_icon: TextureRect
@export var ready_player_2_label: Label
@export var ready_player_2_icon: TextureRect
@export var animation_player: AnimationPlayer

# Game Properties
var _nextScene: String
var _gameScenes: Array[PackedScene]
var _rng: RandomNumberGenerator
var _player_1_ready: bool = true
var _player_2_ready: bool = true

# Tournament Properties
var _round_id: int = 1
var _round_text: String = "Round"
var _nextPairing: TournamentPairing
var _tournamentPairings: Array[TournamentPairing]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Setup Params
	_rng = RandomNumberGenerator.new()
	
	# Setup UI
	scores_label.text = ""
	schedule_label.text = ""
	header_label.text = ""
	versus_label.text = ""
	ready_player_1_label.text = ""
	ready_player_2_label.text = ""
	ready_player_1_icon.visible = false
	ready_player_2_icon.visible = false
	
	# Setup Signals
	GlobalSignals.game_load.connect(on_game_load)
	GlobalSignals.game_started.connect(on_game_started)
	GlobalSignals.game_finished.connect(on_game_finished)
	animation_player.animation_finished.connect(_on_animation_finished)
	
	# Play Fade In
	animation_player.play("fade_in")

func _input(event: InputEvent) -> void:
	# Checks
	if (_player_1_ready == true && _player_2_ready == true):
		return
	
	if (not event.is_action("player_action_8")):
		return
	
	# Setup
	var player = GlobalDeviceManager.get_player_from_event(event)
	if (player == null):
		return
	
	# Apply Ready Check
	match player:
		1:
			_player_1_ready = true
			ready_player_1_label.text = "Ready!"
		2:
			_player_2_ready = true
			ready_player_2_label.text = "Ready!"
	
	# Check
	if (_player_1_ready != true || _player_2_ready != true):
		return
	
	# Reset UI
	header_label.text = ""
	versus_label.text = ""
	ready_player_1_label.text = ""
	ready_player_2_label.text = ""
	ready_player_1_icon.visible = false
	ready_player_2_icon.visible = false
	
	# Start Game
	_load_next_scene()
	
	# Play Fade In
	animation_player.play("fade_in")

#region Events

## This gets called when players have selected a game mode to start (i.e. Versus, Selection, Tournament, etc). 
## It will handle the prepartion and loading for each of these modes. 
func on_game_load():
	# Reset Labels
	scores_label.text = ""
	schedule_label.text = ""
	
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
				var minigame_scene = _get_random_minigame()
				
				if (not _gameScenes.has(minigame_scene)):
					_gameScenes.append(minigame_scene)
			
			# Queue Next Game
			_nextScene = _gameScenes[0].resource_path
		
		GlobalGameProperties.GameTypes.TOURNAMENT:
			# Get Tournament Pairings
			_generate_tournament_pairings();
			
			# Clear + Append Scores
			GlobalGameProperties.player_scores_dict.clear()
			for i in range(0, GlobalGameProperties.tournament_names.size()):
				GlobalGameProperties.player_scores_dict[i] = 0
			
			# Get Pairings
			_nextPairing = _tournamentPairings[_rng.randi_range(0, _tournamentPairings.size() - 1)]
			_nextScene = _nextPairing.game_scene.resource_path
			
			# Remove From Listing
			_tournamentPairings.erase(_nextPairing)
		
		GlobalGameProperties.GameTypes.SINGLE:
			# Reset Params
			_gameScenes.clear()
			
			# Set Main Menu as Next Scene
			_gameScenes.append(GlobalGameProperties.game_scene)
			
			# Queue Game
			_nextScene = _gameScenes[0].resource_path
	
	# Pass to Resource Loader for background loading
	ResourceLoader.load_threaded_request(_nextScene)
	
	# Fade Out
	animation_player.play("fade_out")

## This gets called once a game has started. It'll then prepare the next scene to load (game, main menu, etc). 
## It'll also update the Overlay to state player scores or who will be playing next in a tournament mode. 
func on_game_started():
	# Pass to Resource Loader for background loading
	match GlobalGameProperties.game_type:
		GlobalGameProperties.GameTypes.VERSUS:
			ResourceLoader.load_threaded_request(_nextScene)
			
		GlobalGameProperties.GameTypes.SINGLE:
			ResourceLoader.load_threaded_request(_nextScene)
	
	# Setup Labels
	match GlobalGameProperties.game_type:
		GlobalGameProperties.GameTypes.VERSUS:
			scores_label.text = "%s vs %s\n%s : %s" % [GlobalGameProperties.player_1_name, GlobalGameProperties.player_2_name, GlobalGameProperties.player_scores_dict[1], + GlobalGameProperties.player_scores_dict[2]]
		
		GlobalGameProperties.GameTypes.TOURNAMENT:
			schedule_label.text = "Tournament %s %s\n%s vs %s" % [_round_text, _round_id, GlobalGameProperties.tournament_names[_nextPairing.player_1_id], GlobalGameProperties.tournament_names[_nextPairing.player_2_id]]

## This gets called once a game has been completed so it can handle the winners score and load the next scene (prepared by _on_game_started). 
func on_game_finished(winner: int):
	# Set Scores + Next Steps
	match GlobalGameProperties.game_type:
		GlobalGameProperties.GameTypes.TOURNAMENT:
			# Set Score
			if (winner == 1):
				GlobalGameProperties.player_scores_dict[_nextPairing.player_1_id] += 1
			else:
				GlobalGameProperties.player_scores_dict[_nextPairing.player_2_id] += 1
			
			# Clear current labels
			schedule_label.text = ""
			
			# Increment
			_round_id += 1
			
			# Check if all pairings have been played
			if (_tournamentPairings.size() == 0):
				_check_tournament_scores()
			
			# Pairings Check
			if (_tournamentPairings.size() > 0):
				# Get Next Pairing
				_nextPairing = _tournamentPairings[_rng.randi_range(0, _tournamentPairings.size() - 1)]
				_nextScene = _nextPairing.game_scene.resource_path
				
				# Clear from Listing
				_tournamentPairings.erase(_nextPairing)
			else:
				# Load Menu Scene
				_nextPairing = null
				_nextScene = menuScene.resource_path
			
			# Pass to Resource Loader for background loading
			ResourceLoader.load_threaded_request(_nextScene)
		
		_:
			# Set Score
			if (!GlobalGameProperties.player_scores_dict.has(winner)):
				GlobalGameProperties.player_scores_dict[winner] = 1
			else:
				GlobalGameProperties.player_scores_dict[winner] += 1
	
	# Fade Out
	animation_player.play("fade_out")

## This checks if the fade_out has finished so it can prepare the next scene!
func _on_animation_finished(anim_name: String):
	match anim_name:
		"fade_out":
			# Prepare Next Scene
			match GlobalGameProperties.game_type:
				GlobalGameProperties.GameTypes.TOURNAMENT:
					if (_nextPairing != null):
						# Set Params
						_player_1_ready = false
						_player_2_ready = false
						
						GlobalGameProperties.tournament_player_1_name = GlobalGameProperties.tournament_names[_nextPairing.player_1_id]
						GlobalGameProperties.tournament_player_2_name = GlobalGameProperties.tournament_names[_nextPairing.player_2_id]
						
						# Update UI
						header_label.text = "Tournament %s %s" % [_round_text, _round_id]
						versus_label.text = "%s vs %s" % [GlobalGameProperties.tournament_names[_nextPairing.player_1_id], GlobalGameProperties.tournament_names[_nextPairing.player_2_id]]
						ready_player_1_label.text = "Not Ready"
						ready_player_1_icon.visible = true
						ready_player_2_label.text = "Not Ready"
						ready_player_2_icon.visible = true
						
						# Remove Previous Scene
						current.remove_child(current.get_child(0))
					else:
						# Load Scene
						_load_next_scene()
						
						# Play Fade In
						animation_player.play("fade_in")
				
				_:
					# Setup
					var sceneToLoad = ResourceLoader.load_threaded_get(_nextScene)
					
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
					
					# Remove Current
					if (current.get_child_count() > 0):
						current.remove_child(current.get_child(0))

					# Load Next Scene
					current.add_child(sceneToLoad.instantiate())
					
					# Play Fade In
					animation_player.play("fade_in")

#endregion

#region Operations

func _generate_tournament_pairings():
	# Reset Params
	_round_id = 1
	_round_text = "Round"
	_tournamentPairings.clear()
	
	# Generate Pairings based on player count
	match GlobalGameProperties.tournament_names.size():
		3:
			_tournamentPairings.append(TournamentPairing.new(0, 1, _get_random_minigame()))
			_tournamentPairings.append(TournamentPairing.new(0, 2, _get_random_minigame()))
			_tournamentPairings.append(TournamentPairing.new(1, 2, _get_random_minigame()))
		4:
			_tournamentPairings.append(TournamentPairing.new(0, 1, _get_random_minigame()))
			_tournamentPairings.append(TournamentPairing.new(0, 2, _get_random_minigame()))
			_tournamentPairings.append(TournamentPairing.new(0, 3, _get_random_minigame()))
			_tournamentPairings.append(TournamentPairing.new(1, 2, _get_random_minigame()))
			_tournamentPairings.append(TournamentPairing.new(1, 3, _get_random_minigame()))
			_tournamentPairings.append(TournamentPairing.new(2, 3, _get_random_minigame()))
		_:
			# Setup
			var players = range(0, GlobalGameProperties.tournament_names.size())
			var game_count = int(players.size() / 2)
			
			# Get Players
			while players.size() > 0:
				# Check
				var player_id = players[0]
				var player_game_count = _get_game_count(player_id)
				
				# Append Games
				while (player_game_count < game_count):
					# Get Random Player
					var random_player_id = players[_rng.randi_range(0, players.size() - 1)]
					
					# Checks
					while (_check_validity(player_id, random_player_id, game_count)):
						random_player_id = players[_rng.randi_range(0, players.size() - 1)]
					
					# Append
					_tournamentPairings.append(TournamentPairing.new(player_id, random_player_id, _get_random_minigame()))
					
					# Increment
					player_game_count += 1
				
				# Remove Players
				for player in players:
					if (_get_game_count(player) >= game_count):
						players.erase(player)

func _get_random_minigame() -> PackedScene:
	var minigame_index = _rng.randi_range(0, game_mapping.minigames.size() - 1)
	return game_mapping.minigames.values()[minigame_index]

func _get_game_count(player_id: int) -> int:
	# Setup
	var result = 0
	
	# Iterate over pairings
	for pairing in _tournamentPairings:
		if (pairing.player_1_id == player_id ||
			pairing.player_2_id == player_id):
			result += 1
	
	# Result
	return result

func _get_highest_score() -> int:
	# Setup
	var result: int = 0
	
	# Iterate
	for player in GlobalGameProperties.player_scores_dict:
		if (GlobalGameProperties.player_scores_dict[player] > result):
			result = GlobalGameProperties.player_scores_dict[player]
	
	# Result
	return result

func _get_high_score_player_count(score: int) -> Array:
	# Setup
	var result: Array
	
	# Iterate
	for player in GlobalGameProperties.player_scores_dict:
		if (GlobalGameProperties.player_scores_dict[player] == score):
			result.append(player)
	
	# Result
	return result

func _check_validity(player_id: int, target_id: int, game_count: int) -> bool:
	# Checks
	if (player_id == target_id):
		return true
	
	if (_check_if_already_paired(player_id, target_id)):
		return true
	
	if (_get_game_count(target_id) >= game_count):
		return true
		
	return false

func _check_if_already_paired(player_1_id: int, player_2_id: int) -> bool:
	# Setup
	var result = false
	
	# Iterate
	for pairing in _tournamentPairings:
		if (pairing.player_1_id == player_1_id &&
			pairing.player_2_id == player_2_id):
			return true
			
	# Return
	return result

func _check_tournament_scores():
	# Setup
	var high_score: int = _get_highest_score()
	var players: Array = _get_high_score_player_count(high_score)
	
	# Competition Check
	if (players.size() > 1):
		# Setup
		var game_count = int(players.size() / 2)
		
		# Get Players
		for player_id in players:
			# Check
			var player_game_count = _get_game_count(player_id)
			
			# Append Games
			while (player_game_count < game_count):
				# Get Random Player
				var random_player_id = players[_rng.randi_range(0, players.size() - 1)]
				
				# Checks
				while (_check_validity(player_id, random_player_id, game_count)):
					random_player_id = players[_rng.randi_range(0, players.size() - 1)]
				
				# Append
				_tournamentPairings.append(TournamentPairing.new(player_id, random_player_id, _get_random_minigame()))
				
				# Increment
				player_game_count += 1
		
		# Calculate text based on pairings
		match _tournamentPairings.size():
			1:
				_round_text = "Finals"
			2:
				_round_text = "Semi-Finals"
			4:
				_round_text = "Quarter-Finals"
			_:
				_round_text = "Round"

func _load_next_scene():
	# Setup
	var sceneToLoad = ResourceLoader.load_threaded_get(_nextScene)
	
	# Remove Current
	if (current.get_child_count() > 0):
		current.remove_child(current.get_child(0))

	# Load Next Scene
	current.add_child(sceneToLoad.instantiate())

#endregion
