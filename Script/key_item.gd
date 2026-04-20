extends Node2D
# This script controls the key pickup object

@export var key_id: String
# Identifier for this key
# Example values: "red_key", "blue_key", "boss_key"

func _on_area_2d_body_entered(body: Node2D) -> void:
	# Automatically called when another body enters this Area2D

	if body.has_node("KeyRing"):
		# Check if the colliding body is the player
		# The player must have a KeyRing node

		body.get_node("KeyRing").add_key(key_id)
		# Give this key to the player's inventory

		queue_free()
		# Remove the key from the level after pickup
