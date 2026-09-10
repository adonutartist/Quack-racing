extends Node2D
var bot_scene = preload("res://scenes/Duck.tscn")
var lane_spacing: float = 65.0
var start_y: float = 65.0
func _ready() -> void:
	for i in range(1, 10):
		spawn_bot(1, start_y + i * lane_spacing)
func spawn_bot(bot_number: int, y_position: float) -> void:
	var bot = bot_scene.instantiate()
	bot.name = "Bot" + str(bot_number)
	bot.position = Vector2(150.0, y_position)
	bot.is_bot = true
	bot.max_speed = randf_range(300.0, 520.0)
	bot.smash_power = randf_range(25.0, 50.0)
	bot.slowdown = randf_range(14.0, 25.0)
	add_child(bot)
