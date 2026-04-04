extends CharacterBody2D

const SPEED: int = 100
const knockbackForce: int = 150

var alive: bool = true
var target = null
var health: int = 75

@onready var animSprite: AnimatedSprite2D = $evilSleemSprite
@onready var soundDamage: AudioStreamPlayer2D = $SleemHit
@onready var soundMove: AudioStreamPlayer2D = $SleemMove
@onready var soundDeath: AudioStreamPlayer2D = $Sleemdie




func _physics_process(delta: float) -> void:
	if alive and target:
		_attack(delta)
	
	

func _attack(delta: float) -> void:
	var direction = (target.position - position).normalized()
	position += direction * SPEED * delta
	animSprite.play("walk")

func take_damage(damage: int, attacker_position) -> void:
	health -= damage
	print(health)
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
	
	#disable collision
	$CollisionShape2D.set_deferred("disabled", true)
	$Sight/CollisionShape2D.set_deferred("disabled", true)

	
func _on_sight_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		target = body
		print(target)


func _on_sight_body_exited(body: Node2D) -> void:
	if body.name == "Player" and alive:
		target = null
		animSprite.play("idle")
