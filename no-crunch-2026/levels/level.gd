extends Node2D

@export var offset_on_transition = 30

@onready var camera: Camera2D = $Camera2D
var camera_on_transition = false

func _ready():
	for tableau in $TableauList.get_children():
		var t := tableau as Tableau
		if t:
			t.player_exit.connect(_transition_tableau)
	EventBus.drop_request.connect(_on_player_drop_request)
	EventBus.take_request.connect(_on_player_take_request)
	EventBus.victory.connect(_on_victory)


func _transition_tableau(direction: String):
	if camera_on_transition:
		return
	
	var camera_cible = camera.position
	var player_cible = $Player.position
	if direction == "right":
		if not $Player.is_moving_right:
			return
		camera_cible.x += 1920  # largeur d'un tableau
		player_cible.x += $Player.get_size().x + offset_on_transition
	elif direction == "left":
		if not $Player.is_moving_left:
			return
		camera_cible.x -= 1920
		player_cible.x -= $Player.get_size().x + offset_on_transition
	elif direction == "down":
		if not $Player.is_moving_down:
			return
		camera_cible.y += 1080
		player_cible.y += $Player.get_size().y + offset_on_transition
	elif direction == "up":
		if not $Player.is_moving_up:
			return
		camera_cible.y -= 1080
		player_cible.y -= $Player.get_size().y + offset_on_transition
	
	camera_on_transition = true
	# Bloque le joueur pendant la transition
	$Player.set_physics_process(false)

	var tween = create_tween().set_parallel(true)
	tween.tween_property(camera, "position", camera_cible, 0.5)\
		 .set_trans(Tween.TRANS_SINE)\
		 .set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($Player, "position", player_cible, 0.5)\
		 .set_trans(Tween.TRANS_SINE)\
		 .set_ease(Tween.EASE_IN_OUT)
	
	await tween.finished
	$Player.set_physics_process(true)
	camera_on_transition = false

func _get_tableau_from_position(pos: Vector2) -> Tableau:
	for tableau in $TableauList.get_children():
		var t := tableau as Tableau
		if t:
			var relativ_pos = pos - t.position
			if (0 <= relativ_pos.x and relativ_pos.x < 1920) and (0 <= relativ_pos.y and relativ_pos.y < 1080):
				return t
	return

func _get_current_tableau() -> Tableau:
	return _get_tableau_from_position($Player.position)

func _get_neighbour_tableau(direction: String) -> Tableau:
	var target_pos = $Player.position
	if direction == "right":
		target_pos.x += 1920
	elif direction == "left":
		target_pos.x -= 1920
	elif direction == "down":
		target_pos.y -= 1080
	elif direction == "up":
		target_pos.y += 1080
	else:
		return
	return _get_tableau_from_position(target_pos)

func _on_player_drop_request(node: Node2D) -> void:
	var tableau = _get_current_tableau()
	if tableau:
		tableau.drop_object(node, $Player.position + node.position - tableau.position)


func _on_player_take_request(node: Node2D) -> void:
	var tableau = _get_current_tableau()
	if tableau:
		tableau.take_object(node)
		$Player.take(node)


func _get_max_dimensions() -> Array[Vector2]:
	# On suppose que (0,0) est dans les tableaux
	var max_x = 0
	var max_y = 0
	var min_x = 0
	var min_y = 0
	for tableau in $TableauList.get_children():
		var t := tableau as Tableau
		if t:
			min_x = min(t.position.x, min_x)
			min_y = min(t.position.y, min_y)
			max_x = max(t.position.x+1920, max_x)
			max_y = max(t.position.y+1080, max_y)
	return [Vector2(min_x, min_y), Vector2(max_x, max_y)]


func dezoom():
	# Get zoom target values
	var corners = _get_max_dimensions()
	var min_corner = corners[0]
	var max_corner = corners[1]
	var camera_target = (min_corner+max_corner) / 2
	var zoom_target = max((max_corner.x - min_corner.x)/1920,
						(max_corner.y - min_corner.y)/1080)
	camera_target -= Vector2(1900, 1080) * zoom_target / 2
	zoom_target = 1/zoom_target
	zoom_target = Vector2(zoom_target, zoom_target)
	
	# Zoom with tween
	var tween = create_tween().set_parallel(true)
	tween.tween_property(camera, "position", camera_target, 0.8)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(camera, "zoom", zoom_target, 0.8)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished


func _on_victory():
	set_physics_process(false)
	$VictoryTimer.start()
	dezoom()

func _on_victory_timer_timeout() -> void:
	GameManager.load_next_level()
