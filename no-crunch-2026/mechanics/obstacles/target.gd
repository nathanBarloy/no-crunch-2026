class_name Target
extends Area2D

var already_won: bool = false

func _ready() -> void:
	EventBus.victory.connect(_animate_victory)

func _animate_victory():
	if not already_won:
		already_won = true
		$Sprite2D.play()
		$CrackingCrystal.volume_db = -7
		$CrackingCrystal.play()
