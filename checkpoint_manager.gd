extends Node2D
var lastLocation
var playerCharacter

func _ready() -> void:
	playerCharacter = get_parent().get_node("Player")
	lastLocation = playerCharacter.global_position
