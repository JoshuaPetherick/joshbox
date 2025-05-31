extends Control

# UI Components
@export var master_volume: HSlider
@export var music_volume: HSlider
@export var sfx_volume: HSlider

# Bus Values
@onready var master_bus: int = AudioServer.get_bus_index("Master")
@onready var music_bus: int = AudioServer.get_bus_index("Music")
@onready var sfx_bus: int = AudioServer.get_bus_index("SFX")

func _ready() -> void:
	# Set Values
	master_volume.value = db_to_linear(AudioServer.get_bus_volume_db(master_bus)) * 100
	music_volume.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus)) * 100
	sfx_volume.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus)) * 100
	
	# Setup Signals
	master_volume.value_changed.connect(_on_master_volume_value_changed)
	music_volume.value_changed.connect(_on_music_volume_value_changed)
	sfx_volume.value_changed.connect(_on_sfx_volume_value_changed)

func _on_master_volume_value_changed(value: float):
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(value / 100))

func _on_music_volume_value_changed(value: float):
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(value / 100))

func _on_sfx_volume_value_changed(value: float):
	AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(value / 100))
