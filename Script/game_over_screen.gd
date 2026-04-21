extends Control

@export var TargetNode : Node2D = null

func _on_StartAgainButton_pressed() -> void:
	get_tree().paused = false
	visible = false
	if TargetNode == null:
		push_error("GameOverScreen: TargetNode is not assigned")
		return
	TargetNode.respawn()

func _on_MenuButton_pressed() -> void:
	# Go back to main menu
	get_tree().paused = false
	get_tree().change_scene_to_file("res://menu.tscn")
