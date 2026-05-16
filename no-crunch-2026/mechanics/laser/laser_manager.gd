extends Node2D


var laser = preload("res://mechanics/laser/laser.tscn")
@export var geode_angle: float = 0
var looping_color: Color = Color("#ed77ff")
var filtered_color: Color = Color(0.282, 0.677, 0.503, 1.0)

var laser_index: int = 0

var nb_intersection: int = 0

var last_collider_position: Vector2 = Vector2.ZERO
var last_collider_angle: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().physics_frame
	EventBus.drop_request.connect(_on_redraw_request)
	EventBus.take_request.connect(_on_redraw_request)
	instantiate_laser($Geode.position, geode_angle)
	
	
func _process(_delta: float) -> void:
	if nb_intersection > 0:
		if Input.is_action_just_pressed("turn-clock"):
			_rotate(+PI/8)
		if Input.is_action_just_pressed("turn-anticlock"):
			_rotate(-PI/8)
	
func instantiate_laser(init_position: Vector2, laser_angle: float, index: int = 0, come_from: String = "", filtered := false) -> Laser:
	var new_laser: Laser = laser.instantiate()
	new_laser.position = init_position
	new_laser.angle = laser_angle
	new_laser.come_from = come_from
	if filtered:
		new_laser.color = filtered_color
	else:
		new_laser.color = looping_color
	new_laser.laser_index = index
	new_laser.filtered = filtered
	$Geode.add_child(new_laser)
	new_laser.laser_collision.connect(_on_laser_collision)
	return new_laser
	
func _rotate(angle: float) ->void:
	_clear_lasers()
	geode_angle += angle
	$GeodeSprite.rotation = geode_angle
	fire_geode()
	
func _clear_lasers():
	for child in $Geode.get_children():
		if child is Laser:
			child.queue_free()
	laser_index = 0
			
func fire_geode():
	instantiate_laser($Geode.position, geode_angle, laser_index)
	laser_index += 1
	
func _on_redraw_request(_node):
	_clear_lasers()
	fire_geode()
	
	
func _on_laser_collision(collided_laser: Laser):
	var collided_object: Node2D = collided_laser.get_collider()
	var collided_point: Vector2 = to_local(collided_laser.get_collision_point())
	var collided_angle: float = collided_laser.angle
	
	# prevent infinite loop
	if collided_point == last_collider_position and last_collider_angle == collided_angle:
		return
		
	last_collider_angle = collided_angle
	last_collider_position = collided_point
	
	# generate next laser
	#print("bump: " , collided_object.get_groups())
	if collided_object is Mirror:
		var normal: Vector2 = collided_laser.get_collision_normal()
		var laser_vec = collided_laser.target_position
		var reflected_angle = laser_vec.bounce(normal).angle()
		instantiate_laser(collided_point, reflected_angle)
		$LaserReflection.volume_db = 10
		$LaserReflection.play()
	elif collided_object is Target:
		EventBus.victory.emit()
		
	elif collided_object is Filter:
		instantiate_laser(collided_point, collided_angle, laser_index, "filter", true)
		
	elif not collided_laser.filtered:

		if "tableau_border_up" in collided_object.get_groups():
			var down_position: Vector2 = collided_point
			down_position.y += 1080
			instantiate_laser(down_position, collided_angle, laser_index, "up")
			
		elif "tableau_border_down" in collided_object.get_groups():
			var up_position: Vector2 = collided_point
			up_position.y -= 1080
			instantiate_laser(up_position, collided_angle, laser_index, "down")
			
		elif "tableau_border_left" in collided_object.get_groups():
			var right_position: Vector2 = collided_point
			right_position.x += 1920
			instantiate_laser(right_position, collided_angle, laser_index, "left")
			
		elif "tableau_border_right" in collided_object.get_groups():
			var right_position: Vector2 = collided_point
			right_position.x -= 1920
			instantiate_laser(right_position, collided_angle, laser_index, "right")



func _on_geode_area_entered(area: Area2D) -> void:
	nb_intersection += 1


func _on_geode_area_exited(area: Area2D) -> void:
	nb_intersection -= 1
