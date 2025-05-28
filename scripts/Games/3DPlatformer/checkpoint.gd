extends Area3D

@export 
var player_1_spawn: Marker3D
@export
var player_2_spawn: Marker3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if (body is Player):
		if (body.name == "Player_1"):
			body.checkpoint = player_1_spawn.global_position
		else:
			body.checkpoint = player_2_spawn.global_position
