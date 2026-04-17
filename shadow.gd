extends Area2D

var shadow: bool = false
var SPEED = 300

@onready var thePlayer : Node2D = get_parent().get_node("Player")

func _ready() -> void:
	hide()

func _physics_process(delta: float) -> void:
	if thePlayer.dash:
		SPEED = 600
	else:
		SPEED = 300
		
	if shadow:
			var direction = (thePlayer.position - position).normalized()
			position += direction * SPEED * delta
