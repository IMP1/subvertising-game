class_name NPC
extends CharacterBody2D

signal reached_destination

const MAX_VISION_RANGE := 1134.0
const UPDATE_CHASE_DISTANCE := 96.0
const GROUP_NAME := &"npcs"
const MOVE_SPEED := 128.0
const BASE_DETECTION_SPEED := 0.2 # seconds^(-1)

@export var debug_remote_transform: RemoteTransform2D
@export var time_scale: float = 1.0
@export var sprite_frames: SpriteFrames
@export_category("Personality")
@export_range(-1, 1) var propriety: float = 0.3
@export_range(-1, 1) var happiness: float = -0.2
@export_range(-1, 1) var aggression: float = 0.0
@export_range(-1, 1) var awareness: float = 0.0

var _target: Node2D = null
var _target_detection_progress: float = 0.0
var _chasing_target: bool = false
var _fleeing_target: bool = false
var _anger: Dictionary = {} # Node => float 0-1
var _avoiding_others: bool = true
var _about_to_hit_somebody: bool = false
var _destination: Vector2

@onready var _emote := $Bubble as AnimatedSprite2D
@onready var _nav_agent := $NavigationAgent2D as NavigationAgent2D
@onready var _sprite := $AnimatedSprite2D as AnimatedSprite2D
@onready var _vision := $Vision as Area2D
@onready var _personal_space := $PersonalSpace as Area2D
@onready var _threat_progess := $Threat as TextureProgressBar
@onready var _ray := $RayCast2D as RayCast2D
@onready var _sfx_warning := $Warning as AudioStreamPlayer2D
@onready var _sfx_chasing := $Chasing as AudioStreamPlayer2D


func _ready() -> void:
	add_to_group(GROUP_NAME)
	_threat_progess.visible = false
	_emote.visible = false
	_sprite.sprite_frames = sprite_frames
	_personal_space.body_entered.connect(_personal_space_invaded)


func start_being_present() -> void:
	await get_tree().create_timer(0.3).timeout
	_vision.visible = true
	_vision.monitoring = true
	_personal_space.monitorable = true
	_personal_space.monitoring = true


func prepare_to_free() -> void:
	pass # TODO: Anything that I can do to gracefully delete an NPC?


func move_to(target: Vector2) -> void:
	_destination = target
	_nav_agent.target_position = target


func _process(delta: float) -> void:
	_sprite.speed_scale = time_scale
	_update_player_reaction(delta)


func _physics_process(_delta: float) -> void:
	if _nav_agent.is_navigation_finished():
		return
	var pos := _nav_agent.get_next_path_position()
	var directon := global_position.direction_to(pos)
	if directon == Vector2.ZERO:
		push_error("ZERO DIRECTION")
		return
	_vision.rotation = directon.angle()
	velocity = directon * MOVE_SPEED * time_scale
	_nav_agent.velocity = velocity
	_update_sprite(velocity)


func _adjust_velocity(safe_vel: Vector2) -> void:
	#if _avoiding_others:
	velocity = safe_vel
	move_and_slide()
	if _nav_agent.is_navigation_finished():
		if _chasing_target:
			_attack(_target)
			_nav_agent.target_position = _destination
		else:
			reached_destination.emit()


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
	if target_visible and _chasing_target:
		var offset_squared := _nav_agent.target_position.distance_squared_to(_target.global_position)
		if offset_squared > UPDATE_CHASE_DISTANCE * UPDATE_CHASE_DISTANCE:
			_nav_agent.target_position = _target.global_position
	elif target_visible and _target_detection_progress < 1.0:
		_target_detection_progress += _get_detection_speed() * delta
		_threat_progess.value = _target_detection_progress
		if _target_detection_progress >= 1.0:
			_target_detected()
	else:
		_target_exited_view()


func _get_detection_speed() -> float:
	var speed := BASE_DETECTION_SPEED
	speed *= pow(1.5, awareness)
	speed *= pow(1.3, propriety)
	speed *= pow(1.3, aggression)
	return speed


