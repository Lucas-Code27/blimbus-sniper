class_name Person extends Node2D

const SPEED = 50.0

var villain: bool = false

@onready var move_timer: Timer = $MoveTimer

@onready var face: AnimatedSprite2D = $Face
@onready var accessory: AnimatedSprite2D = $Accessory

func create_villain() -> void:
	#modulate = Color.RED
	villain = true
	
	accessory.frame = randi_range(0, accessory.sprite_frames.get_frame_count(&"default") - 1)
	face.frame = randi_range(0, face.sprite_frames.get_frame_count(&"default") - 1)
	Global.villain_face = face.frame
	Global.villain_accessory = accessory.frame

func create_civilian() -> void:
	accessory.frame = randi_range(0, accessory.sprite_frames.get_frame_count(&"default") - 1)
	
	var face_options: Array = range(face.sprite_frames.get_frame_count(&"default"))
	face_options.remove_at(Global.villain_face)
	
	face.frame = face_options.pick_random()

func _on_move_timer_timeout() -> void:
	var target_location: Vector2 = Global.get_spawn_location()
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", target_location, global_position.distance_to(target_location) / SPEED)
	await tween.finished
	
	move_timer.start()

func _on_hitbox_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("shoot") and Global.aiming:
		Global.kill_person(villain)
		queue_free()
