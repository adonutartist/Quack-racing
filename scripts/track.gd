extends Node2D
var lane_count: int = 10
var lane_spacing: float = 65.0
var track_width: float = 6000.0
var line_thickness: float = 3.0
var start_y: float = 65.0
func _ready() -> void:
	for i in range(1, lane_count):
		var line := ColorRect.new()
		line.position = Vector2(0, start_y + i * lane_spacing)
		line.size = Vector2(track_width, line_thickness)
		line.color = Color(1, 1, 1, 0.25)
		add_child(line)
