extends Node2D

const EASY_LOCKS: Array[Curve2D] = [
	preload("res://resources/qte_curve_zig.tres"),
]
const MEDIUM_LOCKS: Array[Curve2D] = [
	preload("res://resources/qte_curve_wave.tres"),
	preload("res://resources/qte_curve_split_circle.tres"),
]
const HARD_LOCKS: Array[Curve2D] = [
	preload("res://resources/qte_curve_spiral.tres"),
]
const EXTREME_LOCKS: Array[Curve2D] = [
	preload("res://resources/qte_curve_labyrinth.tres"),
]
const ADVERTS: Array[Texture2D] = [
	preload("res://assets/graphics/adverts/Abraxo.png"),
	preload("res://assets/graphics/adverts/Believer.png"),
	preload("res://assets/graphics/adverts/Big Kahuna.png"),
	preload("res://assets/graphics/adverts/Buy N Large.png"),
	preload("res://assets/graphics/adverts/Cellophane.png"),
	preload("res://assets/graphics/adverts/Dread Cola.png"),
	preload("res://assets/graphics/adverts/Filter Tip.png"),
	preload("res://assets/graphics/adverts/Honour.png"),
	preload("res://assets/graphics/adverts/Krusty Burger.png"),
	preload("res://assets/graphics/adverts/Pommery.png"),
	preload("res://assets/graphics/adverts/Professor.png"),
	preload("res://assets/graphics/adverts/Sugar Bombs.png"),
]

const MISCHIEF_LAYER := 4
const CAMERA_SIZE := Vector2(256, 256)
const MUSIC_BUS := 1
const LOW_PASS_FILTER := 0

@export var background_music: AudioStream
@export var time_scale: float = 1.0:
	set = _set_time_scale
@export var night_length: float = 120 # seconds

var _subvertising_count: int = 0
var _indicating_artwork_count: bool = false

@onready var _timer := $Timer as Timer
@onready var _player := $Player as Player
@onready var _time_progress := $HUD/Control/Time/ProgressBar as ProgressBar
@onready var _subvertising_progress := $HUD/Control/SubvertisingCount/Label as Label
@onready var _subvertising_progress_particles := $HUD/Control/SubvertisingCount/Label/GPUParticles2D as GPUParticles2D
@onready var _subvertising_qte := $Menus/SubvertisingEvent as SubvertisingEvent
@onready var _subvertising_art_choice := $Menus/SubvertisingArtworkPlacement as SubvertisingArtworkPlacement
@onready var _subvertising_art_view := $Menus/ViewArtwork as SubvertisingArtworkViewer
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
@onready var _game_over := $Menus/GameOver as Control
@onready var _game_over_impact := $Menus/GameOver/Impact as AnimatedSprite2D
@onready var _game_over_sfx := $Menus/GameOver/Sound as AudioStreamPlayer
@onready var _game_over_vignette := $Menus/GameOver/Vignette as ColorRect
@onready var _game_over_vignette_shader := _game_over_vignette.material as ShaderMaterial


func _set_time_scale(value: float) -> void:
	time_scale = value
	get_tree().set_group(NPC.GROUP_NAME, "time_scale", value)


func _ready() -> void:
	_player.can_move = false
	if background_music:
		MusicManager.blend_to(background_music)
	_subvertising_qte.visible = false
	_menu.visible = false
	_game_over.visible = false
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
		ad.unlocking_started.connect(_start_subvertising.bind(ad))
		ad.subvertising_viewed.connect(_view_subvertising.bind(ad))
		ad.replacement_started.connect(_start_placing_artwork.bind(ad))
		ad.subvertising_lacking_art.connect(_indicate_artwork_count)
		var past_count := ProgressManager.progress.advert_subverted_count[ad.get_index()]
		if past_count < 2:
			ad.unlock_path = EASY_LOCKS.pick_random() as Curve2D
		elif past_count < 3:
			ad.unlock_path = MEDIUM_LOCKS.pick_random() as Curve2D
		elif past_count < 5:
			ad.unlock_path = HARD_LOCKS.pick_random() as Curve2D
		else:
			ad.unlock_path = EXTREME_LOCKS.pick_random() as Curve2D
		ad.texture = ADVERTS.pick_random() as Texture2D


