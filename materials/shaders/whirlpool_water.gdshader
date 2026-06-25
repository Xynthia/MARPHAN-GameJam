// Whirlpool water shader, Compatibility (GL) renderer build for Godot 4
// Combines four reference shaders into one plane material:
//   low-poly faceted water  (flat per-face normals from screen-space derivatives)
//   toon water, no textures (procedural value noise quantized into cel bands)
//   object foam outline      (foam rings around objects fed in from a script)
//   vortex / whirlpool       (vertex funnel sink, radius-accelerated swirl)
//
// The Compatibility renderer cannot read the depth buffer or the screen texture, so the
// depth-based foam and depth color tint of the Forward+ build are replaced here, the color
// darkens toward the drain by radius and the object foam is driven by world positions.
//
// Usage, assign this to a ShaderMaterial on a MeshInstance3D using a subdivided PlaneMesh
// (Subdivide Width/Depth 64+) so the funnel and waves can deform it. For foam around
// objects, add water_interaction_component.gd as a child of that MeshInstance3D and fill
// its Tracked Objects list (the ship, the monster, and so on).

shader_type spatial;
render_mode cull_disabled;

// Surface colors
uniform vec4 water_tint : source_color = vec4(0.04, 0.38, 0.78, 1.0); // first toon cell band
uniform vec4 water_tint_2 : source_color = vec4(0.03, 0.30, 0.62, 1.0); // second toon cell band
uniform vec4 color_shallow : source_color = vec4(0.18, 0.55, 0.62, 1.0); // tint at the outer rim
uniform vec4 color_deep : source_color = vec4(0.02, 0.14, 0.32, 1.0); // tint toward the drain
uniform vec4 foam_color : source_color = vec4(0.85, 0.95, 0.97, 1.0); // surface and object foam

// Waves and low-poly look
uniform float wave_amplitude : hint_range(0.0, 2.0) = 0.25; // vertical wave height
uniform float wave_frequency : hint_range(0.1, 8.0) = 1.2; // spatial wave density
uniform float wave_speed : hint_range(0.0, 5.0) = 1.0; // wave animation speed
uniform float chop : hint_range(0.0, 1.0) = 0.4; // extra chaotic low-poly sloshing
uniform bool faceted_normals = true; // flat per-face normals for the faceted look

// Toon surface pattern (texture free)
uniform float surface_scale : hint_range(0.5, 30.0) = 6.0; // size of the procedural cells
uniform float surface_flow_speed : hint_range(0.0, 2.0) = 0.15; // drift of the surface pattern
uniform float toon_bands : hint_range(1.0, 8.0, 1.0) = 3.0; // number of cel color bands
uniform float surface_foam_amount : hint_range(0.0, 1.0) = 0.35; // strength of surface foam speckle
uniform float surface_foam_threshold : hint_range(0.0, 1.0) = 0.62; // where speckle starts to appear

// Whirlpool / vortex
uniform vec2 vortex_center = vec2(0.5, 0.5); // center of the swirl in UV space
uniform float swirl_strength : hint_range(0.0, 1.0) = 0.25; // twist that accelerates toward the center
uniform float spin_speed : hint_range(-4.0, 4.0) = 0.6; // constant rotation over time
uniform float funnel_depth : hint_range(0.0, 3.0) = 0.6; // how far the center sinks down
uniform float funnel_radius : hint_range(0.01, 1.0) = 0.45; // radius of the funnel cone
uniform float inward_speed : hint_range(0.0, 2.0) = 0.3; // how fast the surface streams to the drain

// Fake depth tint (no depth buffer on Compatibility, so this is radius based)
uniform float deep_strength : hint_range(0.0, 1.0) = 0.9; // how dark the water gets toward the drain
uniform float water_alpha : hint_range(0.0, 1.0) = 0.85; // overall transparency of the water body

// Object foam outline, positions are supplied by water_interaction_component.gd
uniform int interaction_count = 0; // how many tracked objects are active
uniform vec3 interaction_pos[8]; // world positions of the tracked objects
uniform float interaction_radius[8]; // foam ring radius per object, 0 disables a slot
uniform float foam_ring_width : hint_range(0.05, 2.0) = 0.6; // thickness of the foam ring
uniform float foam_noise_amount : hint_range(0.0, 1.0) = 0.5; // animated break up of the ring

// Surface response
uniform float metallic : hint_range(0.0, 1.0) = 0.0;
uniform float roughness : hint_range(0.0, 1.0) = 0.15;
uniform float fresnel_strength : hint_range(0.0, 8.0) = 4.0; // grazing angle rim falloff
uniform vec4 fresnel_color : source_color = vec4(0.7, 0.9, 1.0, 1.0); // rim tint at grazing angles
uniform float emission_amount : hint_range(0.0, 1.0) = 0.05; // small glow so the water is not too dark

// World position of the surface fragment, used for the object foam distance test
varying vec3 v_world_pos;

