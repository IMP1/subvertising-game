@tool
class_name Building
extends Area2D

@export var height: int = 10
@export var snap_to_grid: bool = true
@export var regenerate: bool = false:
	set(value):
		_refresh_shape()


func _ready() -> void:
	_refresh_shape()

#
#func _process(delta: float) -> void:
	#if not Engine.is_editor_hint():
		#return
	#_refresh_shape()


func _refresh_shape() -> void:
	var shape_marker := $Shape as CollisionShape2D
	var shape := shape_marker.shape as RectangleShape2D
	shape.size = snapped(shape.size, Vector2(24, 24)) # Snap to multiple of 24 (8 pixel tile, 3 pixel scale)
	# Move building to shape_marker's position
	global_position = shape_marker.global_position + Vector2(0, shape.size.y / 2)
	# Snap to pixel grid
	global_position = snapped(global_position, Vector2(1, 1))
	# Make shape_maker positionined correctly within building
	shape_marker.position.y = -shape.size.y / 2
	shape_marker.position.x = 0
	
	var collider := $StaticBody2D/CollisionShape2D as CollisionShape2D
	# Duplicate because local to scene doesn't work when instantiated in another scene? 
	# They're local to *that* scene?
	var collider_shape := collider.shape.duplicate() as RectangleShape2D
	collider.shape = collider_shape
	var wall_height := height * 8 + 16
	var roof_height := shape.size.y - wall_height
	collider_shape.size = shape.size
	collider_shape.size.y = shape.size.y - 36
	collider.position = Vector2(0, -shape.size.y / 2)
	collider.position.y += 18
	var wall := $Wall as NinePatchRect
	var roof := $Roof as NinePatchRect
	wall.size = Vector2(shape.size.x / wall.scale.x, wall_height / wall.scale.y)
	wall.position = -Vector2(shape.size.x / 2, wall_height)
	roof.size = Vector2(shape.size.x / roof.scale.x, roof_height / roof.scale.y)
	roof.position = Vector2(-shape.size.x / 2, wall.position.y - roof_height)
