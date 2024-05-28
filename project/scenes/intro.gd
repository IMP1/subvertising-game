extends Control

@export var background_music: AudioStream

var _finished: bool = false

@onready var _animator := $AnimationPlayer as AnimationPlayer


func _ready() -> void:
	if background_music:
		MusicManager.blend_to(background_music)
	_finished = false
	await SceneTransition.transition_completed
	_animator.speed_scale = SettingsManager.settings.type_speed * 0.8
	_animator.play(&"intro")
	await _animator.animation_finished
	await get_tree().create_timer(1.5).timeout
	#_animator.play(&"images")
	#await _animator.animation_finished
	_finish()


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		_finish()


func _finish() -> void:
	if _finished:
		return
	_finished = true
	SceneTransition.transition_to_file("res://scenes/day.tscn")
