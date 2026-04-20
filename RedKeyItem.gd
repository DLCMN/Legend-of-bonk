@tool
extends CharacterBody2D

signal picked_up

@export var key_id: String = "red_key"
@export var key_name: String = "Red Key"
@export var key_texture: Texture2D

@onready var area_2d: Area2D = $Area2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	if key_texture and sprite_2d:
		sprite_2d.texture = key_texture
	
	if Engine.is_editor_hint():
		return
	
	area_2d.body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	var collision_info = move_and_collide(velocity * delta)
	if collision_info:
		velocity = velocity.bounce(collision_info.get_normal())
	velocity = velocity * 0.98

func _on_body_entered(body) -> void:
	if body.is_in_group("player"):
		if Global.add_key(key_id):
			print("Picked up RED KEY!")
			item_picked_up()

func item_picked_up() -> void:
	area_2d.body_entered.disconnect(_on_body_entered)
	audio_stream_player_2d.play()
	visible = false
	picked_up.emit()
	await audio_stream_player_2d.finished
	queue_free()
