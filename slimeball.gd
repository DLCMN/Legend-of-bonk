extends Area2D

var direction :Vector2 = Vector2.RIGHT
var speed : int = 500
var strength: int = 5
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	animated_sprite_2d.play("default")

#goes off screen and deletes itself
func on_screen_exited() -> void:
	queue_free()

#hits an enemy, does damage and deletes itself
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.name.begins_with("Evil"):
		body.take_damage(strength, position , self)
		queue_free()
		
