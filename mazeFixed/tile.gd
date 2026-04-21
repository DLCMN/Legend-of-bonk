extends Area2D

@export var card_id := 0
@export var front_tile_texture : Texture2D
@export var back_tile_texture : Texture2D


@onready var sprite : Sprite2D = $Sprite2D
var maze_game = "res://mazeFixed/maze_game.tscn"
var is_flipped := false


func _ready():
	sprite.texture = back_tile_texture
	add_to_group("tiles")
	body_entered.connect(_on_body_entered)

func flip_tile():
	if is_flipped:
		return

	is_flipped = true
	sprite.texture = front_tile_texture
	maze_game.card_flipped(self)


func reset_tile():
	is_flipped = false
	sprite.texture = back_tile_texture


func _on_body_entered(body: Node2D) -> void:
	if body == maze_game.player:
		flip_tile()
