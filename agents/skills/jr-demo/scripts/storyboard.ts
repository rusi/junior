// <frontend>/tests/demo/storyboard.ts
import fs from "node:fs/promises";
import { createHash, randomUUID } from "node:crypto";
import path from "node:path";
import { expect, type Locator, type Page, type Video } from "@playwright/test";
import type { MultiViewCapture } from './multiview';

const VIEWPORT = { width: 1280, height: 800 };

// What a motion walkthrough delivers. Kept alongside the panels wherever the run was
// pointed, so it is reviewed and committed like any other artifact.
const RECORDING = "walkthrough.webm";

// How long the press indicator takes to play. Exported because a press has to outlast it —
// a hold shorter than this cuts the indicator off and the consequence appears to arrive
// first, which is the whole defect `press` exists to avoid. One number, so lengthening the
// animation cannot silently outrun the hold that was tuned for the old value.
export const PRESS_FEEDBACK_MS = 300;

// One asserted claim. `image` is the panel it was captured as; a motion walkthrough has no
// panels, and what survives of a step is the claim and the fact that it was asserted.
//
// `focus` is where the asserted element sits down the full-page image, 0 to 100. The grid
// crops thumbnails around it, so a thumbnail shows what its caption is about rather than
// whatever happens to be at the top of every page.
type Claim = { caption: string; image: { file: string; focus: number } | null };

function slug(caption: string): string {
  return caption
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 60);
}

export function capturePath(root: string, title: string, identity: string): string {
  if (!root.trim() || !identity.trim()) throw new Error("Capture root and identity must be nonempty.");
  const hash = createHash("sha256").update(identity).digest("hex");
  return path.join(path.resolve(root), `${slug(title) || "walkthrough"}-${hash}`);
}

class CaptureDirectory {
  private readonly token = randomUUID();

  private constructor(
    readonly directory: string,
    private readonly root: string,
    private readonly identity: string,
  ) {}

  private get marker(): string { return path.join(this.directory, ".capture-owner.json"); }

  static async open(root: string, directory: string, identity: string): Promise<CaptureDirectory> {
    if (!root.trim() || !directory.trim() || !identity.trim()) {
      throw new Error("Capture root, directory, and identity must be nonempty.");
    }
    const parent = path.resolve(root);
    const target = path.resolve(directory);
    if (target === parent || path.dirname(target) !== parent) {
      throw new Error("Capture directory must be a direct child of the output root.");
    }
    await fs.mkdir(parent, { recursive: true });
    const canonicalRoot = await fs.realpath(parent);
    const owned = new CaptureDirectory(path.join(canonicalRoot, path.basename(target)), canonicalRoot, identity);
    const existing = await fs.lstat(owned.directory).catch((error: NodeJS.ErrnoException) => {
      if (error.code === "ENOENT") return null;
      throw error;
    });
    if (existing) await owned.remove(false);
    await fs.mkdir(owned.directory);
    await fs.writeFile(owned.marker, JSON.stringify({ identity, token: owned.token }), { flag: "wx" });
    return owned;
  }

  async remove(currentRun = true): Promise<void> {
    // Recheck canonical containment and ownership immediately before every recursive removal.
    if (path.dirname(this.directory) !== this.root ||
        await fs.realpath(this.root) !== this.root ||
        !(await fs.lstat(this.directory)).isDirectory() ||
        await fs.realpath(this.directory) !== this.directory) {
      throw new Error("Capture directory escaped its output root or is not a real directory.");
    }
    if (!(await fs.lstat(this.marker)).isFile()) throw new Error("Capture ownership marker must be a regular file.");
    const owner = JSON.parse(await fs.readFile(this.marker, "utf8"));
    if (owner?.identity !== this.identity || typeof owner.token !== "string" || !owner.token ||
        (currentRun && owner.token !== this.token)) {
      throw new Error("Capture directory ownership does not match this walkthrough or run.");
    }
    await fs.rm(this.directory, { recursive: true });
  }
}

