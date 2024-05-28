extends Control

const SETTINGS_SCENE := preload("res://scenes/settings.tscn")

@export var background_music: AudioStream

var _play_ui_sounds: bool = false

@onready var _continue_button := $VBoxContainer/VBoxContainer/Continue as Button
@onready var _new_game_button := $VBoxContainer/VBoxContainer/NewGame as Button
@onready var _settings_button := $VBoxContainer/VBoxContainer/Settings as Button
@onready var _quit_button := $VBoxContainer/VBoxContainer/Quit as Button
@onready var _sfx_confirm := $UISoundConfirm as AudioStreamPlayer
@onready var _sfx_cursor := $UISoundMove as AudioStreamPlayer


func _ready() -> void:
	MusicManager.blend_to(background_music)
	_continue_button.pressed.connect(_continue)
	_new_game_button.pressed.connect(_new_game)
	_settings_button.pressed.connect(_settings)
	_quit_button.pressed.connect(_quit)
	_continue_button.visible = ProgressManager.file_exists()
	if _continue_button.visible:
		_continue_button.grab_focus()
	else:
		_new_game_button.grab_focus()
	_play_ui_sounds = true


func _new_game() -> void:
	_sfx_confirm.play()
	# TODO: Check for confirmation as this will lose all existing progress
	ProgressManager.reset()
	SceneTransition.transition_to_file("res://scenes/intro.tscn")


func _continue() -> void:
	_sfx_confirm.play()
	if ProgressManager.progress.night_time:
		SceneTransition.transition_to_file("res://scenes/night.tscn")
	else:
		SceneTransition.transition_to_file("res://scenes/day.tscn")


func _settings() -> void:
	_sfx_confirm.play()
	var settings := SETTINGS_SCENE.instantiate() as SettingsScene
	SceneTransition.push_scene(settings)
	await settings.close_requested
	SceneTransition.pop_scene()
	_play_ui_sounds = false
	_settings_button.grab_focus()
	_play_ui_sounds = true


func _quit() -> void:
	_sfx_confirm.play()
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()


func _splash_screen() -> void:
	MusicManager.stop()
	get_tree().change_scene_to_file("res://scenes/splash.tscn")


func _cursor_moved() -> void:
	if not _play_ui_sounds:
		return
	_sfx_cursor.play()
