extends Area3D

@onready 
var splash: AudioStreamPlayer = $Splash

var rng: RandomNumberGenerator

func _ready() -> void:
	rng = RandomNumberGenerator.new()
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if (body is Player):
		# Play SFX
		splash.pitch_scale = 1.0 + rng.randf_range(-0.1, 0.1)
		splash.play()
		
		# Respawn Player
		body.respawn()
