extends Control

const SCROLL_SPEED := 48.0

var _scroll_height: float = 0.0

@onready var _scroll := $ScrollContainer as ScrollContainer
@onready var _prompt := $Prompt as Control


func _ready() -> void:
	_prompt.modulate = Color(1, 1, 1, 0)
	var tween := create_tween()
	tween.tween_property(_prompt, "modulate", Color(1, 1, 1), 2.0).set_delay(2.0)


func _process(delta: float) -> void:
	var speed := SCROLL_SPEED * SettingsManager.settings.type_speed
	_scroll_height += delta * speed
	_scroll.scroll_vertical = _scroll_height


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"cancel"):
		SceneTransition.transition_to_file("res://scenes/title.tscn")