function escapeHtml(value: string): string {
  return value.replace(
    /[&<>"]/g,
    (character) =>
      ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" })[character] ?? character,
  );
}

/**
 * Draw the pointer into the page, because the recorder does not.
 *
 * A screencast composites the page, not the operating system's cursor, so a recording of a
 * pointer interaction shows everything except the pointer. The reviewer of a hover walkthrough
 * is left inferring where the mouse is from whatever the page highlights, and a click
 * walkthrough shows nothing at all at the moment that matters.
 *
 * So it draws the cursor a user would have seen: an arrow whose tip is the exact event
 * coordinate, which is what makes it precise — the hotspot is a point rather than the middle
 * of a shape somebody has to calibrate. The body hangs down-right of that point, away from
 * whatever the caption is about, and a ripple marks each press.
 *
 * Realistic is right here rather than suspect. Nothing renders an arrow cursor as page
 * content, so it cannot be mistaken for the application, and it is driven by the real event
 * stream — a faithful drawing of something the recorder dropped, not an invention.
 *
 * It exists only in motion mode — stills never carry it — and it takes no pointer events,
 * so nothing the walkthrough does can land on it.
 */
function drawPointer({ pressFeedbackMs, animate }: { pressFeedbackMs: number; animate: boolean }): void {
  const ID = "demo-pointer-overlay";
  const IDLE = 700;

  const ensure = () => {
    let root = document.getElementById(ID);
    if (!root) {
      root = document.createElement("div");
      root.id = ID;
      root.style.cssText =
        "position:fixed;left:0;top:0;width:0;height:0;pointer-events:none;z-index:2147483647;display:none";
      // The arrow's tip sits at 0,0 of this container, so the container's position is the
      // pointer's exact position and the arrow's body hangs down-right of it — away from
      // whatever the caption is about, the way a real cursor does. The device sits up-right,
      // out of the arrow's way, and appears only while something is being pressed or turned.
      // Animated overlay layers can stall Chromium screencast delivery. Keep multi-view
      // feedback immediate so the overlay does not distort the captured timeline.
      root.innerHTML = (animate ? "" : `<style>#${ID} * { transition: none !important; }</style>`) +
        '<div data-ripple style="position:absolute;left:0;top:0;width:38px;height:38px;' +
        "margin:-19px 0 0 -19px;border:3px solid rgba(255,60,60,1);border-radius:50%;" +
        "opacity:0;transform:scale(.2);" +
        'transition:transform 300ms ease-out, opacity 300ms ease-out"></div>' +
        '<svg data-device width="24" height="46" viewBox="0 0 24 46" ' +
        'style="position:absolute;left:26px;top:-10px;display:block;opacity:0;' +
        'transition:opacity 160ms ease-out">' +
        '<path data-up d="M6 5 L12 0.8 L18 5" stroke="#ff3c3c" stroke-width="2.6" ' +
        'fill="none" stroke-linecap="round" stroke-linejoin="round" opacity="0"/>' +
        '<path data-down d="M6 41 L12 45.2 L18 41" stroke="#ff3c3c" stroke-width="2.6" ' +
        'fill="none" stroke-linecap="round" stroke-linejoin="round" opacity="0"/>' +
        '<rect x="3" y="8" width="18" height="28" rx="9" fill="rgba(255,255,255,.97)" ' +
        'stroke="rgba(0,0,0,.85)" stroke-width="1.5"/>' +
        // The whole half lights up rather than a dot on it. A left press and a right press
        // have to be told apart at a glance in a moving image, and at this size a dot is a
        // couple of pixels — present, and not something anyone would notice.
        '<path data-left d="M3 20 L3 17 A9 9 0 0 1 12 8 L12 20 Z" fill="transparent"/>' +
        '<path data-right d="M21 20 L21 17 A9 9 0 0 0 12 8 L12 20 Z" fill="transparent"/>' +
        '<line x1="3.4" y1="20" x2="20.6" y2="20" stroke="rgba(0,0,0,.5)" stroke-width="1.2"/>' +
        '<line x1="12" y1="8.6" x2="12" y2="20" stroke="rgba(0,0,0,.5)" stroke-width="1.2"/>' +
        '<rect data-wheel x="10.6" y="11" width="2.8" height="6" rx="1.4" ' +
        'fill="rgba(0,0,0,.6)"/>' +
        "</svg>" +
        '<svg width="20" height="30" viewBox="0 0 20 30" ' +
        'style="position:absolute;left:0;top:0;display:block">' +
        '<path data-path d="M1 1 L1 21.5 L6.2 16.6 L9.6 24.9 L13.1 23.4 L9.8 15.4 L16.4 15.2 Z" ' +
        'fill="#fff" stroke="rgba(0,0,0,.85)" stroke-width="1.6" stroke-linejoin="round"/>' +
        "</svg>";
    }
    // Re-appended rather than assumed present: an init script runs before the page's own
    // scripts, and a framework that rebuilds the body would otherwise take the overlay with it.
    if (!root.isConnected) document.body.appendChild(root);
    const pick = (name: string) => root!.querySelector(`[data-${name}]`) as SVGElement;
    return {
      root,
      path: pick("path"),
      ripple: root.querySelector("[data-ripple]") as HTMLElement,
      device: pick("device"),
      left: pick("left"),
      right: pick("right"),
      wheel: pick("wheel"),
      up: pick("up"),
      down: pick("down"),
    };
  };

  let idleTimer = 0;
  const showDevice = (): void => {
    const { device } = ensure();
    device.style.opacity = "1";
    clearTimeout(idleTimer);
    // Hidden again once nothing is happening, so it marks an interaction rather than
    // sitting beside the pointer in every frame of every walkthrough.
    idleTimer = window.setTimeout(() => {
      device.style.opacity = "0";
    }, IDLE);
  };

  const install = (): void => {
    document.addEventListener(
      animate ? "mousemove" : "pointermove",
      (event) => {
        const { root } = ensure();
        root.style.display = "block";
        root.style.left = `${event.clientX}px`;
        root.style.top = `${event.clientY}px`;
      },
      true,
    );

    document.addEventListener(
      animate ? "mousedown" : "pointerdown",
      (event) => {
        const { path, ripple, left, right, wheel } = ensure();
        showDevice();
        // Which button, shown on the device: a demo that right-clicks looks identical to one
        // that left-clicks unless the artifact says which was pressed.
        const pressed = event.button === 2 ? right : event.button === 1 ? wheel : left;
        pressed.setAttribute("fill", "#ff3c3c");
        path.setAttribute("fill", "#ff3c3c");
        // Restarted from the collapsed state each press, so a second click in the same place
        // is as visible as the first.
        ripple.style.transition = "none";
        ripple.style.opacity = "1";
        ripple.style.transform = "scale(.2)";
        void ripple.offsetWidth;
        ripple.style.transition =
          `transform ${pressFeedbackMs}ms ease-out, opacity ${pressFeedbackMs}ms ease-out`;
        ripple.style.opacity = "0";
        ripple.style.transform = "scale(1.5)";
      },
      true,
    );

    document.addEventListener(
      animate ? "mouseup" : "pointerup",
      () => {
        const { path, left, right, wheel } = ensure();
        path.setAttribute("fill", "#fff");
        left.setAttribute("fill", "transparent");
        right.setAttribute("fill", "transparent");
        wheel.setAttribute("fill", "rgba(0,0,0,.6)");
      },
      true,
    );

    document.addEventListener(
      "wheel",
      (event) => {
        const { wheel, up, down } = ensure();
        showDevice();
        // One flash per wheel event, so a reviewer counts steps rather than watching a page
        // slide for reasons nothing on screen accounts for.
        const chevron = event.deltaY < 0 ? up : down;
        wheel.setAttribute("fill", "#ff3c3c");
        chevron.style.transition = "none";
        chevron.style.opacity = "1";
        // `getBoundingClientRect` rather than `offsetWidth`: an SVG element has no
        // `offsetWidth`, so reading it forces no layout, the restart never happens, and the
        // chevron fades from a value that was never painted — which is to say, not at all.
        chevron.getBoundingClientRect();
        chevron.style.transition = "opacity 450ms ease-out";
        chevron.style.opacity = "0";
        window.setTimeout(() => wheel.setAttribute("fill", "rgba(0,0,0,.6)"), 320);
      },
      true,
    );
  };

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", install, { once: true });
  } else {
    install();
  }
}

