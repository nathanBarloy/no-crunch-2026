extends Node2D

var can_exit = false

func _ready() -> void:
	can_exit = false

func _process(delta: float) -> void:
	if can_exit and Input.is_action_just_pressed("action"):
		GameManager.load_title_scene()

func _on_timer_timeout() -> void:
	can_exit = true
