extends Control


func _ready() -> void:
	await SceneTransition.transition_completed
	if SettingsManager.settings.show_tutorials and ProgressManager.progress.day == 1:
		Tutorials.queue_tutorial(^"Intro", true, false)
		Tutorials.queue_tutorial(^"Day", true, false)


func _end_day() -> void:
	ProgressManager.progress.night_time = true
	SceneTransition.transition_to_file("res://scenes/night.tscn")
