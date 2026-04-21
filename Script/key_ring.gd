class_name KeyRing extends Node

signal key_added(key_id)
signal key_used(key_id)

var keys := {}

func add_key(key_id: String) -> void:
	keys[key_id] = true
	key_added.emit(key_id)

func has_key(key_id: String) -> bool:
	return keys.has(key_id)

func use_key(key_id: String) -> void:
	if has_key(key_id):
		keys.erase(key_id)
		key_used.emit(key_id)
