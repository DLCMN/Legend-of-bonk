class_name player
extends CharacterBody2D


@export var speed : float = 150
@export var animation_tree : AnimationTree
@onready var soundDamage: AudioStreamPlayer2D = $PlayerDamage
@onready var damage_cooldown: Timer = $DamageCooldown
@onready var respawn_shield: Timer = $RespawnShield
@onready var hud: CanvasLayer = $"../HUD"
@onready var player_health_bar: TextureProgressBar = $CanvasLayer/playerHealthBar
@onready var player_heart: AnimatedSprite2D = $CanvasLayer/playerHealthBar/PlayerHeart
@onready var heart_break_sound: AudioStreamPlayer2D = $heartBreakSound








var input : Vector2
var playback : AnimationNodeStateMachinePlayback
var strength : int = 15
var maxHealth : int
var health : int 
var dead : bool = false
var friendDead : bool = false
var checkpointManager



@export var is_attacking = false

#animation running the last frame compared to new one
func _ready() -> void:
	#load health
	health = PlayerStats.health
	maxHealth = PlayerStats.Maxhealth
	playback = animation_tree["parameters/playback"]
	checkpointManager = get_parent().get_node("CheckpointManager")


#movement (input, actual moving)
func _physics_process(_delta: float) -> void:
	if not is_attacking and not dead:
		input = Input.get_vector("left", "right", "up", "down")
	
	if Input.is_action_just_pressed("Attack") and not is_attacking and not dead:
		is_attacking = true
		print("Attack")
		velocity = Vector2.ZERO
		playback.travel("Attack1") #go to attack
		
	
	else:
		#only move when not attacking pls
		if not is_attacking and not dead:
			velocity = input * speed
		else:
			velocity = Vector2.ZERO

		move_and_slide()
		select_animation()
		update_animation_parameters()

	# dash
	if Input.is_action_just_pressed("Dash") and not is_attacking and not dead:
		$DashTimer.start()
		speed *= 10
		velocity = input * speed

	#runs animation

func attack_finished():
	is_attacking = false
	
	
func select_animation() -> void:
	if is_attacking or dead:
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


func _on_sword_hit_box_body_entered(body: Node2D) -> void:
	if is_attacking and body.name.begins_with("Evil") :
		body.take_damage(strength, position, self)
		
		
func takeDamage(amount: int) -> void:
	if damage_cooldown.time_left > 0 and not dead:
		return
	health -= amount
	soundDamage.play()
	PlayerStats.health = health
	player_health_bar.updateHealth(health)
	if health <= 0:
		die()
	#Damagecooldown
	damage_cooldown.start()
	
func die() -> void:
	dead = true
	friendDead = true
	playback.travel("death")
	$CollisionShape2D.set_deferred("disabled", true)
	respawn_shield.start()


func DeathAnimFinished() -> void:
	await get_tree().create_timer(0.7).timeout
	heart_break_sound.play()
	await get_tree().create_timer(0.8).timeout
	await hud.fade(1.0)
	friendDead = false
	position = checkpointManager.lastLocation
	health = PlayerStats.Maxhealth
	player_health_bar.updateHealth(health)
	await hud.fade(0.3)
	dead = false
	hud.fade(0.0)
	

func _on_respawn_shield_timeout() -> void:
	$CollisionShape2D.set_deferred("disabled", false)
