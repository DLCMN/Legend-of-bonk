class_name player
extends CharacterBody2D

@export var speed : float = 150
@export var animation_tree : AnimationTree

var input : Vector2
var playback : AnimationNodeStateMachinePlayback

func _ready():
	playback = animation_tree["parameters/playback"]

func _physics_process(_delta: float) -> void:
	input = Input.get_vector("left" , "right" , "up" , "down")
	velocity = input * speed
	move_and_slide()
	select_animation()
	update_animation_parameters()
	
func select_animation(): 
	if velocity == Vector2.ZERO:
		playback.travel("walk")
	
func update_animation_parameters(): 
	if input == Vector2.ZERO:
		return
		
	animation_tree["parameters/walk/blend_position"] = input
	


func _OnBodyEnteredDown(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	pass # Replace with function body.
