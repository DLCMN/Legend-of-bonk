class_name Door extends Node2D
#Door is a Node2D so it can be rotated easily

@export var locked_audio : AudioStream
@export var open_audio : AudioStream 

@onready var body = $StaticBody2D  # Reference to physics body that blocks the player
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var interact_area: Area2D = $InteractArea2D

@export var required_key_id: String = ""
# Which key opens this door
# Empty string = unlocked door

@export var consume_key := true
# If true, key is removed after use

var opened := false
# Prevents door from opening multiple times


func _on_Area2D_body_entered(player): # Called when player enters door's interaction area

	if opened: # If already open, do nothing
		return

	if not player.has_node("KeyRing"): # Ensure this is the player
		return

	var keyring = player.get_node("KeyRing") # Access player's inventory
	if required_key_id != "": # Door is locked

		if not keyring.has_key(required_key_id): # Player does not have the key
			locked_audio.play("closed") # Play the door opening animation
			return

		if consume_key: # Remove key after use (if enabled)
			keyring.use_key(required_key_id)
	open() # Open the door

func open(): # Actually opens the door
	opened = true # Mark as open
	body.get_node("CollisionShape2D").disabled = true # Disable collision so player can pass
	animation.play("open") # Play the door opening animation
