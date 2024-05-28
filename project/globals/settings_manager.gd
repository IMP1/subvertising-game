extends Node

const BUS_MASTER := 0
const BUS_MUSIC := 1
const BUS_SOUNDS := 2
const BUS_UI := 3

const SETTINGS_FILEPATH := "user://usersettings.tres"

var settings: Settings = Settings.new()


func _ready() -> void:
	load_from_file()


func load_from_file() -> void:
	if not _file_exists():
		settings.changed.connect(_apply_settings)
		return
	if settings.changed.is_connected(_apply_settings):
		settings.changed.disconnect(_apply_settings)
	settings = ResourceLoader.load(SETTINGS_FILEPATH) as Settings
	settings.changed.connect(_apply_settings)
	_apply_settings()


func save_to_file() -> void:
	ResourceSaver.save(settings, SETTINGS_FILEPATH)


func _file_exists() -> bool:
	return ResourceLoader.exists(SETTINGS_FILEPATH)


func _notification(what: int):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_to_file()


func _apply_settings() -> void:
	AudioServer.set_bus_volume_db(BUS_MASTER, linear_to_db(settings.volume_master / 100))
	AudioServer.set_bus_volume_db(BUS_MUSIC, linear_to_db(settings.volume_music / 100))
	AudioServer.set_bus_volume_db(BUS_SOUNDS, linear_to_db(settings.volume_sounds / 100))
	AudioServer.set_bus_volume_db(BUS_UI, linear_to_db(settings.volume_ui / 100))
