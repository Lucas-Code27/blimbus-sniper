extends Control

@onready var camera: Camera2D = $SubViewportContainer/SubViewport/Camera2D
@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport


func _input(_event: InputEvent) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_UP):
		camera.zoom += Vector2(0.1, 0.1)
		camera.zoom = camera.zoom.minf(3.0)
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_DOWN):
		camera.zoom -= Vector2(0.1, 0.1)
		camera.zoom = camera.zoom.maxf(Global.game_camera.zoom.x)

func _ready() -> void:
	sub_viewport.world_2d = get_tree().root.world_2d
	get_parent().get_viewport().get_camera_2d().draw.connect(_on_camera_draw)

func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()
	camera.global_position = (get_global_mouse_position() / Global.game_camera.zoom) - (get_viewport().get_visible_rect().size / (2 * Global.game_camera.zoom))
	get_parent().get_viewport().get_camera_2d().queue_redraw()

func _on_camera_draw() -> void:
	get_parent().get_viewport().get_camera_2d().draw_rect(Rect2(camera.global_position + ((Vector2(256, 256) / camera.zoom) / -2), Vector2(256, 256) / camera.zoom), Color(0.0, 1.0, 1.0, 0.102))
