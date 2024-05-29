class_name SubvertisingArtworkPlacement
extends Control

signal finished(success: bool)

@export var old_texture: Texture2D
var artwork: Texture2D = null

@onready var _ad_artwork := $AdvertPanel/Advert as TextureRect
@onready var _artwork_list := $ArtPanel/Contents/ScrollContainer/List as Control
@onready var _confirm_button := $Confirm as Button
@onready var _cursor_sfx := $Cursor as AudioStreamPlayer


func setup() -> void:
	artwork = null
	_ad_artwork.texture = old_texture
	for child in _artwork_list.get_children():
		child.queue_free()
	for art in ProgressManager.progress.artwork:
		var button := Button.new()
		_artwork_list.add_child(button)
		button.custom_minimum_size = Vector2(200, 282)
		button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.expand_icon = true
		button.icon = art
		button.pressed.connect(_set_art.bind(art))
		button.focus_entered.connect(_cursor_moved)
	_confirm_button.disabled = true
	await get_tree().process_frame
	if _artwork_list.get_child_count() > 0:
		(_artwork_list.get_child(0) as Button).grab_focus()
		_cursor_sfx.stop()


func _set_art(artwork: Texture2D) -> void:
	_ad_artwork.texture = artwork
	_confirm_button.disabled = false


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	if event.is_action_pressed(&"cancel"):
		_cancel()
		get_viewport().set_input_as_handled()


func _cursor_moved() -> void:
	_cursor_sfx.play()


func _cancel() -> void:
	finished.emit(false)


func _confirm() -> void:
	artwork = _ad_artwork.texture
	finished.emit(true)
