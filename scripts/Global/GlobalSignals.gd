extends Node

# App Signals
signal app_loaded

# Game Signals
signal game_load
signal game_started
signal game_finished(winner: int)

# Device Signals
signal device_connected(player: int)
