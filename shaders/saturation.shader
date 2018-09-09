shader_type canvas_item;

uniform float amount : hint_range(0,5);

void fragment() {
	vec3 original = textureLod(SCREEN_TEXTURE,SCREEN_UV, 0).rgb;
    vec3 W = vec3(0.2125, 0.7154, 0.0721);
    vec3 intensity = vec3(dot(original, W));
	COLOR.rgb = mix(intensity, original, amount);
}