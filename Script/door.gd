extends Node2D
class_name Door

@export var locked_audio : AudioStream
@export var open_audio : AudioStream 

@export var required_key_id: String = "" # Which key opens this door. Empty string = unlocked door
@export var consume_key := true # If true, key is removed after use


@onready var body = $StaticBody2D  # Reference to physics body that blocks the player
@onready var collision_shape: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var interact_area: Area2D = $InteractArea2D

var opened := false # Prevents door from opening multiple times


func _on_Interact_Area2D_body_entered(player) -> void: # Called when player enters door's interaction area

	if opened: # If already open, do nothing
		return

	if not player.has_node("KeyRing"): # Ensure this is the player
		return

	var keyring = player.get_node("KeyRing") # Access player's inventory
	if required_key_id != "": # Door is locked
		if not keyring.has_key(required_key_id): # Player does not have the key
			audio_player.stream = locked_audio
			audio_player.play() # Play the door closed sound
			return

		if consume_key: # Remove key after use (if enabled)
			keyring.use_key(required_key_id)
	open() # Open the door

func open(): # Actually opens the door
	opened = true
	collision_shape.set_deferred("disabled", true)
	interact_area.set_deferred("monitoring", false)    # Stops further Area2D interaction

	animation.play("open") # Play the door opening animation
	audio_player.stream = open_audio
	audio_player.play() #Play open audio
