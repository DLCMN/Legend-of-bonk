extends CharacterBody2D

var speed = 40
var patrol_speed = 30

enum EnemyState {
	PATROL,
	CHASE
}
var current_state = EnemyState.PATROL

var patrol_points = []
var current_patrol_index = 0
var patrol_size = 30
var start_position = Vector2.ZERO

var target_player = null
var can_take_damage = true
var health = 100
var player_inattack_zone = false

func _ready():
	start_position = position
	create_patrol_square(patrol_size)
	
	if $detection_area:
		if not $detection_area.is_connected("body_entered", Callable(self, "_on_detection_area_body_entered")):
			$detection_area.body_entered.connect(_on_detection_area_body_entered)
		if not $detection_area.is_connected("body_exited", Callable(self, "_on_detection_area_body_exited")):
			$detection_area.body_exited.connect(_on_detection_area_body_exited)
	
	if $enemy_hitbox:
		if not $enemy_hitbox.is_connected("body_entered", Callable(self, "_on_enemy_hitbox_body_entered")):
			$enemy_hitbox.body_entered.connect(_on_enemy_hitbox_body_entered)
		if not $enemy_hitbox.is_connected("body_exited", Callable(self, "_on_enemy_hitbox_body_exited")):
			$enemy_hitbox.body_exited.connect(_on_enemy_hitbox_body_exited)
	
	if $take_damage_cooldown:
		if not $take_damage_cooldown.is_connected("timeout", Callable(self, "_on_take_damage_cooldown_timeout")):
			$take_damage_cooldown.timeout.connect(_on_take_damage_cooldown_timeout)

func create_patrol_square(size: float):
	patrol_points = [
		start_position + Vector2(-size, -size),
		start_position + Vector2(size, -size),
		start_position + Vector2(size, size),
		start_position + Vector2(-size, size)
	]

func _physics_process(_delta: float) -> void:
	deal_with_damage()
	
	match current_state:
		EnemyState.PATROL:
			patrol()
		EnemyState.CHASE:
			chase_player()
	
	move_and_slide()
	update_animation()

func patrol():
	if patrol_points.is_empty():
		return
	
	var target_point = patrol_points[current_patrol_index]
	var direction = (target_point - position).normalized()
	velocity = direction * patrol_speed
	
	if position.distance_to(target_point) < 10:
		current_patrol_index = (current_patrol_index + 1) % patrol_points.size()

func chase_player():
	if target_player and is_instance_valid(target_player) and target_player.player_alive == true:
		var direction = (target_player.position - position).normalized()
		velocity = direction * speed
	else:
		current_state = EnemyState.PATROL
		target_player = null
		current_patrol_index = 0

func update_animation():
	if not $AnimatedSprite2D:
		return
	
	if velocity == Vector2.ZERO:
		$AnimatedSprite2D.play("idle")
	else:
		$AnimatedSprite2D.play("walk")
		if velocity.x < 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.has_method("player") and body.player_alive == true:
		target_player = body
		current_state = EnemyState.CHASE

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		await get_tree().create_timer(0.5).timeout
		if current_state == EnemyState.CHASE and $detection_area and not $detection_area.has_overlapping_bodies():
			current_state = EnemyState.PATROL
			target_player = null
			current_patrol_index = 0

func enemy():
	pass

func _on_enemy_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("player") and body.player_alive == true:
		player_inattack_zone = true

func _on_enemy_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_inattack_zone = false

func deal_with_damage():
	if player_inattack_zone and Global.player_current_attack == true:
		if can_take_damage == true:
			health = health - 20
			can_take_damage = false
			if $take_damage_cooldown:
				$take_damage_cooldown.start()
			print("Slime health: ", health)
			if health <= 0:
				self.queue_free()

func _on_take_damage_cooldown_timeout() -> void:
	can_take_damage = true
