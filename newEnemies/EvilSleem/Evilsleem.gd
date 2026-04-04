extends CharacterBody2D

const SPEED: int = 100
const knockbackForce: int = 150

var alive: bool = true
var target = null
var targetInRange:bool = false
var strength: int  = 10
var health: int = 75

@onready var animSprite: AnimatedSprite2D = $evilSleemSprite
@onready var soundDamage: AudioStreamPlayer2D = $SleemHit
@onready var soundMove: AudioStreamPlayer2D = $SleemMove
@onready var soundDeath: AudioStreamPlayer2D = $Sleemdie
@onready var healthBar: Node2D = $HealthBar
@onready var evil_sleem_sprite: AnimatedSprite2D = $evilSleemSprite
@onready var attack_timer: Timer = $AttackTimer




func _physics_process(delta: float) -> void:
	if alive:
		show()
	if alive and target:
		_attack(delta)
	
	

func _attack(delta: float) -> void:
	var direction = (target.position - position).normalized()
	position += direction * SPEED * delta
	if targetInRange and alive:
		animSprite.play("attack")
	else:
		animSprite.play("walk")

func take_damage(damage: int, attacker_position) -> void:
	health -= damage
	healthBar.updateHealth(health)
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
	
	
func die() -> void:
	alive = false
	animSprite.play("death")
	soundDeath.play()
	$Evaporation.start()
	
	#disable collision
	$CollisionShape2D.set_deferred("disabled", true)
	$Sight/CollisionShape2D.set_deferred("disabled", true)
	$Hitbox/CollisionShape2D.set_deferred("disabled", true)

	
func _on_sight_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		target = body
		print(target)


func _on_sight_body_exited(body: Node2D) -> void:
	if body.name == "Player" and alive:
		target = null
		animSprite.play("idle")


func _on_evaporation_timeout() -> void:
	if not alive:
		hide()


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

func _on_attack_timer_timeout() -> void:
	if target and targetInRange:
		target.takeDamage(strength)
