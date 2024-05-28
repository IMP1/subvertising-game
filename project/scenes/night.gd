extends Node2D

const MISCHIEF_LAYER := 8
const CAMERA_SIZE := Vector2(256, 256)
const MUSIC_BUS := 1
const LOW_PASS_FILTER := 0

@export var background_music: AudioStream
@export var time_scale: float = 1.0:
	set = _set_time_scale
@export var night_length: float = 120 # seconds

var _subvertising_count: int = 0

@onready var _timer := $Timer as Timer
@onready var _player := $Player as Player
@onready var _time_progress := $HUD/Control/Time/ProgressBar as ProgressBar
@onready var _subvertising_progress := $HUD/Control/SubvertisingCount/Label as Label
@onready var _subvertising_progress_particles := $HUD/Control/SubvertisingCount/Label/GPUParticles2D as GPUParticles2D
@onready var _subvertising_qte := $Menus/SubvertisingEvent as SubvertisingEvent
@onready var _artwork_count_hud := $HUD/Control/ArtworkCount as Control
@onready var _artwork_count := $HUD/Control/ArtworkCount/Count as Label
@onready var _artwork_count_buzzer := $HUD/Control/ArtworkCount/Buzzer as AudioStreamPlayer
@onready var _menu := $Menus/Menu as Control
@onready var _menu_item := $Menus/Menu/Menu/PanelContainer/VBoxContainer/Resume as Button
@onready var _menu_audio_cursor := $Menus/Menu/Menu/Cursor as AudioStreamPlayer
@onready var _menu_audio_accept := $Menus/Menu/Menu/Accept as AudioStreamPlayer
@onready var _settings := $Menus/Settings as SettingsScene
@onready var _map := $World as Node2D
@onready var _bike := $World/Decor/Bike as Bike


func _set_time_scale(value: float) -> void:
	time_scale = value
	get_tree().set_group(NPC.GROUP_NAME, "time_scale", value)


func _ready() -> void:
	_player.can_move = false
	if background_music:
		MusicManager.blend_to(background_music)
	_subvertising_qte.visible = false
	_menu.visible = false
	_timer.wait_time = night_length
	_timer.start()
	_time_progress.max_value = night_length
	_time_progress.value = 0
	_subvertising_progress.text = str(0)
	_artwork_count.text = str(ProgressManager.progress.artwork.size())
	_setup_ads()
	_timer.paused = true
	await SceneTransition.transition_completed
	if ProgressManager.progress.day == 1:
		Tutorials.queue_tutorial(^"Night", true, true)
		await Tutorials.finished
	_player.can_move = true
	_timer.paused = false


func _setup_ads() -> void:
	for node in get_tree().get_nodes_in_group(Advert.GROUP_NAME):
		var ad := node as Advert
		ad.subvertising_started.connect(_start_subvertising.bind(ad))
		ad.subvertising_viewed.connect(_view_subvertising.bind(ad))
		ad.subvertising_lacking_art.connect(_indicate_artwork_count)
		# TODO: Set path based on day and progress
		ad.unlock_path = load("res://resources/qte_curve_zig.tres")
		# TODO: Set ads based on which day it is, and other progress variables


func _unhandled_input(event: InputEvent) -> void:
	if _settings.visible:
		return
	if event.is_action_pressed(&"toggle_menu"):
		if _menu.visible:
			_hide_menu()
		else:
			_show_menu()


func _show_menu() -> void:
	_menu.visible = true
	get_tree().paused = _menu.visible
	AudioServer.set_bus_effect_enabled(MUSIC_BUS, LOW_PASS_FILTER, _menu.visible)
	_menu_item.grab_focus()
	_menu_audio_cursor.stop()


func _hide_menu() -> void:
	_menu.visible = false
	get_tree().paused = _menu.visible
	AudioServer.set_bus_effect_enabled(MUSIC_BUS, LOW_PASS_FILTER, _menu.visible)


func _menu_cursor_moved() -> void:
	_menu_audio_cursor.play()


func _resume() -> void:
	_menu_audio_accept.play()
	_hide_menu()


func _show_settings() -> void:
	_menu_audio_accept.play()
	_menu.visible = false
	_settings.visible = true
	_settings.take_focus()
	await _settings.close_requested
	_settings.visible = false
	_menu.visible = true


func _cycle_home() -> void:
	_bike.bell.play()
	await get_tree().create_timer(1.0).timeout
	ProgressManager.progress.night_time = false
	ProgressManager.progress.day += 1
	SceneTransition.transition_to_file("res://scenes/day.tscn", &"fade_black")


func _end_night() -> void:
	_menu_audio_accept.play()
	_hide_menu()
	ProgressManager.progress.night_time = false
	ProgressManager.progress.day += 1
	SceneTransition.transition_to_file("res://scenes/day.tscn", &"fade_black")


func _quit() -> void:
	_menu_audio_accept.play()
	_hide_menu()
	SceneTransition.transition_to_file("res://scenes/title.tscn", &"fade_black")


func _process(_delta: float) -> void:
	if get_tree().paused:
		return
	_time_progress.value = _timer.wait_time - _timer.time_left
	var time_ratio := (_timer.wait_time - _timer.time_left) / _timer.wait_time
	_map.modulate = lerp(Color("dbc7b5"), Color("614d7a"), time_ratio)


func _start_subvertising(advert: Advert) -> void:
	_set_time_scale(0.5)
	advert._player_exit_area(_player)
	_player.can_move = false
	_player.collision_layer += MISCHIEF_LAYER
	_player.focus_camera_on(advert.global_position, 1.6)
	_subvertising_qte.advert_texture = advert.texture
	_subvertising_qte.path = advert.unlock_path
	_subvertising_qte.setup()
	_subvertising_qte.visible = true
	AudioServer.set_bus_effect_enabled(MUSIC_BUS, LOW_PASS_FILTER, true)
	
	if SettingsManager.settings.show_tutorials and ProgressManager.progress.subverted_advert_count == 0:
		Tutorials.queue_tutorial(^"Subverting", true, true)
		await Tutorials.finished
	
	var success := await _subvertising_qte.finished as bool
	_finish_subvertising(advert, success)


func _finish_subvertising(advert: Advert, success: bool) -> void:
	AudioServer.set_bus_effect_enabled(MUSIC_BUS, LOW_PASS_FILTER, false)
	_subvertising_qte.visible = false
	advert._player_enter_area(_player)
	_player.can_move = true
	_player.collision_layer -= MISCHIEF_LAYER
	_player.focus_camera_on(_player.global_position, 1)
	_set_time_scale(1.0)
	if not success:
		return
	# TODO: Show option for choosing artwork
	var art := ProgressManager.progress.artwork.pop_back() as Texture2D
	advert.texture = art
	advert.subverted = true
	_subvertising_count += 1
	_subvertising_progress.text = str(_subvertising_count)
	_subvertising_progress_particles.emitting = true
	ProgressManager.progress.subverted_advert_count += 1
	_artwork_count.text = str(ProgressManager.progress.artwork.size())


func _view_subvertising(advert: Advert) -> void:
	# TODO: Show the thing :)
	print("Already subverted :)")
	pass


func _indicate_artwork_count(colour: Color = Color.CRIMSON) -> void:
	_artwork_count_buzzer.play()
	var old_colour := _artwork_count_hud.modulate
	_artwork_count_hud.modulate = colour
	_artwork_count_hud.scale = Vector2(2, 2)
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT_IN)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(_artwork_count_hud, "scale", Vector2.ONE, 1.0)
	await tween.finished
	_artwork_count_hud.modulate = old_colour
