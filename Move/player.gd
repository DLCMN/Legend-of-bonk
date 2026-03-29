class_name player
extends CharacterBody2D

@export var speed : float = 150
@export var animation_tree : AnimationTree


var input : Vector2
var playback : AnimationNodeStateMachinePlayback
var is_attacking = false

#animation running the last frame compared to new one
func _ready() -> void:
	playback = animation_tree["parameters/playback"]


#movement (input, actual moving)
func _physics_process(_delta: float) -> void:
	input = Input.get_vector("left", "right", "up", "down")
	
	if Input.is_action_just_pressed("Attack") and not is_attacking:
		is_attacking = true
		velocity = Vector2.ZERO
		playback.travel("Attack1") #go to attack
		
	
	else:
		#only move when not attacking pls
		if not is_attacking:
			velocity = input * speed
		else:
			velocity = Vector2.ZERO

		move_and_slide()
		select_animation()
		update_animation_parameters()

	# dash
	if Input.is_action_just_pressed("Dash") and not is_attacking:
		$DashTimer.start()
		speed *= 10
		velocity = input * speed

	#runs animation

func attack_finished():
	is_attacking = false
	
func select_animation() -> void:
	if is_attacking:
		return
	if velocity == Vector2.ZERO:
		playback.travel("Idle")
	else :
		playback.travel("walk")
		
		
	
func update_animation_parameters(): 
	if input == Vector2.ZERO:
		return
		
	animation_tree["parameters/walk/blend_position"] = input
	animation_tree["parameters/Idle/blend_position"] = input
	animation_tree["parameters/Attack1/blend_position"] = input
	

 #reset dash
func _on_dash_timer_timeout() -> void:
	speed = 150
