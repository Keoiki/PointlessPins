#pragma header

uniform vec3 uRed;
uniform vec3 uGreen;
uniform vec3 uBlue;
uniform float uApply;

vec3 blendAdd(vec3 base, vec3 blend, vec3 blend2)
{
	return min(base + blend + blend2, vec3(1.0));
}

vec4 flixel_texture2DExtra(sampler2D bitmap, vec2 coord)
{
	vec4 color = texture2D(bitmap, coord);

	vec3 r = color.r * uRed;
	vec3 g = color.g * uGreen;
	vec3 b = color.b * uBlue;

	vec3 result = blendAdd(r, g, b);

	vec4 ares = vec4(result, color.a);

	color = mix(color, ares, uApply);

	if (!hasTransform) { return color; }

	if (color.a == 0.0) { return vec4(0.0, 0.0, 0.0, 0.0); }

	if (!hasColorTransform) { return color * openfl_Alphav; }

	color = vec4(color.rgb / color.a, color.a);

	mat4 colorMultiplier = mat4(0);
	colorMultiplier[0][0] = openfl_ColorMultiplierv.x;
	colorMultiplier[1][1] = openfl_ColorMultiplierv.y;
	colorMultiplier[2][2] = openfl_ColorMultiplierv.z;
	colorMultiplier[3][3] = openfl_ColorMultiplierv.w;

	color = clamp(openfl_ColorOffsetv + (color * colorMultiplier), 0.0, 1.0);

	if (color.a > 0.0)
    {
		return vec4(color.rgb * color.a * openfl_Alphav, color.a * openfl_Alphav);
	}
	return vec4(0.0, 0.0, 0.0, 0.0);
}

void main()
{
	gl_FragColor = flixel_texture2DExtra(bitmap, openfl_TextureCoordv);
}