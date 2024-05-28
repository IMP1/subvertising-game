extends Node

const NPC_CLASS := preload("res://objects/npc.tscn")

const WORKER_SPRITE_FRAMES := [
	preload("res://resources/sprites/worker_1.tres"),
	preload("res://resources/sprites/worker_2.tres"),
]
const HAPPY_WORKER_SPRITE_FRAMES := [ # TODO: Replace with happier people
	preload("res://resources/sprites/worker_1.tres"),
	preload("res://resources/sprites/worker_2.tres"),
]
const REGULAR_PEOPLE_SPRITE_FRAMES := [
	preload("res://resources/sprites/person_1.tres"),
]
const PARTY_SPRITE_FRAMES := [
	preload("res://resources/sprites/person_1.tres"),
]
const OFFICER_SPRITE_FRAMES := [
	preload("res://resources/sprites/officer_1.tres"),
]


@export var npc_list: Node2D
@export var sources: Node2D
@export var random_areas: Node2D
@export var destinations: Node2D
@export var timer: Timer

var _end_of_work_early: bool = false
var _end_of_work_late: bool = false
var _end_of_work_latest: bool = false
var _party_goers: bool = false


func _ready() -> void:
	_spawn_initial_npcs()


func _process(_delta: float) -> void:
	var time_progress := (timer.wait_time - timer.time_left) / timer.wait_time
	var hour := lerpf(4.0, 12.0, time_progress)
	if hour > 4.5 and not _end_of_work_early:
		_end_of_work_early = true
		_spawn_early_work_leavers()
	if hour > 6.0 and not _end_of_work_late:
		_end_of_work_late = true
		_spawn_work_leavers()
	if hour > 8.0 and not _end_of_work_latest:
		_end_of_work_latest = true
		_spawn_late_work_leavers()
	if hour > 10.0 and not _party_goers:
		_party_goers = true
		_spawn_party_goers()


func _spawn_initial_npcs() -> void:
	var npc_count := randi_range(2, 8)
	for i in npc_count:
		var area := random_areas.get_children().pick_random() as Area2D
		var collider := area.get_node("CollisionShape2D") as CollisionShape2D
		var shape := collider.shape as RectangleShape2D
		var x := randi_range(-shape.size.x / 2, shape.size.x / 2) + collider.global_position.x
		var y := randi_range(-shape.size.y / 2, shape.size.y / 2) + collider.global_position.y
		_spawn_npc_from_position(Vector2(x, y), REGULAR_PEOPLE_SPRITE_FRAMES)


func _spawn_early_work_leavers() -> void:
	for door in sources.get_children().filter(func(source: Node) -> bool: return source is Door):
		if absf(randfn(0.0, 1.0)) < 1.0: # ~68%
			var amount := clampi(floori(absf(randfn(0.0, 1.0))), 1, 3)
			_spawn_npc_from_building(door as Door, WORKER_SPRITE_FRAMES, amount)
	await get_tree().create_timer(6.0).timeout
	for door in sources.get_children().filter(func(source: Node) -> bool: return source is Door):
		if absf(randfn(0.0, 1.0)) < 1.0: # ~68%
			var amount := clampi(floori(absf(randfn(0.0, 1.0))), 1, 3)
			_spawn_npc_from_building(door as Door, WORKER_SPRITE_FRAMES, amount)


func _spawn_work_leavers() -> void:
	print("Work leavers")
	# If progress is such, also spawn some guards/police


func _spawn_late_work_leavers() -> void:
	print("Laaaate work leavers")
	# If progress is such, spawn some more guards/police


func _spawn_party_goers() -> void:
	print("Party time!")
	# Spawn some police cos party goers


func _spawn_npc_from_building(door: Door, possible_looks: Array, amount: int = 1) -> void:
	door.show_warning()
	await get_tree().create_timer(1.0).timeout
	door.hide_warning()
	
	door.open()
	for i in amount:
		var destination := door.destinations.pick_random() as Marker2D
		var npc := NPC_CLASS.instantiate() as NPC
		npc_list.add_child(npc)
		await get_tree().create_timer(1.0).timeout
		await door.exit_npc(npc)
		var pos := npc.global_position
		npc.get_parent().remove_child(npc)
		await _setup_npc(npc, possible_looks, pos, destination.global_position)
	door.close()


func _spawn_npc_from_source(source: NPCSource, possible_looks: Array) -> void:
	var destination := source.destinations.pick_random() as Marker2D
	var npc := NPC_CLASS.instantiate() as NPC
	npc.sprite_frames = load("res://resources/sprites/person_1.tres") as SpriteFrames
	await _setup_npc(npc, possible_looks, source.global_position, destination.global_position)


func _spawn_npc_from_position(location: Vector2, possible_looks: Array) -> void:
	var destination := destinations.get_children().pick_random() as Marker2D
	var npc := NPC_CLASS.instantiate() as NPC
	npc.sprite_frames = load("res://resources/sprites/person_1.tres") as SpriteFrames
	await _setup_npc(npc, possible_looks, location, destination.global_position)


func _setup_npc(npc: NPC, possible_looks: Array, initial_pos: Vector2, final_pos: Vector2) -> NPC:
	npc.sprite_frames = possible_looks.pick_random() as SpriteFrames
	npc_list.add_child(npc)
	await get_tree().process_frame
	npc.global_position = initial_pos
	npc.move_to(final_pos)
	npc.reached_destination.connect(_remove_npc.bind(npc))
	return npc


func _remove_npc(npc: NPC) -> void:
	npc.queue_free()
