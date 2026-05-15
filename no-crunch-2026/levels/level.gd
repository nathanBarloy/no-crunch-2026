extends Node2D

@export var offset_on_transition = 30

@onready var camera: Camera2D = $Camera2D
var camera_on_transition = false

func _ready():
	for tableau in $TableauList.get_children():
		var t := tableau as Tableau
		if t:
			t.player_exit.connect(_transition_tableau)


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


func _get_current_tableau() -> Tableau:
	for tableau in $TableauList.get_children():
		var t := tableau as Tableau
		if t:
			var relativ_pos = $Player.position - t.position
			if (0 <= relativ_pos.x and relativ_pos.x < 1920) and (0 <= relativ_pos.y and relativ_pos.y < 1080):
				return t
	return


func _on_player_drop_request(node: Node2D) -> void:
	var tableau = _get_current_tableau()
	if tableau:
		tableau.drop_object(node, $Player.position + node.position - tableau.position)


func _on_player_take_request(node: Node2D) -> void:
	var tableau = _get_current_tableau()
	if tableau:
		tableau.take_object(node)
		$Player.take(node)
