extends Node2D

const SHEET := preload("res://assets/player sheet with hair.png")

func _ready() -> void:
	var image := SHEET.get_image()

	var frames := DuckSheetParser.create_sprite_frames(image)

	if frames == null:
		print("FAILED: Could not create SpriteFrames.")
		return

	var sprite := AnimatedSprite2D.new()
	sprite.sprite_frames = frames
	sprite.animation = "walk"
	sprite.position = Vector2(300, 200)
	sprite.scale = Vector2(3, 3)

	add_child(sprite)

	sprite.play("walk")
