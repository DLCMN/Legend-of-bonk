extends Node2D

func _ready() -> void:
	var player = $Player
	var key_indicators = $UI_for_the_keyRing_indicators/Root/KeyIndicators
	key_indicators.connect_player(player)
