extends Node2D
class_name KeyItem

@export var key_id: String

func _on_Area2D_body_entered(body: Node) -> void:
	if not body.has_node("KeyRing"):
		return
	var keyring = body.get_node("KeyRing")
	keyring.add_key(key_id)
	queue_free()
