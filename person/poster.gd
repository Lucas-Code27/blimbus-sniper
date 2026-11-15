class_name Poster extends Node2D

@onready var face: AnimatedSprite2D = $Face
@onready var accessory: AnimatedSprite2D = $Accessory

func set_poster() -> void:
	face.frame = Global.villain_face
	accessory.frame = Global.villain_accessory
