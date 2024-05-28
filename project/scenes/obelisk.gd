extends Node3D

const HEAD_TURN_SPEED := TAU / 14
const BODY_TURN_SPEED := TAU / 15

@onready var _head := $Head as Node3D
@onready var _body := $Body as Node3D


func _process(delta: float) -> void:
	_head.rotate_y(HEAD_TURN_SPEED * delta)
	_body.rotate_y(BODY_TURN_SPEED * delta)
