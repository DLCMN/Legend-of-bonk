extends CharacterBody2D

const SPEED: int = 100

var knockbackForce: int = 150

const DROP_CHANCE:float = 1.0

var alive: bool = true
var target = null
var targetInRange:bool = false
var strength: int  = 10
var health: int = 75
var jumping: bool = false
var jumpCountdown = false
var targetedPosition: Vector2 

#var health_pickup_scene=preload("res://health_pickup.tscn")

@onready var animSprite: AnimatedSprite2D = $evilSleemSprite

@onready var soundDamage: AudioStreamPlayer2D = $SleemHit
@onready var soundMove: AudioStreamPlayer2D = $SleemMove
@onready var soundDeath: AudioStreamPlayer2D = $Sleemdie
@onready var healthBar: Node2D = $HealthBar
@onready var attack_timer: Timer = $AttackTimer
@onready var JumpDelay: Timer = $JumpDelay

@onready var Shadow : Node2D = get_parent().get_node("Shadow")
@onready var thePlayer : Node2D = get_parent().get_node("Player")



func _physics_process(delta: float) -> void:
	#resets to show when game starts again
	if alive:
		show()
	if alive and target:    #how it attacks
		_attack(delta)
	
	
#how it targets the player, through getting its position and moving towards it
func _attack(delta: float) -> void:
	if jumping:
		return
	if not jumping:
		if not jumpCountdown and not jumping:
			JumpDelay.start
		var direction = (target.position - position).normalized()
		position += direction * SPEED * delta
		if targetInRange and alive: #checks it is touching the player and is alive before attacking otherwise it doesnt follow through
			animSprite.play("attack")
		else:
			animSprite.play("walk")
#how the enemy's health deducts, and specifies if the damage is coming from the player or companion
func take_damage(damage: int, attacker_position, body) -> void:
	if body.name == "Player":
		knockbackForce = 100
	else:
		knockbackForce = 25
	
	health -= damage
	healthBar.updateHealth(health)  # updates visible healthbar
	if health <= 0:
		die()
	else:
		soundDamage.play()
	
		#knockback
		var knockbackDirection = (position - attacker_position).normalized()
		var targetPosition = position + knockbackDirection * knockbackForce
		
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "position", targetPosition, 0.3)
	
	
func JumpTime():
	jumping = true
	Shadow.show()
	await get_tree().create_timer(2).timeout
	targetedPosition = thePlayer.position
	
	animSprite.play("jump")
	
	var jumpTween = create_tween()
	jumpTween.tween_property(self, "global_position", targetedPosition, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	await jumpTween.finished
	animSprite.play("Slam")
	
	#enemy dying
func die() -> void:
	alive = false
	animSprite.play("death")
	soundDeath.play()
	$Evaporation.start()
	
	#disable collision
	$CollisionShape2D.set_deferred("disabled", true)
	$Sight/CollisionShape2D.set_deferred("disabled", true)
	$Hitbox/CollisionShape2D.set_deferred("disabled", true)

#Drop health pickup
	#if randf()<=DROP_CHANCE:
		#drop_item()

	#targeting the player
func _on_sight_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		target = body
		print(target)


func _on_sight_body_exited(body: Node2D) -> void:
	if body.name == "Player" and alive:
		target = null
		animSprite.play("idle")

#after a certain amount of time after it dies, the sprite dissapears
func _on_evaporation_timeout() -> void:
	if not alive:
		hide()

#actually hitting the player only when it is within range
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		targetInRange = true
		body.takeDamage(strength)
		attack_timer.start()
		animSprite.play("attack")

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		targetInRange = false
		attack_timer.stop()
#attack cooldown
func _on_attack_timer_timeout() -> void:
	if target and targetInRange:
		target.takeDamage(strength)


#func drop_item():
	#var drop = health_pickup_scene.instantiate()
	#drop.position=position 
	#var level_root = get_parent()
	#var items_node= level_root.get_node("Items")
	
	#items_node.call_deferred("add_child", drop)
	
	


func _on_jump_delay_timeout() -> void:
	pass # Replace with function body.
