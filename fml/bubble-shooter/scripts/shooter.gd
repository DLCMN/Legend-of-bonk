extends Node2D
class_name Shooter

signal shot_fired(bubble: Bubble, angle: float)
# Signal emitted when a bubble is fired
const TRAJECTORY_STEP: float = 5.0
const MAX_TRAJECTORY_LENGTH: float = 2000.0
var left_wall: float
var right_wall: float
var ceiling_y: float

var current_bubble: Bubble = null
var next_bubble: Bubble = null
var bubble_scene: PackedScene
var is_aiming: bool = false
var current_angle: float = PI / 2
var can_shoot: bool = true
var grid: BubbleGrid

@onready var aim_line: Line2D = $AimLine
@onready var current_bubble_pos: Marker2D = $CurrentBubblePos
@onready var next_bubble_pos: Marker2D = $NextBubblePos
@onready var bubble_container: Node2D = $BubbleContainer
 # Load bubble scene and hide aim line initially
func _ready() -> void:
	bubble_scene = preload("res://scenes/bubble.tscn")
	aim_line.visible = false
# Store grid reference and boundarie
func setup(bubble_grid: BubbleGrid, _screen_width: float = 720.0) -> void:
	grid = bubble_grid
	left_wall = Config.LEFT_WALL
	right_wall = Config.RIGHT_WALL
	ceiling_y = grid.global_position.y
	grid.active_colors_changed.connect(_on_active_colors_changed)  # Update bubble colors when active colors change
	prepare_bubbles()

func _on_active_colors_changed(colors: Array[Bubble.BubbleColor]) -> void:
	# Update current bubble if its color is no longer on the board
	if current_bubble != null and current_bubble.bubble_color not in colors:
		current_bubble.set_bubble_color(Bubble.get_random_color_from_set(colors))
	# Update next bubble if its color is no longer on the board
	if next_bubble != null and next_bubble.bubble_color not in colors:
		next_bubble.set_bubble_color(Bubble.get_random_color_from_set(colors))

func prepare_bubbles() -> void:
	if current_bubble == null: # Ensure both bubbles exist
		spawn_current_bubble()
	if next_bubble == null:
		spawn_next_bubble()
# Create the bubble and place it at the shooter position
func spawn_current_bubble() -> void:
	var colors = grid.get_active_colors() if grid else []
	current_bubble = bubble_scene.instantiate() as Bubble # Center horizontally, near bottom of screen
	bubble_container.add_child(current_bubble)

	var screen_width = get_viewport_rect().size.x
	var screen_height = get_viewport_rect().size.y

	# Center horizontally, near bottom
	current_bubble.position = Vector2(screen_width / 2, screen_height - 100)

	current_bubble.set_bubble_color(
		Bubble.get_random_color_from_set(colors) if not colors.is_empty() 
		else Bubble.get_random_color()
	)

	print("Current bubble position: ", current_bubble.position)
# Create the next bubble and place it in preview position
func spawn_next_bubble() -> void:
	var colors = grid.get_active_colors() if grid else []
	next_bubble = bubble_scene.instantiate() as Bubble
	bubble_container.add_child(next_bubble)
	var screen_width = get_viewport_rect().size.x
	var screen_height = get_viewport_rect().size.y
	next_bubble.position = Vector2(screen_width / 2 - 100, screen_height - 200)
	next_bubble.scale = Vector2(Config.NEXT_BUBBLE_SCALE, Config.NEXT_BUBBLE_SCALE)
	next_bubble.set_bubble_color(Bubble.get_random_color_from_set(colors) if not colors.is_empty() else Bubble.get_random_color())
 # Update aim line while aiming
func _process(_delta: float) -> void:
	if is_aiming and can_shoot:
		update_aim()

func _input(event: InputEvent) -> void:
	if not can_shoot:
		return
 # Swap bubbles with left/right input
	if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right"):
		swap_bubbles()
		return
# Mouse input
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var local_pos = to_local(event.global_position)
			if local_pos.length() < Config.LAUNCHER_RADIUS and local_pos.y > -30:
				swap_bubbles()
			else:
				start_aiming()
		elif is_aiming:
			shoot()
	elif event is InputEventMouseMotion and is_aiming: # Mouse movement updates aim
		update_aim()
  # Keyboard aimin
	if event.is_action_pressed("ui_accept") and not is_aiming:
		start_aiming()
	elif event.is_action_released("ui_accept") and is_aiming:
		shoot()
  # Swap current and next bubble visually + logically
func swap_bubbles() -> void:
	if current_bubble == null or next_bubble == null:
		return
	var temp = current_bubble
	current_bubble = next_bubble
	next_bubble = temp
