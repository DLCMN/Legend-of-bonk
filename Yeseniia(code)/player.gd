extends CharacterBody2D

var enemy_inattack_range = false
var enemy_attack_cooldown = true 
var health = 160
var max_health = 160
var player_alive = true
var attack_ip = false

@export var speed: float = 50
@export var animation_tree: AnimationTree

var input: Vector2
var playback: AnimationNodeStateMachinePlayback
var current_dir = "down"

var start_position = Vector2.ZERO
var respawn_timer = null

func _ready():
	start_position = position
	
	if animation_tree:
		playback = animation_tree["parameters/playback"]
	
	if has_node("player_hitbox"):
		if not $player_hitbox.is_connected("body_entered", Callable(self, "_on_player_hitbox_body_entered")):
			$player_hitbox.body_entered.connect(_on_player_hitbox_body_entered)
		if not $player_hitbox.is_connected("body_exited", Callable(self, "_on_player_hitbox_body_exited")):
			$player_hitbox.body_exited.connect(_on_player_hitbox_body_exited)
	
	if has_node("attack_cooldown"):
		if not $attack_cooldown.is_connected("timeout", Callable(self, "_on_attack_cooldown_timeout")):
			$attack_cooldown.timeout.connect(_on_attack_cooldown_timeout)
	
	if has_node("deal_attack_timer"):
		if not $deal_attack_timer.is_connected("timeout", Callable(self, "_on_deal_attack_timer_timeout")):
			$deal_attack_timer.timeout.connect(_on_deal_attack_timer_timeout)
	
	respawn_timer = Timer.new()
	respawn_timer.wait_time = 2.0
	respawn_timer.one_shot = true
	respawn_timer.connect("timeout", Callable(self, "_on_respawn_timer_timeout"))
	add_child(respawn_timer)

func _physics_process(_delta: float) -> void:
	if not player_alive:
		return
	
	enemy_attack()
	attack()
	
	if health <= 0:
		die()
		return
	
	input = Input.get_vector("left", "right", "up", "down")
	velocity = input * speed
	move_and_slide()
	
	update_direction()
	update_animation_parameters()
	select_animation()

func die():
	player_alive = false
	health = 0
	print("Player has been killed")
	hide()
	set_physics_process(false)
	respawn_timer.start()

func _on_respawn_timer_timeout():
	respawn()
	print("Player respawned")

func respawn():
	player_alive = true
	health = max_health
	position = start_position
	show()
	set_physics_process(true)
	velocity = Vector2.ZERO
	
	Global.player_current_attack = false
	attack_ip = false
	
	if has_node("deal_attack_timer") and $deal_attack_timer.is_stopped() == false:
		$deal_attack_timer.stop()

func update_direction():
	if input.x > 0:
		current_dir = "right"
	elif input.x < 0:
		current_dir = "left"
	elif input.y > 0:
		current_dir = "down"
	elif input.y < 0:
		current_dir = "up"

func select_animation():
	if animation_tree and playback:
		if velocity == Vector2.ZERO:
			playback.travel("idle")
		else:
			playback.travel("walk")

func update_animation_parameters():
	if not animation_tree:
		return
	
	if input == Vector2.ZERO:
		return
	
	animation_tree["parameters/walk/blend_position"] = input

func player():
	pass

func _on_player_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_inattack_range = true

func _on_player_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_inattack_range = false

func enemy_attack():
	if enemy_inattack_range and enemy_attack_cooldown == true:
		health = health - 20
		enemy_attack_cooldown = false
		$attack_cooldown.start()
		print("Player health: ", health)

func _on_attack_cooldown_timeout() -> void:
	enemy_attack_cooldown = true

func attack():
	if Input.is_action_just_pressed("attack") and player_alive:
		Global.player_current_attack = true
		attack_ip = true
		
		var sword_hitbox = $SwordHitbox
		
		if sword_hitbox:
			sword_hitbox.monitoring = true
			sword_hitbox.monitorable = true
			var sword_collision = sword_hitbox.get_child(0)
			if sword_collision:
				sword_collision.disabled = false
		
		match current_dir:
			"right":
				if has_node("Sprite2D"):
					$Sprite2D.flip_h = false
					$Sprite2D.play("side_attack")
				if sword_hitbox:
					sword_hitbox.position = Vector2(28, 0)
					sword_hitbox.rotation = 0
			"left":
				if has_node("Sprite2D"):
					$Sprite2D.flip_h = true
					$Sprite2D.play("side_attack")
				if sword_hitbox:
					sword_hitbox.position = Vector2(-28, 0)
					sword_hitbox.rotation = 0
			"down":
				if has_node("Sprite2D"):
					$Sprite2D.play("front_attack")
				if sword_hitbox:
					sword_hitbox.position = Vector2(0, 28)
					sword_hitbox.rotation = 0
			"up":
				if has_node("Sprite2D"):
					$Sprite2D.play("back_attack")
				if sword_hitbox:
					sword_hitbox.position = Vector2(0, -28)
					sword_hitbox.rotation = 0
		
		if has_node("deal_attack_timer"):
			$deal_attack_timer.start()

func _on_deal_attack_timer_timeout() -> void:
	if has_node("deal_attack_timer"):
		$deal_attack_timer.stop()
	
	var sword_hitbox = $SwordHitbox
	if sword_hitbox:
		sword_hitbox.monitoring = false
		sword_hitbox.monitorable = false
		
		var sword_collision = sword_hitbox.get_child(0)
		if sword_collision:
			sword_collision.disabled = true
	
	Global.player_current_attack = false
	attack_ip = false
