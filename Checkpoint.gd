extends Area2D

var checkpointManager

#how individual checkpoints function

func _ready() -> void:
	checkpointManager = get_parent().get_parent().get_node("CheckpointManager")
	
func _physics_process(_delta: float) -> void:
	pass
#sends location to global when player touches
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		checkpointManager.lastLocation = $RespawnPoint.global_position
