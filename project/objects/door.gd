class_name Door
extends NPCSource

const INITIAL_OFFSET := Vector2(30, -8)

@onready var _animation := $DoorSprite as AnimatedSprite2D
@onready var _mask := $Mask as ColorRect
@onready var _warning := $Warning as TextureRect


func _ready() -> void:
	_warning.visible = false


func open() -> void:
	_animation.play(&"open")
	await _animation.animation_finished


func exit_npc(npc: NPC) -> void:
	npc.reparent(_mask)
	await get_tree().process_frame
	npc.position = INITIAL_OFFSET
	var tween := create_tween()
	tween.tween_property(npc, "position", Vector2(30, 130), 1.0)
	await tween.finished


func close() -> void:
	_animation.play(&"close")
	await _animation.animation_finished


func show_warning() -> void:
	_warning.visible = true


func hide_warning() -> void:
	_warning.visible = false
