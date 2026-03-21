extends Area2D

@export var card_id = 0
@export var front_tile_texture : Texture2D
@export var back_tile_texture : Texture2D
@export var is_good_tile := false  

@onready var sprite = $Sprite2D

var is_flipped = false

func _ready():
	sprite.texture = back_tile_texture
	sprite.texture = back_tile_texture
	z_index = 0
	add_to_group("tiles")

func flip_tile():
	if is_flipped:
		return 
	
	is_flipped = true 
	sprite.texture = front_tile_texture
	
	if is_good_tile:
		on_good_tile()
	else:
		on_bad_tile()

func on_good_tile():
	GameManager.card_flipped(self)

func on_bad_tile():
	GameManager.reset_player_position()


func _on_body_entered(body: Node2D) -> void:
	if body == GameManager.player and not GameManager.checking:
		flip_tile()
