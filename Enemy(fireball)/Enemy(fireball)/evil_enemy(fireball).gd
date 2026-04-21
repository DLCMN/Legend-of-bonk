extends CharacterBody2D

@export var moveSpeed: float = 90
@export var fireball: PackedScene=preload("res://Enemy(fireball)/Enemy(fireball)/fireball_2d.tscn")

@onready var evilAnimation: AnimatedSprite2D = $evilSleemSprite
@onready var player: Node2D = get_parent().get_node("Player")
@onready var bulletCooldown: Timer = $BulletCooldown
@onready var rayCast: RayCast2D = $RayCast2D

var summoned: bool = true
var enemyTarget = null

func _physics_process(_delta: float) -> void:
	if not summoned:
		hide()
		return
	
	if player == null:
		return
	
	var to_player: Vector2 = (player.position - position)
	var direction = to_player.length()
	
	if direction > 50:
		velocity = to_player.normalized() * moveSpeed
		if evilAnimation.animation != "walk":
			evilAnimation.play("walk")
	else:
		velocity = Vector2.ZERO
		if evilAnimation.animation != "idle":
			evilAnimation.play("idle")
	
	move_and_slide()
	
	if enemyTarget:
		aim()
		collisionChecker()

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
		bullet.global_position = global_position
		var direction_to_player = (enemyTarget.global_position - global_position).normalized()
		bullet.set_direction(direction_to_player)
		get_tree().current_scene.add_child(bullet)

func _on_bullet_cooldown_timeout() -> void:
	shoot()
