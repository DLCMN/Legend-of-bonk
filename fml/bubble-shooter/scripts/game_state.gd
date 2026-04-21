extends Node
# Signal sent when game ends
# won = true if player clears all bubbles
signal game_over(won: bool, final_score: int)
# Signal sent when a new game starts
signal game_started
# Stores if game is currently active
var is_playing: bool = false
# Stores if player has won
var game_won: bool = false

# Starts a new game
func start_game() -> void:
	is_playing = true
	game_won = false
	game_started.emit()

# Called after each shot and returns false so no new rows are added
func register_shot(_removed_bubbles: bool) -> bool:
	return false

# Called when all bubbles are cleared and ends the game as a win
func board_cleared() -> void:
	end_game(true)

# Ends the game
# won = true for win, false for lose
func end_game(won: bool) -> void:
	is_playing = false
	game_won = won
	game_over.emit(won, 0)
	
