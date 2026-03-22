extends Node

var checking = false

var player : Node2D
var start_position : Vector2

var path_progress = 0
var correct_path = []#this is getting filled in later  
					

func _ready():
	
	correct_path = [1, 2, 3, 4, 5, 11, 
					17, 16, 15, 14, 13, 
					19, 25, 26, 27, 28, 
					29, 30, 36]

func register_player(p):
	player = p
	start_position = p.global_position

func card_flipped(tile):
	if checking:
		return
	
	checking = true

	if tile.card_id == correct_path[path_progress]:
		path_progress += 1

		if path_progress >= correct_path.size():
			checking = false
			return
	else:
		await get_tree().create_timer(0.5).timeout
		reset_player_position()
		return
	
	checking = false

func reset_player_position():
	if player:
		player.global_position = start_position
	
	path_progress = 0

	reset_tiles()

func reset_tiles():
	for tile in get_tree().get_nodes_in_group("tiles"):
		tile.is_flipped = false
		tile.sprite.texture = tile.back_tile_texture
