@tool
class_name Laser
extends RayCast2D

# Appearance
@export var color :Color = Color("#ed77ff")
@onready var line_2d: Line2D = %Line2D

var cast_speed: float = 15.0
var max_length: float = 10000

# Intrinsic to laser
@export var is_casting := false: set = set_is_casting
@export var angle: float = 0 # in radians
var already_collided: bool = false
var filtered := false

var come_from: String = ""
var laser_index: int = 0

signal laser_collision(laser_collided: Laser)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	line_2d.points[0] = Vector2.ZERO
	line_2d.points[1] = Vector2.ZERO
	target_position = Vector2.ZERO
	line_2d.visible = true
	set_color(color)
	add_exceptions()
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
			laser_collision.emit(self)
			set_physics_process(false)

		line_2d.points[1] = laser_end_position
	else:
		set_physics_process(false)
	
func set_color(new_color: Color = Color("#ed77ff")) -> void:
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
		
func add_exceptions():
	for obj in get_tree().get_nodes_in_group("player"):
		if obj is CollisionObject2D:
			add_exception(obj)
	if come_from == "filter":
		for obj in get_tree().get_nodes_in_group("filter"):
			add_exception(obj)
	if come_from == "unfilter":
		for obj in get_tree().get_nodes_in_group("unfilter"):
			add_exception(obj)
	
	if not filtered:
		if come_from == "up" or come_from == "down":
			for obj in get_tree().get_nodes_in_group("tableau_border_down"):
				add_exception(obj)
		if come_from == "down" or come_from == "up":
				for obj in get_tree().get_nodes_in_group("tableau_border_up"):
					add_exception(obj)
		if come_from == "left" or come_from == "right":
				for obj in get_tree().get_nodes_in_group("tableau_border_right"):
					add_exception(obj)
		if come_from == "right" or come_from == "left":
				for obj in get_tree().get_nodes_in_group("tableau_border_left"):
					add_exception(obj)
					
	else:
		for obj in get_tree().get_nodes_in_group("tableau_border_up"):
			add_exception(obj)
		for obj in get_tree().get_nodes_in_group("tableau_border_down"):
			add_exception(obj)
		for obj in get_tree().get_nodes_in_group("tableau_border_left"):
			add_exception(obj)
		for obj in get_tree().get_nodes_in_group("tableau_border_right"):
			add_exception(obj)
		

		
	
		
