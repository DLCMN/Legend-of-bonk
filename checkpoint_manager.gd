extends Node2D
@export var lastLocation : Vector2
var playerCharacter
#manages checkpoints as a whole
func _ready() -> void:
	playerCharacter = get_parent().get_node("Player")
	lastLocation = playerCharacter.global_position
	
