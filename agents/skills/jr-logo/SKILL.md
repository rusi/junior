---
name: jr-logo
description: Run `/jr-logo` to explore, preview, and refine animated logo concepts, then install the chosen mark in the product.
---

# Logo

## Purpose

Give a product a looping animated mark and a matching favicon by iterating on several concepts
with the user. Concepts are standalone SVGs compared in a live preview page and light and dark
GIFs, then the accepted mark is installed in the product's header and favicon, with a recorded
decision.

## Type

Contract-style iteration: context → concept set → show → feedback → revise and show again →
user acceptance → product integration → decision record.

## When to Use

- The operator invokes `/jr-logo` for a new mark, a rebrand, or a refinement of the current one.
- Use `/jr-ui-prototype` for interface layout and interaction; a mark is a standalone asset
  reviewed outside the product's component system, then placed into it.

## Process

### 1. Context

Track context, concept set, user review, revisions, integration, and the decision record with
the available plan tool. Mark user review pending until the user answers.

Read before drawing:

- The product's mission and audience (product docs, README) and its domain vocabulary: the
  objects its users work with every day.
- Its real palette from the design tokens or stylesheet, for both light and dark themes, plus
  the page backgrounds.
- The current header, title treatment and favicon, and the framework's static-asset convention.
- An existing brand folder or decision record. Revise it rather than starting a parallel one.

Agree a one-line design question with the user only when the request leaves it open (for
example, a new mark versus a refinement). Otherwise proceed.

### 2. Concept Set

Work in `.junior/research/brand/` unless the project already keeps brand material elsewhere.
Copy `templates/concepts.json` there and fill in the product name, theme colours, and groups.

Draw 4–6 concepts that differ in idea, not just in styling. Ground them in the product's domain
vocabulary as well as its name. A literal reading of the name alone tends to produce marks that
say nothing about what the product does. Give each concept a one-line rationale for the user.

Follow `references/svg-animation.md` for every file. It covers prefixes, CSS-only motion,
reduced motion, loop timing, and the geometry traps that render silently wrong.

### 3. Preview and Self-Check

Run `scripts/preview.py <brand-dir>` with the project's Python, and add `--gif` with Pillow
available. The script writes `preview.html` (every mark large, beside the product title, and at
16px, in every theme), plus `preview-<theme>.gif` when GIFs are requested. Each frame is a
headless-browser launch, about one to two seconds, so start GIF runs as tracked background
tasks.

Before showing anything, read frames captured at three or more points in the loop, in both
themes. Fix any mark that is broken, clipped, or illegible. Investigate a missing element with
the isolation step in the reference before changing the drawing.

### 4. Show and Receive Feedback

Open `preview.html` for the user, embed the GIF or the frames, and give each concept's
rationale and its 16px legibility in one line. Recommend one concept and say why. Ask one
focused question using the structured question tool, and wait for the answer.

Silence, an instruction to keep exploring, or approval of a direction is not acceptance of a
mark.

### 5. Revision Loop

- **A direction rejected:** ask what the marks failed to say if the feedback does not state it,
  then draw a new set as a new group in `concepts.json`. Keep the earlier groups in the preview,
  so the user compares against what they have already seen.
- **A concept chosen with tweaks:** revise that file in place and re-render.
- **A requested output** (GIFs per theme, one mark alone, other sizes): produce it from the same
  sources with the script rather than with a one-off renderer.

Re-check only the changed marks, show the result again, and ask again. Repeat until the user
explicitly accepts one mark.

### 6. Product Integration

After acceptance, install the mark following the project's conventions:

- **Animated logo:** a copy of the accepted SVG in the product's static assets, shown beside the
  header title with `alt=""` because the title already names the product, and sized to the title
  block. Write the header test first (logo present and decorative), then the change.
- **Favicon:** a separate static tile, with the mark's silhouette in high contrast on a filled
  rounded square, linked from the document head.
- **Verification:** the project's unit tests, type check, and build (assets present in the
  output); the running app's header captured in light and dark; and the favicon read at 16, 32,
  64, and 128px.

Apply the shared [product isolation](../_shared/references/product-isolation.md) `tree` check
and its semantic review to the product files. Product files never reference the brand folder.

### 7. Decision Record and Handoff

Write or update `brand-decisions.md` in the brand folder, then follow the
[planning completion handoff](../_shared/references/planning-completion.md). Commit through
`/jr-commit`. Product files and brand material are separate groups. The SVGs, `concepts.json`,
and `brand-decisions.md` are committed; `preview*.html`, `preview-*.gif`, and `frames/` are
regenerated output and are not.

## Output Spec

Baseline: [artifact output spec](../_shared/references/artifact-output-spec.md). Apply these
contents at each write and update, including drafts.

### Concept SVGs and concepts.json

- **For:** the preview script and whoever revises a mark later; answers what each concept looks
  like and how it moves.
- **Goes in:** one mark per file, as specified in `references/svg-animation.md`; groups and labels
  naming each direction.
- **Never goes in:** comments that narrate the design history, rejected variants kept as dead
  elements, or external references.

### Preview Page and GIFs

- **For:** the user comparing concepts; answers how each mark looks at real sizes in each theme.
- **Goes in:** only what the script renders from the sources.
- **Never goes in:** hand edits, annotations, or marks missing from `concepts.json`.

### Product Logo Files

- **For:** the product's users and maintainers.
- **Goes in:** the accepted mark, the static favicon tile, and the header change with its test.
- **Never goes in:** brand-folder paths, concept names presented as product terms, or provenance.

### brand-decisions.md

- **For:** a future maintainer asking why the mark looks the way it does.
- **Goes in:** the chosen mark and where it lives in the product; its animation and
  reduced-motion state; the rejected directions with the reason for each; and the preview
  command.
- **Never goes in:** feedback transcripts, round-by-round narration, or counts of concepts drawn.

### Review Response

- **For:** the user deciding what to try, change, or accept next.
- **Goes in:** the opening link, the GIF or frames, a one-line rationale per concept, legibility
  at small sizes, one recommendation, and one question.
- **Never goes in:** assumed acceptance, the drawing process, or verification paperwork.

**Register:** headings are noun labels, never sentences, questions, or conversational phrases.
Prose states facts. No editorial lead, no anthropomorphising, no dramatic adjective.

## Tool Integration

Use repository search and file tools for context; the shell for `scripts/preview.py` and the
headless browser; image reading to inspect captured frames; the structured question tool for
feedback; and the project's test runner for integration. Follow
[tool selection](../_shared/references/tool-selection.md). A missing browser or image library is
a stated limitation to resolve, never evidence that a mark renders correctly.

## Examples

- `/jr-logo` in a new project: three directions, one accepted, then installed as the header
  logo and favicon.
- `/jr-logo` after a rejected round: a second group of concepts built from the product's domain
  vocabulary, compared beside the first.
- `/jr-logo` to refine the current mark: one SVG revised, re-rendered, and reinstalled.
