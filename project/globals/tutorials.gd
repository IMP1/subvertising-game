extends CanvasLayer

signal finished

var _tutorial_queue: Array[NodePath]
var _modal_queue: Array[bool]
var _pause_queue: Array[bool]
var _input_enabled: bool

@onready var _modal := $Modal as ColorRect
@onready var _ui := $UI as Control
@onready var _tutorials := $Tutorials as Control


func _ready() -> void:
	_hide_all()
	_tutorial_queue = []
	_modal_queue = []
	_pause_queue = []


func _hide_all() -> void:
	_input_enabled = false
	visible = false
	_ui.visible = false
	for child in _tutorials.get_children():
		child.visible = false


func queue_tutorial(tutorial: NodePath, show_modal: bool, pause_tree: bool) -> void:
	if not SettingsManager.settings.show_tutorials:
		return
	_tutorial_queue.push_back(tutorial)
	_modal_queue.push_back(show_modal)
	_pause_queue.push_back(pause_tree)
	if not visible:
		_show_next_tutorial()


func _show_next_tutorial() -> void:
	var tutorial_path := _tutorial_queue.pop_front() as NodePath
	var show_modal := _modal_queue.pop_front() as bool
	var pause_tree := _pause_queue.pop_front() as bool
	_hide_all()
	_modal.visible = show_modal
	_tutorials.get_node(tutorial_path).visible = true
	_ui.visible = true
	visible = true
	get_tree().paused = pause_tree
	# This is to avoid immediately continuing on from the tutorial if, that 
	# frame, the interact action was taken
	await get_tree().process_frame
	_input_enabled = true


func _continue() -> void:
	_hide_all()
	if _tutorial_queue.is_empty():
		get_tree().paused = false
		finished.emit()
	else:
		_show_next_tutorial()


func _stop_tutorials() -> void:
	SettingsManager.settings.show_tutorials = false
	_tutorial_queue.clear()
	_modal_queue.clear()
	_continue()


func _input(event: InputEvent) -> void:
	if not _input_enabled:
		return
	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		_continue()
