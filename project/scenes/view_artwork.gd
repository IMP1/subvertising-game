class_name SubvertisingArtworkViewer
extends Control

signal finished

@export var artwork: Texture2D = null

@onready var _ad_artwork := $AdvertPanel/Advert as TextureRect


func setup() -> void:
	_ad_artwork.texture = artwork


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	if event.is_action_pressed(&"cancel") or event.is_action_pressed(&"interact"):
		get_viewport().set_input_as_handled()
		_cancel()


func _cancel() -> void:
	finished.emit(false)
