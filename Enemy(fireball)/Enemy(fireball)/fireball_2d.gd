extends Area2D

var speed: float = 800
var damage: int = 20
var direction: Vector2 = Vector2.RIGHT

func _ready():
	update_rotation()
	start_lifetime()


func _physics_process(delta):
	global_position += direction * speed * delta


func _on_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(damage, global_position)
		queue_free()


func start_lifetime():
	await get_tree().create_timer(3.0).timeout
	queue_free()

func set_direction(dir: Vector2):
	direction = dir.normalized()
	update_rotation()

func update_rotation():
	rotation = direction.angle()
