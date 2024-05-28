extends Node


func _ready() -> void:
	if ProgressManager.file_exists():
		SceneTransition.transition_to_file.call_deferred("res://scenes/title.tscn", "")
	else:
		SceneTransition.transition_to_file.call_deferred("res://scenes/splash.tscn", "")
