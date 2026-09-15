extends Node3D
var dash_pending: bool = false
var dash_active: bool = false
var dash_time: float = 0.0
var dash_duration: float = 0.5
var dash_strength: float = 220.0
var camera_shake_time: float = 0.0
var camera_shake_strength: float = 35.0
var start_countdown: float = 4.5
var countdown_started: bool = false
var race_started: bool = false
var start_combo: Array[String] = []
var combo_index: int = 0
var combo_success: bool = true
@onready var start_countdown_label: RichTextLabel = $HUD/StartCountdown
@onready var timing_ring: Control = $HUD/TimingRing
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
var lane_spacing: float = 32.0
var duck_y: float = -245.0
@onready var player: CharacterBody3D = $Duck3D
@onready var camera: Camera3D = $RaceCamera
func _ready() -> void:
	generate_start_combo()
	start_countdown_label.fit_content = true
	start_countdown_label.scroll_active = false
	update_intro_display()
	start_countdown_label.modulate.a = 0.0
	start_countdown_label.scale = Vector2(0.7, 0.7)
	var intro_tween := create_tween()
	intro_tween.set_parallel(true)
	intro_tween.tween_property(
		start_countdown_label,
		"modulate:a",
		1.0,
		0.35
	)
	intro_tween.tween_property(
		start_countdown_label,
		"scale",
		Vector2(1.0, 1.0),
		0.45
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	intro_tween.set_parallel(false)
	await intro_tween.finished
	await get_tree().create_timer(1.0).timeout
	countdown_started = true
	for i in range(1, 10):
		spawn_bot(i, (i - 5) * lane_spacing)
func _process(delta: float) -> void:
	if dash_active:
		dash_time += delta
		var jump_progress: float = dash_time / dash_duration
		if jump_progress < 0.5:
			player.position.y = lerp(
				-245.0,
				-175.0,
				jump_progress * 2.0
			)
		else:
			player.position.y = lerp(
				-175.0,
				-245.0,
				(jump_progress - 0.5) * 2.0
			)
		if dash_time >= dash_duration:
			dash_active = false
			player.position.y = -245.0
	if camera_shake_time > 0.0:
		camera_shake_time -= delta
		var shake_amount: float = camera_shake_strength * (
			camera_shake_time / 0.5
		)
		camera.position.x = player.position.x + randf_range(
			-shake_amount,
			shake_amount
		)
	else:
		camera.position.x = player.position.x
	if not race_started:
		if not countdown_started:
			return
		start_countdown -= delta
		if start_countdown > 0.0:
			var countdown_number: int = int(ceil(start_countdown))
			update_countdown_display(countdown_number)
			animate_countdown_number(countdown_number)
		else:
			race_started = true
			start_countdown_label.text = "QUACK!"
			if dash_pending:
				trigger_jump_dash()
				dash_pending = false
			for child in get_children():
				if child is CharacterBody3D and child.is_bot:
					if child.bot_dash_pending:
						child.trigger_bot_jump_dash()
						child.bot_dash_pending = false
			var go_tween := create_tween()
			start_countdown_label.scale = Vector2(1.5, 1.5)
			start_countdown_label.modulate.a = 1.0
			go_tween.set_parallel(true)
			go_tween.tween_property(
				start_countdown_label,
				"scale",
				Vector2(1.0, 1.0),
				0.35
			).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			go_tween.tween_property(
				start_countdown_label,
				"modulate:a",
				0.0,
				0.6
			)
			for child in get_children():
				if child is CharacterBody3D:
					child.race_started = true
		return
	var race_progress: float = clamp(
		player.position.x / player.finish_x,
		0.0,
		1.0
	)
	timing_ring.set_race_progress(race_progress)
	if Input.is_action_just_pressed("smash"):
		var quality: String = timing_ring.get_hit_quality()
		player.attempt_smash(quality)
	update_dashboard()
func update_dashboard() -> void:
	# SPEED / CLICKS PER SECOND
	speed_gauge.value = player.smash_cps
	
	# FATIGUE
	fatigue_gauge.value = player.fatigue
	
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
	bot.generate_bot_start_combo()
	bot.max_speed = randf_range(300.0, 520.0)
	bot.smash_power = randf_range(25.0, 50.0)
	bot.slowdown = randf_range(14.0, 25.0)
	add_child(bot)
	bot.scale = player.scale
	var bot_sprite: AnimatedSprite3D = bot.get_node("Sprite")
	bot_sprite.no_depth_test = true
	bot_sprite.visible = true
	bot_sprite.scale = Vector3(100.0, 100.0, 100.0)
func generate_start_combo() -> void:
	var letters := [
		"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"
	]
	start_combo.clear()
	for i in range(4):
		start_combo.append(
			letters.pick_random()
		)
	combo_index = 0
	combo_success = true
func _input(event: InputEvent) -> void:
	if race_started:
		return
	if not event is InputEventKey:
		return
	if not event.pressed or event.echo:
		return
	var key_name: String = OS.get_keycode_string(event.keycode)
	if key_name.length() != 1:
		return
	if not key_name in start_combo:
		combo_success = false
		start_countdown_label.text = "WRONG!"
		return
	if key_name == start_combo[combo_index]:
		combo_index += 1
		update_combo_display()
		if combo_index >= start_combo.size():
			update_countdown_display(int(ceil(start_countdown)))
			
			#COMBOBOOST
			dash_pending = true
			combo_success = true
	else:
		combo_success = false
func animate_countdown_number(_number: int) -> void:
	start_countdown_label.scale = Vector2(1.35, 1.35)
	start_countdown_label.modulate.a = 1.0
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		start_countdown_label,
		"scale",
		Vector2(1.0, 1.0),
		0.3
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		start_countdown_label,
		"modulate:a",
		0.65,
		0.3
	)
func update_combo_display() -> void:
	var combo_text := ""
	for i in range(start_combo.size()):
		if i < combo_index:
			combo_text += "[color=green]" + start_combo[i] + "[/color]"
		else:
			combo_text += "[color=red]" + start_combo[i] + "[/color]"
		if i < start_combo.size() - 1:
			combo_text += "   "
	start_countdown_label.text = (
		"[center]"
		+ "[font_size=48]Ready to WADDLE?[/font_size]"
		+ "\n\n"
		+ "[font_size=40]"
		+ combo_text
		+ "[/font_size]"
		+ "[/center]"
	)
func update_countdown_display(number: int) -> void:
	var combo_text := ""
	for i in range(start_combo.size()):
		if i < combo_index:
			combo_text += "[color=green]" + start_combo[i] + "[/color]"
		else:
			combo_text += "[color=red]" + start_combo[i] + "[/color]"
		if i < start_combo.size() - 1:
			combo_text += "   "
	start_countdown_label.text = (
		"[center]"
		+ "[font_size=64]"
		+ str(number)
		+ "[/font_size]"
		+ "\n\n"
		+ combo_text
		+ "[/center]"
	)
func update_intro_display() -> void:
	var combo_text := ""
	for i in range(start_combo.size()):
		combo_text += start_combo[i]
		if i < start_combo.size() - 1:
			combo_text += "   "
	start_countdown_label.text = (
		"Ready to WADDLE?"
		+ "\n\n"
		+ combo_text
	)
func trigger_jump_dash() -> void:
	print("JUMP DASH ACTIVATED")
	player.speed += 220.0
	player.speed = min(player.speed, player.max_speed)
	dash_active = true
	dash_time = 0.0
	camera_shake_time = 0.5
