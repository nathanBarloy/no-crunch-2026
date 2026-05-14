extends CharacterBody2D

@export var speed = 400  # (pixel/s)
var is_moving_right = false
var is_moving_left = false
var is_moving_up = false
var is_moving_down = false

signal drop_request(node: Node)
signal take_request()


func _physics_process(delta: float) -> void:
	# Process movement
	var velo = get_velo()
	velocity = velo
	move_and_slide()
	
	# Update moving flags
	is_moving_right = velo.x > 0
	is_moving_left = velo.x < 0
	is_moving_down = velo.y > 0
	is_moving_up = velo.y < 0
	
	
	# Process action
	if Input.is_action_just_pressed("action"):
		action()


func get_velo() -> Vector2:
	var velo = Vector2.ZERO
	if Input.is_action_pressed("move-right"):
		velo.x += 1
	if Input.is_action_pressed("move-left"):
		velo.x -= 1
	if Input.is_action_pressed("move-up"):
		velo.y -= 1
	if Input.is_action_pressed("move-down"):
		velo.y += 1
	
	if velo.length() != 0:
		velo = velo.normalized() * speed
	
	return velo


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


func get_size() -> Vector2:
	return $CollisionShape2D.shape.size
