extends Node
var player_is_attacking = false 

func playerAttack():
	if Input.is_action_just_pressed("Attack") and not player_is_attacking:
		player_is_attacking = true
