extends Area2D 

@export var card_id : int = 0 
@export var face_up_texture : Texture2D 
@export var face_down_texture : Texture2D 

@onready var sprite = $Sprite2D 

var card_manager = "res://JanusPuzzle/card_manager.tscn"
var is_flipped = false 
var is_matched = false 

func _ready(): 
	sprite.texture = face_down_texture 


func flip(): 
	$AnimationPlayer.play("flipping")
	if is_matched or is_flipped or card_manager.checking:
		return 
	
	is_flipped = true 
	sprite.texture = face_up_texture 
	
	card_manager.card_flipped(self) 


func flip_back():
	is_flipped = false
	sprite.texture = face_down_texture
	$AnimationPlayer.play("flipping")


func set_matched(): 
	is_matched = true 


func _on_body_entered(body: Node2D) -> void: 
	if body.name == "Player": 
		flip()
