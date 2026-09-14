shader_type spatial;

uniform sampler2D track_texture : source_color;

varying vec3 local_position;

void vertex() {
	local_position = VERTEX;
}

void fragment() {
	if (NORMAL.y > 0.5) {
		vec2 track_uv;

		track_uv.x = local_position.x / 6000.0 + 0.5;
		track_uv.y = local_position.z / 650.0 + 0.5;

		ALBEDO = texture(track_texture, track_uv).rgb;
	} else {
		ALBEDO = vec3(0.15, 0.55, 0.12);
	}
}