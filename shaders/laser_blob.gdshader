// NOTE: Shader automatically converted from Godot Engine 4.4.1.stable's CanvasItemMaterial.

shader_type canvas_item;
render_mode blend_add;

uniform float width = 0.1;
uniform float glow_width = 1.0;
uniform sampler2D noise_texture : filter_linear, repeat_enable;

float inv_lerp(float a, float b, float x) {
	return (x - a) / (b - a);
}
float remap(float a, float b, float c, float d, float x) {
	return mix(c, d, inv_lerp(a, b, x));
}

void fragment() {
	float d = distance(UV, vec2(0.5)) * 2.0;

	float noise = sin(d * 10.0 - TIME * 30.0) * 0.005;
	noise += sin(d * 8.0 - TIME * 20.0) * 0.005;
	noise += texture(noise_texture, UV - vec2(TIME*0.5,0)).x * 0.1;

	float w = width;
	w += noise;
	float gw = glow_width;

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
		t = pow(t, 1.5);
		COLOR.a *= t;
	}
}
