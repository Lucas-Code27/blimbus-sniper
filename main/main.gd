extends Node

@onready var camera: Camera2D = $Camera
@onready var crosshair_layer: CanvasLayer = $CrosshairLayer
@onready var poster: Poster = $CanvasLayer/Control/Poster

@onready var failure_layer: CanvasLayer = $FailureLayer
@onready var score_text: Label = $FailureLayer/ScoreText
@onready var fail_text: Label = $FailureLayer/FailText

@onready var success_layer: CanvasLayer = $SuccessLayer

@onready var aim_sound: AudioStreamPlayer = $AimSound
@onready var shoot_sound: AudioStreamPlayer = $ShootSound
@onready var unaim_sound: AudioStreamPlayer = $UnaimSound

@onready var round_timer: Timer = $RoundTimer
@onready var time_left: ProgressBar = $CanvasLayer/ProgressBar

var game_over: bool = false

var guy_amount: int = 80 + (10 * Global.score)

const GUY_SCENE = preload("res://person/person.tscn")

func _input(event: InputEvent) -> void:
	if game_over:
		return
	
	if event.is_action_pressed("aim"):
		aim_sound.play()
	elif event.is_action_released("aim"):
		unaim_sound.play()

func _ready() -> void:
	get_tree().paused = false
	Global.person_shot.connect(_on_person_shot)
	
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	Global.game_camera = camera
	camera.zoom *= move_toward(1, 0.33, Global.score * 0.04)
	
	# Make villain then the civilians
	var guy_inst: Person = GUY_SCENE.instantiate()
	add_child(guy_inst)
	guy_inst.global_position = Global.get_spawn_location()
	guy_inst.create_villain()
	
	for i in guy_amount - 1:
		_spawn_guy()
	
	poster.set_poster()

func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("aim"):
		crosshair_layer.show()
		Global.aiming = true
	else:
		crosshair_layer.hide()
		Global.aiming = false

func _process(_delta: float) -> void:
	time_left.value = round_timer.time_left / round_timer.wait_time
	
	if time_left.value < 0.3:
		time_left.modulate = Color.RED

func _spawn_guy() -> void:
	var guy_inst: Person = GUY_SCENE.instantiate()
	add_child(guy_inst)
	guy_inst.global_position = Global.get_spawn_location()
	guy_inst.create_civilian()

func _on_person_shot(villain: bool) -> void:
	round_timer.stop()
	game_over = true
	shoot_sound.play()
	
	if villain:
		get_tree().paused = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		success_layer.show()
	else:
		get_tree().paused = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
		await get_tree().physics_frame
		for child in get_children():
			if child is Person:
				if not child.villain:
					child.queue_free()
			
			await get_tree().create_timer(0.5 / guy_amount).timeout
		
		score_text.text = "Score: " + str(Global.score)
		failure_layer.show()


func _on_button_pressed() -> void:
	Global.score = 0
	get_tree().reload_current_scene()

func _on_next_pressed() -> void:
	Global.score += 1
	get_tree().reload_current_scene()

func _on_round_timer_timeout() -> void:
	game_over = true
	
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	score_text.text = "Score: " + str(Global.score)
	fail_text.text = "The Target Got Away!"
	
	await get_tree().physics_frame
	for child in get_children():
			if child is Person:
				if not child.villain:
					child.queue_free()
			
			await get_tree().create_timer(0.5 / guy_amount).timeout
	
	failure_layer.show()
