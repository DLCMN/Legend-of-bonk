extends TextureProgressBar

func _ready() -> void:
	max_value = PlayerStats.Maxhealth
	value = PlayerStats.health
	
func updateHealth(new_health: int) -> void:
	value = new_health
