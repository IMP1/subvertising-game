class_name Bike
extends StaticBody2D

signal interacted

@export var press_length: float = 1.0

var _player_near: bool = false
var _player: Player = null
var _press: float = 0.0
var _is_interacting: bool = false
var _hide_bar_tween: Tween

@onready var _area := $Area2D as Area2D
@onready var _input_prompt_timer := $PromptTimer as Timer
@onready var _interaction_progress := $InteractionBar as ProgressBar
@onready var _bars := $CanvasLayer as CanvasLayer
@onready var _bar_top := $CanvasLayer/Bars/Top as Control
@onready var _bar_container := $CanvasLayer/Bars as Control
@onready var _bar_bottom := $CanvasLayer/Bars/Bottom as Control
@onready var _bar_text := $CanvasLayer/Label as Label
@onready var bell := $Bell as AudioStreamPlayer2D


func _ready() -> void:
	_player_near = _area.has_overlapping_bodies()
	_interaction_progress.max_value = press_length
	_interaction_progress.visible = false
	_bar_text.visible = false


func _player_enter_area(body: Node2D) -> void:
	_player_near = true
	_input_prompt_timer.start()
	_player = body as Player


func _player_exit_area(body: Node2D) -> void:
	_player_near = false
	_input_prompt_timer.stop()
	_cancel_interaction()
	var player = body as Player
	player.hide_input()


func _show_player_input_prompt() -> void:
	_player.show_input(&"interact")


func _input(event: InputEvent) -> void:
	if _player_near and event.is_action_pressed(&"interact") and not _is_interacting:
		_start_interacting()
	if event.is_action_released(&"interact") and _is_interacting:
		_cancel_interaction()
		if _player_near:
			_input_prompt_timer.start()


func _start_interacting() -> void:
	_is_interacting = true
	_input_prompt_timer.stop()
	_interaction_progress.visible = true
	_bar_text.visible = true
	_bars.visible = true


func _cancel_interaction(hide_bars:=true) -> void:
	_is_interacting = false
	_press = 0
	_interaction_progress.value = 0
	_interaction_progress.visible = false
	if hide_bars:
		_hide_bars()


func _process(delta: float) -> void:
	if _is_interacting:
		_press += delta
		_interaction_progress.value = _press
		_update_bars()
		if _press >= press_length:
			_cancel_interaction(false)
			interacted.emit()


func _update_bars() -> void:
	if _hide_bar_tween:
		_hide_bar_tween.stop()
		_hide_bar_tween = null
	var ratio := clampf(_press / (press_length / 2), 0, 1)
	_bar_top.position = lerp(Vector2(0, -96), Vector2(0, 0), ratio)
	_bar_bottom.position = lerp(Vector2(0, _bar_container.size.y), Vector2(0, _bar_container.size.y - 96), ratio)


func _hide_bars() -> void:
	if _hide_bar_tween:
		_hide_bar_tween.stop()
	_bar_text.visible = false
	_hide_bar_tween = create_tween()
	_hide_bar_tween.set_parallel()
	_hide_bar_tween.tween_property(_bar_top, "position", Vector2(0, -96), 0.3)
	_hide_bar_tween.tween_property(_bar_bottom, "position", Vector2(0, _bar_container.size.y), 0.3)
