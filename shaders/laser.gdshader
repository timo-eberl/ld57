// NOTE: Shader automatically converted from Godot Engine 4.4.1.stable's CanvasItemMaterial.

shader_type canvas_item;
render_mode blend_mix;

uniform float width = 0.1;
uniform float glow_width = 1.0;

varying vec2 pos;

void vertex() {
	pos = VERTEX;
}

float inv_lerp(float a, float b, float x) {
	return (x - a) / (b - a);
}
float remap(float a, float b, float c, float d, float x) {
	return mix(c, d, inv_lerp(a, b, x));
}

void fragment() {
	vec3 laser_color = COLOR.xyz;
	float d = distance(pos.y, 0) * 0.002;

	float dx = distance(pos.x, 0) * 0.002;

	float noise = sin(pos.x * 0.003 - TIME * 25.0) * 0.03;
	noise += sin(pos.x * 0.002 - TIME * 25.0) * 0.02;
	noise = (noise);

	dx *= 0.25;
	dx = 1.0-dx;
	dx = max(0.0, dx);
	dx = pow(dx, 1.5);

	float w = width * (1.2-dx);
	w += noise;
	float gw = glow_width * (1.2-dx);

	if (d < w) {
		COLOR = vec4(1);
	}
	else if (d < w * 2.0) {
		float t = inv_lerp(w * 2.0, w, d);
		t = smoothstep(0,1,t);
		COLOR = mix(COLOR, vec4(1), t);
	}
	else {
		float t = inv_lerp(gw, w * 2.0, d);
		t = smoothstep(0,1.0,t);
		COLOR.a *= t;
	}
	//COLOR.xyz = vec3(dx);
	//COLOR.a = 1.0;
}
