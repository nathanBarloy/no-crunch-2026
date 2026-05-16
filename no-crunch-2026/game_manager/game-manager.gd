extends Node

var current_scene: Node = null
var current_level_number: int = 0

func unload_scene():
	if current_scene:
		current_scene.queue_free()
		current_scene = null

func level_exists(lvl_number: int) -> bool:
	return ResourceLoader.exists("res://levels/%d/level.tscn" % lvl_number)

func load_level(lvl_number: int):
	unload_scene()
	var scene = load("res://levels/%d/level.tscn" % lvl_number).instantiate()
	current_scene = scene
	current_level_number = lvl_number
	get_tree().root.add_child(scene)

func load_next_level():
	if level_exists(current_level_number+1):
		load_level(current_level_number+1)
	else:
		load_end_scene()

func load_end_scene():
	unload_scene()
	var scene = load("res://title_screen/end_screen.tscn").instantiate()
	current_scene = scene
	get_tree().root.add_child(scene)
	
