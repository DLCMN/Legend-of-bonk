class_name player
extends CharacterBody2D
var enemy_inattack_range=false
var enemy_attack_cooldown=true 
var health =160
var player_alive=true
var attack_ip=false

@export var speed : float = 50
@export var animation_tree : AnimationTree

var input : Vector2
var playback : AnimationNodeStateMachinePlayback
var current_dir="down"

##func _ready():
	##playback = animation_tree["parameters/playback"]

func _physics_process(_delta: float) -> void:
	enemy_attack()
	attack()
	
	if health <=0:
		player_alive=false
		health=0
		print("player has been killed")
		self.queue_free()
	input = Input.get_vector("left" , "right" , "up" , "down")
	velocity = input * speed
	move_and_slide()
	select_animation()
	update_animation_parameters()
	
func update_direction():
	if input.x > 0:
		current_dir = "right"
	elif input.x < 0:
		current_dir = "left"
	elif input.y > 0:
		current_dir = "down"
	elif input.y < 0:
		current_dir = "up"
	
func select_animation(): 
	if velocity == Vector2.ZERO:
		playback.travel("walk")
	
func update_animation_parameters(): 
	if input == Vector2.ZERO:
		return
		
	animation_tree["parameters/walk/blend_position"] = input
	
func player():
	pass 


func _on_player_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_inattack_range=true


func _on_player_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_inattack_range=false

func enemy_attack():
	if enemy_inattack_range and enemy_attack_cooldown==true:
		health=health-20
		enemy_attack_cooldown=false
		$attack_cooldown.start()
		print(health)

func _on_attack_cooldown_timeout() -> void:
	enemy_attack_cooldown=true

func attack():
	var dir = current_dir
	if  Input.is_action_just_pressed("attack"):
		global.player_current_attack=true
		attack_ip=true
		if dir=="right":
			$Sprite2D.flip_h=false
			$Sprite2D.play("side_attack")
			$deal_attack_timer.start()
			
	if dir=="left":
			$Sprite2D.flip_h=true
			$Sprite2D.play("side_attack")
			$deal_attack_timer.start()
			
	if dir=="down":
			$Sprite2D.play("front_attack")
			$deal_attack_timer.start()
			
	if dir=="up":
			$Sprite2D.play("back_attack")
			$deal_attack_timer.start()

func _on_deal_attack_timer_timeout() -> void:
	$deal_attack_timer.stop()
	global.player_current_attack=false
	attack_ip=false
