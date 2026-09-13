extends Node3D

var lane_count: int = 10
var lane_spacing: float = 65.0
var track_length: float = 6000.0


func _ready() -> void:
	for i in range(1, lane_count):
		create_lane_line(i)


func create_lane_line(lane_index: int) -> void:
	var line := MeshInstance3D.new()

	var mesh := BoxMesh.new()
	mesh.size = Vector3(
		track_length,
		0.05,
		0.08
	)

	line.mesh = mesh

	var material := StandardMaterial3D.new()
	material.albedo_color = Color.WHITE

	line.material_override = material

	line.position = Vector3(
		track_length / 2.0,
		0.15,
		lane_index * lane_spacing
	)

	add_child(line)
