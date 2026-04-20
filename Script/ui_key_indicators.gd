extends HBoxContainer

@onready var indicators := {}
# Dictionary: key_id -> indicator node

func _ready() -> void:
	for child in get_children():
		if child is UiIndicator:
			indicators[child.key_id] = child
		else:
			push_warning("KeyIndicators: child %s is not a UiIndicator" % child.name)
		
func connect_player(player: Node) -> void:
	# Called ONCE to connect UI to the player.
	# We do this from the level, not from the UI itself.
	if not player.has_node("KeyRing"):
		push_error("KeyIndicators: Player has no KeyRing")
		return
	var keyring = player.get_node("KeyRing")
	# Get the player's KeyRing inventory.

	keyring.key_added.connect(_on_key_added)
	keyring.key_used.connect(_on_key_used)

func _on_key_added(key_id: String) -> void: 
	if indicators.has(key_id):
		indicators[key_id].visible = true

func _on_key_used(key_id: String) -> void:
	if indicators.has(key_id):
		indicators[key_id].visible = false
