shader_type spatial;
render_mode unshaded, blend_mix, fog_disabled, cull_disabled;

// Author: Élie Michel - License: CC BY 3.0 - July 2017
// Converted to spatial by Phenosi

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float frequency : hint_range(-10.0, 4.0, 0.1) = 0.0;
uniform float size : hint_range(0.001, 0.05, 0.001) = 0.015;

void vertex() {
    POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

vec2 rand(vec2 c) {
    mat2 m = mat2(vec2(12.9898, 0.16180), vec2(78.233, 0.31415));
    return fract(sin(m * c) * vec2(43758.5453, 14142.1));
}

vec2 noise(vec2 p) {
    vec2 co = floor(p);
    vec2 mu = fract(p);
    mu = 3.0 * mu * mu - 2.0 * mu * mu * mu;
    vec2 a = rand(co + vec2(0.0, 0.0));
    vec2 b = rand(co + vec2(1.0, 0.0));
    vec2 nc = rand(co + vec2(0.0, 1.0));
    vec2 nd = rand(co + vec2(1.0, 1.0));
    return mix(mix(a, b, mu.x), mix(nc, nd, mu.x), mu.y);
}

void fragment() {
    vec2 u = SCREEN_UV;
    vec2 n = noise(u * 0.1 * 200.0);

    // resolution from the screen texture itself
    vec2 iResolution = vec2(textureSize(screen_texture, 0));

    vec4 out_color = textureLod(screen_texture, u, 2.5);

    for (float r = 4.0; r > frequency; r--) {
        vec2 x = iResolution * r * size;
        vec2 p = 6.28 * u * x + (n - 0.5) * 2.0;
        vec2 s = sin(p);

        vec2 grid_uv = round(u * x - 0.25) / x;
        vec4 d = vec4(noise(grid_uv * 200.0), noise(grid_uv));

        float t = (s.x + s.y) * max(0.0, 1.0 - fract(TIME * (d.b + 0.1) + d.g) * 2.0);

        if (d.r < (5.0 - r) * 0.08 && t > 0.5) {
            vec3 drop_normal = normalize(-vec3(cos(p), mix(0.2, 2.0, t - 0.5)));
            out_color = texture(screen_texture, u - drop_normal.xy * 0.3);
        }
    }

    ALBEDO = out_color.rgb;
    ALPHA = 1.0;
}