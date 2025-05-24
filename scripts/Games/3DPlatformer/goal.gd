extends Area3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if (body is Player):
		if (body.name == "Player_1"):
			call_deferred("_game_over", 1)
		else:
			call_deferred("_game_over", 2)

func _game_over(winner: int):
	GlobalSignals.game_finished.emit(winner)