func _can_see(target: Node2D) -> bool:
	_ray.target_position = _ray.to_local(target.global_position)
	if _ray.target_position.length_squared() > MAX_VISION_RANGE * MAX_VISION_RANGE:
		_ray.target_position = _ray.target_position.normalized() * MAX_VISION_RANGE
	_ray.force_raycast_update()
	return _ray.is_colliding() and _ray.get_collider() == target


func _personal_space_invaded(body: Node2D) -> void:
	return # TODO: Remove this and fix bugs
	#if not _anger.has(body):
		#_anger[body] = 0.0
	#var agression_step := 0.4 * clampf(aggression, 0, 1)
	#_anger[body] += agression_step
	#if _anger[body] >= 1.0:
		#_attack(body)
	#elif _anger[body] >= 1 - agression_step:
		#if body is Player:
			#emote(&"angry", true)
			#_about_to_hit_somebody = true
			#_sfx_warning.pitch_scale = 2.8
			#_sfx_warning.play()
	#elif _anger[body] >= 1 - (agression_step * 2):
		#emote(&"exclamation")
		#if body is Player:
			#_sfx_warning.pitch_scale = 2.5
			#_sfx_warning.play()
	#elif _anger[body] >= 1 - (agression_step * 3):
		#emote(&"exclamation")
		#if body is Player:
			#_sfx_warning.pitch_scale = 2.0
			#_sfx_warning.play()
	#elif _anger[body] > 0.0:
		#emote(&"angry")
	#if body is Player:
		#print("%.4f" % _anger[body])


func _target_entered_view(body: Node2D) -> void:
	if _target: 
		if _chasing_target:
			print("Found them!")
			_nav_agent.target_position = _target.global_position
		return
	if propriety < -0.5:
		print("Target seen, don't care...")
		return
	print("Something spotted...")
	emote(&"question")
	_target = body
	_threat_progess.visible = true


func _target_exited_view() -> void:
	if propriety < 0.0:
		print("Target lost, don't care...")
		_target_forgotten()
		return # Don't care
	emote(&"question")
	if aggression > 0.3:
		print("Target lost! After them!")
		_start_chase()
	else:
		print("Target lost, don't care...")
		_target_forgotten()


func _target_detected() -> void:
	print("Target detected!")
	if propriety < 0.0:
		print("Don't care...")
		return # Don't care
	emote(&"exclamation", true)
	if aggression > 0.1:
		_start_chase()
	elif aggression < -0.1:
		_fleeing_target = true


func _target_forgotten() -> void:
	print("Target forgotten")
	emote(&"waiting", true) 
	_chasing_target = false
	_nav_agent.set_avoidance_mask_value(1, true)
	_target = null
	_threat_progess.visible = false


func emote(emotion: StringName, override: bool = false) -> void:
	if _emote.visible and not override:
		return
	_emote.visible = true
	_emote.play("_show")
	await _emote.animation_finished
	_emote.play(emotion)
	await _emote.animation_finished
	_emote.play_backwards("_show")
	await _emote.animation_finished
	_emote.visible = false


func _body_entered_area(body: Node2D) -> void:
	if _can_see(body):
		_target_entered_view(body)


func _start_chase() -> void:
	print("Chasing!")
	print(_target.global_position)
	if global_position.distance_squared_to(_target.global_position) < 64:
		print("Already here!")
	_nav_agent.set_avoidance_mask_value(1, false)
	_nav_agent.target_position = _target.global_position
	_sfx_chasing.play()
	_chasing_target = true


func _attack(body: Node2D) -> void:
	if not body is Player:
		return
	var player := body as Player
	move_to(player.global_position)
	_avoiding_others = false
	
	var directon := global_position.direction_to(player.global_position)
	# TODO: Trying to find bug
	if directon.length() < 0.1:
		print("Small determinant?")
		print(directon)
	_vision.rotation = directon.angle()
	_update_sprite(directon)
	player.knocked_out.emit()
