extends Control
@export var title: String = "SPEED"
@export var unit: String = "CPS"
@export var max_value: float = 20.0
@export var reverse: bool = false
var value: float = 0.0
func _ready() -> void:
	queue_redraw()
func _draw() -> void:
	var center: Vector2 = size / 2.0
	var radius: float = min(size.x, size.y) * 0.42

	# OUTER CIRCLE
	draw_arc(
		center,
		radius,
		0.0,
		TAU,
		64,
		Color.WHITE,
		3.0
	)

	# TICK MARKS + NUMBERS
	var tick_count: int = 11
	if reverse:
		tick_count = 10
	for i in range(tick_count):
		var ratio: float
		if reverse:
			ratio = float(i) / 9.0
		else:
			ratio = float(i) / 10.0
		var angle: float = deg_to_rad(
			135.0 + ratio * 270.0
		)
		var outer: Vector2 = center + Vector2(
			cos(angle),
			sin(angle)
		) * radius
		var inner: Vector2 = center + Vector2(
			cos(angle),
			sin(angle)
		) * (radius - 12.0)
		draw_line(
			inner,
			outer,
			Color.WHITE,
			2.0
		)
		var number: String
		if reverse:
			number = str(
				int(max_value - (max_value - 1.0) * ratio)
			)
		else:
			number = str(
				int(max_value * ratio)
			)
		var text_position: Vector2 = center + Vector2(
			cos(angle),
			sin(angle)
		) * (radius - 30.0)
		draw_string(
			ThemeDB.fallback_font,
			text_position - Vector2(10, -5),
			number,
			HORIZONTAL_ALIGNMENT_CENTER,
			20,
			14,
			Color.WHITE
		)

	# NEEDLE
	var needle_ratio: float = clamp(
		value / max_value,
		0.0,
		1.0
	)
	if reverse:
		needle_ratio = 1.0 - ((value - 1.0) / (max_value - 1.0))
	var needle_angle: float = deg_to_rad(
		135.0 + needle_ratio * 270.0
	)
	var needle_end: Vector2 = center + Vector2(
		cos(needle_angle),
		sin(needle_angle)
	) * (radius - 18.0)
	draw_line(
		center,
		needle_end,
		Color.WHITE,
		5.0
	)

	# CENTER HUB
	draw_circle(
		center,
		8.0,
		Color.WHITE
	)

	# VALUE
	var value_text: String = str(round(value))
	draw_string(
		ThemeDB.fallback_font,
		center + Vector2(-30, 55),
		value_text,
		HORIZONTAL_ALIGNMENT_CENTER,
		60,
		22,
		Color.WHITE
	)
	
	# UNIT
	draw_string(
		ThemeDB.fallback_font,
		center + Vector2(-30, 78),
		unit,
		HORIZONTAL_ALIGNMENT_CENTER,
		60,
		12,
		Color.WHITE
	)
	
	# TITLE
	draw_string(
		ThemeDB.fallback_font,
		center + Vector2(-50, radius + 30),
		title,
		HORIZONTAL_ALIGNMENT_CENTER,
		100,
		14,
		Color.WHITE
	)
