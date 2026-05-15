class_name Tableau
extends Node2D

signal player_exit(direction: String)


func _ready():
	$LeftBorder.body_entered.connect(func(body):
		if body.is_in_group("player"):
			player_exit.emit("left"))
	$RightBorder.body_entered.connect(func(body):
		if body.is_in_group("player"):
			player_exit.emit("right"))
	$DownBorder.body_entered.connect(func(body):
		if body.is_in_group("player"):
			player_exit.emit("down"))
	$UpBorder.body_entered.connect(func(body):
		if body.is_in_group("player"):
			player_exit.emit("up"))


func drop_object(node: Node2D, position: Vector2) -> void:
	add_child(node)
	node.position = position

func take_object(node: Node2D) -> void:
	remove_child(node)
