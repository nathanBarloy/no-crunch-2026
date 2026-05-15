extends Node2D


var laser = preload("res://mechanics/laser/laser.tscn")
@export var geode_angle: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().physics_frame
	
func instantiate_laser(init_position: Vector2, laser_angle: float) -> Laser:
	var new_laser: Laser = laser.instantiate()
	new_laser.position = init_position
	new_laser.angle = laser_angle
	add_child(new_laser)
	new_laser.laser_collision.connect(_on_laser_collision)
	return new_laser

func _on_button_button_down() -> void:
	instantiate_laser($Geode.position, geode_angle)
	
func _on_laser_collision(collided_laser: Laser, collided_position: Vector2):
	var collided_object = collided_laser.get_collider()
	var normal: Vector2 = collided_laser.get_collision_normal()
	var laser_vec = collided_laser.target_position
	var reflected_angle = laser_vec.bounce(normal).angle()
	print(reflected_angle)
	if collided_object is Mirror:
		instantiate_laser(to_local(collided_laser.get_collision_point()), reflected_angle)
		
