class_name Target
extends Area2D

func _ready() -> void:
	EventBus.victory.connect(_animate_victory)

func _animate_victory():
	$Sprite2D.play()
