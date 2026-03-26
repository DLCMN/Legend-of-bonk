class_name player
extends CharacterBody2D

@export var speed : float = 50
@export var animation_tree : AnimationTree

var input : Vector2
var playback : AnimationNodeStateMachinePlayback
var is_attacking = false

func _ready():
	playback = animation_tree["parameters/playback"]

func _physics_process(_delta: float) -> void:
	if is_attacking == false:
	
<<<<<<< Updated upstream
=======
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
	if Input.is_action_just_pressed("Attack"):
		is_attacking = true
		
	#runs animation
	
	
	
	
func attack_finished():
	is_attacking = false


>>>>>>> Stashed changes
func select_animation(): 
	if is_attacking:
		playback.travel("Attack1")
		attack_finished()
	if velocity == Vector2.ZERO:
<<<<<<< Updated upstream
		playback.travel("walk")
=======
		playback.travel("Idle")
	else:
		playback.travel("Walk")
		
>>>>>>> Stashed changes
	
func update_animation_parameters(): 
	if input == Vector2.ZERO:
		return
		
		
	animation_tree["parameters/walk/blend_position"] = input
	animation_tree["parameters/Idle/blend_position"] = input
	animation_tree["parameters/Attack1/blend_position"] = input
	
<<<<<<< Updated upstream
=======


 #reset dash
func _on_dash_timer_timeout() -> void:
	speed = 150
>>>>>>> Stashed changes
