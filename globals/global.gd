extends Node

signal person_shot(villain: bool)

var game_camera: Camera2D

const BORDER_PADDING = 60

var aiming: bool = false

var villain_face: int
var villain_accessory: int

var score: int = 0

func get_spawn_location() -> Vector2:
	var spawn_area: Rect2 = Rect2(Global.game_camera.global_position, get_viewport().get_visible_rect().size / game_camera.zoom)
	
	return Vector2(
		spawn_area.position.x + randf_range((-spawn_area.size.x / 2) + BORDER_PADDING, (spawn_area.size.x / 2) - BORDER_PADDING),
		spawn_area.position.y + randf_range((-spawn_area.size.y / 2) + BORDER_PADDING, (spawn_area.size.y / 2) - BORDER_PADDING)
	)

func kill_person(villain: bool) -> void:
	person_shot.emit(villain)
