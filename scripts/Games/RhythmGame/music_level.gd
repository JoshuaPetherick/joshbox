extends Resource
class_name MusicLevel

@export var game_music: AudioStreamWAV

@export_group("Lane 1")
@export var action_1: String
@export var timestamps_1: Array[float]

@export_group("Lane 2")
@export var action_2: String
@export var timestamps_2: Array[float]

@export_group("Lane 3")
@export var action_3: String
@export var timestamps_3: Array[float]
