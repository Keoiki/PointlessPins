#pragma header

const vec3 iResolution = vec3(1280.0, 720.0, 1.0);
uniform float iTime;
#define iChannel0 bitmap

// Palette function
vec3 palette(float t) {
    vec3 a = vec3(1.0);
    vec3 b = vec3(1.5);
    vec3 c = vec3(1.0);
    vec3 d = vec3(0.0, 0.6, 0.2);
    return a + b * cos(6.28318 * (c * t + d));
}

// Hash to generate random value from position
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

// 2D value noise
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

vec4 foil(vec2 fragCoord) {
    // Normalize pixel coordinates (0.0 - 1.0)
    vec2 uv = fragCoord.xy * 0.25;
    vec2 orig = uv;
    vec3 col = vec3(0.0);

    // Slow global rotation
    float angle = mod(iTime * 0.1, 6.283185);
    mat2 rot = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
    uv *= rot;

    // Fractal layering
    for (float i = 1.0; i <= 3.0; i++) {
        // Apply noise distortion
        uv += (noise(uv * 4.0 + iTime * 0.4) - hash(uv) * 0.01);

        float d = length(uv) * exp(-length(orig) * 0.1);
        float t = sin(d * 2.0 - iTime * 0.3 + i) * 0.8;
        float intensity = pow(0.01 / max(abs(t) , 0.00001), 1.1);

        vec3 p = palette(length(orig) + i * 0.1 - iTime*0.3);
        col += p * sin(intensity);
    }

    // Gamma correction and boost
    // col = pow(col, vec3(0.8)) * 0.5;
    return vec4(col, 1.0);
}

void main()
{
  vec4 bg = flixel_texture2D(iChannel0, openfl_TextureCoordv);
  vec4 src = foil(openfl_TextureCoordv);

  // Un-premultiply the alpha before blending
  src.rgb = src.a > 0.0 ? src.rgb / src.a : src.rgb;

  // Divide Blend
  vec4 res = bg / src;
  gl_FragColor = vec4(mix(bg.rgb, res.rgb, 0.005), mix(bg.a, res.a, src.a));
}