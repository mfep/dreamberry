shader_type canvas_item;

uniform float amount : hint_range(0,5);
uniform vec2 center;

void fragment() {
	vec3 original = textureLod(SCREEN_TEXTURE,SCREEN_UV, 0).rgb;
	vec3 blurred = textureLod(SCREEN_TEXTURE,SCREEN_UV,amount).rgb;
	float dst = length(center - SCREEN_UV);
	dst = smoothstep(0, 1, dst);
	if (dst < 0.1) { COLOR.rgb = mix(original, blurred, 0.1*smoothstep(0.0, 0.1, dst/0.1)); }
	else { COLOR.rgb = mix(original, blurred, smoothstep(0.1, 1.0, 3.0*dst)); }
}