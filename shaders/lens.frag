#version 460 core
#include <flutter/runtime_effect.glsl>

// عدسة سائلة: انكسار عند الحواف + انحراف لوني خفيف + تمويه طفيف.
// uTex هو ما خلف الفقاعة. أنظمة الإحداثيات تختلف بين الأجهزة، لذلك
// أُرسل الأصل وحجم الخامة وقلب المحور من Dart (انظر أوضاع المعايرة).
uniform vec2 uSize;     // حجم العدسة
uniform vec2 uOrigin;   // موضع العدسة في فضاء FlutterFragCoord
uniform vec2 uTexSize;  // حجم الخامة في نفس الفضاء
uniform float uFlip;    // 1 = قلب المحور الرأسي
uniform float uStrength;
uniform float uEdge;
uniform float uAberr;
uniform float uPx;      // معامل تحويل بكسلات الإعدادات
uniform sampler2D uTex;

out vec4 fragColor;

float sdPill(vec2 p, vec2 hs) {
  float r = hs.y;
  vec2 q = vec2(max(abs(p.x) - (hs.x - r), 0.0), p.y);
  return length(q) - r;
}

vec3 samp(vec2 f) {
  vec2 uv = f / uTexSize;
  if (uFlip > 0.5) uv.y = 1.0 - uv.y;
  return texture(uTex, clamp(uv, 0.0, 1.0)).rgb;
}

vec3 sampFrost(vec2 f) {
  float o = 1.5 * uPx;
  vec3 c = samp(f + vec2(-o, -o)) + samp(f + vec2(o, -o)) +
           samp(f + vec2(-o, o)) + samp(f + vec2(o, o));
  return c * 0.25;
}

void main() {
  vec2 frag = FlutterFragCoord().xy;
  vec2 lp = frag - uOrigin;           // إحداثي محلي داخل العدسة
  vec2 hs = uSize * 0.5;
  vec2 p = lp - hs;

  float edge = uEdge * uPx;
  float depth = -sdPill(p, hs);
  float t = clamp(1.0 - depth / edge, 0.0, 1.0);
  float bend = t * t * (3.0 - 2.0 * t) * uStrength;

  vec2 e = vec2(1.0, 0.0);
  vec2 g = vec2(
    sdPill(p + e.xy, hs) - sdPill(p - e.xy, hs),
    sdPill(p + e.yx, hs) - sdPill(p - e.yx, hs));
  vec2 n = g / max(length(g), 1e-4);

  vec2 base = frag - p * 0.07 * uStrength;
  vec2 off = -n * bend * edge * 0.9;

  vec3 col;
  col.r = sampFrost(base + off * (1.0 - uAberr * 0.12)).r;
  col.g = sampFrost(base + off).g;
  col.b = sampFrost(base + off * (1.0 + uAberr * 0.12)).b;
  fragColor = vec4(col, 1.0);
}
