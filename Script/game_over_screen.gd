extends Control

func _on_StartAgainButton_pressed() -> void:
	# Restart the game by loading level_1
	get_tree().change_scene_to_file("res://level_1.tscn")

func _on_MenuButton_pressed() -> void:
	# Go back to main menu
	get_tree().change_scene_to_file("res://menu.tscn")
