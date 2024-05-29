extends Control

signal _news_hidden

const SETTINGS_SCENE := preload("res://scenes/settings.tscn")
const NORMAL_STYLEBOX := preload("res://resources/style_button_collection_normal.tres")
const PRESSED_STYLEBOX := preload("res://resources/style_button_collection_pressed.tres")

var _current_artwork_container: Node
var _current_artwork_index: int
var _collection_button_group: ButtonGroup

@onready var _day_counter := $DayNumber/Panel/DayNumber as Label
@onready var _locations := $Location/Tabs as TabContainer
@onready var _location_navigation := $LocationList/VBoxContainer/List as Control
@onready var _collection := $Collection/VBoxContainer/ScrollContainer/MarginContainer/HBoxContainer as Control
@onready var _art_view := $ArtworkViewer as Control
@onready var _art_panel := $ArtworkViewer/PanelContainer/TextureRect as TextureRect
@onready var _art_prev := $ArtworkViewer/Navigation/Previous as Button
@onready var _art_next := $ArtworkViewer/Navigation/Next as Button
@onready var _art_add := $ArtworkViewer/Actions/AddToCollection as Button
@onready var _sfx_cursor := $Sounds/CursorMove as AudioStreamPlayer
@onready var _sfx_confirm := $Sounds/Confirm as AudioStreamPlayer
@onready var _settings_button := $Actions/Settings as Button
@onready var _newspaper_modal := $Modal as Control
@onready var _newspaper := $Modal/Newspaper as Control
@onready var _newspaper_header := $Modal/Newspaper/Contents/Headline as Label
@onready var _newspaper_photo := $Modal/Newspaper/Contents/HBoxContainer/Image/TextureRect as TextureRect
@onready var _newspaper_subheader := $Modal/Newspaper/Contents/Subheading as Label
@onready var _start_night_button := $Actions/StartNight as Button

func _ready() -> void:
	_newspaper_modal.visible = false
	_day_counter.text = str(ProgressManager.progress.day)
	_hide_art()
	_sfx_confirm.stop()
	if SettingsManager.settings.show_tutorials and ProgressManager.progress.day == 1:
		Tutorials.queue_tutorial(^"Intro", true, false)
		Tutorials.queue_tutorial(^"Day", true, false)
	_setup_day()
	await SceneTransition.transition_completed


func _go_to_location(index: int) -> void:
	_locations.current_tab = index


func _setup_day() -> void:
	for child in _collection.get_children():
		_collection.remove_child(child)
		child.queue_free()
	_collection_button_group = ButtonGroup.new()
	for art in ProgressManager.progress.artwork:
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
		button.pressed.connect(_show_art.bind(_collection, button, false))
		_collection.add_child(button)
	_setup_possible_adverts()
	_show_todays_news()
	_start_night_button.disabled = (ProgressManager.progress.artwork.size() == 0)


