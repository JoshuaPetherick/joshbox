extends Control

@export var background_music: AudioStreamWAV
@export var background_node: TextureRect
@export var background_images: Array[Texture]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Setup
	var rng = RandomNumberGenerator.new()
	var img = rng.randi_range(0, background_images.size() - 1)
	background_node.texture = background_images[img]
	
	# Play Music
	GlobalMusicManager.play_song(background_music)
