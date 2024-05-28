extends Control

const SETTINGS_SCENE := preload("res://scenes/settings.tscn")
const NORMAL_STYLEBOX := preload("res://resources/style_button_collection_normal.tres")
const PRESSED_STYLEBOX := preload("res://resources/style_button_collection_pressed.tres")

var _current_artwork_container: Node
var _current_artwork_index: int
var _collection_button_group: ButtonGroup

@onready var _day_counter := $DayNumber/Panel/DayNumber as Label
@onready var _locations := $Location/Tabs as TabContainer
@onready var _collection := $Collection/VBoxContainer/ScrollContainer/MarginContainer/HBoxContainer as Control
@onready var _art_view := $ArtworkViewer as Control
@onready var _art_panel := $ArtworkViewer/PanelContainer/TextureRect as TextureRect
@onready var _art_prev := $ArtworkViewer/Navigation/Previous as Button
@onready var _art_next := $ArtworkViewer/Navigation/Next as Button
@onready var _art_add := $ArtworkViewer/Actions/AddToCollection as Button
@onready var _sfx_cursor := $Sounds/CursorMove as AudioStreamPlayer
@onready var _sfx_confirm := $Sounds/Confirm as AudioStreamPlayer
@onready var _settings_button := $Actions/Settings as Button


func _ready() -> void:
	_day_counter.text = str(ProgressManager.progress.day)
	_hide_art()
	_sfx_confirm.stop()
	await SceneTransition.transition_completed
	if SettingsManager.settings.show_tutorials and ProgressManager.progress.day == 1:
		Tutorials.queue_tutorial(^"Intro", true, false)
		Tutorials.queue_tutorial(^"Day", true, false)
	_setup_day()


func _go_to_location(index: int) -> void:
	_locations.current_tab = index


func _setup_day() -> void:
	for child in _collection.get_children():
		_collection.remove_child(child)
		child.queue_free()
	_collection_button_group = ButtonGroup.new()
	for i in ProgressManager.progress.artwork.size():
		var art := ProgressManager.progress.artwork[i]
		var button := Button.new()
		button.button_group = _collection_button_group
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		button.toggle_mode = true
		button.icon = art
		button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.expand_icon = true
		button.custom_minimum_size = Vector2(100, 150)
		button.add_theme_stylebox_override(&"normal", NORMAL_STYLEBOX)
		button.add_theme_stylebox_override(&"pressed", PRESSED_STYLEBOX)
		button.pressed.connect(_show_art.bind(_collection, i, false))
		_collection.add_child(button)
	
	# TODO: Make some locations only available on certain days
	# TODO: Add more new adverts to each location every day
	# QUESTION: Don't add artwork player already has taken?
	for location in _locations.get_children():
		var location_button_group := ButtonGroup.new()
		var artwork := location.get_node("Artwork") as Control
		for i in artwork.get_child_count():
			var button := artwork.get_child(i) as Button
			button.button_group = location_button_group
			button.toggle_mode = true
			button.pressed.connect(_show_art.bind(artwork, i, true))


func _end_day() -> void:
	ProgressManager.progress.night_time = true
	SceneTransition.transition_to_file("res://scenes/night.tscn")


func _show_art(container: Node, index: int, allow_adding: bool) -> void:
	_art_view.visible = true
	_current_artwork_container = container
	_current_artwork_index = index
	_art_add.visible = allow_adding
	_update_current_art()


func _hide_art() -> void:
	_sfx_confirm.play()
	_art_view.visible = false


func _update_current_art() -> void:
	var current_artwork := _current_artwork_container.get_child(_current_artwork_index) as Button
	print(current_artwork.name)
	current_artwork.button_pressed = true
	_art_panel.texture = current_artwork.icon
	_art_prev.disabled = (_current_artwork_index == 0)
	_art_next.disabled = (_current_artwork_index == _current_artwork_container.get_child_count() - 1)


func _prev_art() -> void:
	_sfx_cursor.play()
	_current_artwork_index -= 1
	_update_current_art()


func _next_art() -> void:
	_sfx_cursor.play()
	_current_artwork_index += 1
	_update_current_art()


func _cursor_moved() -> void:
	_sfx_cursor.play()


func _add_art_to_collection() -> void:
	var current_artwork := _current_artwork_container.get_child(_current_artwork_index) as Button
	var texture := current_artwork.icon
	ProgressManager.progress.artwork.append(texture)
	var new_id := _collection.get_child_count()
	var button := Button.new()
	button.button_group = _collection_button_group
	button.icon = texture
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.expand_icon = true
	button.custom_minimum_size = Vector2(100, 150)
	button.add_theme_stylebox_override(&"normal", NORMAL_STYLEBOX)
	button.add_theme_stylebox_override(&"pressed", PRESSED_STYLEBOX)
	button.pressed.connect(_show_art.bind(_collection, new_id, false))
	_collection.add_child(button)
	current_artwork.queue_free()
	_hide_art()


func _quit_to_title() -> void:
	SceneTransition.transition_to_file("res://scenes/title.tscn", &"fade_black")


func _open_settings() -> void:
	_sfx_confirm.play()
	var settings := SETTINGS_SCENE.instantiate() as SettingsScene
	SceneTransition.push_scene(settings)
	await settings.close_requested
	SceneTransition.pop_scene()
	_settings_button.grab_focus()
	_sfx_cursor.stop()
