class_name Advert
extends Node2D

signal subvertising_lacking_art
signal unlocking_started
signal replacement_started
signal subvertising_viewed

const GROUP_NAME = &"adverts"

@export var unlocked: bool = false
@export var subverted: bool = false
@export var texture: Texture2D:
	set(value):
		texture = value
		if _board:
			_board.texture = texture
@export var unlock_path: Curve2D

var _player_near: bool = false
var _player: Player = null

@onready var _area := $Area2D as Area2D
@onready var _board := $Board as Sprite2D
@onready var _input_prompt_timer := $PromptTimer as Timer


func _ready() -> void:
	add_to_group(GROUP_NAME)
	_player_near = _area.has_overlapping_bodies()
	_board.texture = texture


func _player_enter_area(body: Node2D) -> void:
	_player_near = true
	_input_prompt_timer.start()
	_player = body as Player


func _player_exit_area(body: Node2D) -> void:
	_player_near = false
	_input_prompt_timer.stop()
	var player = body as Player
	player.hide_input()


func _show_player_input_prompt() -> void:
	_player.show_input(&"interact")


func _player_has_artwork() -> bool:
	return ProgressManager.progress.artwork.size() > 0


func _input(event: InputEvent) -> void:
	if _player_near and event.is_action_pressed(&"interact"):
		if subverted:
			subvertising_viewed.emit()
		elif not unlocked:
			unlocking_started.emit()
		elif not _player_has_artwork():
			subvertising_lacking_art.emit()
		else:
			replacement_started.emit()

