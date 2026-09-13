extends Node3D

var bot_scene = preload("res://scenes/Duck3D.tscn")

var lane_spacing: float = 65.0

@onready var player: CharacterBody3D = $Duck3D
@onready var camera: Camera3D = $RaceCamera


func _ready() -> void:
	for i in range(1, 10):
		spawn_bot(i, (i - 5) * lane_spacing)


func _process(_delta: float) -> void:
	camera.position.x = player.position.x


func spawn_bot(bot_number: int, z_position: float) -> void:
	var bot = bot_scene.instantiate()

	bot.name = "Bot" + str(bot_number)

	bot.position = Vector3(
		150.0,
		5.0,
		z_position
	)

	bot.is_bot = true

	bot.max_speed = randf_range(300.0, 520.0)
	bot.smash_power = randf_range(25.0, 50.0)
	bot.slowdown = randf_range(14.0, 25.0)

	add_child(bot)

	bot.scale = player.scale

	var bot_sprite: AnimatedSprite3D = bot.get_node("Sprite")

	# Prevent the 3D track from hiding the 2D duck.
	bot_sprite.no_depth_test = true
	bot_sprite.visible = true

	# Same visual size as the player setup.
	bot_sprite.scale = Vector3(50.0, 50.0, 50.0)
