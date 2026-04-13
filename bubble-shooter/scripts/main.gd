extends Node2D

@onready var bubble_grid: BubbleGrid = $BubbleGrid
@onready var shooter: Shooter = $Shooter
@onready var hud = $HUD
@onready var game_over_screen: GameOverScreen = $GameOverScreen as GameOverScreen
@onready var clear_board_celebration = $ClearBoardCelebration
@onready var score_popup_container: Node2D = $ScorePopupContainer

# Game variables
var score_popup_scene: PackedScene
var flying_bubble: Bubble = null
var game_active: bool = false

# Runs when the game starts
func _ready() -> void:
	randomize()
	score_popup_scene = preload("res://scenes/score_popup.tscn")
	#connects signals
	shooter.shot_fired.connect(_on_shot_fired)
	bubble_grid.bubbles_popped.connect(_on_bubbles_popped)
	bubble_grid.bubble_landed.connect(_on_bubble_landed)
	bubble_grid.board_cleared.connect(_on_board_cleared)
	bubble_grid.danger_line_reached.connect(_on_danger_line_reached)
	game_over_screen.play_again_pressed.connect(_on_play_again)
	clear_board_celebration.celebration_finished.connect(_on_celebration_finished)
	GameState.game_over.connect(_on_game_over)
	# Setup shooter and start game
	shooter.setup(bubble_grid, Config.SCREEN_WIDTH)
	start_game()
 # Starts and resets the game
func start_game() -> void:
	bubble_grid.reset()
	shooter.reset()
	game_over_screen.hide_screen()
	shooter.set_can_shoot(true)
	game_active = true
	GameState.start_game()
# Called when player shoots a bubble
func _on_shot_fired(bubble: Bubble, _angle: float) -> void:
	flying_bubble = bubble
	shooter.set_can_shoot(false)
# Runs every frame (movement and collision)
func _physics_process(_delta: float) -> void:
	# Stops if no active bubble
	if flying_bubble == null or not is_instance_valid(flying_bubble) or not flying_bubble.is_shooting:
		return
	# Converts bubble position into grid coordinates
	var bubble_local_pos = bubble_grid.to_local(flying_bubble.global_position)
	 # Handles wall bounce
	check_wall_collision(flying_bubble)
	 # Checks collision with ceiling
	if bubble_grid.check_ceiling_collision(bubble_local_pos):
		land_bubble(bubble_local_pos)
		return
	 # Checks collision with other bubbles
	if bubble_grid.check_collision(bubble_local_pos).x >= 0:
		land_bubble(bubble_local_pos)
# Handles bubble bouncing off walls
func check_wall_collision(bubble: Bubble) -> void:
	# If the bubble hits left wall
	if bubble.global_position.x <= Config.LEFT_WALL:
		bubble.global_position.x = Config.LEFT_WALL
		bubble.reflect_horizontal()
	# If the bubble hits right wall
	elif bubble.global_position.x >= Config.RIGHT_WALL:
		bubble.global_position.x = Config.RIGHT_WALL
		bubble.reflect_horizontal()
# Handles when a bubble lands on grid
func land_bubble(local_pos: Vector2) -> void:
	# If no active bubble, do nothing
	if flying_bubble == null:
		return

	var bubble = flying_bubble
	# resets active bubble
	flying_bubble = null
	# Moves bubble from shooter to grid
	bubble.get_parent().remove_child(bubble)
	bubble_grid.add_child(bubble)
	bubble.position = local_pos
	# Trying to place the bubble in grid
	if bubble_grid.place_bubble(bubble, local_pos):
		bubble_grid.process_bubble_placement(bubble)
	else:
		bubble.queue_free()
		shooter.set_can_shoot(true)
# Called when bubbles are popped
func _on_bubbles_popped(count: int, dropped: int, pop_positions: Array[Vector2], drop_positions: Array[Vector2]) -> void:
	GameState.add_score(count, dropped) # updates the score
	GameState.register_shot(true)  # if it is a successful shot
	shooter.set_can_shoot(true)  # allows the next shot
	# Shows the score popups for popped bubbles
	for i in range(pop_positions.size()):
		var score = Config.BASE_BUBBLE_SCORE if i < Config.MIN_MATCH_COUNT else Config.COMBO_BONUS_PER_BUBBLE
		spawn_score_popup(pop_positions[i], score, Color(1, 1, 0.5))
		await get_tree().create_timer(0.05).timeout
	# Shows score popups for dropped bubbles
	for pos in drop_positions:
		spawn_score_popup(pos, Config.DROP_BONUS, Color(0.5, 1, 0.5))
		await get_tree().create_timer(0.05).timeout
# Creates floating score text
func spawn_score_popup(pos: Vector2, score: int, color: Color) -> void:
	var popup = score_popup_scene.instantiate()
	score_popup_container.add_child(popup)
	popup.global_position = pos
	popup.setup(score, color)
# Called when a bubble lands but no match
func _on_bubble_landed() -> void:
	if GameState.register_shot(false):
		bubble_grid.add_row_at_top()
	shooter.set_can_shoot(true)
# Called when all bubbles are cleared- win
func _on_board_cleared() -> void:
	game_active = false
	shooter.set_can_shoot(false)
	clear_board_celebration.show_celebration(GameState.get_time_bonus())
# After the celebration board ends
func _on_celebration_finished() -> void:
	GameState.board_cleared()
# Called when bubbles reach danger line - lose
func _on_danger_line_reached() -> void:
	game_active = false
	shooter.set_can_shoot(false)
	GameState.end_game(false)
# Handles game over screen
func _on_game_over(won: bool, final_score: int) -> void:
	shooter.set_can_shoot(false)
	game_over_screen.show_game_over(won, final_score, GameState.get_time_bonus() if won else 0)
# Restarts the game when player presses play again
func _on_play_again() -> void:
	start_game()
#End