#Animate the swap
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(current_bubble, "position", current_bubble_pos.position, Config.BUBBLE_SWAP_DURATION).set_ease(Tween.EASE_OUT)
	tween.tween_property(current_bubble, "scale", Vector2.ONE, Config.BUBBLE_SWAP_DURATION)
	tween.tween_property(next_bubble, "position", next_bubble_pos.position, Config.BUBBLE_SWAP_DURATION).set_ease(Tween.EASE_OUT)
	tween.tween_property(next_bubble, "scale", Vector2(Config.NEXT_BUBBLE_SCALE, Config.NEXT_BUBBLE_SCALE), Config.BUBBLE_SWAP_DURATION)

func start_aiming() -> void:
	is_aiming = true
	aim_line.visible = true
	update_aim()
 # Begin aiming mode
func update_aim() -> void: # Clamp angle to allowed range
	var mouse_pos = get_global_mouse_position()
	var shooter_pos = current_bubble_pos.global_position
	var direction = mouse_pos - shooter_pos
	var min_rad = deg_to_rad(Config.MIN_AIM_ANGLE)
	var max_rad = deg_to_rad(Config.MAX_AIM_ANGLE)
	current_angle = clampf(atan2(-direction.y, direction.x), min_rad, max_rad)
# Calculate angle based on mouse position
	var trajectory = calculate_trajectory(shooter_pos, current_angle)
	aim_line.clear_points() 
	# Draw aim line
	for point in trajectory:
		aim_line.add_point(to_local(point))
# Bounce off left wall
func calculate_trajectory(start_pos: Vector2, angle: float) -> Array[Vector2]: # Simulates bubble movement to draw bounce prediction
	var points: Array[Vector2] = [start_pos]
	var current_pos = start_pos
	@warning_ignore("shadowed_variable")
	var current_angle = angle
	var total_distance: float = 0.0

	while total_distance < MAX_TRAJECTORY_LENGTH:
		var direction = Vector2(cos(current_angle), -sin(current_angle))
		var next_pos = current_pos + direction * TRAJECTORY_STEP
		total_distance += TRAJECTORY_STEP

		if next_pos.x <= left_wall:
			var t = (left_wall - current_pos.x) / direction.x
			next_pos = current_pos + direction * t
			next_pos.x = left_wall
			points.append(next_pos)
			current_angle = PI - current_angle
			current_pos = next_pos
			continue
			
		# Bounce off right wall
		elif next_pos.x >= right_wall:
			var t = (right_wall - current_pos.x) / direction.x
			next_pos = current_pos + direction * t
			next_pos.x = right_wall
			points.append(next_pos)
			current_angle = PI - current_angle
			current_pos = next_pos
			continue
			  # Hit ceiling
		if next_pos.y <= ceiling_y + Config.BUBBLE_RADIUS:
			var t = (ceiling_y + Config.BUBBLE_RADIUS - current_pos.y) / direction.y
			if t > 0:
				next_pos = current_pos + direction * t
			next_pos.y = ceiling_y + Config.BUBBLE_RADIUS
			points.append(next_pos)
			break

		# Hit another bubble in the grid
		var local_pos = grid.to_local(next_pos)
		if grid.check_collision(local_pos).x >= 0:
			points.append(next_pos)
			break

		current_pos = next_pos
  # If no bounce or collision, draw a short line
	if points.size() == 1:
		points.append(start_pos + Vector2(cos(angle), -sin(angle)) * 100)
	return points
 # Fire the bubble
func shoot() -> void:
	if current_bubble == null or not can_shoot:
		return
	is_aiming = false
	aim_line.visible = false

	var bubble = current_bubble
	current_bubble = null
# Move bubble to world root so it can travel freely
	var global_pos = bubble.global_position
	bubble_container.remove_child(bubble)
	get_parent().add_child(bubble)# start bubble movement
	bubble.global_position = global_pos#notify the bubble postion
	bubble.shoot(current_angle)
# Move next bubble into position
	shot_fired.emit(bubble, current_angle)
	advance_bubbles()

func advance_bubbles() -> void:
	 # Promote next bubble to current bubble
	if next_bubble != null:
		current_bubble = next_bubble
		next_bubble = null
		var tween = current_bubble.create_tween()
		tween.tween_property(current_bubble, "position", current_bubble_pos.position, Config.BUBBLE_ADVANCE_DURATION)
		tween.tween_property(current_bubble, "scale", Vector2.ONE, Config.BUBBLE_ADVANCE_DURATION * 0.67)
	spawn_next_bubble()

func set_can_shoot(value: bool) -> void: # Enable/disable shooting
	can_shoot = value
	if not can_shoot:
		is_aiming = false
		aim_line.visible = false

func reset() -> void:
	 # Remove existing bubbles and respawn
	if current_bubble:
		current_bubble.queue_free()
		current_bubble = null
	if next_bubble:
		next_bubble.queue_free()
		next_bubble = null   
	prepare_bubbles() 
	
