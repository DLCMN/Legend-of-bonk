extends CharacterBody2D

@export var moveSpeed: float = 90
@export var fireball: PackedScene

@onready var evilAnimation: AnimatedSprite2D = $evilSleemSprite
@onready var player: Node2D = get_parent().get_node("Player")
@onready var bulletCooldown: Timer = $BulletCooldown
@onready var rayCast: RayCast2D = $RayCast2D

var knockbackForce: int = 20
var teleporting: bool = false
var summoned: bool = true
var enemyTarget = null

func _physics_process(_delta: float) -> void:
	
	var to_player: Vector2 = (player.position - position)
	var direction = to_player.length()
	
	if summoned:
		if player.friendDead == true:
			mourn()
		else:
			if not teleporting:
				if direction > 50:
					velocity = to_player.normalized() * moveSpeed
					evilAnimation.play("walk")
				else:
					velocity = Vector2.ZERO
					evilAnimation.play("idle")
				
				if direction < 20:
					var knockbackDirection = (position - player.position).normalized()
					var targetPosition = position + knockbackDirection * knockbackForce
					
					var tween = create_tween()
					tween.set_ease(Tween.EASE_OUT)
					tween.set_trans(Tween.TRANS_CUBIC)
					tween.tween_property(self, "position", targetPosition, 0.5)
				
				if direction > 250:
					teleporting = true
					evilAnimation.play("TeleportStart")
					await get_tree().create_timer(0.8).timeout
					position = player.position * 1.1
				
				move_and_slide()
				
				if enemyTarget:
					aim()
					collisionChecker()
	else:
		hide()

func mourn():
	evilAnimation.play("sleemCry")

func _on_animated_sprite_2d_animation_finished() -> void:
	if evilAnimation.animation == "TeleportStart":
		teleporting = false

func _on_sight_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		enemyTarget = body
		print("Player detected!")

func _on_sight_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		enemyTarget = null

func aim():
	rayCast.target_position = to_local(enemyTarget.position)

func collisionChecker():
	if enemyTarget and rayCast.get_collider() == enemyTarget and bulletCooldown.is_stopped():
		bulletCooldown.start()
	elif rayCast.get_collider() != enemyTarget and bulletCooldown.is_stopped():
		bulletCooldown.stop()

func shoot():
	if enemyTarget:
		var bullet = fireball.instantiate()
		bullet.position = position
		bullet.direction = (rayCast.target_position).normalized()
		get_tree().current_scene.add_child(bullet)

func _on_bullet_cooldown_timeout() -> void:
	shoot()


func _on_evil_sleem_sprite_animation_finished() -> void:
	pass # Replace with function body.
