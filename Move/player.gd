class_name player
extends CharacterBody2D

@export var speed : float = 150
@export var animation_tree : AnimationTree


var input : Vector2
var playback : AnimationNodeStateMachinePlayback


#animation running the last frame compared to new one
func _ready():
	playback = animation_tree["parameters/playback"]


#movement (input, actual moving)
func _physics_process(_delta: float) -> void:
	input = Input.get_vector("left" , "right" , "up" , "down")
	velocity = input * speed
	move_and_slide()
	select_animation()
	update_animation_parameters()
	
	#Handles dash
	if Input.is_action_just_pressed("Dash"):
		$DashTimer.start()
		speed *= 10
		velocity = input * speed
	#runs animation
	
	
func select_animation(): 
	if velocity == Vector2.ZERO:
		playback.travel("walk")
		
	
func update_animation_parameters(): 
	if input == Vector2.ZERO:
		return
		
	animation_tree["parameters/walk/blend_position"] = input
	

 #reset dash
func _on_dash_timer_timeout() -> void:
	speed = 150
