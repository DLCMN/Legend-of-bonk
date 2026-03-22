class_name Player
extends CharacterBody2D

@export var speed : float = 100
@export var animation_tree : AnimationTree

var input
var playback : AnimationNodeStateMachinePlayback

func _ready():
	playback = animation_tree["parameters/playback"]
	z_index = 10  
	GameManager.register_player(self)

func _physics_process(delta: float) -> void:
	input = Input.get_vector("left" , "right" , "up" , "down")
	velocity = input * speed
	move_and_slide()
	select_animation()
	update_animation_parameters()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is Area2D and collider.has_method("flip"):
			collider.flip()
	
func select_animation(): 
	if velocity == Vector2.ZERO:
		playback.travel("walk")
	else:
		playback.travel("walk")
		


func update_animation_parameters():
	if input == Vector2.ZERO:
		return
		
	animation_tree["parameters/walk/blend_position"] = input
