extends Node2D
var is_bot: bool = false
var finish_x: float = 5500.0
var speed: float = 0.0
var max_speed: float = 500.0
var smash_power: float = 40.0
var slowdown: float = 20.0
var bot_smash_timer: float = 0.0
func _process(delta: float) -> void:
	var race_progress: float = clamp(position.x / finish_x, 0.0, 1.0)
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
	var current_slowdown: float = lerp(slowdown, slowdown * 3.5, race_progress)
	speed -= current_slowdown * delta
	speed = max(speed, 0.0)
	position.x += speed * delta
