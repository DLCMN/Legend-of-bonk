extends Node2D


@onready var healthBar: Sprite2D = $Health
@onready var defaultBarWidth = healthBar.region_rect.size.x
@onready var defaultBarHeight = healthBar.region_rect.size.y

#enemy healthbar that responds to enemy health
#resize healthbar
func updateHealth(new_health: int) -> void:
	var newBarWidth = (new_health / 100.0) * defaultBarWidth
	healthBar.region_rect = Rect2(0, 0, newBarWidth, defaultBarHeight)
