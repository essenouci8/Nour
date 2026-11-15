#version 460 core
#include <flutter/runtime_effect.glsl>

// عدسة سائلة: انكسار عند الحواف + انحراف لوني خفيف + تمويه طفيف.
// المُدخل الأول (uTex) هو ما خلف الفقاعة، يضبطه Flutter تلقائيًا.
uniform vec2 uSize;       // حجم الفقاعة
uniform float uStrength;  // قوة الانكسار
uniform float uEdge;      // سُمك منطقة الانكسار عند الحافة (بكسل)
uniform float uAberr;     // الانحراف اللوني
uniform sampler2D uTex;

out vec4 fragColor;

float sdPill(vec2 p, vec2 hs) {
  float r = hs.y;
  vec2 q = vec2(max(abs(p.x) - (hs.x - r), 0.0), p.y);
  return length(q) - r;
}

vec3 samp(vec2 f) {
  vec3 c = vec3(0.0);
  c += texture(uTex, clamp((f + vec2(-1.5, -1.5)) / uSize, 0.0, 1.0)).rgb;
  c += texture(uTex, clamp((f + vec2( 1.5, -1.5)) / uSize, 0.0, 1.0)).rgb;
  c += texture(uTex, clamp((f + vec2(-1.5,  1.5)) / uSize, 0.0, 1.0)).rgb;
  c += texture(uTex, clamp((f + vec2( 1.5,  1.5)) / uSize, 0.0, 1.0)).rgb;
  return c * 0.25;
}

void main() {
  vec2 frag = FlutterFragCoord().xy;
  vec2 hs = uSize * 0.5;
  vec2 p = frag - hs;

  float depth = -sdPill(p, hs);
  float t = clamp(1.0 - depth / uEdge, 0.0, 1.0);
  float bend = t * t * (3.0 - 2.0 * t) * uStrength;

  vec2 e = vec2(1.0, 0.0);
  vec2 g = vec2(
    sdPill(p + e.xy, hs) - sdPill(p - e.xy, hs),
    sdPill(p + e.yx, hs) - sdPill(p - e.yx, hs));
  vec2 n = g / max(length(g), 1e-4);

  vec2 base = frag - p * 0.07 * uStrength;   // تكبير خفيف للمركز
  vec2 off = -n * bend * uEdge * 0.9;

  vec3 col;
  col.r = samp(base + off * (1.0 - uAberr * 0.12)).r;
  col.g = samp(base + off).g;
  col.b = samp(base + off * (1.0 + uAberr * 0.12)).b;
  fragColor = vec4(col, 1.0);
}
