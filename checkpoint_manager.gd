extends Node2D
var lastLocation
var playerCharacter
#manages checkpoints as a whole
func _ready() -> void:
	playerCharacter = get_parent().get_node("Player")
	lastLocation = playerCharacter.global_position
