extends CharacterBody3D
@onready var shadow: Sprite3D = $Shadow
var racer_name: String = "YOU"
var smash_times: Array[float] = []
var smash_cps: float = 0.0
@onready var name_label: Label3D = $NameLabel
var is_bot: bool = false
var finish_x: float = 5500.0
var speed: float = 0.0
var max_speed: float = 500.0
var smash_power: float = 40.0
var slowdown: float = 20.0
var bot_smash_timer: float = 0.0
var has_finished: bool = false
@onready var sprite: AnimatedSprite3D = $Sprite
@onready var dust_particles: GPUParticles3D = $DustParticles
const DUCK_SHEET := preload("res://assets/player sheet.png")
func _ready() -> void:
	setup_shadow()
	setup_animations()
	sprite.no_depth_test = true
	shadow.no_depth_test = true
	name_label.text = racer_name + "\n▼"
	sprite.play("idle")
	start_idle_bounce()
func setup_shadow() -> void:
	var source_image: Image = Image.load_from_file(
		"res://assets/player sheet.png"
	)
	var duck_image: Image = source_image.get_region(
		Rect2i(0, 0, 100, 100)
	)
	var shadow_image := Image.create(
		180,
		100,
		false,
		Image.FORMAT_RGBA8
	)
	shadow_image.fill(Color(0, 0, 0, 0))
	for y in range(100):
		for x in range(100):
			var pixel: Color = duck_image.get_pixel(x, y)
			if pixel.a > 0.1:
				var progress := 1.0 - (float(y) / 100.0)
				var shadow_x := int(
					x - progress * 70.0
				)
				var shadow_y := int(
					85.0 - progress * 45.0
				)
				if shadow_x >= 0 and shadow_x < 180:
					if shadow_y >= 0 and shadow_y < 100:
						shadow_image.set_pixel(
							shadow_x,
							shadow_y,
							Color(0, 0, 0, 0.30)
						)
	shadow.texture = ImageTexture.create_from_image(
		shadow_image
	)
func start_idle_bounce() -> void:
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(
		sprite,
		"scale",
		Vector3(1.04, 0.96, 1.0),
		0.35
	)
	tween.tween_property(
		sprite,
		"scale",
		Vector3(0.97, 1.03, 1.0),
		0.25
	)
	tween.tween_property(
		sprite,
		"scale",
		Vector3(1.0, 1.0, 1.0),
		0.30
	)
func setup_animations() -> void:
	var frames := SpriteFrames.new()
	# IDLE
	frames.add_animation("idle")
	frames.set_animation_speed("idle", 1.0)
	frames.set_animation_loop("idle", true)
	frames.add_frame(
		"idle",
		make_frame(Rect2(0, 0, 100, 100))
	)

	# WALK
	frames.add_animation("walk")
	frames.set_animation_speed("walk", 6.0)
	frames.set_animation_loop("walk", true)
	frames.add_frame(
		"walk",
		make_frame(Rect2(0, 128, 100, 100))
	)
	frames.add_frame(
		"walk",
		make_frame(Rect2(100, 128, 100, 100))
	)

	# RUN
	frames.add_animation("run")
	frames.set_animation_speed("run", 10.0)
	frames.set_animation_loop("run", true)
	frames.add_frame(
		"run",
		make_frame(Rect2(0, 256, 100, 100))
	)
	frames.add_frame(
		"run",
		make_frame(Rect2(100, 256, 100, 100))
	)
	sprite.sprite_frames = frames
func make_frame(region: Rect2) -> AtlasTexture:
	var frame := AtlasTexture.new()
	frame.atlas = DUCK_SHEET
	frame.region = region
	return frame
func _process(delta: float) -> void:
	if has_finished:
		speed = move_toward(speed, 0.0, 250.0 * delta)
		position.x += speed * delta
		update_animation()
		update_particles()
		return
	var race_progress: float = clamp(
		position.x / finish_x,
		0.0,
		1.0
	)
	if is_bot:
		bot_smash_timer -= delta
		if bot_smash_timer <= 0.0:
			speed += smash_power
			speed = min(speed, max_speed)
			bot_smash_timer = randf_range(0.08, 0.25)
	else:
		if Input.is_action_just_pressed("smash"):
			speed += smash_power
			speed = min(speed, max_speed)
			smash_times.append(Time.get_ticks_msec() / 1000.0)
	
	# CALCULATE CPS
	var current_time: float = Time.get_ticks_msec() / 1000.0
	while not smash_times.is_empty() and current_time - smash_times[0] > 1.0:
		smash_times.pop_front()
	smash_cps = float(smash_times.size())
	var current_slowdown: float = lerp(
		slowdown,
		slowdown * 4.0,
		race_progress
	)
	speed -= current_slowdown * delta
	if speed < 20.0:
		speed = 0.0
	position.x += speed * delta
	if position.x >= finish_x - 120.0:
		has_finished = true
	update_animation()
	update_particles()
func update_animation() -> void:
	if has_finished:
		sprite.speed_scale = 1.0
		if sprite.animation != "idle":
			sprite.play("idle")
		return
	if speed < 20.0:
		sprite.speed_scale = 1.0
		if sprite.animation != "idle":
			sprite.play("idle")
	elif sprite.animation == "idle":
		sprite.speed_scale = 1.0
		sprite.play("walk")
	elif sprite.animation == "walk":
		sprite.speed_scale = 1.0
		if speed > 370.0:
			sprite.play("run")
	elif sprite.animation == "run":
		if speed < 320.0:
			sprite.speed_scale = 1.0
			sprite.play("walk")
		else:
			sprite.speed_scale = lerp(
				1.0,
				2.0,
				(speed - 350.0) / 150.0
			)
func update_particles() -> void:
	if speed < 120.0:
		dust_particles.emitting = false
		return
	dust_particles.emitting = true
	var particle_amount := int(
		lerp(2.0, 8.0, speed / max_speed)
	)
	dust_particles.amount = particle_amount
