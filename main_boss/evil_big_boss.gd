extends CharacterBody2D

const SPEED: int = 100

var knockbackForce: int = 150
var alive: bool = true
var target = null
var targetInRange:bool = false
var strength: int  = 10
var health: int = 75
var enemyTarget = null


@export var ammo: PackedScene

@onready var bullet_cooldown: Timer = $BulletCooldown
@onready var rayCast: RayCast2D = $RayCast2D
@onready var raycastTwo: RayCast2D = $RayCast2D2
@onready var raycast3: RayCast2D = $RayCast2D3

@onready var animSprite: AnimatedSprite2D = $evilSleemSprite
@onready var soundDamage: AudioStreamPlayer2D = $SleemHit
@onready var soundMove: AudioStreamPlayer2D = $SleemMove
@onready var soundDeath: AudioStreamPlayer2D = $Sleemdie
@onready var healthBar: Node2D = $HealthBar
@onready var evil_sleem_sprite: AnimatedSprite2D = $evilSleemSprite
@onready var attack_timer: Timer = $AttackTimer




func _physics_process(delta: float) -> void:
	#resets to show when game starts again
	if alive:
		show()
	if alive and target:    #how it attacks
		_attack(delta)
	
	
#how it targets the player, through getting its position and moving towards it
func _attack(delta: float) -> void:
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


func _on_stab_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.takeDamage(strength)


func _on_projectile_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		enemyTarget = body
		print(enemyTarget)
	
	
func collisionChecker():
	if enemyTarget and raycastTwo.get_collider() == enemyTarget and rayCast.get_collider() == enemyTarget  and raycast3.get_collider() == enemyTarget and bullet_cooldown.is_stopped():
		bullet_cooldown.start()
	elif rayCast.get_collider() != enemyTarget and bullet_cooldown.is_stopped():
		bullet_cooldown.stop()
	

func shoot():
	#ensures enemy is in range and is attacking player, then shoots
	if enemyTarget and enemyTarget.target:
		var bullet = ammo.instantiate()
		bullet.position = position
		bullet.direction = (rayCast.target_position).normalized()
		get_tree().current_scene.add_child(bullet)

func _on_bullet_cooldown_timeout() -> void:
	shoot()
