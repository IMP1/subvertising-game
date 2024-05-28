class_name Door
extends NPCSource

@onready var _animation := $DoorSprite as AnimatedSprite2D
@onready var _mask := $Mask as ColorRect
@onready var _warning := $Warning as TextureRect


func _ready() -> void:
	_warning.visible = false


func open() -> void:
	_animation.play(&"open")


func exit_npc(npc: NPC) -> void:
	npc.reparent(_mask)
	await get_tree().process_frame
	npc.position = Vector2(30, -8)
	var tween := create_tween()
	tween.tween_property(npc, "position", Vector2(30, 130), 1.0)
	await tween.finished


func close() -> void:
	_animation.play(&"close")


func show_warning() -> void:
	_warning.visible = true


func hide_warning() -> void:
	_warning.visible = false
