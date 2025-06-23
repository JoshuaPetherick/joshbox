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
	if (lane.current_notes.size() < 1):
		return
	
	# Setup
	var note: RhythmNote = lane.current_notes[0]
	
	# Action Check
	if (event.is_action(note.expected_input)):
		# Note Hit!
		note_hit.emit(lane.available_points)
		
		# Check
		if (lane.available_points >= 100):
			lane.animation_player.play("green_flash")
		else:
			lane.animation_player.play("blue_flash")
		
		# Destory Note
		lane.remove_note(note)

func get_lane_spawn_position(lane_id: int) -> Vector2:
	match lane_id:
		1: return lane_1.spawn_marker.global_position
		2: return lane_2.spawn_marker.global_position
		3: return lane_3.spawn_marker.global_position
	return Vector2.ZERO
