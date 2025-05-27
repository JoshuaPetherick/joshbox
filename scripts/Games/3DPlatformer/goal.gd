extends Area3D

@onready
var endgame_timer: Timer = $EndGameTimer

var winner: int = 0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	endgame_timer.timeout.connect(_on_endgame_timer)

func _on_body_entered(body: Node3D) -> void:
	if (winner != 0):
		return
	
	if (body is Player):
		# Get Winner
		if (body.name == "Player_1"):
			winner = 1
		else:
			winner = 2
		
		# Start Endgame Timer
		endgame_timer.start()

func _on_endgame_timer():
	GlobalSignals.game_finished.emit(winner)
