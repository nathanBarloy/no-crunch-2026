extends Node2D


var laser = preload("res://mechanics/laser/laser.tscn")
@export var geode_angle: float = 0
var looping_color: Color = Color("#ed77ff")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().physics_frame
	instantiate_laser($Geode.position, geode_angle)
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("turn-clock"):
		_rotate(+PI/8)
	if Input.is_action_just_pressed("turn-anticlock"):
		_rotate(-PI/8)
	
func instantiate_laser(init_position: Vector2, laser_angle: float, come_from: String = "") -> Laser:
	var new_laser: Laser = laser.instantiate()
	new_laser.position = init_position
	new_laser.angle = laser_angle
	new_laser.come_from = come_from
	new_laser.color = looping_color
	$Geode.add_child(new_laser)
	new_laser.laser_collision.connect(_on_laser_collision)
	return new_laser
	
func _rotate(angle: float) ->void:
	for child in $Geode.get_children():
		if child is Laser:
			child.queue_free()
	geode_angle += angle
	$GeodeSprite.rotation = geode_angle
	instantiate_laser($Geode.position, geode_angle)
	
	
func _on_laser_collision(collided_laser: Laser):
	var collided_object: Node2D = collided_laser.get_collider()
	var collided_point: Vector2 = to_local(collided_laser.get_collision_point())
	
	if collided_object is Mirror:
		var normal: Vector2 = collided_laser.get_collision_normal()
		var laser_vec = collided_laser.target_position
		var reflected_angle = laser_vec.bounce(normal).angle()
		instantiate_laser(collided_point, reflected_angle)

	elif collided_object is Target:
		EventBus.victory.emit()

	elif "tableau_border_up" in collided_object.get_groups():
		var down_position: Vector2 = collided_point
		down_position.y += DisplayServer.screen_get_size().y
		instantiate_laser(down_position, collided_laser.angle, "up")
		
	elif "tableau_border_down" in collided_object.get_groups():
		var up_position: Vector2 = collided_point
		up_position.y -= DisplayServer.screen_get_size().y
		instantiate_laser(up_position, collided_laser.angle, "down")
		
	elif "tableau_border_left" in collided_object.get_groups():
		var right_position: Vector2 = collided_point
		right_position.x += DisplayServer.screen_get_size().x
		instantiate_laser(right_position, collided_laser.angle, "left")
		
	elif "tableau_border_right" in collided_object.get_groups():
		var right_position: Vector2 = collided_point
		right_position.x -= DisplayServer.screen_get_size().x
		instantiate_laser(right_position, collided_laser.angle, "right")

func _on_geode_area_entered(area: Area2D) -> void:
	pass
	# print(area)
	
