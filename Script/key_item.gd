extends Area2D

@export var key_id: String = "red_key"

func _on_body_entered(body):
	if body.has_node("KeyRing"):
		body.get_node("KeyRing").add_key(key_id)
		queue_free()
		
