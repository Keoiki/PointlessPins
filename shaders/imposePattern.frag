#pragma header

uniform float TIME = 0.0;
uniform vec3 RES = vec3(1280.0, 720.0, 1.0);
const vec2 HALF = vec2(0.5);
uniform vec2 DIRECTION = vec2(1.0, 0.5);
uniform float SPEED = 0.1;
uniform vec4 patternColor;
uniform sampler2D patternTexture;
uniform vec2 patternTexSize;
uniform float patternAngle = 0.0;
uniform int BLEND;

vec4 applyColor(vec4 base, vec4 blend)
{
    if (BLEND == 1)
    {
        // This makes non-opaque areas closer to white the more transparent they are.
        return vec4(base.rgb * (patternColor.rgb * blend.a + (vec3(1.0) * (1.0 - blend.a))), base.a);
    }
    else
    {
        return vec4(mix(base.rgb, blend.rgb * patternColor.rgb, blend.a), base.a);
    }
}

vec2 rotate2D(vec2 p, float theta)
{
    return p * mat2(cos(theta), -sin(theta), sin(theta), cos(theta));
}

void main()
{
    float aSin = sin(patternAngle);
    float aCos = cos(patternAngle);

    float screenAspect = RES.x / RES.y;
    float patternAspect = patternTexSize.x / patternTexSize.y;
    float aspect = patternAspect / screenAspect;

    vec2 coord = gl_FragCoord.xy / RES.xy;
    coord.y = 1.0 - coord.y;

    coord.y *= aspect;
    coord.y -= aspect * 0.5 - 0.5;

    coord -= HALF;
	coord.x *= patternAspect;
    coord = rotate2D(coord, patternAngle);
	coord.x *= 1.0 / patternAspect;
    coord += HALF;

    vec4 base = flixel_texture2D(bitmap, openfl_TextureCoordv);
    lowp vec4 blend = flixel_texture2D(patternTexture, vec2(mod(coord.x + (-DIRECTION.x * TIME * SPEED), 1.0), mod(coord.y + (DIRECTION.y * TIME * SPEED), 1.0)));

	gl_FragColor = applyColor(base, blend);
}