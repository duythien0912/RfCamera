#version 460 core
#include <flutter/runtime_effect.glsl>

// Optics pass: barrel distortion (fisheye adapters) plus lateral chromatic
// aberration (prism / D3D / VHS). Everything else — grain, leaks, vignette —
// is painted on top in Dart, where it is cheap and easy to match in the bake.

uniform vec2 uSize;
uniform float uDistort;  // 0 = rectilinear, 1 = strong barrel
uniform float uChroma;   // pixels of R/B separation at the frame edge
uniform sampler2D uTex;

out vec4 fragColor;

vec2 barrel(vec2 uv, float k) {
  vec2 c = uv - 0.5;
  float r2 = dot(c, c) * 4.0;
  return c / (1.0 + k * r2) + 0.5;
}

vec4 sampleClamped(vec2 uv) {
  if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
    return vec4(0.0, 0.0, 0.0, 1.0);
  }
  return texture(uTex, uv);
}

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  vec2 duv = barrel(uv, uDistort);

  if (uChroma <= 0.001) {
    fragColor = sampleClamped(duv);
    return;
  }

  // Separation grows toward the edge, the way a real lens misbehaves.
  vec2 dir = duv - 0.5;
  vec2 off = dir * (uChroma / max(uSize.x, 1.0)) * 2.0;

  float r = sampleClamped(duv + off).r;
  vec4 g = sampleClamped(duv);
  float b = sampleClamped(duv - off).b;

  fragColor = vec4(r, g.g, b, g.a);
}
