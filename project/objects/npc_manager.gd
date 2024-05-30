extends Node

const NPC_CLASS := preload("res://objects/npc.tscn")

# TODO: More sprites!

const WORKER_SPRITE_FRAMES := [
	preload("res://resources/sprites/worker_1.tres"),
	preload("res://resources/sprites/worker_2.tres"),
	preload("res://resources/sprites/worker_3.tres"),
	preload("res://resources/sprites/worker_4.tres"),
	preload("res://resources/sprites/worker_5.tres"),
]
const HAPPY_WORKER_SPRITE_FRAMES := [
	preload("res://resources/sprites/worker_1_happy.tres"),
	preload("res://resources/sprites/worker_2_happy.tres"),
	preload("res://resources/sprites/worker_3_happy.tres"),
	preload("res://resources/sprites/worker_4_happy.tres"),
	preload("res://resources/sprites/worker_5_happy.tres"),
]
const REGULAR_PEOPLE_SPRITE_FRAMES := [
	preload("res://resources/sprites/person_1.tres"),
	preload("res://resources/sprites/person_2.tres"),
	preload("res://resources/sprites/person_3.tres"),
	preload("res://resources/sprites/person_4.tres"),
]
const PARTY_SPRITE_FRAMES := [
	preload("res://resources/sprites/party_1.tres"),
	preload("res://resources/sprites/party_2.tres"),
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
		_spawn_officers()
	if hour > 8.0 and not _end_of_work_latest:
		_end_of_work_latest = true
		_spawn_late_work_leavers()
		_spawn_officers()
	if hour > 10.0 and not _party_goers:
		_party_goers = true
		_spawn_party_goers()


func _spawn_initial_npcs() -> void:
	var npc_count := randi_range(2, 8)
	for i in npc_count:
		var area := random_areas.get_children().pick_random() as Area2D
		var collider := area.get_node("CollisionShape2D") as CollisionShape2D
		var shape := collider.shape as RectangleShape2D
		var x := randf_range(-shape.size.x / 2, shape.size.x / 2) + collider.global_position.x
		var y := randf_range(-shape.size.y / 2, shape.size.y / 2) + collider.global_position.y
		_spawn_npc_from_position(Vector2(x, y), _setup_pedestrian)


func _spawn_early_work_leavers() -> void:
	var progress := ProgressManager.progress.get_total_subvertisement_count()
	var chance := 0.0
	if progress < 6:
		chance = 0.7
	elif process_mode < 12:
		chance = 0.5
	elif process_mode < 18:
		chance = 0.5
	elif process_mode < 24:
		chance = 0.9
	for door in sources.get_children().filter(func(source: Node) -> bool: return source is Door):
		if randf() < chance:
			var amount := clampi(floori(absf(randfn(0.0, 1.0))), 1, 3)
			_spawn_npc_from_building(door as Door, _setup_worker, amount)
	await get_tree().create_timer(6.0).timeout
	for door in sources.get_children().filter(func(source: Node) -> bool: return source is Door):
		if randf() < chance * 0.8:
			var amount := clampi(floori(absf(randfn(0.0, 1.0))), 1, 2)
			_spawn_npc_from_building(door as Door, _setup_worker, amount)


func _spawn_work_leavers() -> void:
	var progress := ProgressManager.progress.get_total_subvertisement_count()
	var chance := 0.0 # TODO: Tweak the numbers
	if progress < 6:
		chance = 0.7
	elif process_mode < 12:
		chance = 0.5
	elif process_mode < 18:
		chance = 0.5
	elif process_mode < 24:
		chance = 0.9
	for door in sources.get_children().filter(func(source: Node) -> bool: return source is Door):
		if randf() < chance:
			var amount := clampi(floori(absf(randfn(0.0, 1.0))), 1, 3)
			_spawn_npc_from_building(door as Door, _setup_worker, amount)
	await get_tree().create_timer(6.0).timeout
	for door in sources.get_children().filter(func(source: Node) -> bool: return source is Door):
		if randf() < chance * 0.8:
			var amount := clampi(floori(absf(randfn(0.0, 1.0))), 1, 2)
			_spawn_npc_from_building(door as Door, _setup_worker, amount)  


func _spawn_late_work_leavers() -> void:
	var progress := ProgressManager.progress.get_total_subvertisement_count()
	var chance := 0.0
	if progress < 6:
		chance = 0.9
	elif process_mode < 12:
		chance = 0.7
	elif process_mode < 18:
		chance = 0.4
	elif process_mode < 24:
		chance = 0.1
	for door in sources.get_children().filter(func(source: Node) -> bool: return source is Door):
		if randf() < chance:
			var amount := clampi(floori(absf(randfn(0.0, 1.0))), 1, 2)
			_spawn_npc_from_building(door as Door, _setup_worker, amount)
	await get_tree().create_timer(6.0).timeout
	for door in sources.get_children().filter(func(source: Node) -> bool: return source is Door):
		if randf() < chance * 0.8:
			_spawn_npc_from_building(door as Door, _setup_worker)


func _spawn_party_goers() -> void:
	var progress := ProgressManager.progress.get_total_subvertisement_count()
	var chance := 0.0
	if progress < 6:
		chance = 0.9
	elif process_mode < 12:
		chance = 0.7
	elif process_mode < 18:
		chance = 0.4
	elif process_mode < 24:
		chance = 0.9
	for map_edge in sources.get_children().filter(func(source: Node) -> bool: return not source is Door):
		if randf() < chance:
			_spawn_npc_from_source(map_edge as NPCSource, _setup_partier)


func _spawn_officers() -> void:
	var progress := ProgressManager.progress.get_total_subvertisement_count()
	var officer_number := 0
	if progress < 6:
		return
	elif progress <= 12: 
		officer_number = randi_range(1, 3)
	elif progress <= 18:
		officer_number = randi_range(2, 4)
	elif progress <= 20:
		officer_number = randi_range(2, 3)
	
	var map_edges := sources.get_children().filter(func(source: Node) -> bool: return not source is Door)
	map_edges.shuffle()
	for i in officer_number:
		var source := map_edges[i] as NPCSource
		_spawn_npc_from_source(source, _setup_officer)


func _spawn_npc_from_building(door: Door, setup_func: Callable, amount: int = 1) -> void:
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
		await _setup_npc(npc, setup_func, pos, destination.global_position)
	door.close()


func _spawn_npc_from_source(source: NPCSource, setup_func: Callable) -> void:
	var destination := source.destinations.pick_random() as Marker2D
	var npc := NPC_CLASS.instantiate() as NPC
	await _setup_npc(npc, setup_func, source.global_position, destination.global_position)


func _spawn_npc_from_position(location: Vector2, setup_func: Callable) -> void:
	var destination := destinations.get_children().pick_random() as Marker2D
	var npc := NPC_CLASS.instantiate() as NPC
	await _setup_npc(npc, setup_func, location, destination.global_position)


func _setup_npc(npc: NPC, setup: Callable, initial_pos: Vector2, final_pos: Vector2) -> NPC:
	setup.call(npc)
	npc_list.add_child(npc)
	await get_tree().process_frame
	npc.global_position = initial_pos
	npc.move_to(final_pos)
	npc.reached_destination.connect(_remove_npc.bind(npc))
	return npc


func _remove_npc(npc: NPC) -> void:
	npc.queue_free()


func _setup_officer(npc: NPC) -> void:
	npc.sprite_frames = OFFICER_SPRITE_FRAMES.pick_random() as SpriteFrames
	npc.propriety = 1.0
	npc.happiness = -1.0
	npc.aggression = 1.0
	npc.awareness = 1.0


func _setup_worker(npc: NPC) -> void:
	var happiness: float
	var aggression: float
	var progress := ProgressManager.progress.get_total_subvertisement_count()
	if progress < 6:
		happiness = randf_range(-1, 0.3)
		aggression = randf_range(0, 1)
	elif progress <= 12: 
		happiness = randf_range(-1, 1)
		aggression = randf_range(0, 1)
	elif progress <= 18:
		happiness = randf_range(-1, 1)
		aggression = randf_range(-1, 1)
	elif progress <= 20:
		happiness = randf_range(-0.3, 1)
		aggression = randf_range(-1, 0)
	npc.sprite_frames = WORKER_SPRITE_FRAMES.pick_random() as SpriteFrames
	npc.propriety = randf_range(0.0, 1.0)
	npc.happiness = happiness
	npc.aggression = aggression
	npc.awareness = randf_range(-1, 1)


func _setup_partier(npc: NPC) -> void:
	npc.sprite_frames = PARTY_SPRITE_FRAMES.pick_random() as SpriteFrames
	npc.propriety = randf_range(-1, 0.4)
	npc.happiness = randf_range(-0.3, 1.0)
	npc.aggression = randf_range(-1, 1)
	npc.awareness = randf_range(-1, 0)


func _setup_pedestrian(npc: NPC) -> void:
	var happiness: float
	var aggression: float
	var propriety: float
	var progress := ProgressManager.progress.get_total_subvertisement_count()
	if progress < 6:
		happiness = randf_range(-1, 0.3)
		aggression = randf_range(0, 1)
		propriety = randf_range(-1, 1)
	elif progress <= 12: 
		happiness = randf_range(-1, 1)
		aggression = randf_range(0, 1)
		propriety = randf_range(-0.5, 1)
	elif progress <= 18:
		happiness = randf_range(-1, 1)
		aggression = randf_range(-1, 1)
		propriety = randf_range(-1, 1)
	elif progress <= 20:
		happiness = randf_range(-0.3, 1)
		aggression = randf_range(-1, 0)
		propriety = randf_range(-1, 0)
	npc.sprite_frames = REGULAR_PEOPLE_SPRITE_FRAMES.pick_random() as SpriteFrames
	npc.propriety = propriety
	npc.happiness = happiness
	npc.aggression = aggression
	npc.awareness = randf_range(-1, 1)
