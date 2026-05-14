extends Node2D

@export var speed = 400  # (pixel/s)

signal drop_request(node: Node)
signal take_request()


func _process(delta: float) -> void:
	# Process movement
	var frame_speed = get_frame_speed(delta)
	self.position += frame_speed
	
	# Process action
	if Input.is_action_just_pressed("action"):
		action()


func get_frame_speed(delta: float) -> Vector2:
	var frame_speed = Vector2.ZERO
	if Input.is_action_pressed("move-right"):
		frame_speed.x += 1
	if Input.is_action_pressed("move-left"):
		frame_speed.x -= 1
	if Input.is_action_pressed("move-up"):
		frame_speed.y -= 1
	if Input.is_action_pressed("move-down"):
		frame_speed.y += 1
	
	if frame_speed.length() != 0:
		frame_speed = frame_speed.normalized() * speed * delta
	
	return frame_speed


func can_take() -> bool:
	return $Inventory.get_children().size() == 0


func take(object: Node) -> void:
	$Inventory.add_child(object)


func drop() -> void:
	var drop_node = $Inventory.get_child(0)
	remove_child(drop_node)
	drop_request.emit(drop_node)


func action() -> void:
	if can_take():
		take_request.emit()
	else:
		drop()
