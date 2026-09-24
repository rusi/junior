// <frontend>/tests/demo/multiview.ts
import fs from 'node:fs/promises';
import path from 'node:path';
import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import type { CDPSession, Page } from '@playwright/test';

export const FRAME_RATE = 25;
export const LABEL_HEIGHT = 48;
type Frame = { timestamp: number; file: string };
type Stream = { session: CDPSession; frames: Frame[]; pending: Promise<void>; removeListener: () => void };
const run = promisify(execFile);

/** Sample both streams on the same absolute clock, never on their arrival times. */
export function framePlan(frames: Frame[], start: number, end: number, fps: number): string[] {
  if (!Number.isFinite(start) || !Number.isFinite(end) || end <= start ||
      !Number.isInteger(fps) || fps <= 0 || !frames.length || frames[0].timestamp > start) {
    throw new Error('Capture requires a valid interval, frame rate, and starting frame.');
  }
  for (let i = 0; i < frames.length; i++) {
    if (!Number.isFinite(frames[i].timestamp) || (i > 0 && frames[i].timestamp < frames[i - 1].timestamp)) {
      throw new Error('Capture timestamps must be finite and monotonic.');
    }
  }
  let cursor = 0;
  const duration = Math.round(end * 1e6) - Math.round(start * 1e6);
  return Array.from({ length: Math.ceil(duration * fps / 1e6) }, (_, tick) => {
    const time = start + tick / fps;
    // Never pull a sparse stream's future change forward by more than half a frame.
    while (cursor + 1 < frames.length && frames[cursor + 1].timestamp <= time + .5 / fps &&
        Math.abs(frames[cursor + 1].timestamp - time) <= Math.abs(frames[cursor].timestamp - time)) cursor++;
    return frames[cursor].file;
  });
}

/** Chromium frame timestamps retain a common epoch across independently opened pages. */
export class MultiViewCapture {
  private readonly streams: Stream[] = [];
  private error: unknown;
  private start = 0;
  private elapsedStart = 0;
  private stopped = false;

  private constructor(private readonly scratch: string, private readonly labels: readonly string[]) {}

  static async open(pages: readonly Page[], labels: readonly string[], directory: string): Promise<MultiViewCapture> {
    const capture = new MultiViewCapture(await fs.mkdtemp(path.join(directory, '.frames-')), labels);
    try {
      // Sequential initialization is intentional: the shared epoch must tolerate skew.
      for (const page of pages) await capture.attach(page);
      capture.start = Date.now() / 1000;
      capture.elapsedStart = performance.now();
      return capture;
    } catch (error) {
      await capture.dispose();
      throw error;
    }
  }

  private async attach(page: Page): Promise<void> {
    const session = await page.context().newCDPSession(page);
    const view = this.streams.length;
    let ready!: () => void;
    let failed!: (error: Error) => void;
    const first = new Promise<void>((resolve, reject) => { ready = resolve; failed = reject; });
    const timer = setTimeout(() => failed(new Error('No timestamped capture frame arrived within 10 seconds.')), 10_000);
    const onFrame = (event: { data: string; sessionId: number; metadata: { timestamp?: number } }): void => {
      const { timestamp } = event.metadata;
      if (typeof timestamp !== 'number' || !Number.isFinite(timestamp)) {
        this.error = new Error('The browser omitted the frame timestamp.');
        failed(this.error as Error);
        return;
      }
      const file = `${view}-${stream.frames.length}.jpg`;
      stream.frames.push({ timestamp, file });
      stream.pending = stream.pending.then(async () => {
        await fs.writeFile(path.join(this.scratch, file), Buffer.from(event.data, 'base64'));
        await session.send('Page.screencastFrameAck', { sessionId: event.sessionId });
        ready();
      }).catch(error => { this.error = error; failed(error); });
    };
    const stream: Stream = { session, frames: [], pending: Promise.resolve(),
      removeListener: () => { session.off('Page.screencastFrame', onFrame); } };
    this.streams.push(stream);
    session.on('Page.screencastFrame', onFrame);
    try {
      await Promise.all([
        session.send('Page.startScreencast', { format: 'jpeg', quality: 95, everyNthFrame: 1 }), first,
      ]);
    } finally { clearTimeout(timer); }
  }

  private async stop(): Promise<void> {
    if (this.stopped) return;
    this.stopped = true;
    // Release every session even if one page crashed or closed during the walkthrough.
    const results = await Promise.allSettled(this.streams.map(async stream => {
      stream.removeListener();
      try {
        await stream.session.send('Page.stopScreencast');
      } finally {
        await stream.pending;
        await stream.session.detach();
      }
    }));
    for (const result of results) if (result.status === 'rejected') throw result.reason;
    if (this.error) throw this.error;
  }

  async finish(destination: string): Promise<void> {
    const end = Date.now() / 1000;
    const elapsed = (performance.now() - this.elapsedStart) / 1000;
    await this.stop();
    if (Math.abs(end - this.start - elapsed) > 1 / FRAME_RATE) {
      throw new Error('The capture clock changed; synchronized timing cannot be established.');
    }
    for (const [view, stream] of this.streams.entries()) {
      const plan = framePlan(stream.frames, this.start, end, FRAME_RATE);
      for (const [index, source] of plan.entries()) {
        await fs.link(path.join(this.scratch, source), path.join(this.scratch, `view${view}-${String(index).padStart(8, '0')}.jpg`));
      }
      await fs.writeFile(path.join(this.scratch, `label${view}.txt`), this.labels[view]);
    }
    const filters = this.streams.map((_, i) =>
      `[${i}:v]pad=iw:ih+${LABEL_HEIGHT}:0:${LABEL_HEIGHT}:color=0x18202b,` +
      `drawtext=textfile=label${i}.txt:expansion=none:fontcolor=white:fontsize=24:x=20:y=10[v${i}]`);
    await run('ffmpeg', [
      '-hide_banner', '-loglevel', 'error',
      ...this.streams.flatMap((_, i) => ['-framerate', String(FRAME_RATE), '-i', `view${i}-%08d.jpg`]),
      '-filter_complex', `${filters.join(';')};[v0][v1]hstack=inputs=2[out]`, '-map', '[out]',
      '-an', '-c:v', 'libvpx', '-deadline', 'realtime', '-cpu-used', '4', '-crf', '10',
      '-b:v', '4M', '-threads', '2', '-pix_fmt', 'yuv420p', '-y', destination,
    ], { cwd: this.scratch, timeout: 120_000 });
    await fs.rm(this.scratch, { recursive: true });
  }

  async dispose(): Promise<void> {
    try { await this.stop(); }
    finally { await fs.rm(this.scratch, { recursive: true, force: true }); }
  }
}
