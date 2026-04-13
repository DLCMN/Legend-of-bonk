extends Camera2D
class_name roomTransitionCamera

const Horizontal_Offset : int = 56
const Vertical_Offset : int = 64

@export var TargetNode : Node2D = null

@onready var m_CameraHorizontalMovement : int = get_viewport_rect().size.x - Horizontal_Offset
@onready var m_CameraVerticalMovement : int = get_viewport_rect().size.y - Vertical_Offset

# Initialize the current room the camera is pointing at
var m_CurrentRoom : Vector2 = Vector2.ZERO

# Initialize the offset from the origin point
var m_OriginOffset : Vector2 = Vector2.ZERO

func _ready() -> void:
	m_OriginOffset = TargetNode.get_position()
	set_position(m_OriginOffset)
	

func _UpdateCameraPosition(direction : Vector2) -> void:
	m_CurrentRoom += direction
	set_position(m_OriginOffset + m_CurrentRoom * Vector2(m_CameraHorizontalMovement, m_CameraVerticalMovement))

func _OnBodyEnteredNorth(body: Node2D) -> void:
	_UpdateCameraPosition(Vector2.UP)


func _OnBodyEnteredSouth(body: Node2D) -> void:
	_UpdateCameraPosition(Vector2.DOWN)


func _OnBodyEnteredEast(body: Node2D) -> void:
	_UpdateCameraPosition(Vector2.RIGHT)


func _OnBodyEnteredWest(body: Node2D) -> void:
	_UpdateCameraPosition(Vector2.LEFT)
