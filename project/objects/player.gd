class_name Player
extends CharacterBody2D

signal knocked_out

@export var move_speed: float = 320
@export var can_move: bool = true

@onready var _camera := $Camera2D as Camera2D
@onready var _sprite := $Sprite as AnimatedSprite2D
@onready var _emote := $Bubble as AnimatedSprite2D
@onready var _input_prompt := $Bubble/Icon as TextureRect


func _ready() -> void:
	_input_prompt.visible = false


func _process(_delta: float) -> void:
	if not can_move:
		velocity = Vector2.ZERO
		return
	var movement := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	_update_sprite(movement)
	velocity = movement * move_speed
	_update_camera()


func _update_sprite(movement: Vector2) -> void:
	if movement == Vector2.ZERO:
		_sprite.stop()
		return
	var portion := TAU / 4
	var angle := snappedf(movement.angle() / portion, 1)
	if angle == 1:
		_sprite.play(&"down")
	elif angle == -1:
		_sprite.play(&"up")
	elif angle == 2 or angle == -2:
		_sprite.play(&"left")
	elif angle == 0:
		_sprite.play(&"right")


func _update_camera() -> void:
	var mouse_offset := get_local_mouse_position() / (get_viewport().get_visible_rect().size / 2)
	var target_pos := mouse_offset * 96
	_camera.position = target_pos


func _physics_process(_delta: float) -> void:
	move_and_slide()


func focus_camera_on(pos: Vector2, zoom: float) -> void:
	var tween := create_tween()
	tween.parallel().tween_property(_camera, ^"global_position", pos, 0.3)
	tween.parallel().tween_property(_camera, ^"zoom", Vector2(zoom, zoom), 0.3)


func show_input(action: StringName) -> void:
	var icon := load("res://assets/graphics/inputs/E_Key_Light.png") as Texture2D # TODO: Get from action
	_input_prompt.texture = icon
	_emote.play(&"_show")
	await _emote.animation_finished
	_input_prompt.visible = true


func hide_input() -> void:
	_emote.animation_finished.emit()
	_input_prompt.visible = false
	_emote.play_backwards(&"_show")
	