func _setup_possible_adverts() -> void:
	var day := ProgressManager.progress.day
	print(day)
	
	if day == 1 and ProgressManager.progress.ad_production_day == 1:
		ProgressManager.progress.available_artworks_home.append_array(ProgressManager.progress.HOME_ARTWORK_DAY_1)
		ProgressManager.progress.available_artworks_housing_coop.append_array(ProgressManager.progress.HOUSING_COOP_ARTWORK_DAY_1)
		ProgressManager.progress.available_artworks_printers.append_array(ProgressManager.progress.PRINTERS_ARTWORK_DAY_1)
		ProgressManager.progress.available_artworks_art_studio.append_array(ProgressManager.progress.ART_STUDIO_ARTWORK_DAY_1)
		ProgressManager.progress.available_artworks_bookshop.append_array(ProgressManager.progress.BOOKSHOP_ARTWORK_DAY_1)
	if day == 2 and ProgressManager.progress.ad_production_day == 2:
		ProgressManager.progress.available_artworks_home.append_array(ProgressManager.progress.HOME_ARTWORK_DAY_2)
		ProgressManager.progress.available_artworks_housing_coop.append_array(ProgressManager.progress.HOUSING_COOP_ARTWORK_DAY_2)
		ProgressManager.progress.available_artworks_printers.append_array(ProgressManager.progress.PRINTERS_ARTWORK_DAY_2)
		ProgressManager.progress.available_artworks_art_studio.append_array(ProgressManager.progress.ART_STUDIO_ARTWORK_DAY_2)
		ProgressManager.progress.available_artworks_bookshop.append_array(ProgressManager.progress.BOOKSHOP_ARTWORK_DAY_2)
	if day == 3 and ProgressManager.progress.ad_production_day == 3:
		ProgressManager.progress.available_artworks_home.append_array(ProgressManager.progress.HOME_ARTWORK_DAY_3)
		ProgressManager.progress.available_artworks_housing_coop.append_array(ProgressManager.progress.HOUSING_COOP_ARTWORK_DAY_3)
		ProgressManager.progress.available_artworks_printers.append_array(ProgressManager.progress.PRINTERS_ARTWORK_DAY_3)
		ProgressManager.progress.available_artworks_art_studio.append_array(ProgressManager.progress.ART_STUDIO_ARTWORK_DAY_3)
		ProgressManager.progress.available_artworks_bookshop.append_array(ProgressManager.progress.BOOKSHOP_ARTWORK_DAY_3)
	if day == 4 and ProgressManager.progress.ad_production_day == 4:
		ProgressManager.progress.available_artworks_home.append_array(ProgressManager.progress.HOME_ARTWORK_DAY_4)
		ProgressManager.progress.available_artworks_housing_coop.append_array(ProgressManager.progress.HOUSING_COOP_ARTWORK_DAY_4)
		ProgressManager.progress.available_artworks_printers.append_array(ProgressManager.progress.PRINTERS_ARTWORK_DAY_4)
		ProgressManager.progress.available_artworks_art_studio.append_array(ProgressManager.progress.ART_STUDIO_ARTWORK_DAY_4)
		ProgressManager.progress.available_artworks_bookshop.append_array(ProgressManager.progress.BOOKSHOP_ARTWORK_DAY_4)
	if day == 5 and ProgressManager.progress.ad_production_day == 5:
		ProgressManager.progress.available_artworks_home.append_array(ProgressManager.progress.HOME_ARTWORK_DAY_5)
		ProgressManager.progress.available_artworks_housing_coop.append_array(ProgressManager.progress.HOUSING_COOP_ARTWORK_DAY_5)
		ProgressManager.progress.available_artworks_printers.append_array(ProgressManager.progress.PRINTERS_ARTWORK_DAY_5)
		ProgressManager.progress.available_artworks_art_studio.append_array(ProgressManager.progress.ART_STUDIO_ARTWORK_DAY_5)
		ProgressManager.progress.available_artworks_bookshop.append_array(ProgressManager.progress.BOOKSHOP_ARTWORK_DAY_5)
	if day == 6 and ProgressManager.progress.ad_production_day == 6:
		ProgressManager.progress.available_artworks_home.append_array(ProgressManager.progress.HOME_ARTWORK_DAY_6)
		ProgressManager.progress.available_artworks_housing_coop.append_array(ProgressManager.progress.HOUSING_COOP_ARTWORK_DAY_6)
		ProgressManager.progress.available_artworks_printers.append_array(ProgressManager.progress.PRINTERS_ARTWORK_DAY_6)
		ProgressManager.progress.available_artworks_art_studio.append_array(ProgressManager.progress.ART_STUDIO_ARTWORK_DAY_6)
		ProgressManager.progress.available_artworks_bookshop.append_array(ProgressManager.progress.BOOKSHOP_ARTWORK_DAY_6)
	if day == 7 and ProgressManager.progress.ad_production_day == 7:
		ProgressManager.progress.available_artworks_home.append_array(ProgressManager.progress.HOME_ARTWORK_DAY_7)
		ProgressManager.progress.available_artworks_housing_coop.append_array(ProgressManager.progress.HOUSING_COOP_ARTWORK_DAY_7)
		ProgressManager.progress.available_artworks_printers.append_array(ProgressManager.progress.PRINTERS_ARTWORK_DAY_7)
		ProgressManager.progress.available_artworks_art_studio.append_array(ProgressManager.progress.ART_STUDIO_ARTWORK_DAY_7)
		ProgressManager.progress.available_artworks_bookshop.append_array(ProgressManager.progress.BOOKSHOP_ARTWORK_DAY_7)
	
	if day == ProgressManager.progress.ad_production_day:
		ProgressManager.progress.ad_production_day += 1
	# TODO: Make some locations only available on certain days
	# TODO: Add more new adverts to each location every day
	for location in _locations.get_children():
		var location_button_group := ButtonGroup.new()
		var artwork_container := location.get_node("Artwork") as Control
		for child in artwork_container.get_children():
			artwork_container.remove_child(child)
			child.queue_free()
		var location_artwork: Array[Texture2D]
		match location.name:
			"Anarres":
				location_artwork = ProgressManager.progress.available_artworks_housing_coop
			"Footprint":
				location_artwork = ProgressManager.progress.available_artworks_printers
			"Serf":
				location_artwork = ProgressManager.progress.available_artworks_art_studio
			"Housmans":
				location_artwork = ProgressManager.progress.available_artworks_bookshop
			"TAZ":
				location_artwork = ProgressManager.progress.available_artworks_home
		for art in location_artwork:
			var button := Button.new()
			button.button_group = location_button_group
			button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			button.toggle_mode = true
			button.icon = art
			button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
			button.expand_icon = true
			button.custom_minimum_size = Vector2(100, 150)
			button.add_theme_stylebox_override(&"normal", NORMAL_STYLEBOX)
			button.add_theme_stylebox_override(&"pressed", PRESSED_STYLEBOX)
			button.pressed.connect(_show_art.bind(artwork_container, button, true))
			artwork_container.add_child(button)
	
	for location in _location_navigation.get_children():
		var location_accessible: bool
		match location.name:
			"Home":
				location_accessible = true # everyday
			"HousingCoop":
				location_accessible = ((day-1) % 3 != 1) # 2 days in 3
			"Printers":
				location_accessible = ((day-1) % 3 != 0) # 2 days in 3
			"ArtStudio":
				location_accessible = ((day-1) % 2 == 0) # every other day
			"Bookshop":
				location_accessible = ((day-1) % 3 == 1) # 1 day in 3
		location.visible = location_accessible
	for location in _location_navigation.get_children():
		if location.visible:
			location.grab_focus()
			location.button_pressed = true
			location.pressed.emit()
			break
	_sfx_cursor.stop()