// Rotates a 2D point around the origin by angle radians
vec2 rotate2d(vec2 p, float angle) {
	float s = sin(angle);
	float c = cos(angle);
	return vec2(c * p.x - s * p.y, s * p.x + c * p.y);
}

// Cheap hash for the texture free noise
float hash(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

// Smooth value noise, the building block the toon water reference uses
float value_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

// Four octaves of value noise for the surface cells and foam
float fbm(vec2 p) {
	float total = 0.0;
	float amp = 0.5;
	for (int i = 0; i < 4; i++) {
		total += value_noise(p) * amp;
		p *= 2.0;
		amp *= 0.5;
	}
	return total;
}

// Grazing angle falloff, brighter at the rim
float fresnel(float amount, vec3 normal, vec3 view) {
	return pow(1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0), amount);
}

void vertex() {
	vec2 centered = UV - vortex_center;
	float r = length(centered);

	// Animated waves in mesh local space so the wave field, the funnel and the swirl
	// all share one frame and stay aligned when the plane is moved or rotated
	vec2 local = VERTEX.xz;
	float wave = (sin(local.x * wave_frequency + TIME * wave_speed)
		+ cos(local.y * wave_frequency + TIME * wave_speed)) * 0.5 * wave_amplitude;

	// Extra higher frequency chop for the chaotic low-poly surface
	float chop_wave = sin((local.x + local.y) * wave_frequency * 2.3 + TIME * wave_speed * 1.7);
	wave += chop_wave * wave_amplitude * chop;

	// Funnel sink, deepest at the center and fading out at funnel_radius
	float funnel = funnel_depth * smoothstep(funnel_radius, 0.0, r);

	VERTEX.y += wave - funnel;

	// Pass the world position to the fragment stage for the object foam test
	v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	// Whirlpool swirl coordinate, the angle accelerates toward the center and spins over time
	vec2 centered = UV - vortex_center;
	float r = length(centered);
	vec2 safe_dir = normalize(centered + vec2(0.0001));
	float angle = spin_speed * TIME + swirl_strength / max(r, 0.05);
	vec2 swirled = rotate2d(centered, angle);

	// Stream the surface pattern inward toward the drain
	vec2 flow_uv = swirled * surface_scale - safe_dir * TIME * (inward_speed + surface_flow_speed);

	// Toon surface, quantize procedural noise into a few flat cel bands
	float n = fbm(flow_uv);
	float bands = max(toon_bands, 1.0);
	float cells = floor(n * bands) / bands;
	vec3 surface = mix(water_tint.rgb, water_tint_2.rgb, cells);

	// Surface foam speckle on the noise crests
	float crest = fbm(flow_uv * 1.7 + vec2(13.0, 7.0));
	float speckle = smoothstep(surface_foam_threshold, surface_foam_threshold + 0.12, crest);
	surface = mix(surface, foam_color.rgb, speckle * surface_foam_amount);

	// Fake depth tint, the water darkens toward the drain since there is no depth buffer
	float deep_factor = smoothstep(funnel_radius * 1.6, 0.0, r) * deep_strength;
	vec3 depth_color = mix(color_shallow.rgb, color_deep.rgb, deep_factor);
	surface = mix(surface, depth_color, deep_factor * 0.85);

	// Object foam outline, draw a ring around each tracked world position
	float object_foam = 0.0;
	for (int i = 0; i < 8; i++) {
		if (i >= interaction_count) {
			break;
		}
		float rad = interaction_radius[i];
		if (rad <= 0.0) {
			continue;
		}
		float d = distance(v_world_pos.xz, interaction_pos[i].xz);
		float ring = 1.0 - smoothstep(0.0, rad * max(foam_ring_width, 0.01), abs(d - rad));
		object_foam = max(object_foam, ring);
	}
	float foam_n = fbm(v_world_pos.xz * 0.5 + vec2(TIME * 0.3));
	object_foam *= mix(1.0, foam_n + 0.4, foam_noise_amount);
	object_foam = clamp(object_foam, 0.0, 1.0);

	vec3 body = mix(surface, foam_color.rgb, object_foam);

	// Faceted geometric normal gives the low-poly flat shaded facets. Resolve it before
	// the rim so the toon highlight follows the same normal that lighting uses.
	vec3 shading_normal = NORMAL;
	if (faceted_normals) {
		shading_normal = normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));
		// the plane is double sided, keep the facet normal facing the camera
		if (!FRONT_FACING) {
			shading_normal = -shading_normal;
		}
	}
	NORMAL = shading_normal;

	// Posterized fresnel rim for the toon edge highlight
	float fres = fresnel(fresnel_strength, shading_normal, VIEW);
	fres = floor(fres * bands) / bands;
	body = mix(body, fresnel_color.rgb, fres * fresnel_color.a);

	ALBEDO = body;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	EMISSION = body * emission_amount + foam_color.rgb * object_foam * 0.5;
	ALPHA = clamp(water_alpha + object_foam + speckle * surface_foam_amount, 0.0, 1.0);
}