/**
 * A storyboard accepts panels through one door.
 *
 * `step` asserts before it captures, and nothing else can append. The screenshot function
 * is taken off the page at open time and kept here, so a walkthrough that reaches for it
 * gets an error rather than an unasserted panel.
 *
 * A walkthrough that opted into motion is the same object with the same one door. Its steps
 * assert and record their claim; the artifact they land in is a recording rather than a
 * grid. Captions identify demonstrated states; intervening frames remain visual evidence
 * for a person to evaluate, not individually asserted states.
 */
async function installPointer(page: Page, animate: boolean): Promise<void> {
  const options = { pressFeedbackMs: PRESS_FEEDBACK_MS, animate };
  await page.addInitScript(drawPointer, options);
  await page.evaluate(drawPointer, options);
}

export class Storyboard {
  private readonly claims: Claim[] = [];
  private summary = "";
  private readonly views = new Map<string, Page>();
  private multiCapture: MultiViewCapture | null = null;

  private constructor(
    private readonly page: Page,
    private readonly capture: Page["screenshot"],
    private readonly recording: Video | null,
    private readonly output: CaptureDirectory,
    private readonly title: string,
    private readonly viewLabels: readonly [string, string] | null,
  ) {}

  private get directory(): string { return this.output.directory; }

  static async open(
    page: Page,
    title: string,
    directory: string,
    motion: boolean,
    outputRoot: string,
    identity: string,
    viewLabels: readonly [string, string] | null = null,
  ): Promise<Storyboard> {
    if (viewLabels && (motion || viewLabels.length !== 2 ||
        viewLabels.some(label => !label.trim() || label.length > 60 || /[\r\n]/.test(label)) ||
        viewLabels[0] === viewLabels[1])) {
      throw new Error('Two-view capture requires two distinct short labels and video: "off".');
    }
    if (viewLabels && page.video()) throw new Error('Two-view pages must use video: "off".');
    await page.setViewportSize(VIEWPORT);

    const capture = page.screenshot.bind(page);
    page.screenshot = async () => {
      throw new Error(
        "A demo walkthrough cannot capture directly. Use step(caption, locator), which " +
          "asserts the locator is visible before it captures.",
      );
    };

    // A recorder can be running for reasons that have nothing to do with the medium, so
    // what routes the artifact is the declaration rather than the recorder's presence.
    // Where the two disagree, say so: a walkthrough asking for motion with nothing
    // recording would otherwise deliver a sheet pointing at a file that was never written.
    const recording = motion ? page.video() : null;
    if (motion && !recording) {
      throw new Error(
        "This walkthrough asked for motion and nothing is recording. Its own `video` " +
          "declaration is being overridden below it — check the demo project's options.",
      );
    }

    if (motion || viewLabels) {
      // On every navigation from here, and once on the page already open — an init script
      // alone would leave the overlay missing until the walkthrough happened to navigate.
      await installPointer(page, !viewLabels);
    }

    const output = await CaptureDirectory.open(outputRoot, directory, identity);
    const storyboard = new Storyboard(page, capture, recording, output, title, viewLabels);
    if (viewLabels) storyboard.views.set(viewLabels[0], page);
    return storyboard;
  }

