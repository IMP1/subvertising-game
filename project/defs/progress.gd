class_name Progress
extends Resource

const STARTING_ART: Array[Texture2D] = [
	preload("res://assets/graphics/artwork/nearest-park.png"),
	preload("res://assets/graphics/artwork/take-a-breath.png"),
]

@export var day: int = 1
@export var night_time: bool = false
@export var subverted_advert_count: int = 0
@export var artwork: Array[Texture2D] = STARTING_ART.duplicate() as Array[Texture2D]
