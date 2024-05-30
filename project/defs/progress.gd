class_name Progress
extends Resource

const HOME_ARTWORK_DAY_1: Array[Texture2D] = [
	preload("res://assets/graphics/artwork/take-a-breath.png"),
]
const HOUSING_COOP_ARTWORK_DAY_1: Array[Texture2D] = [
	preload("res://assets/graphics/artwork/saint-or-communist.png"),
]
const PRINTERS_ARTWORK_DAY_1: Array[Texture2D] = []
const ART_STUDIO_ARTWORK_DAY_1: Array[Texture2D] = [
	preload("res://assets/graphics/artwork/ergo-sum.png"),
]
const BOOKSHOP_ARTWORK_DAY_1: Array[Texture2D] = []

const HOME_ARTWORK_DAY_2: Array[Texture2D] = [
	preload("res://assets/graphics/artwork/black.png"),
]
const HOUSING_COOP_ARTWORK_DAY_2: Array[Texture2D] = []
const PRINTERS_ARTWORK_DAY_2: Array[Texture2D] = [
	preload("res://assets/graphics/artwork/brain.png"),
	preload("res://assets/graphics/artwork/leaves.png"),
]
const ART_STUDIO_ARTWORK_DAY_2: Array[Texture2D] = []
const BOOKSHOP_ARTWORK_DAY_2: Array[Texture2D] = [
	preload("res://assets/graphics/artwork/fuck-work.png"),
]

const HOME_ARTWORK_DAY_3: Array[Texture2D] = [
	preload("res://assets/graphics/artwork/nearest-park.png"),
	preload("res://assets/graphics/artwork/nearest-library.png"),
]
const HOUSING_COOP_ARTWORK_DAY_3: Array[Texture2D] = [
	preload("res://assets/graphics/artwork/garden.png"),
]
const PRINTERS_ARTWORK_DAY_3: Array[Texture2D] = [
	preload("res://assets/graphics/artwork/boss-haiku.png"),
]
const ART_STUDIO_ARTWORK_DAY_3: Array[Texture2D] = [
	preload("res://assets/graphics/artwork/lies.png"),
]
const BOOKSHOP_ARTWORK_DAY_3: Array[Texture2D] = []

const HOME_ARTWORK_DAY_4: Array[Texture2D] = [
	preload("res://assets/graphics/artwork/buy-more.png"),
]
const HOUSING_COOP_ARTWORK_DAY_4: Array[Texture2D] = [
	preload("res://assets/graphics/artwork/sonic.png"),
]
const PRINTERS_ARTWORK_DAY_4: Array[Texture2D] = []
const ART_STUDIO_ARTWORK_DAY_4: Array[Texture2D] = []
const BOOKSHOP_ARTWORK_DAY_4: Array[Texture2D] = []

const HOME_ARTWORK_DAY_5: Array[Texture2D] = [
	preload("res://assets/graphics/artwork/black.png"),
]
const HOUSING_COOP_ARTWORK_DAY_5: Array[Texture2D] = []
const PRINTERS_ARTWORK_DAY_5: Array[Texture2D] = [
	preload("res://assets/graphics/artwork/tony-says.png"),
]
const ART_STUDIO_ARTWORK_DAY_5: Array[Texture2D] = [
	preload("res://assets/graphics/artwork/life-is-great.png"),
]
const BOOKSHOP_ARTWORK_DAY_5: Array[Texture2D] = [
	preload("res://assets/graphics/artwork/trickle-down.png"),
]

const HOME_ARTWORK_DAY_6: Array[Texture2D] = [
	preload("res://assets/graphics/artwork/black.png"),
]
const HOUSING_COOP_ARTWORK_DAY_6: Array[Texture2D] = [
	preload("res://assets/graphics/artwork/common.png"),
]
const PRINTERS_ARTWORK_DAY_6: Array[Texture2D] = [
	preload("res://assets/graphics/artwork/boss-haiku.png"),
]
const ART_STUDIO_ARTWORK_DAY_6: Array[Texture2D] = []
const BOOKSHOP_ARTWORK_DAY_6: Array[Texture2D] = []

const HOME_ARTWORK_DAY_7: Array[Texture2D] = [
	preload("res://assets/graphics/artwork/nearest-park.png"),
	preload("res://assets/graphics/artwork/nearest-library.png"),
]
const HOUSING_COOP_ARTWORK_DAY_7: Array[Texture2D] = [
	preload("res://assets/graphics/artwork/sonic.png"),
]
const PRINTERS_ARTWORK_DAY_7: Array[Texture2D] = []
const ART_STUDIO_ARTWORK_DAY_7: Array[Texture2D] = [
	preload("res://assets/graphics/artwork/ergo-sum.png"),
]
const BOOKSHOP_ARTWORK_DAY_7: Array[Texture2D] = []

const HOME_ARTWORK_DAY_8: Array[Texture2D] = [
	preload("res://assets/graphics/artwork/take-a-breath.png"),
]
const HOUSING_COOP_ARTWORK_DAY_8: Array[Texture2D] = []
const PRINTERS_ARTWORK_DAY_8: Array[Texture2D] = [
	preload("res://assets/graphics/artwork/leaves.png"),
]
const ART_STUDIO_ARTWORK_DAY_8: Array[Texture2D] = []
const BOOKSHOP_ARTWORK_DAY_8: Array[Texture2D] = [
	preload("res://assets/graphics/artwork/fuck-work.png"),
	preload("res://assets/graphics/artwork/brain.png"),
	preload("res://assets/graphics/artwork/trickle-down.png"),
]

const HOME_ARTWORK_DAY_9: Array[Texture2D] = [
	preload("res://assets/graphics/artwork/buy-more.png"),
]
const HOUSING_COOP_ARTWORK_DAY_9: Array[Texture2D] = [
	preload("res://assets/graphics/artwork/saint-or-communist.png"),
]
const PRINTERS_ARTWORK_DAY_9: Array[Texture2D] = [
	preload("res://assets/graphics/artwork/tony-says.png"),
]
const ART_STUDIO_ARTWORK_DAY_9: Array[Texture2D] = [
	preload("res://assets/graphics/artwork/lies.png"),
	preload("res://assets/graphics/artwork/life-is-great.png"),
]
const BOOKSHOP_ARTWORK_DAY_9: Array[Texture2D] = []

@export var day: int = 1
@export var ad_production_day: int = 1
@export var night_time: bool = false
@export var artwork: Array[Texture2D] = []
@export var advert_subverted_count: Array[int] = [0, 0, 0, 0, 0]
@export var newspaper_stage: int = 0

@export var available_artworks_housing_coop: Array[Texture2D] = []
@export var available_artworks_printers: Array[Texture2D] = []
@export var available_artworks_art_studio: Array[Texture2D] = []
@export var available_artworks_bookshop: Array[Texture2D] = []
@export var available_artworks_home: Array[Texture2D] = []


func get_total_subvertisement_count() -> int:
	return advert_subverted_count.reduce(func(sum, n): return sum + n, 0)


func increase_subvertisement_count(advert_index: int, amount: int = 1) -> void:
	advert_subverted_count[advert_index] += amount
