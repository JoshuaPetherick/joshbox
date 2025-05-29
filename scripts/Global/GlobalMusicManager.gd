extends Node

const AUDIO_TRANSITION_SPEED_DB: float = 80

# Audio Properties
var audio_1_focus: bool = true
var transitioning: bool = false

# Audio Components
var _audio_stream_player_1: AudioStreamPlayer
var _audio_stream_player_2: AudioStreamPlayer

func _ready() -> void:
	# Setup two AudioStreams
	_audio_stream_player_1 = AudioStreamPlayer.new()
	_audio_stream_player_2 = AudioStreamPlayer.new()
	
	# Setup 
	_audio_stream_player_1.bus = "Music_1"
	_audio_stream_player_2.bus = "Music_2"
	
	# Default
	_audio_stream_player_1.volume_db = 0.0
	_audio_stream_player_2.volume_db = -80.0
	
	# Add as Children
	add_child(_audio_stream_player_1)
	add_child(_audio_stream_player_2)

func _process(delta: float) -> void:
	# Transition Check
	if (transitioning):
		if (audio_1_focus):
			if (_audio_stream_player_1.volume_db >= 0.0 &&
				_audio_stream_player_2.volume_db <= -79.9):
				# Set Volume
				_audio_stream_player_1.volume_db = 0.0
				_audio_stream_player_2.volume_db = -80.0
				
				# Reset Params
				transitioning = false
				_audio_stream_player_2.stop()
				_audio_stream_player_2.stream = null
			else:
				# Transition Music
				_audio_stream_player_1.volume_db += AUDIO_TRANSITION_SPEED_DB * delta
				_audio_stream_player_2.volume_db -= AUDIO_TRANSITION_SPEED_DB * delta
		else:
			if (_audio_stream_player_2.volume_db >= 0.0 &&
				_audio_stream_player_1.volume_db <= -79.9):
				# Set Volume
				_audio_stream_player_2.volume_db = 0.0
				_audio_stream_player_1.volume_db = -80.0
				
				# Reset Params
				transitioning = false
				_audio_stream_player_1.stop()
				_audio_stream_player_1.stream = null
			else:
				# Transition Music
				_audio_stream_player_2.volume_db += AUDIO_TRANSITION_SPEED_DB * delta
				_audio_stream_player_1.volume_db -= AUDIO_TRANSITION_SPEED_DB * delta
		
		print(_audio_stream_player_1.volume_db)
		print(_audio_stream_player_2.volume_db)
		print('------')
		
		return
	
	# Loop Check
	if (_audio_stream_player_1.stream != null && 
		not _audio_stream_player_1.playing):
		_audio_stream_player_1.play()
	
	if (_audio_stream_player_2.stream != null && 
		not _audio_stream_player_2.playing):
		_audio_stream_player_2.play()	

func play_song(stream: AudioStreamWAV):
	# Check if playing
	if (_audio_stream_player_1.stream == null && 
		_audio_stream_player_2.stream == null):
		audio_1_focus = true
		_audio_stream_player_1.stream = stream
		_audio_stream_player_1.play()
		
	elif (_audio_stream_player_1.stream == null):
		transitioning = true
		audio_1_focus = true
		_audio_stream_player_1.stream = stream
		_audio_stream_player_1.play()
		
	else:
		transitioning = true
		audio_1_focus = false
		_audio_stream_player_2.stream = stream
		_audio_stream_player_2.play()
