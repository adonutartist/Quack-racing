extends Node3D
@onready var speed_gauge: Control = $HUD/Dashboard/SpeedGauge
@onready var position_gauge: Control = $HUD/Dashboard/PositionGauge
@onready var fatigue_gauge: Control = $HUD/Dashboard/FatigueGauge
var bot_names := [
	"Captain Nemo-no-wings", "Found Him It’s Nemo", "Nemo The Honkfish", 
	"Finding Nemo’s Gecko", "Geck-O’s Cereal", "Insurance Rep 404",
	"15 Percent Or More", "Sticky Toes McGee", "Sir Wall Crawler",
	"Cobra Chicken 3000", "Goosey McGooseFace", "Long Neck Larry", 
	"Quack-a-Doodle-Don't", "Webby McWaddles", "Sharkbait Gecko Ha Ha", 
	"Breadcrumb Bandit", "Mayo Chicken", "Nemo The Wall Crawler", 
	"Honk.exe Has Crashed", "Tail Drop Timmy", "Toe Nibbler 9000"
]
var bot_scene = preload("res://scenes/Duck3D.tscn")
var lane_spacing: float = 45.0
var duck_y: float = -245.0
@onready var player: CharacterBody3D = $Duck3D
@onready var camera: Camera3D = $RaceCamera
func _ready() -> void:
	for i in range(1, 10):
		spawn_bot(i, (i - 5) * lane_spacing)
func _process(_delta: float) -> void:
	camera.position.x = player.position.x
	update_dashboard()
func update_dashboard() -> void:
	# SPEED / CLICKS PER SECOND
	speed_gauge.value = player.smash_cps
	
	# FATIGUE
	var race_progress: float = clamp(
		player.position.x / player.finish_x,
		0.0,
		1.0
	)
	fatigue_gauge.value = race_progress * 100.0
	
	# POSITION
	var racers: Array[Node] = []
	for child in get_children():
		if child is CharacterBody3D:
			racers.append(child)
	racers.sort_custom(
		func(a: Node, b: Node) -> bool:
			return a.position.x > b.position.x
	)
	var player_position: int = racers.find(player) + 1
	position_gauge.value = player_position
	
	# REDRAW
	speed_gauge.queue_redraw()
	position_gauge.queue_redraw()
	fatigue_gauge.queue_redraw()
func spawn_bot(bot_number: int, z_position: float) -> void:
	var bot = bot_scene.instantiate()
	bot.name = "Bot" + str(bot_number)
	bot.position = Vector3(
		150.0,
		duck_y,
		z_position
	)
	bot.is_bot = true
	bot.racer_name = bot_names[bot_number - 1]
	bot.max_speed = randf_range(300.0, 520.0)
	bot.smash_power = randf_range(25.0, 50.0)
	bot.slowdown = randf_range(14.0, 25.0)
	add_child(bot)
	bot.scale = player.scale
	var bot_sprite: AnimatedSprite3D = bot.get_node("Sprite")
	bot_sprite.no_depth_test = true
	bot_sprite.visible = true
	bot_sprite.scale = Vector3(50.0, 50.0, 50.0)
