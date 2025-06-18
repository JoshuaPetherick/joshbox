extends Node2D
class_name RhythmPlayer

signal note_hit(points: int)
signal note_missed

@export var player_id: int = 1

@export var lane_1: RhythmLane
@export var lane_2: RhythmLane
@export var lane_3: RhythmLane

func _input(event: InputEvent) -> void:
	# Setup
	var player = GlobalDeviceManager.get_player_from_event(event)
	
	# Checks
	if (player == null):
		return
	
	if (player != player_id):
		return
	
	# Lane Checks
	_check_lane(lane_1, event)
	_check_lane(lane_2, event)
	_check_lane(lane_3, event)

func _check_lane(lane: RhythmLane, event: InputEvent) -> void:
	# Checks
	if (lane.current_note == null):
		return
	
	# Setup
	var note: RhythmNote = lane.current_note
	
	# Action Check
	if (event.is_action(note.expected_input)):
		# Note Hit!
		note_hit.emit(lane.available_points)
	#else:
		## Note Missed
		#note_missed.emit()
	
		# Destory Note
		lane.current_note = null
		note.queue_free()

func get_lane_spawn_position(lane_id: int) -> Vector2:
	match lane_id:
		1: return lane_1.spawn_marker.global_position
		2: return lane_2.spawn_marker.global_position
		3: return lane_3.spawn_marker.global_position
	return Vector2.ZERO
