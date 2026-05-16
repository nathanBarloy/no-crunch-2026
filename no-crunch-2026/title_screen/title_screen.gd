extends Node2D

func _ready() -> void:
	GameManager.current_scene = self
	$MoleomMainTitle.play()

func _process(delta: float) -> void:
	pass
		


func _on_button_start_pressed() -> void:
	GameManager.load_level(1)


func _on_button_credits_pressed() -> void:
	GameManager.load_end_scene()
