extends Node2D

func _ready() -> void:
	var player = $Player
	var key_indicators = $UI_for_the_keyRing_indicators/Root/KeyIndicators
	key_indicators.connect_player(player)
	
	$Player.player_died.connect(_on_player_died)
	
	
func _on_player_died() -> void:
	$Gameover_screen.visible = true
	get_tree().paused = true
