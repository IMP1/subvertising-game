extends CanvasLayer

signal transition_completed

const DEFAULT_ANIM = &"fade_white"

@export var previous_scene_texture: TextureRect
@export var animation_player: AnimationPlayer

var _scene_stack: Array[Node]


func _ready() -> void:
	visible = false


func _transition(transition: StringName, duration: float, scene_switch: Callable) -> void:
	if transition.is_empty():
		scene_switch.call()
		return
	
	var screenshot := get_viewport().get_texture().get_image()
	await get_tree().process_frame
	var texture := ImageTexture.create_from_image(screenshot)
	previous_scene_texture.texture = texture
	visible = true
	
	scene_switch.call()

	var speed := animation_player.get_animation(transition).length / duration
	animation_player.speed_scale = speed
	animation_player.play(transition)
	await animation_player.animation_finished
	animation_player.speed_scale = 1.0
	visible = false
	transition_completed.emit()


func is_transitioning() -> bool:
	return visible


func transition_to_file(next_scene_path: String, transition:=DEFAULT_ANIM, duration:=1.0) -> void:
	if transition.is_empty():
		get_tree().change_scene_to_file(next_scene_path)
		return
	await _transition(transition, duration, func():
		get_tree().change_scene_to_file(next_scene_path)
	)


func transition_to_packed(next_scene: PackedScene, transition:=DEFAULT_ANIM, duration:=1.0) -> void:
	await _transition(transition, duration, func():
		get_tree().change_scene_to_packed(next_scene)
	)


func transition_to_scene(next_scene: Node, transition:=DEFAULT_ANIM, duration:=1.0) -> void:
	await _transition(transition, duration, func():
		get_tree().current_scene.queue_free()
		get_tree().root.add_child(next_scene)
		get_tree().current_scene = next_scene
	)


func push_scene(next_scene: Node, transition:=DEFAULT_ANIM, duration:=1.0) -> void:
	await _transition(transition, duration, func():
		_scene_stack.push_back(get_tree().current_scene)
		get_tree().root.add_child(next_scene)
		get_tree().current_scene = next_scene
	)


func pop_scene(transition:=DEFAULT_ANIM, duration:=1.0) -> void:
	await _transition(transition, duration, func():
		assert(_scene_stack.size() >= 1)
		get_tree().current_scene.queue_free()
		get_tree().current_scene = _scene_stack.pop_back() as Node
	)
