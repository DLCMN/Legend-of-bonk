extends Node

#sets the player stats globally, useful later
var health: int = 40
var Maxhealth: int = 40

func reset() -> void:
	health = Maxhealth
