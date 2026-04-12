extends Area2D

var direction :Vector2 = Vector2.RIGHT
var speed : int = 500
var strength: int = 5
var exploding: bool = false
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	if not exploding:
		position += direction * speed * delta
		animated_sprite_2d.play("default")


func on_screen_exited() -> void:
	queue_free()


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.name.begins_with("Evil"):
		body.take_damage(strength, position , self)
		exploding = true
		animated_sprite_2d.play("explode")
		

		


func animation_finished() -> void:
	if animated_sprite_2d.animation == "explode":
		exploding = false
		queue_free()
