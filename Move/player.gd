class_name player
extends CharacterBody2D

# To be assigned to Player Health Assets
@export var player_health_bar : TextureProgressBar =  null
@export var player_heart : AnimatedSprite2D = null

@export var speed : float = 150
@export var animation_tree : AnimationTree
@export var atkNumber: int = 3

@onready var soundDamage: AudioStreamPlayer2D = $PlayerDamage
@onready var damage_cooldown: Timer = $DamageCooldown
@onready var respawn_shield: Timer = $RespawnShield
@onready var hud: CanvasLayer = $"../HUD"
# @onready var player_health_bar: TextureProgressBar = $CanvasLayer/playerHealthBar
# @onready var player_heart: AnimatedSprite2D = $CanvasLayer/playerHealthBar/PlayerHeart
@onready var heart_break_sound: AudioStreamPlayer2D = $heartBreakSound








var input : Vector2
var playback : AnimationNodeStateMachinePlayback
var strength : int = 15
var maxHealth : int
var health : int 

var friendDead : bool = false
var checkpointManager
var cooldownCombo: bool = false
var dash = false

@export var dead : bool = false
@export var is_attacking = false

#animation running the last frame compared to new one
func _ready() -> void:
	animation_tree.active = true
	#load health
	health = PlayerStats.health
	maxHealth = PlayerStats.Maxhealth
	playback = animation_tree["parameters/playback"]
	checkpointManager = get_parent().get_node("CheckpointManager")


#movement (input, actual moving)
func _physics_process(_delta: float) -> void:
	if not is_attacking and not dead:
		input = Input.get_vector("left", "right", "up", "down")
	#the attack + the deciding which combo its on, so which animation to play
	if Input.is_action_just_pressed("Attack") and not is_attacking and not dead and not cooldownCombo:
		is_attacking = true
		print("Attack")
		velocity = Vector2.ZERO
		if Input.is_action_just_pressed("Attack") and atkNumber == 3:
			playback.travel("Attack1") #go to attack
			removeAtkNumber()
		elif Input.is_action_just_pressed("Attack") and atkNumber == 2:
			playback.travel("Attack2") #go to attack
			removeAtkNumber()
		elif Input.is_action_just_pressed("Attack") and atkNumber == 1:
			playback.travel("Attack3") #go to attack
			removeAtkNumber()
			comboCooldown()
			
		
	
	else:
		#only move when not attacking
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
		dash = true


#ending attack
func attack_finished():
	is_attacking = false
#combo countdown
func removeAtkNumber():
	print(atkNumber)
	if atkNumber <= 1:
		atkNumber = 3
	else:
		atkNumber = atkNumber - 1
		
	
		#runs animation
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
	animation_tree["parameters/Attack2/blend_position"] = input
	animation_tree["parameters/Attack3/blend_position"] = input


 #reset dash
func _on_dash_timer_timeout() -> void:
	speed = 150
	dash = false

#attacking the enemy when it swings with something in it
func _on_sword_hit_box_body_entered(body: Node2D) -> void:
	if is_attacking and body.name.begins_with("Evil") :
		body.take_damage(strength, position, self)
		
# how the player takes damage and eventually dies
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
	


#death
func die() -> void:
	dead = true
	friendDead = true
	playback.travel("death")
	$CollisionShape2D.set_deferred("disabled", true)
	respawn_shield.start()

#actually resetting + respawning and running the screen fade
func DeathAnimFinished() -> void:
	await get_tree().create_timer(0.7).timeout
	heart_break_sound.play()
	await get_tree().create_timer(0.8).timeout
	await hud.fade(1.0)
	friendDead = false #notifys sleem to stop crying
	position = checkpointManager.lastLocation
	health = PlayerStats.Maxhealth
	player_health_bar.updateHealth(health)
	playback.travel("Idle")
	await hud.fade(0.3)
	dead = false #resetting various variables
	is_attacking = false
	cooldownCombo = false
	hud.fade(0.0)
	
	 #making it so the combo actually appears as a combo and not just a spam of three animations
func comboCooldown():
	cooldownCombo = true
	await get_tree().create_timer(0.2).timeout
	cooldownCombo = false

#temporary respawn invulnerability so player doesnt get spawn killed
func _on_respawn_shield_timeout() -> void:
	$CollisionShape2D.set_deferred("disabled", false)
