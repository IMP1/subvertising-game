class_name SubvertisingEvent
extends Control

signal finished(success: bool)

const RETREAT_SPEED := 192.0
const AUTO_SOLVE_SPEED := 256.0
const SOUND_PITCH_MIN := 1.0
const SOUND_PITCH_MAX := 2.0

@export var advert_texture: Texture2D
@export var path: Curve2D
@export var sections: int = 8
@export var fill_colour: Color = Color.BLUE_VIOLET
@export var default_colour: Color = Color.WHITE
@export var line_width: int = 10
@export var leeway: float = 2 # px outside of line

var _is_ready: bool = false
var _started: bool = false
var _success: bool = false
var _progress: float = 0.0
var _progress_ratio: float = 0.0
var _is_mouse_over_start: bool = false
var _is_auto_solving: bool = false

@onready var _path := $QTE/Path2D as Path2D
@onready var _line := $QTE/Line2D as Line2D
@onready var _progress_line := $QTE/Progress as Line2D
@onready var _start_area := $QTE/Start as Area2D
@onready var _finish_area := $QTE/Finish as Area2D
@onready var _start_marker := $QTE/Start/Polygon2D as Polygon2D
@onready var _start_pulse := $QTE/Start/Pulse as Polygon2D
@onready var _finish_marker := $QTE/Finish/Polygon2D as Polygon2D
@onready var _particles := $QTE/Finish/GPUParticles2D as GPUParticles2D
@onready var _animation := $AnimationPlayer as AnimationPlayer
@onready var _sound_success := $Sounds/Success as AudioStreamPlayer
@onready var _sound_failure := $Sounds/Failure as AudioStreamPlayer
@onready var _sound_progress := $Sounds/Progress as AudioStreamPlayer
@onready var _advert := $AdvertPanel/Advert as TextureRect


func _ready() -> void:
	_start_area.mouse_entered.connect(_start)
	_start_area.mouse_exited.connect(func():
		_is_mouse_over_start = false)
	_finish_area.mouse_entered.connect(_finish)
	_is_ready = false


func setup() -> void:
	_is_ready = false
	_path.curve = path
	var curve := _path.curve
	var midpoint := ($QTE as Control).size.x / 2
	var offset := Vector2(midpoint, 0) - curve.get_point_position(0)
	for i in curve.point_count:
		var pos := curve.get_point_position(i)
		curve.set_point_position(i, pos + offset)
	if offset != Vector2.ZERO:
		ResourceSaver.save(curve, "res://resources/qte_adjusted.tres")
	
	_advert.texture = advert_texture
	_line.default_color = default_colour
	_line.points = _path.curve.get_baked_points()
	_line.width = line_width
	_progress_line.width = line_width
	_progress_line.default_color = fill_colour
	_progress_line.clear_points()
	_started = false
	_success = false
	_start_area.position = _path.curve.get_point_position(0)
	_finish_area.position = _path.curve.get_point_position(_path.curve.point_count-1)
	_start_pulse.color = fill_colour
	_finish_marker.color = default_colour
	_particles.modulate = fill_colour
	_particles.emitting = false
	_animation.play(&"pulse")
	_is_auto_solving = false
	
	if SettingsManager.settings.accessibility_qte == Settings.QuickTimeEventOptions.AUTO_SOLVE:
		_auto_solve()
	_is_ready = true


func _auto_solve() -> void:
	_start()
	_is_auto_solving = true


func _start() -> void:
	_is_mouse_over_start = true
	_line.default_color = default_colour
	_start_marker.color = fill_colour
	_started = true
	_animation.stop()


func _finish() -> void:
	if _success:
		return
	if not _started:
		return
	_is_auto_solving = false
	_finish_marker.color = fill_colour
	_line.default_color = fill_colour
	_particles.emitting = true
	_success = true
	_sound_success.play()
	_sound_progress.pitch_scale = 2.0
	_sound_progress.play()
	_progress = 0
	_progress_ratio = 0.0
	await _particles.finished
	finished.emit(true)


func _fail() -> void:
	_sound_failure.play()
	setup()


func _cancel() -> void:
	setup()
	_progress = 0
	_progress_ratio = 0.0
	finished.emit(false)


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	if not _is_ready:
		return
	if event.is_action_pressed(&"cancel"):
		_cancel()
		get_viewport().set_input_as_handled()
	if event.is_action_pressed(&"interact") and SettingsManager.settings.accessibility_qte == Settings.QuickTimeEventOptions.BUTTON_INPUT:
		_auto_solve()


func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	if _success:
		return
	if _is_auto_solving:
		_update_auto_solve(delta)
		return
	if not _started:
		_update_rewind(delta)
		return
	var allowed_distance := line_width + leeway
	var local_mouse := _path.get_local_mouse_position()
	var nearest_point := _path.curve.get_closest_point(local_mouse)
	var distance_squared := nearest_point.distance_squared_to(local_mouse)
	if distance_squared > (allowed_distance * allowed_distance) and not _is_mouse_over_start:
		_fail()
		return
	# Update filled line
	var offset := _path.curve.get_closest_offset(local_mouse)
	_progress = _get_curve_baked_point_index_from_offset(_path.curve, offset)
	_progress_line.points = _path.curve.get_baked_points().slice(0, int(_progress))
	# Update sounds
	var previous_progress_ratio := _progress_ratio
	_progress_ratio = offset / _path.curve.get_baked_length()
	var next_progress_ratio := _progress_ratio
	for i in sections:
		var ratio := float(i) / sections
		if previous_progress_ratio <= ratio and next_progress_ratio > ratio:
			_sound_progress.pitch_scale = SOUND_PITCH_MIN + ratio * (SOUND_PITCH_MAX - SOUND_PITCH_MIN)
			_sound_progress.play()
			break


func _update_auto_solve(delta: float) -> void:
	_progress += AUTO_SOLVE_SPEED * delta
	_progress_line.points = _path.curve.get_baked_points().slice(0, int(_progress))
	if _progress >= _path.curve.get_baked_points().size():
		_finish()


func _update_rewind(delta: float) -> void:
	if _progress <= 0:
		return
	_progress -= RETREAT_SPEED * delta
	_progress = maxf(0, _progress)
	_progress_line.points = _path.curve.get_baked_points().slice(0, int(_progress))


func _get_curve_baked_point_index_from_offset(curve: Curve2D, offset: float) -> int:
	var baked_points := curve.get_baked_points()
	var curve_point_length := baked_points.size()
	if curve_point_length < 2: 
		return curve_point_length
	for i in range(1, curve_point_length):
		var current_point_offset := curve.get_closest_offset(baked_points[i])
		if current_point_offset > offset: 
			return i
	return curve_point_length
