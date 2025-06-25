extends Sprite2D
class_name RhythmLane

@export var top: Area2D
@export var middle: Area2D
@export var bottom: Area2D

@export var animation_player: AnimationPlayer
@export var spawn_marker: Marker2D

var current_notes: Array[RhythmNote]
var available_points: int = 0

func _ready() -> void:
	# Setup Signals
	top.body_entered.connect(_on_top_body_entered)
	middle.body_entered.connect(_on_middle_body_entered)
	middle.body_exited.connect(_on_middle_body_exited)
	bottom.body_exited.connect(_on_bottom_body_exited)

func _on_top_body_entered(body: Node2D):
	if (body is RhythmNote):
		available_points = 50
		current_notes.append(body)

func _on_middle_body_entered(body: Node2D):
	if (body is RhythmNote):
		available_points = 100

func _on_middle_body_exited(body: Node2D):
	if (body is RhythmNote):
		available_points = 50

func _on_bottom_body_exited(body: Node2D):
	if (body is RhythmNote):
		available_points = 0
		current_notes.erase(body)

func remove_note(note: RhythmNote):
	current_notes.erase(note)
	note.queue_free()
