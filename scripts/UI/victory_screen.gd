extends Control

const FIRST_PLACE_CROWN_COLOUR: Color = "#FFD700"
const SECOND_PLACE_CROWN_COLOUR: Color = "#C0C0C0"
const THIRD_PLACE_CROWN_COLOUR: Color = "#CD7F32"

const FIRST_PLACE_CROWN_SIZE: int = 36
const SECOND_PLACE_CROWN_SIZE: int = 32
const THIRD_PLACE_CROWN_SIZE: int = 28

const FIRST_PLACE_FONT_SIZE: int = 32
const SECOND_PLACE_FONT_SIZE: int = 28

@export var icons_list: VBoxContainer
@export var names_list: VBoxContainer
@export var scores_list: VBoxContainer

@export var first_place_icon: Texture
@export var second_place_icon: Texture
@export var third_place_icon: Texture

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Load based on Game Type
	match GlobalGameProperties.game_type:
		GlobalGameProperties.GameTypes.VERSUS:
			load_game_results()
		GlobalGameProperties.GameTypes.TOURNAMENT:
			load_game_results()

func load_game_results():
	# Clear Existing
	for i in icons_list.get_children():
		icons_list.remove_child(i)
		i.queue_free()
	
	for n in names_list.get_children():
		names_list.remove_child(n)
		n.queue_free()
	
	for s in scores_list.get_children():
		scores_list.remove_child(s)
		s.queue_free()
	
	# Get Scores
	var scores: Array = GlobalGameProperties.player_scores_dict.keys()
	
	# Sort Scores in descending order of values
	scores.sort_custom(sort_scores_descending)
	
	# Interate over and append to Lists
	for player in scores:
		# Setup
		var player_name: Label = Label.new()
		var player_score: Label = Label.new()
				
		# Append
		match names_list.get_children().size():
			0:
				# Setup
				var icon: TextureRect = TextureRect.new()
				
				# Assign Values
				icon.texture = first_place_icon
				icon.modulate = FIRST_PLACE_CROWN_COLOUR
				icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				icon.custom_minimum_size = Vector2(FIRST_PLACE_CROWN_SIZE, FIRST_PLACE_CROWN_SIZE)
				
				player_name.text = get_player_name(player)
				player_name.add_theme_font_size_override("font_size", FIRST_PLACE_FONT_SIZE)
				
				player_score.text = str(GlobalGameProperties.player_scores_dict[player])
				player_score.add_theme_font_size_override("font_size", FIRST_PLACE_FONT_SIZE)
				
				# Append Nodes
				icons_list.add_child(icon)
			1: 
				# Setup
				var icon: TextureRect = TextureRect.new()
				
				# Assign Values
				icon.texture = second_place_icon
				icon.modulate = SECOND_PLACE_CROWN_COLOUR
				icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				icon.custom_minimum_size = Vector2(SECOND_PLACE_CROWN_SIZE, SECOND_PLACE_CROWN_SIZE)
				
				player_name.text = get_player_name(player)
				player_name.add_theme_font_size_override("font_size", SECOND_PLACE_FONT_SIZE)
				
				player_score.text = str(GlobalGameProperties.player_scores_dict[player])
				player_score.add_theme_font_size_override("font_size", SECOND_PLACE_FONT_SIZE)
				
				# Append Nodes
				icons_list.add_child(icon)
			2: 
				# Setup
				var icon: TextureRect = TextureRect.new()
				
				# Assign Values
				icon.texture = third_place_icon
				icon.modulate = THIRD_PLACE_CROWN_COLOUR
				icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				icon.custom_minimum_size = Vector2(THIRD_PLACE_CROWN_SIZE, THIRD_PLACE_CROWN_SIZE)
				
				player_name.text = get_player_name(player)
				player_score.text = str(GlobalGameProperties.player_scores_dict[player])
				
				# Append Nodes
				icons_list.add_child(icon)
			_:
				# Assign Values
				player_name.text = get_player_name(player)
				player_score.text = str(GlobalGameProperties.player_scores_dict[player])
		
		# Defaults
		player_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		player_name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		
		player_score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		player_score.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		
		# Add Nodes
		names_list.add_child(player_name)
		scores_list.add_child(player_score)

func sort_scores_descending(x, y) -> bool: 
	return GlobalGameProperties.player_scores_dict[x] > GlobalGameProperties.player_scores_dict[y]

func get_player_name(index: int) -> String:
	# Get Player Name based on Game Type
	match GlobalGameProperties.game_type:
		GlobalGameProperties.GameTypes.VERSUS:
			if (index == 1):
				return GlobalGameProperties.player_1_name
			else:
				return GlobalGameProperties.player_2_name
		GlobalGameProperties.GameTypes.TOURNAMENT:
			return GlobalGameProperties.tournament_names[index]
	
	# Return empty string upon error!
	return ""
