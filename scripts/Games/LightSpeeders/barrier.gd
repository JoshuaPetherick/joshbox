extends Area2D

@export var redirect: LSPlayer.DIRECTIONS

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if (body is LSPlayer):		
		match body.name:
			"Player1":
				body.call_deferred("change_direction", redirect)
			"Player2":
				body.call_deferred("change_direction", redirect)
