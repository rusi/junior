// tests/demo/viewer.ts
export const RECORDING = "walkthrough.webm";
export type Claim = { caption: string; image: { file: string; focus: number } | null };

function escapeHtml(value: string): string {
  return value.replace(
    /[&<>"]/g,
    (character) =>
      ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" })[character] ?? character,
  );
}

/**
 * The page both media render into: the title, the brief, and a line saying what is below it.
 *
 * No external stylesheet, script, or font: a sheet has to render from a directory someone
 * was handed, with nothing serving it.
 */
function sheet(title: string, summary: string, count: string, style: string, body: string): string {
  return `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>${escapeHtml(title)}</title>
<style>
  :root { color-scheme: light dark; --rule: rgba(128,128,128,.35); --dim: color-mix(in srgb, currentColor 55%, transparent); }
  body { margin: 0; padding: 2rem; font: 15px/1.55 system-ui, sans-serif; }
  header { max-width: 68ch; margin: 0 0 2rem; }
  h1 { margin: 0 0 .5rem; font-size: 1.3rem; font-weight: 600; }
  .brief { margin: 0; color: var(--dim); }
  .count { margin: .75rem 0 0; font-size: .82rem; letter-spacing: .06em; text-transform: uppercase; color: var(--dim); font-variant-numeric: tabular-nums; }
${style}
</style>
</head>
<body>
<header>
  <h1>${escapeHtml(title)}</h1>
  <p class="brief">${escapeHtml(summary)}</p>
  <p class="count">${count}</p>
</header>
${body}
</body>
</html>
`;
}

const GRID_STYLE = `  .sheet { display: grid; gap: 1.5rem; grid-template-columns: repeat(auto-fill, minmax(340px, 1fr)); }
  figure { margin: 0; }
  .shot { display: block; width: 100%; padding: 0; border: 1px solid var(--rule); border-radius: 4px; background: none; cursor: zoom-in; overflow: hidden; height: 240px; }
  .shot img { display: block; width: 100%; height: 100%; object-fit: cover; }
  .shot:hover { border-color: currentColor; }
  .shot:focus-visible { outline: 2px solid currentColor; outline-offset: 2px; }
  figcaption { margin-top: .5rem; font-size: .9rem; display: flex; gap: .5rem; align-items: baseline; }
  figcaption b { opacity: .5; font-variant-numeric: tabular-nums; }

  dialog.viewer { width: 100%; max-width: 100%; height: 100%; max-height: 100%; margin: 0; padding: 0; border: 0; background: Canvas; color: CanvasText; }
  dialog.viewer::backdrop { background: rgba(0,0,0,.8); }
  .viewer-bar { position: sticky; top: 0; z-index: 1; display: flex; gap: 1rem; align-items: baseline; padding: .85rem 1.25rem; background: Canvas; border-bottom: 1px solid var(--rule); }
  .viewer-num { font-variant-numeric: tabular-nums; opacity: .55; }
  .viewer-caption { flex: 1; font-weight: 500; }
  .viewer-bar button { font: inherit; padding: .3rem .7rem; border: 1px solid var(--rule); border-radius: 4px; background: none; color: inherit; cursor: pointer; }
  .viewer-bar button:disabled { opacity: .35; cursor: default; }
  .viewer-scroll { padding: 1.25rem; }
  .viewer-scroll img { display: block; width: 100%; max-width: 1280px; margin: 0 auto; border: 1px solid var(--rule); }
  @media (prefers-reduced-motion: no-preference) { .shot img { transition: transform .2s ease; } .shot:hover img { transform: scale(1.02); } }`;

/**
 * A grid of captioned panels.
 *
 * The grid shows a fixed-height crop of each panel, centred on the element that panel
 * asserted — a crop of the top would look the same for every screen. The
 * click opens the whole image, and reviewing happens there: it steps forward and back, so a
 * reviewer walks the sequence instead of hunting the grid for what came next.
 */
export function contactSheet(title: string, summary: string, claims: Claim[]): string {
  const panels = claims.flatMap((claim) =>
    claim.image ? [{ ...claim.image, caption: claim.caption }] : [],
  );

  const figures = panels
    .map(
      (panel, index) => `
    <figure class="panel" data-index="${index}">
      <button class="shot" type="button" aria-label="Open panel ${index + 1}: ${escapeHtml(panel.caption)}">
        <img src="${panel.file}" alt="${escapeHtml(panel.caption)}" style="object-position: 50% ${panel.focus.toFixed(1)}%" />
      </button>
      <figcaption><b>${String(index + 1).padStart(2, "0")}</b><span>${escapeHtml(panel.caption)}</span></figcaption>
    </figure>`,
    )
    .join("");

  // The viewer reads captions from here rather than the DOM, so opening a panel never depends
  // on how the grid happens to be marked up.
  const data = JSON.stringify(panels.map((p) => ({ file: p.file, caption: p.caption }))).replace(/</g, "\\u003c");

  return sheet(
    title,
    summary,
    `${panels.length} panel${panels.length === 1 ? "" : "s"} &middot; click any panel to step through`,
    GRID_STYLE,
    `<div class="sheet">${figures}
</div>

<dialog class="viewer">
  <div class="viewer-bar">
    <span class="viewer-num"></span>
    <span class="viewer-caption"></span>
    <button type="button" data-nav="-1">&larr; Prev</button>
    <button type="button" data-nav="1">Next &rarr;</button>
    <button type="button" data-close>Close</button>
  </div>
  <div class="viewer-scroll"><img alt="" /></div>
</dialog>

<script>
  const panels = ${data};
  const viewer = document.querySelector(".viewer");
  const img = viewer.querySelector("img");
  const num = viewer.querySelector(".viewer-num");
  const cap = viewer.querySelector(".viewer-caption");
  const prev = viewer.querySelector('[data-nav="-1"]');
  const next = viewer.querySelector('[data-nav="1"]');
  let at = 0;

  function show(index) {
    at = Math.max(0, Math.min(panels.length - 1, index));
    const panel = panels[at];
    img.src = panel.file;
    img.alt = panel.caption;
    num.textContent = String(at + 1).padStart(2, "0") + " / " + String(panels.length).padStart(2, "0");
    cap.textContent = panel.caption;
    prev.disabled = at === 0;
    next.disabled = at === panels.length - 1;
    viewer.querySelector(".viewer-scroll").scrollTop = 0;
  }

  document.querySelectorAll(".panel .shot").forEach((button, index) => {
    button.addEventListener("click", () => {
      show(index);
      viewer.showModal();
    });
  });

  viewer.querySelectorAll("[data-nav]").forEach((button) => {
    button.addEventListener("click", () => show(at + Number(button.dataset.nav)));
  });
  viewer.querySelector("[data-close]").addEventListener("click", () => viewer.close());

  document.addEventListener("keydown", (event) => {
    if (!viewer.open) return;
    if (event.key === "ArrowRight") { event.preventDefault(); show(at + 1); }
    if (event.key === "ArrowLeft") { event.preventDefault(); show(at - 1); }
  });
</script>`,
  );
}

const PLAYER_STYLE = `  video { display: block; width: 100%; max-width: 1280px; border: 1px solid var(--rule); border-radius: 4px; background: #000; }
  .claims { max-width: 68ch; margin: 1.5rem 0 0; padding: 0; list-style: none; }
  .claims li { display: flex; gap: .5rem; align-items: baseline; padding: .35rem 0; border-bottom: 1px solid var(--rule); }
  .claims b { opacity: .5; font-variant-numeric: tabular-nums; }
  .note { max-width: 68ch; margin: 1.25rem 0 0; font-size: .9rem; color: var(--dim); }`;

/**
 * A recording, and the ordered claims the run asserted while making it.
 *
 * There is no grid, because what a reviewer does with a recording is watch it. The list is
 * what the run proved. The viewer describes states and transitions without exposing the
 * capture process; assertion evidence stays in the runner's completion receipt.
 */
export function recordingSheet(title: string, summary: string, claims: Claim[], wide = false): string {
  const items = claims
    .map(
      (claim, index) => `
    <li><b>${String(index + 1).padStart(2, "0")}</b><span>${escapeHtml(claim.caption)}</span></li>`,
    )
    .join("");

  return sheet(
    title,
    summary,
    `${claims.length} moment${claims.length === 1 ? "" : "s"} &middot; play the walkthrough`,
    PLAYER_STYLE + (wide ? "\nvideo { max-width: 2560px; }" : ""),
    `<video controls preload="metadata" src="${RECORDING}"></video>

<ol class="claims">${items}
</ol>

<p class="note">Captions identify demonstrated states. Watch the recording to inspect the
transitions between them.</p>`,
  );
}
