extends Node2D
var speed: float = 0.0
var max_speed: float = 420.0
var smash_power: float = 30.0
var slowdown: float = 18.0
func _process(delta: float) -> void:
	speed += randf_range(-8.0, 8.0) * delta
	speed = clamp(speed, 100.0, max_speed)
	speed -= slowdown * delta
	speed = max(speed, 0.0)
	position.x += speed * delta
