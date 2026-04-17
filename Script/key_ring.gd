extends Node
# This script is attached to a Node (KeyRing) under Player

signal key_added(key_id)
# Signal emitted when a key is added
# key_id tells which key was picked up

signal key_used(key_id)
# Signal emitted when a key is consumed (used on a door)

var keys := {}
# Dictionary that stores keys the player owns
# Example: { "red_key": true, "blue_key": true }

func add_key(key_id: String) -> void:
	# Called when the player picks up a key

	keys[key_id] = true
	# Add the key to the dictionary

	key_added.emit(key_id)
	# Notify UI and other systems that a key was added

func has_key(key_id: String) -> bool:
	# Checks if the player currently has this key

	return keys.has(key_id)
	# Returns true if the key exists in the dictionary

func use_key(key_id: String) -> void:
	# Removes a key after it is used on a door

	if has_key(key_id):
		# Safety check: only remove if player actually has it

		keys.erase(key_id)
		# Remove the key from inventory

		key_used.emit(key_id)
		# Notify UI that the key is gone
