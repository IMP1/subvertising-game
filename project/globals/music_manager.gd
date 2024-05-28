extends Node

signal track_finished
signal blend_finished

var is_blending: bool = false

@onready var _track_1 := $Track1 as AudioStreamPlayer
@onready var _track_2 := $Track2 as AudioStreamPlayer


func blend_to(stream: AudioStream, duration:float=1.0) -> void:
	if _track_1.playing and _track_2.playing:
		print("Already blending")
		return
	
	var track_to: AudioStreamPlayer = _track_2 if _track_1.playing else _track_1
	var track_from: AudioStreamPlayer = _track_1 if _track_1.playing else _track_2
	
	is_blending = true
	track_to.stream = stream
	track_to.volume_db = -80.0
	track_to.play()
	var fade_out_tween := create_tween()
	fade_out_tween.tween_property(track_from, "volume_db", -80.0, duration)
	fade_out_tween.set_trans(Tween.TRANS_EXPO)
	fade_out_tween.set_ease(Tween.EASE_OUT)
	fade_out_tween.play()
	var fade_in_tween := create_tween()
	fade_in_tween.tween_property(track_to, "volume_db", 0.0, duration)
	fade_in_tween.set_trans(Tween.TRANS_EXPO)
	fade_in_tween.set_ease(Tween.EASE_IN)
	fade_in_tween.play()
	await fade_in_tween.finished
	track_from.stop()
	is_blending = false
	blend_finished.emit()


func play(stream: AudioStream) -> void:
	if _track_2.playing:
		_track_2.stop()
	_track_1.stream = stream
	_track_1.play()


func stop() -> void:
	_track_1.stop()
	_track_2.stop()


func is_playing() -> bool:
	return _track_1.playing or _track_2.playing


func _track_finished() -> void:
	track_finished.emit()