  /** Register the second, already initialized page; labels determine the fixed placement. */
  async registerView(label: string, page: Page): Promise<void> {
    if (!this.viewLabels || !this.viewLabels.includes(label) || this.views.has(label) ||
        [...this.views.values()].includes(page) || this.multiCapture) {
      throw new Error('Register each declared view once, before recording starts.');
    }
    if (page.video()) throw new Error('Two-view pages must use video: "off".');
    await page.setViewportSize(VIEWPORT);
    await installPointer(page, false);
    page.screenshot = async () => { throw new Error('Use step with a registered view instead of capturing directly.'); };
    this.views.set(label, page);
  }

  /** Start a common timeline after both views have reached their intended starting state. */
  async startRecording(): Promise<void> {
    if (!this.viewLabels || this.views.size !== 2 || this.multiCapture || this.claims.length) {
      throw new Error('Start recording once, with both declared views registered and before any claims.');
    }
    const { MultiViewCapture } = await import('./multiview');
    this.multiCapture = await MultiViewCapture.open(
      this.viewLabels.map(label => this.views.get(label)!), this.viewLabels, this.directory,
    );
  }

  /** What this walkthrough shows, and what a reviewer should judge. Required before `write`. */
  brief(text: string): void {
    this.summary = text.trim();
  }

