extends CanvasLayer

signal celebration_finished
# UI elements for celebration screen
@onready var clear_board_label: Label = $CenterContainer/VBoxContainer/ClearBoardLabel

# Runs when scene is loaded
func _ready() -> void:
	visible = false # hide celebration screen initially
# Shows the level clear celebration animation
func show_celebration() -> void:
	clear_board_label.scale = Vector2.ZERO # Reset UI scale and transparency before animation
	
	clear_board_label.modulate.a = 0
	
	# to create "level cleared" text
	var tween = create_tween()
	tween.tween_property(clear_board_label, "scale", Vector2(1.2, 1.2), 0.3).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(clear_board_label, "modulate:a", 1.0, 0.2)
	tween.tween_property(clear_board_label, "scale", Vector2.ONE, 0.15).set_ease(Tween.EASE_IN_OUT)
	tween.tween_interval(1.5) # Wait before closing celebration
	tween.tween_callback(_on_celebration_done)
	
	# Called when celebration animation finishes
func _on_celebration_done() -> void:
	# Fade out whole celebration UI
	var container = $CenterContainer
	var tween = create_tween()
	tween.tween_property(container, "modulate:a", 0.0, 0.3)
	# After fade-out, hide UI and notify game
	tween.tween_callback(func():
		visible = false
		container.modulate.a = 1.0
		celebration_finished.emit()
	)
# Hides celebration screen immediately
func hide_celebration() -> void:
	visible = false
