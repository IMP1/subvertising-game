extends Node

const PROGRESS_FILEPATH := "user://game-progress.tres"

var progress: Progress = null


func _ready() -> void:
	load_from_file()


func reset() -> void:
	progress = Progress.new()


func load_from_file() -> void:
	if not file_exists():
		return
	progress = ResourceLoader.load(PROGRESS_FILEPATH) as Progress


func save_to_file() -> void:
	if progress:
		ResourceSaver.save(progress, PROGRESS_FILEPATH)


func file_exists() -> bool:
	return ResourceLoader.exists(PROGRESS_FILEPATH)


func _notification(what: int):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_to_file()
