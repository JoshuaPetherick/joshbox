extends RigidBody3D

@export var card_front: Sprite3D

var card_value: int

# Set the Card Texture
func setup(card: Texture, value: int):
	card_value = value
	card_front.texture = card
