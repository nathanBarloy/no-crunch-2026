extends Node2D

func _ready() -> void:
	GameManager.current_scene = self
	$MoleomMainTitle.play()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("action"):
		GameManager.load_level(1)
		
