extends CharacterBody2D



@export var moveSpeed = 90
@export var ammo: PackedScene

@onready var sleemAnimation: AnimatedSprite2D = $AnimatedSprite2D
@onready var bonk: Node2D = get_parent().get_node("Player")
@onready var bullet_cooldown: Timer = $BulletCooldown
@onready var rayCast: RayCast2D = $RayCast2D


var knockbackForce: int = 80
var teleporting: bool = false
var summoned: bool = true
var enemyTarget = null

func _physics_process(_delta: float) -> void:
	
	#setting what direction to follow player
	var to_player: Vector2 = (bonk.position - position)
	var direction = to_player.length()
	
	#if unlocked, show
	if summoned:
		#cry if player dies
		if bonk.friendDead == true:
			mourn()
		else:
			#move if not in the middle of telporting
			if not teleporting:
				#tells it to follow player until it reachs that distance away
				if direction > 50:
					velocity = to_player.normalized() * moveSpeed
					sleemAnimation.play("walk")
					
				else:
					velocity = Vector2.ZERO
					sleemAnimation.play("idle")
					
				#player pushes sleem
				if direction < 20:
					var knockbackDirection = (position - bonk.position).normalized()
					var targetPosition = position + knockbackDirection * knockbackForce
					
					var tween = create_tween()
					tween.set_ease(Tween.EASE_OUT)
					tween.set_trans(Tween.TRANS_CUBIC)
					tween.tween_property(self, "position", targetPosition, 0.5)
					
				#teleportation
				if direction > 250:
					teleporting = true
					sleemAnimation.play("TeleportStart")
					await get_tree().create_timer(0.8).timeout
					position = bonk.position * 1.1
					
				move_and_slide()
				if enemyTarget:
					aim()
					collisionChecker()
					
	else:
		hide()
#cry
func mourn():
	sleemAnimation.play("sleemCry")

#tells system when sleem stops teleporting
func _on_animated_sprite_2d_animation_finished() -> void:
	if sleemAnimation.animation == "TeleportStart":
		teleporting = false

#targets enemy and shoots
func _on_sight_body_entered(body: Node2D) -> void:
	if body.name.begins_with("Evil"):
		enemyTarget = body
		print(enemyTarget)
		


func _on_sight_body_exited(body: Node2D) -> void:
	
	if body.name.begins_with("Evil"):
		enemyTarget = null

func aim():
	rayCast.target_position = to_local(enemyTarget.position)
	
func collisionChecker():
	if enemyTarget and rayCast.get_collider() == enemyTarget and bullet_cooldown.is_stopped():
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
#nerfs the sleem
func _on_bullet_cooldown_timeout() -> void:
	shoot()
	
