extends Area2D

var shadow: bool = false
var SPEED = 500

@onready var thePlayer : Node2D = get_parent().get_node("Player")

func _ready() -> void:
	hide()

func _physics_process(delta: float) -> void:
	if shadow:
			var direction = (thePlayer.position - position).normalized()
			position += direction * SPEED * delta
