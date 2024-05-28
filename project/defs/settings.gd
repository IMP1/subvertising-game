class_name Settings
extends Resource

enum QuickTimeEventOptions {
	MOUSE_INPUT,
	BUTTON_INPUT,
	AUTO_SOLVE
}

@export var volume_master: float = 100.0
@export var volume_music: float = 100.0
@export var volume_sounds: float = 100.0
@export var volume_ui: float = 100.0
@export var accessibility_qte: QuickTimeEventOptions = QuickTimeEventOptions.MOUSE_INPUT
@export var type_speed: float = 1.0
@export var show_tutorials: bool = true