func _end_day() -> void:
	ProgressManager.progress.night_time = true
	SceneTransition.transition_to_file("res://scenes/night.tscn")


func _show_art(container: Node, button: Button, allow_adding: bool) -> void:
	_art_view.visible = true
	_current_artwork_container = container
	_current_artwork_index = button.get_index()
	_art_add.visible = allow_adding
	_update_current_art()


func _hide_art() -> void:
	_sfx_confirm.play()
	_art_view.visible = false


func _update_current_art() -> void:
	var current_artwork := _current_artwork_container.get_child(_current_artwork_index) as Button
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
	var location_name := _current_artwork_container.get_parent().name
	var current_artwork := _current_artwork_container.get_child(_current_artwork_index) as Button
	var texture := current_artwork.icon
	
	var list: Array[Texture2D]
	var index: int
	match location_name:
		"Anarres":
			list = ProgressManager.progress.available_artworks_housing_coop
			index = list.find(texture)
		"Footprint":
			list = ProgressManager.progress.available_artworks_printers
			index = list.find(texture)
		"Serf":
			list = ProgressManager.progress.available_artworks_art_studio
			index = list.find(texture)
		"Housmans":
			list = ProgressManager.progress.available_artworks_bookshop
			index = list.find(texture)
		"TAZ":
			list = ProgressManager.progress.available_artworks_home
			index = list.find(texture)
	list.remove_at(index)
	
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
	_start_night_button.disabled = false


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


func _input(event: InputEvent) -> void:
	if _newspaper_modal.visible and event.is_action_pressed(&"interact"):
		_hide_news()


func _show_todays_news() -> void:
	if ProgressManager.progress.get_total_subvertisement_count() > 24 and ProgressManager.progress.newspaper_stage == 3:
		ProgressManager.progress.newspaper_stage += 1
		_show_news(load("res://resources/news_public_space.tres"))
		await _news_hidden
		ProgressManager.reset()
		SceneTransition.transition_to_file("res://scenes/outro.tscn")
	elif ProgressManager.progress.get_total_subvertisement_count() > 18 and ProgressManager.progress.newspaper_stage == 2:
		ProgressManager.progress.newspaper_stage += 1
		_show_news(load("res://resources/news_chaos.tres"))
	elif ProgressManager.progress.get_total_subvertisement_count() > 12 and ProgressManager.progress.newspaper_stage == 1:
		ProgressManager.progress.newspaper_stage += 1
		_show_news(load("res://resources/news_police.tres"))
	elif ProgressManager.progress.get_total_subvertisement_count() > 6 and ProgressManager.progress.newspaper_stage == 0:
		ProgressManager.progress.newspaper_stage += 1
		_show_news(load("res://resources/news_rising.tres"))


func _show_news(news: NewsPage) -> void:
	_newspaper_modal.visible = true
	_newspaper_header.text = news.headline
	_newspaper_subheader.text = news.subheader
	_newspaper_photo.texture = news.photo
	_newspaper.scale = Vector2.ZERO
	_newspaper.rotation = -TAU * 3
	var duration := 1.2
	var tween := create_tween()
	tween.set_parallel()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(_newspaper, "scale", Vector2.ONE, duration).set_delay(0.4)
	tween.tween_property(_newspaper, "rotation", 0, duration).set_delay(0.4)
	await tween.finished


func _hide_news() -> void:
	_newspaper_modal.visible = false
	_news_hidden.emit()
