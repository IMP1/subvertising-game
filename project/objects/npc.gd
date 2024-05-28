class_name NPC
extends CharacterBody2D

signal reached_destination

const GROUP_NAME := &"npcs"
const MOVE_SPEED := 128

@export var time_scale: float = 1.0
@export var sprite_frames: SpriteFrames
@export_category("Personality")
@export_range(0, 1) var propriety: float = 0.8
@export_range(0, 1) var happiness: float = 0.2
@export_range(0, 1) var aggression: float = 0.5

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
		emote(&"angry", 2.0))


func move_to(target: Vector2) -> void:
	_nav_agent.target_position = target


func _process(_delta: float) -> void:
	_sprite.speed_scale = time_scale


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


func _body_entered_view(body: Node2D) -> void:
	emote(&"question")
	pass


func _body_exited_view(body: Node2D) -> void:
	# TODO: Need to call this even if still in area, but ray no longer finds them
	pass


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
	_ray.target_position = _ray.to_local(body.global_position)
	_ray.force_raycast_update()
	if _ray.is_colliding() and _ray.get_collider() == body:
		_body_entered_view(body)


func _body_exited_area(body: Node2D) -> void:
	_body_exited_view(body)
