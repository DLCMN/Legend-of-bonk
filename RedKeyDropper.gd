extends Node2D

const RED_KEY = preload("res://RedKeyItem.tscn")

var has_dropped: bool = false

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer

func drop_red_key() -> void:
	if has_dropped == true:
		return
	has_dropped = true
	
	var red_key = RED_KEY.instantiate()
	red_key.global_position = global_position
	get_tree().current_scene.add_child(red_key)
	audio.play()
	print("Red key dropped at: ", global_position)