func _unhandled_input(event: InputEvent) -> void:
	if _settings.visible:
		return
	if event.is_action_pressed(&"toggle_menu"):
		if _menu.visible:
			_hide_menu()
		else:
			_show_menu()
	if event.is_action_pressed(&"toggle_cameras"):
		_knock_out()


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


func _knock_out() -> void:
	_player.can_move = false
	_game_over.visible = true
	_game_over_impact.visible = false
	var screen_pos := _player.get_global_transform_with_canvas().origin
	var uv_pos := (screen_pos - Vector2(0, 30)) / get_viewport().get_visible_rect().size
	_game_over_vignette_shader.set_shader_parameter(&"centre", uv_pos)
	var tween := create_tween()
	tween.tween_method(func(value: float): _game_over_vignette_shader.set_shader_parameter(&"progress", value), 0.0, 1.0, 0.6)
	await tween.finished
	await get_tree().create_timer(0.2).timeout
	_game_over_sfx.play()
	_game_over_impact.modulate = Color.WHITE
	_game_over_impact.position = screen_pos - Vector2(0, 60)
	_game_over_impact.play(&"stars")
	_game_over_impact.visible = true
	await _game_over_impact.animation_finished
	_game_over_impact.visible = false
	await get_tree().create_timer(0.2).timeout
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
	_start_advert_interaction(advert)
	_subvertising_qte.advert_texture = advert.texture
	_subvertising_qte.path = advert.unlock_path
	_subvertising_qte.setup()
	_subvertising_qte.visible = true
	AudioServer.set_bus_effect_enabled(MUSIC_BUS, LOW_PASS_FILTER, true)
	
	if SettingsManager.settings.show_tutorials and ProgressManager.progress.get_total_subvertisement_count() == 0:
		Tutorials.queue_tutorial(^"Subverting", true, true)
		await Tutorials.finished
	
	var success := await _subvertising_qte.finished as bool
	_subvertising_qte.visible = false
	if not success:
		_end_advert_interaction(advert)
		return
	advert.unlocked = true
	if ProgressManager.progress.artwork.is_empty():
		_end_advert_interaction(advert)
		return
	_start_placing_artwork(advert)


func _start_placing_artwork(advert: Advert) -> void:
	_start_advert_interaction(advert)
	var old_ad := advert.texture
	_subvertising_art_choice.old_texture = old_ad
	_subvertising_art_choice.visible = true
	_subvertising_art_choice.setup()
	var success := await _subvertising_art_choice.finished as bool
	_subvertising_art_choice.visible = false
	if not success:
		_end_advert_interaction(advert)
		return
	var new_art := _subvertising_art_choice.artwork
	_subvertising_art_choice.visible = false
	advert.texture = new_art
	advert.subverted = true
	_subvertising_count += 1
	_subvertising_progress.text = str(_subvertising_count)
	_subvertising_progress_particles.emitting = true
	ProgressManager.progress.increase_subvertisement_count(advert.get_index())
	var index := ProgressManager.progress.artwork.find(new_art)
	ProgressManager.progress.artwork.remove_at(index)
	_artwork_count.text = str(ProgressManager.progress.artwork.size())
	_end_advert_interaction(advert)


func _start_advert_interaction(advert: Advert) -> void:
	_set_time_scale(0.5)
	advert._player_exit_area(_player)
	_player.can_move = false
	_player.set_collision_layer_value(MISCHIEF_LAYER, true)
	_player.focus_camera_on(advert.global_position, 1.6)


func _end_advert_interaction(advert: Advert) -> void:
	AudioServer.set_bus_effect_enabled(MUSIC_BUS, LOW_PASS_FILTER, false)
	advert._player_enter_area(_player)
	_player.can_move = true
	_player.set_collision_layer_value(MISCHIEF_LAYER, false)
	_player.focus_camera_on(_player.global_position, 1)
	_set_time_scale(1.0)


func _view_subvertising(advert: Advert) -> void:
	_start_advert_interaction(advert)
	_subvertising_art_view.artwork = advert.texture
	_subvertising_art_view.visible = true
	_subvertising_art_view.setup()
	await _subvertising_art_view.finished
	_subvertising_art_view.visible = false
	_end_advert_interaction(advert)


func _indicate_artwork_count(colour: Color = Color.CRIMSON) -> void:
	if _indicating_artwork_count:
		return
	_indicating_artwork_count = true
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
	_indicating_artwork_count = false
