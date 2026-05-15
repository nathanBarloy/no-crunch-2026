extends CharacterBody2D

@export var speed = 400  # (pixel/s)
var is_moving_right = false
var is_moving_left = false
var is_moving_up = false
var is_moving_down = false
var objects_in_range: Array[Node2D] = []

signal drop_request(node: Node2D)
signal take_request(node: Node2D)


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


func take(object: Node2D) -> void:
	$Inventory.add_child(object)
	object.position = Vector2.ZERO


func drop() -> void:
	var drop_node = $Inventory.get_child(0)
	$Inventory.remove_child(drop_node)
	drop_request.emit(drop_node)


func action() -> void:
	if can_take():
		if len(objects_in_range) > 0:
			take_request.emit(objects_in_range[0])
	else:
		drop()


func get_size() -> Vector2:
	return $CollisionShape2D.shape.size


func _on_area_entered(area: Area2D):
	if area.is_in_group("pickable"):
		objects_in_range.append(area)

func _on_area_exited(area: Area2D):
	if area.is_in_group("pickable"):
		objects_in_range.erase(area)
