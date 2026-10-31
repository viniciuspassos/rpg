shader_type canvas_item;
render_mode blend_mix;

uniform int pass_index;
uniform float opacity = 0.68;

void fragment() {
	vec4 effect = texture(TEXTURE, UV);
	float energy = smoothstep(0.04, 0.16, effect.b - effect.r);
	float debris = (1.0 - energy) * smoothstep(0.55, 0.9, effect.a);
	float dust = 1.0 - energy - debris;
	float weight = pass_index == 2 ? energy : (pass_index == 1 ? debris : dust);
	float gray = dot(effect.rgb, vec3(0.299, 0.587, 0.114));
	vec3 color = pass_index == 2 ? mix(effect.rgb, vec3(gray), 0.35) : effect.rgb;
	COLOR = vec4(color, effect.a * weight * opacity);
}
