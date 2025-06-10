extends Area2D
class_name Trail

signal player_collision(player: int)

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if (body is LSPlayer):		
		match body.name:
			"Player1":
				player_collision.emit(1)
			"Player2":
				player_collision.emit(2)
