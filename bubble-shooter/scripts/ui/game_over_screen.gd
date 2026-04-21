extends CanvasLayer
class_name GameOverScreen



# Only keep nodes that STILL exist in the scene
@onready var title_label: Label = $Panel/VBoxContainer/TitleLabel



func _ready() -> void:
	# Hide game over screen at start
	visible = false


func show_game_over(won: bool, _final_score: int = 0) -> void:

	# Update title text based on win/lose
	if won:
		title_label.text = "Board Cleared!" 
		title_label.add_theme_color_override("font_color", Color.GREEN)
	else:
		title_label.text = "Game Over"
		title_label.add_theme_color_override("font_color", Color.RED)

	visible = true


func hide_screen() -> void:
	# Simply hide UI again
	visible = false
