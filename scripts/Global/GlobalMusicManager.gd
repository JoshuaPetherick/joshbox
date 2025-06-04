extends Node

const AUDIO_MIN_VOLUME: float = 0.0001
const AUDIO_MAX_VOLUME: float = 1.0
const AUDIO_TRANSITION_UP_SPEED_DB: float = 0.2
const AUDIO_TRANSITION_DOWN_SPEED_DB: float = 0.5

# Audio Properties
var music_1_focus: bool = true
var transitioning: bool = false

var audio_1_volume: float = 1.0
var audio_2_volume: float = 0.0

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
	
	# Default Volume
	audio_1_volume = AUDIO_MAX_VOLUME
	audio_2_volume = AUDIO_MIN_VOLUME
	
	_audio_stream_player_1.volume_db = linear_to_db(audio_1_volume)
	_audio_stream_player_2.volume_db = linear_to_db(audio_2_volume)
	
	# Add as Children
	add_child(_audio_stream_player_1)
	add_child(_audio_stream_player_2)

func _process(delta: float) -> void:
	# Transition Check
	if (transitioning):
		# Check + Set Volume
		if (music_1_focus):
			if (audio_1_volume >= AUDIO_MAX_VOLUME && audio_2_volume <= AUDIO_MIN_VOLUME):
				# Reset Params
				transitioning = false
				_audio_stream_player_2.stop()
				_audio_stream_player_2.stream = null
			else:
				# Transition Music
				audio_1_volume += AUDIO_TRANSITION_UP_SPEED_DB * delta
				audio_2_volume -= AUDIO_TRANSITION_DOWN_SPEED_DB * delta
		else:
			if (audio_1_volume <= AUDIO_MIN_VOLUME && audio_2_volume >= AUDIO_MAX_VOLUME):
				# Reset Params
				transitioning = false
				_audio_stream_player_1.stop()
				_audio_stream_player_1.stream = null
			else:
				# Transition Music
				audio_1_volume -= AUDIO_TRANSITION_DOWN_SPEED_DB * delta
				audio_2_volume += AUDIO_TRANSITION_UP_SPEED_DB * delta
		
		# Clamp Values
		audio_1_volume = clamp(audio_1_volume, AUDIO_MIN_VOLUME, AUDIO_MAX_VOLUME)
		audio_2_volume = clamp(audio_2_volume, AUDIO_MIN_VOLUME, AUDIO_MAX_VOLUME)
		
		# Set Volume
		_audio_stream_player_1.volume_db = linear_to_db(audio_1_volume)
		_audio_stream_player_2.volume_db = linear_to_db(audio_2_volume)
	
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
		music_1_focus = true
		_audio_stream_player_1.stream = stream
		_audio_stream_player_1.play()
	
	elif (_audio_stream_player_1.stream == null):
		transitioning = true
		music_1_focus = true
		_audio_stream_player_1.stream = stream
		_audio_stream_player_1.play()
	
	else:
		transitioning = true
		music_1_focus = false
		_audio_stream_player_2.stream = stream
		_audio_stream_player_2.play()