  /** Assert the locator is visible, capture the whole page, and append the panel. */
  async step(caption: string, locator: Locator): Promise<void> {
    if (this.viewLabels) {
      const view = [...this.views].find(([, page]) => page === locator.page());
      if (!view) throw new Error('An assertion must belong to a registered view.');
      if (!this.multiCapture) throw new Error('Start recording before asserting a two-view claim.');
      caption = `${view[0]}: ${caption}`;
    }
    const position = this.claims.length + 1;
    await expect(locator, `panel ${position}: ${caption}`).toBeVisible();
    // Bring the asserted element into view before capturing. `fullPage` makes framing a
    // non-issue for the image, but the scroll still settles lazy content that only renders
    // once it has been reached.
    await locator.scrollIntoViewIfNeeded();

    if (this.recording || this.viewLabels) {
      // Motion is already being captured continuously, so a still here would be a second
      // artifact of the same moment. The claim and its assertion are what this step adds.
      this.claims.push({ caption, image: null });
      return;
    }

    // Where the asserted element sits in the document, as a fraction of the whole page. Read
    // before capturing, from the element the caption is about.
    const focus = await locator.evaluate((element) => {
      const box = element.getBoundingClientRect();
      const centre = box.top + window.scrollY + box.height / 2;
      const height = document.documentElement.scrollHeight || 1;
      return Math.max(0, Math.min(100, (centre / height) * 100));
    });

    const file = `${String(position).padStart(2, "0")}-${slug(caption)}.png`;
    // `fullPage` captures the whole document, not the viewport. A caption describing a list
    // then cannot be contradicted by where the page happened to be scrolled — the commonest
    // way a panel passes its assertion and still shows the reviewer the wrong thing.
    // `scale: "css"` pins the image to CSS pixels, so a retina runner does not silently
    // quadruple the weight of every panel.
    await this.capture({ path: path.join(this.directory, file), fullPage: true, scale: "css" });
    this.claims.push({ caption, image: { file, focus } });
  }

  /**
   * Save the recording, for a walkthrough that opted into motion. Returns what it weighs,
   * for the run to report; null for stills.
   *
   * The page is closed here rather than left to the runner's own teardown: a recording is
   * finalized on close, and this is the last moment at which the artifact directory still
   * exists to save it into.
   */
  async record(): Promise<string | null> {
    const file = path.join(this.directory, RECORDING);
    if (this.viewLabels) {
      if (!this.multiCapture) throw new Error('Two-view recording was never started.');
      try { await this.multiCapture.finish(file); }
      finally { await Promise.all([...this.views.values()].map(page => page.close())); }
    } else {
      if (!this.recording) return null;
      await this.page.close();
      await this.recording.saveAs(file);
    }

    // Reported rather than enforced. What a recording should weigh depends on what it is
    // evidence for, and a limit that refuses would throw away a complete, correct artifact
    // over a number — so the run states the weight and the person committing it decides.
    const { size } = await fs.stat(file);
    return `${(size / 1024 / 1024).toFixed(1)} MB`;
  }

  /** Write the contact sheet and return the file to open. */
  async write(): Promise<string> {
    if (!this.claims.length) throw new Error("A capture requires at least one asserted moment.");
    if (!this.summary) {
      // A reviewer arriving at eight screenshots with no framing infers the question from the
      // pictures, and infers a different one than the author meant. Optional would mean
      // forgotten, so this fails the run instead of shipping a sheet nobody can act on.
      throw new Error(
        "This storyboard has no brief. Call demo.brief(...) with what the walkthrough shows " +
          "and what a reviewer should judge.",
      );
    }
    const index = path.join(this.directory, "index.html");
    const sheet = this.recording || this.viewLabels
      ? recordingSheet(this.title, this.summary, this.claims, Boolean(this.viewLabels))
      : contactSheet(this.title, this.summary, this.claims);
    await fs.writeFile(index, sheet, "utf8");
    return index;
  }

  /**
   * Remove a partial run. A walkthrough that failed leaves no artifact behind.
   *
   * The recording goes with the directory, in the one method, because the runner keeps its
   * own copy of a recording whether or not the walkthrough passed. Two calls to remember
   * would eventually be one call made: a video of the run that failed, sitting where the
   * next person looks for a demo.
   */
  async discard(): Promise<void> {
    try {
      if (this.viewLabels) {
        try { if (this.multiCapture) await this.multiCapture.dispose(); }
        finally { await Promise.all([...this.views.values()].map(page => page.close())); }
      }
    } finally { await this.output.remove(); }
    if (this.viewLabels || !this.recording) return;
    // The recorder finalizes on close and `delete` waits for that, so closing first keeps
    // the wait inside this teardown rather than the runner's. Closing twice is harmless.
    await this.page.close();
    await this.recording.delete();
  }
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
 * Panels are full-page images, so the grid shows a fixed-height crop of each, centred on the
 * element that panel asserted — a crop of the top would look the same for every page. The
 * click opens the whole image, and reviewing happens there: it steps forward and back, so a
 * reviewer walks the sequence instead of hunting the grid for what came next.
 */
function contactSheet(title: string, summary: string, claims: Claim[]): string {
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
function recordingSheet(title: string, summary: string, claims: Claim[], wide = false): string {
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
