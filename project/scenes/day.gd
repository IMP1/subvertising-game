extends Control

@onready var _day_counter := $DayNumber/Panel/DayNumber as Label


func _ready() -> void:
	_day_counter.text = str(ProgressManager.progress.day)
	await SceneTransition.transition_completed
	if SettingsManager.settings.show_tutorials and ProgressManager.progress.day == 1:
		Tutorials.queue_tutorial(^"Intro", true, false)
		Tutorials.queue_tutorial(^"Day", true, false)


func _end_day() -> void:
	ProgressManager.progress.night_time = true
	SceneTransition.transition_to_file("res://scenes/night.tscn")
