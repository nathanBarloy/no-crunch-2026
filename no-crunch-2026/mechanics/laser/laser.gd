@tool
class_name Laser
extends RayCast2D

# Appearance
@export var color := Color.WHITE: set = set_color
@onready var line_2d: Line2D = %Line2D
var cast_speed: float = 5.0
var max_length: float = 2000

# Intrinsic to laser
@export var is_casting := false: set = set_is_casting
@export var angle: float = 0 # in radians
var already_collided: bool = false

signal laser_collision(collided_object: Variant, collided_position: Vector2, collided_normal: Vector2)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	line_2d.points[0] = Vector2.ZERO
	line_2d.points[1] = Vector2.ZERO
	target_position = Vector2.ZERO
	line_2d.visible = true
	set_is_casting(true)
	
func _physics_process(_delta: float) -> void:
	if target_position.length() < max_length:
		target_position.x += cos(angle) * cast_speed
		target_position.y += sin(angle) * cast_speed

		var laser_end_position := target_position
		force_raycast_update()

		if is_colliding() and not already_collided:
			already_collided = true
			laser_end_position = to_local(get_collision_point())
			laser_collision.emit(self, laser_end_position)
			set_physics_process(false)

		line_2d.points[1] = laser_end_position
	else:
		set_physics_process(false)
	
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
		line_2d.visible = true
	else:
		target_position = Vector2.ZERO
		line_2d.visible = false
		
