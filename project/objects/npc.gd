class_name NPC
extends CharacterBody2D

signal reached_destination

const MAX_VISION_RANGE := 544.0
const GROUP_NAME := &"npcs"
const MOVE_SPEED := 128.0
const BASE_DETECTION_SPEED := 0.5 # seconds^(-1)

@export var time_scale: float = 1.0
@export var sprite_frames: SpriteFrames
@export_category("Personality")
@export_range(-1, 1) var propriety: float = 0.3
@export_range(-1, 1) var happiness: float = -0.2
@export_range(-1, 1) var aggression: float = 0.0
@export_range(-1, 1) var awareness: float = 0.0

var _target: Node2D = null
var _target_detection_progress: float = 0.0

@onready var _emote := $Bubble as AnimatedSprite2D
@onready var _nav_agent := $NavigationAgent2D as NavigationAgent2D
@onready var _sprite := $AnimatedSprite2D as AnimatedSprite2D
@onready var _vision := $Vision as Node2D
@onready var _personal_space := $PersonalSpace as Area2D
@onready var _ray := $RayCast2D as RayCast2D


func _ready() -> void:
	add_to_group(GROUP_NAME)
	_emote.visible = false
	_sprite.sprite_frames = sprite_frames
	_personal_space.body_entered.connect(func(body: Node2D) -> void:
		emote(&"angry", 1.0))


func move_to(target: Vector2) -> void:
	_nav_agent.target_position = target


func _process(delta: float) -> void:
	_sprite.speed_scale = time_scale
	_update_player_reaction(delta)


func _physics_process(_delta: float) -> void:
	if _nav_agent.is_navigation_finished():
		return
	var pos := _nav_agent.get_next_path_position()
	var directon := global_position.direction_to(pos)
	_vision.rotation = directon.angle()
	velocity = directon * MOVE_SPEED * time_scale
	_update_sprite(velocity)
	move_and_slide()
	if _nav_agent.is_navigation_finished():
		reached_destination.emit()


func _adjust_velocity(safe_vel: Vector2) -> void:
	_nav_agent.velocity = safe_vel


func _update_sprite(movement: Vector2) -> void:
	if movement == Vector2.ZERO:
		_sprite.stop()
		return
	var portion := TAU / 4
	var angle := snappedf(movement.angle() / portion, 1)
	if angle == 1:
		_sprite.play(&"down")
	elif angle == -1:
		_sprite.play(&"up")
	elif angle == 2 or angle == -2:
		_sprite.play(&"left")
	elif angle == 0:
		_sprite.play(&"right")


func _update_player_reaction(delta: float) -> void:
	if not _target:
		return
	var target_visible := _can_see(_target)
	if target_visible and _target_detection_progress < 1.0:
		_target_detection_progress += delta * _get_detection_speed()
		if _target_detection_progress >= 1.0:
			_target_detected()
	else:
		_target_exited_view()


func _get_detection_speed() -> float:
	var speed := BASE_DETECTION_SPEED
	speed *= pow(2, awareness)
	speed *= pow(1.8, propriety)
	speed *= pow(1.8, aggression)
	return speed


func _can_see(target: Node2D) -> bool:
	_ray.target_position = _ray.to_local(target.global_position)
	if _ray.target_position.length_squared() > MAX_VISION_RANGE * MAX_VISION_RANGE:
		_ray.target_position = _ray.target_position.normalized() * MAX_VISION_RANGE
	_ray.force_raycast_update()
	return _ray.is_colliding() and _ray.get_collider() == target


func _target_entered_view(body: Node2D) -> void:
	emote(&"question")
	_target = body


func _target_exited_view() -> void:
	emote(&"question")
	# TODO: Either chase or forget depending on personality


func _target_detected() -> void:
	emote(&"exclamation")
	# TODO: Either chase, flee, or ignore depending on personality


func _target_forgotten() -> void:
	emote(&"waiting", 1.0)
	_target = null


func emote(emotion: StringName, duration: float = -1) -> void:
	_emote.visible = true
	_emote.play("_show")
	await _emote.animation_finished
	_emote.play(emotion)
	if duration > 0:
		await get_tree().create_timer(duration).timeout
		_emote.play_backwards("_show")
		await _emote.animation_finished
		_emote.visible = false
	else:
		await _emote.animation_finished
		_emote.play_backwards("_show")
		await _emote.animation_finished
		_emote.visible = false


func _body_entered_area(body: Node2D) -> void:
	if _can_see(body):
		_target_entered_view(body)
