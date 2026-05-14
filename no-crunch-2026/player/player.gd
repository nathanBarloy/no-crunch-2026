extends Node2D

@export var speed = 400  # (pixel/s)


func _process(delta: float) -> void:
	var frame_speed = get_frame_speed(delta)
	self.position += frame_speed


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
