# Animated SVG Marks

Rules for concept SVGs that `scripts/preview.py` inlines into one page and captures frame by frame.
Each rule prevents a failure that renders silently wrong rather than erroring.

## File Shape

- One self-contained file per concept: `viewBox="0 0 64 64"`, `role="img"`, `aria-label` set to the
  product name, an inline `<style>`, no external references or fonts.
- Prefix every `id`, class and `@keyframes` name with a short concept prefix (`hz-`, `st-`). The
  preview inlines every mark into one document, where unprefixed names collide across concepts.
  The same mark repeated at several sizes may share ids, because the geometry is identical.

## Motion

- CSS animations only, never SMIL (`<animate>`, `<animateMotion>`). The reduced-motion rule and
  the preview's frame freezing both act on CSS animations; SMIL keeps running through both.
  - Travel along a path: `offset-path: path("...")` with an animated `offset-distance`.
  - Self-drawing lines: `pathLength="100"` with `stroke-dasharray` and an animated `stroke-dashoffset`.
- Every mark ends with
  `@media (prefers-reduced-motion: reduce) { * { animation: none !important; } }` plus a meaningful
  static state: hide ripples and glints, and show progress complete and travellers at their goal.
- Loop timing: every duration divides `loop_seconds` (default 4s, so 4s, 2s, 1s or 4/3s). The GIF
  captures exactly one loop length, so any other duration produces a visible jump at the seam.
- Stagger with negative `animation-delay`, so frame 0 is already mid-cycle. Elements whose
  sequences must reset together need their own keyframes, because CSS has no per-iteration delay.
- Scale and ripple SVG elements with `transform-box: fill-box` and an explicit `transform-origin`.
  CSS `px` in an SVG transform equals one user unit.
- Motion that another element must track exactly (a "now" marker and the progress behind it):
  put the tracked axis on an outer group with `linear` timing and any eased motion (hops, scale)
  on an inner element. With linear x, a bar spanning `[s, e]` fills from the moment x reaches
  `s` to the moment it reaches `e`, so its keyframes are computed, not tuned; eased segments
  would drift between keyframes.

## Geometry Traps

- A `clip-path` on a transformed element moves with the element. Clip a parent group and
  animate the child inside it.
- `objectBoundingBox` gradients (the default) render nothing on zero-height or zero-width
  geometry such as a horizontal stroked line. Use a solid colour or `gradientUnits="userSpaceOnUse"`.
- A stroked dash of zero length with round caps can still paint a dot. Hide strokes that have
  not started drawing with opacity, not with the dash offset alone.

## Colour and Legibility

- Take colours from the product's own tokens and check each against both the light and the dark
  background. Avoid a colour the product already uses for meaning (an amber "at risk", a red
  error) unless the mark means it.
- Animated `fill` interpolates in sRGB. Opposite hues fade through mud (orange to green passes
  olive); neighbouring hues stay clean (blue to green passes teal). Keep fades between distant
  hues to a frame or two.
- Motion detail serves the header size. At 16px only the silhouette survives, so the favicon is a
  separate static tile, with high-contrast shapes on a filled rounded square.

## Verifying a Drawing

- Read captured frames (`<page>?t=<seconds>` freezes every animation at that time) at three or
  more points in the loop before showing anything.
- An element missing from a frame is not yet a defect. Isolate that SVG on its own page and
  capture it at several times; the motion may simply fall between the frames inspected.
- For a quick contact sheet, inline several copies of one mark into a scratch page, freeze each
  copy at its own time with `svg.getAnimations({ subtree: true })` and `currentTime`, and take
  one screenshot. One browser launch replaces one per time point.
- To preview a subset, give it its own folder whose `concepts.json` lists marks by relative path
  (`../anim-x.svg`); outputs then land in that folder, and the SVGs stay single-sourced.
