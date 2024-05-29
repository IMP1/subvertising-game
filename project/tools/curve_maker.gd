extends Control

@export var path_filename: String = "adjusted"

@onready var _path := $Path2D as Path2D


func _ready() -> void:
	var curve := _path.curve
	var offset := -curve.get_point_position(0)
	for i in curve.point_count:
		var pos := curve.get_point_position(i)
		curve.set_point_position(i, pos + offset)
	ResourceSaver.save(curve, "res://resources/qte_curve_%s.tres" % path_filename)
