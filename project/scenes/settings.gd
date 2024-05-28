class_name SettingsScene
extends Control

signal close_requested

@onready var _volume_master := $ScrollContainer/VBoxContainer/Audio/VBoxContainer/MasterVolume/HSlider as HSlider
@onready var _volume_music := $ScrollContainer/VBoxContainer/Audio/VBoxContainer/MusicVolume/HSlider as HSlider
@onready var _volume_sounds := $ScrollContainer/VBoxContainer/Audio/VBoxContainer/SoundsVolume/HSlider as HSlider
@onready var _volume_ui := $ScrollContainer/VBoxContainer/Audio/VBoxContainer/UIVolume/HSlider as HSlider
@onready var _access_qte := $ScrollContainer/VBoxContainer/Accessibility/VBoxContainer/QTE/OptionButton as OptionButton
@onready var _tutorials := $ScrollContainer/VBoxContainer/Accessibility/VBoxContainer/Tutorials/CheckButton as CheckButton
@onready var _type_speed := $ScrollContainer/VBoxContainer/Accessibility/VBoxContainer/TextSpeed/VBoxContainer/HSlider as HSlider
@onready var _return_button := $Return as Button
@onready var _type_animation := $ScrollContainer/VBoxContainer/Accessibility/VBoxContainer/TextSpeed/AnimationPlayer as AnimationPlayer
@onready var _sfx_confirm := $UISoundConfirm as AudioStreamPlayer
@onready var _sfx_cursor := $UISoundCursor as AudioStreamPlayer


func _ready() -> void:
	_reset()
	
	_return_button.pressed.connect(func(): 
		_sfx_confirm.play()
		close_requested.emit())
	
	_volume_master.value_changed.connect(func(value: float):
		SettingsManager.settings.volume_master = value
		SettingsManager.settings.emit_changed())
	_volume_music.value_changed.connect(func(value: float):
		SettingsManager.settings.volume_music = value
		SettingsManager.settings.emit_changed())
	_volume_sounds.value_changed.connect(func(value: float):
		SettingsManager.settings.volume_sounds = value
		SettingsManager.settings.emit_changed())
	_volume_ui.value_changed.connect(func(value: float):
		SettingsManager.settings.volume_ui = value
		SettingsManager.settings.emit_changed())
	_access_qte.item_selected.connect(func(index: int):
		SettingsManager.settings.accessibility_qte = index as Settings.QuickTimeEventOptions
		SettingsManager.settings.emit_changed())
	_type_speed.value_changed.connect(func(value: float):
		SettingsManager.settings.type_speed = value
		SettingsManager.settings.emit_changed())
	_tutorials.toggled.connect(func(value: bool):
		SettingsManager.settings.show_tutorials = value
		SettingsManager.settings.emit_changed())
	
	_volume_master.grab_focus()
	_sfx_cursor.stop()


func take_focus() -> void:
	_volume_master.grab_focus()
	_sfx_cursor.stop()


func _reset() -> void:
	_volume_master.value = SettingsManager.settings.volume_master
	_volume_music.value = SettingsManager.settings.volume_music
	_volume_sounds.value = SettingsManager.settings.volume_sounds
	_volume_ui.value = SettingsManager.settings.volume_ui
	_access_qte.selected = int(SettingsManager.settings.accessibility_qte)
	_type_speed.value = SettingsManager.settings.type_speed
	_type_animation.speed_scale = _type_speed.value
	_tutorials.button_pressed = SettingsManager.settings.show_tutorials


func _test_typing(on: bool) -> void:
	if on:
		_type_animation.play(&"type")
	else:
		_type_animation.stop()


func _cursor_moved() -> void:
	_sfx_cursor.play()
