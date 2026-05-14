
extends RayCast2D

# Appearance
@export var color := Color.WHITE: set = set_color
@onready var line_2d: Line2D = %Line2D
@export var max_length := 1400.0
@export var cast_speed := 100.0

# Intrinsic to laser
@export var is_casting := false: set = set_is_casting
@export var angle: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_is_casting(true)
	
func _physics_process(delta: float) -> void:
	target_position.x += sin(angle)
	target_position.y += cos(angle)

	var laser_end_position := target_position
	force_raycast_update()

	if is_colliding():
		laser_end_position = to_local(get_collision_point())

	line_2d.points[1] = laser_end_position

	
func set_color(new_color: Color) -> void:
	color = new_color
	if line_2d == null:
		return
	line_2d.modulate = new_color
	
func set_is_casting(new_value: bool) -> void:
	if is_casting == new_value:
		return
	is_casting = new_value

	set_physics_process(is_casting)

	if not line_2d:
		return

	if is_casting:
		var laser_start := Vector2.RIGHT
		line_2d.points[0] = laser_start
		line_2d.points[1] = laser_start
		line_2d.visible = true
	else:
		target_position = Vector2.ZERO
		line_2d.visible = false
