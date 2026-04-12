extends TextureProgressBar

@onready var playerHeart: AnimatedSprite2D = $PlayerHeart


func _ready() -> void:
	max_value = PlayerStats.Maxhealth
	value = PlayerStats.health
	playerHeart.play("FullHealth")
	
func updateHealth(new_health: int) -> void: #updating the healthbar live
	value = new_health
	
	

func _physics_process(_float) -> void:
	if value <= 0:
		playerHeart.play("Death") #heart break when die
		
		
	else: #figuring out what heart beat to play based on health left
		if value > (max_value/4*3):
			playerHeart.play("FullHealth")
		elif value > (max_value/2):
			playerHeart.play("3QuarterHealth")
		elif value > (max_value/4):
			playerHeart.play("HalfHealth")
		elif value > 0:
			playerHeart.play("LowHealth")
