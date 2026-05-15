class_name Mirror

extends Area2D

@export var is_tilted: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if is_tilted:
		$Straight.visible = false
		$Tilted.visible = true
		$MirrorCollision.rotate(PI/4)
	else:
		$Tilted.visible = false
		$Straight.visible = true
