extends Area2D
class_name Bubble

signal popped(bubble: Bubble)

enum BubbleColor { RED, BLUE, GREEN, YELLOW, PURPLE, ORANGE }
# Maps each bubblcolor to an actual Godot Color value
const COLOR_VALUES: Dictionary = {
	BubbleColor.RED: Color("#FF4444"),
	BubbleColor.BLUE: Color("#4477FF"),
	BubbleColor.GREEN: Color("#44DD44"),
	BubbleColor.YELLOW: Color("#FFDD44"),
	BubbleColor.PURPLE: Color("#DD44DD"),
	BubbleColor.ORANGE: Color("#FF8844"),
}

@export var bubble_color: BubbleColor = BubbleColor.RED
# Movement and state variables
var angle: float = 0.0
var speed: float = 0.0
var is_shooting: bool = false
var is_falling: bool = false
var is_attached: bool = false
var fall_velocity: float = 0.0
var grid_position: Vector2i = Vector2i(-1, -1)

@onready var sprite: Sprite2D = $Sprite2D
# Reference to the bubbles sprite
func _ready() -> void:
	update_color()
# If the bubble is being shot, move it in its angle direction
func _physics_process(delta: float) -> void:
	if is_shooting:
		position += Vector2(cos(angle), -sin(angle)) * speed * delta
	elif is_falling:
		fall_velocity += Config.FALL_ACCELERATION * delta
		position.y += fall_velocity * delta
		position.x += randf_range(-20, 20) * delta
		if position.y > Config.SCREEN_HEIGHT + 100:   # If bubble falls off-screen, delete it
			queue_free()
# Change the bubble's color and update its appearance
func set_bubble_color(color: BubbleColor) -> void:
	bubble_color = color
	update_color()
# Apply the color to the sprite
func update_color() -> void:
	if sprite:
		sprite.modulate = COLOR_VALUES[bubble_color]
# Called when the bubble is fired
func shoot(shoot_angle: float) -> void:
	angle = shoot_angle
	speed = Config.SHOOT_SPEED
	is_shooting = true
	is_attached = false
	is_falling = false
# Bounce off a wall by flipping the angle horizontally
func reflect_horizontal() -> void:
	angle = PI - angle
# Stop all movement and reset velocities
func stop() -> void:
	is_shooting = false
	is_falling = false
	speed = 0.0
	fall_velocity = 0.0
# Attach bubble to the grid
func attach() -> void:
	stop()
	is_attached = true
# Start falling animation + physics when bubble is detached
func start_falling() -> void:
	is_attached = false
	is_shooting = false
	is_falling = true
	fall_velocity = 0.0
	 # Squash and stretch animation when bubble begins falling
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 0.8), Config.FALL_SQUASH_DURATION)
	tween.tween_property(self, "scale", Vector2.ONE, Config.FALL_SQUASH_DURATION)
# Pop animation and signal and deletion
func pop() -> void:
	is_attached = false
	is_shooting = false
	is_falling = false
	popped.emit(self) # Notify the game that this bubble popped
	
	# Animate bubble growing + fading out
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), Config.POP_ANIMATION_DURATION).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, Config.POP_ANIMATION_DURATION)
	tween.set_parallel(false) # After animation, delete the bubble
	tween.tween_callback(queue_free)
# Pick a random bubble color from all available colors
static func get_random_color() -> BubbleColor:
	return BubbleColor.values()[randi() % BubbleColor.size()]
# Pick a random color from a provided subset
static func get_random_color_from_set(colors: Array[Bubble.BubbleColor]) -> BubbleColor:
	if colors.is_empty():
		return get_random_color()
	return colors[randi() % colors.size()]
