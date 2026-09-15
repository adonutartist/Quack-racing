extends Control
var target_radius: float = 115.0
var target_speed: float = 85.0
var hit_radius: float = 55.0
var start_hit_width: float = 22.0
var end_hit_width: float = 6.0
var perfect_width: float = 8.0
var good_width: float = 22.0
var race_progress: float = 0.0
var active: bool = true
func set_race_progress(progress: float) -> void:
	race_progress = clamp(progress, 0.0, 1.0)
	queue_redraw()
func free() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()
func _process(delta: float) -> void:
	if not active:
		return
	target_radius -= target_speed * delta
	if target_radius < 20.0:
		reset_target()
	queue_redraw()
func reset_target() -> void:
	target_radius = 115.0
func get_hit_quality() -> String:
	var current_good_width: float = lerp(
		good_width,
		6.0,
		race_progress
	)
	var current_perfect_width: float = lerp(
		perfect_width,
		3.0,
		race_progress
	)
	var difference: float = abs(target_radius - hit_radius)
	if difference <= current_perfect_width:
		reset_target()
		return "perfect"
	if difference <= current_good_width:
		reset_target()
		return "good"
	reset_target()
	return "miss"
func _draw() -> void:
	var center: Vector2 = size / 2.0
	#HIT ZONE
	var current_hit_width: float = lerp(
		start_hit_width,
		end_hit_width,
		race_progress
	)
	draw_arc(
		center,
		hit_radius,
		0.0,
		TAU,
		64,
		Color(0.3, 1.0, 0.5),
		current_hit_width
	)
	
	#TARGET RING
	draw_arc(
		center,
		target_radius,
		0.0,
		TAU,
		64,
		Color.WHITE,
		5.0
	)
	
	#CENTER
	draw_circle(
		center,
		5.0,
		Color.WHITE
	)
