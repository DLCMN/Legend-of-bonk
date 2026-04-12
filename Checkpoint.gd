extends Area2D

var checkpointManager

func _ready() -> void:
	checkpointManager = get_parent().get_parent().get_node("CheckpointManager")
	
func _physics_process(_delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		checkpointManager.lastLocation = $RespawnPoint.global_position
