extends Node

var checking := false

var player : Node2D
var start_position : Vector2

var path_progress := 0
var correct_path := []


func _ready():
	correct_path = [
		1,1,1,1,1,1,
		1,1,1,1,1,
		1,1,1,1,1,
		1,1,1
	]


func _physics_process(delta):
	if player == null:
		return

	var tiles = get_tree().get_nodes_in_group("tiles")
	var touching_tile := false

	for tile in tiles:
		if tile.get_overlapping_bodies().has(player):
			touching_tile = true
			break

	if not touching_tile and path_progress > 0:
		reset_player_position()


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
			print("Maze complete")
			checking = false
			return
	else:
		await get_tree().create_timer(0.3).timeout
		reset_player_position()
		checking = false
		return

	checking = false


func reset_player_position():
	path_progress = 0
	reset_tiles()

	if player:
		player.global_position = start_position


func reset_tiles():
	for tile in get_tree().get_nodes_in_group("tiles"):
		tile.reset_tile()
