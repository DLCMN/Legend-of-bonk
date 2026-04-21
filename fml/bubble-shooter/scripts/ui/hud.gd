extends CanvasLayer
class_name HUD

@onready var time_value: Label = $TopBar/TimeSection/TimeValue
@onready var score_value: Label = $TopBar/ScoreSection/ScoreValue

func _ready() -> void:
	# Connect signals
	GameState.score_changed.connect(_on_score_changed)
	GameState.time_changed.connect(_on_time_changed)
	# Removed hearts signal because hearts no longer exist

	# Initialize HUD values
	_on_score_changed(0)
	_on_time_changed(Config.GAME_DURATION)
	# _on_turns_changed removed because hearts are gone

func _on_score_changed(new_score: int) -> void:
	score_value.text = str(new_score)
	var tween = score_value.create_tween()
	tween.tween_property(score_value, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(score_value, "scale", Vector2.ONE, 0.1)

func _on_time_changed(time_left: float) -> void:
	var minutes = int(time_left / 60)
	var seconds = int(time_left) % 60
	var min_str = "0" + str(minutes) if minutes < 10 else str(minutes)
	var sec_str = "0" + str(seconds) if seconds < 10 else str(seconds)
	time_value.text = min_str + ":" + sec_str

	if time_left <= 30:
		time_value.add_theme_color_override("font_color", Color(1, 0.3, 0.3, 1))
	else:
		time_value.remove_theme_color_override("font_color")
