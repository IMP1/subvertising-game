extends Control

@export var next_scene: PackedScene

@onready var _animator := $AnimationPlayer as AnimationPlayer
@onready var _dedication := $Dedication as CanvasItem
@onready var _developer := $Panel as CanvasItem


func _ready() -> void:
	_dedication.visible = false
	_developer.modulate = Color(1, 1, 1, 0)
	_animator.play(&"dedication")
	await _animator.animation_finished
	await get_tree().create_timer(1.0).timeout
	_animator.play(&"developer")
	await _animator.animation_finished
	_finish()


func _finish() -> void:
	SceneTransition.transition_to_packed(next_scene, &"fade_black", 2.0)

