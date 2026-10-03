import * as app from "./target/js/app/app.main.mjs";
import { init_tags, to_js_data } from "./target/js/app/calcit.core.mjs";

const tags = init_tags(["segments", "seed", "generation"]);
app.main_$x_();

const canvas = document.querySelector("#app");
const context = canvas.getContext("2d");
const params = new URLSearchParams(location.search);
const requestedSeed = Number(params.get("seed") ?? 17);
const seed =
  Number.isInteger(requestedSeed) &&
  requestedSeed > 0 &&
  requestedSeed < 2147483647
    ? requestedSeed
    : 17;
let model = app.initial(seed);
let time = Number(params.get("t") ?? 0);
if (!Number.isFinite(time) || time < 0) time = 0;
let playing = !params.has("t");
let last = performance.now();
let frame = 0;
let closed = false;
const play = document.querySelector("#play");
const status = document.querySelector("#status");

function render() {
  const width = window.innerWidth;
  const height = window.innerHeight;
  const dpr = window.devicePixelRatio || 1;
  if (
    canvas.width !== Math.round(width * dpr) ||
    canvas.height !== Math.round(height * dpr)
  ) {
    canvas.width = Math.round(width * dpr);
    canvas.height = Math.round(height * dpr);
  }
  context.setTransform(dpr, 0, 0, dpr, 0, 0);
  context.fillStyle = "black";
  context.fillRect(0, 0, width, height);
  const scene = app.sample(model, time, width, height);
  app.draw_$x_(context, scene, canvas.width, canvas.height, dpr);
  status.textContent = `${model.get(tags.segments).len()} 段 · ${time.toFixed(2)} s · seed ${model.get(tags.seed)}`;
  play.textContent = playing ? "暂停" : "播放";
  return scene;
}

function tick(now) {
  if (closed) return;
  if (playing && !document.hidden) time += Math.min((now - last) / 1000, 0.1);
  last = now;
  if (playing) render();
  frame = requestAnimationFrame(tick);
}

function toggle() {
  playing = !playing;
  last = performance.now();
  render();
}

function generate() {
  model = app.regenerate(model);
  render();
}

async function fullscreen() {
  try {
    if (document.fullscreenElement) await document.exitFullscreen();
    else await document.documentElement.requestFullscreen();
  } catch (error) {
    status.textContent = `全屏不可用：${error.message}`;
  }
}

const listeners = [];
function listen(target, event, callback) {
  target.addEventListener(event, callback);
  listeners.push(() => target.removeEventListener(event, callback));
}
listen(play, "click", toggle);
listen(document.querySelector("#generate"), "click", generate);
listen(document.querySelector("#fullscreen"), "click", fullscreen);
listen(window, "resize", render);
listen(document, "visibilitychange", () => {
  last = performance.now();
});
listen(window, "keydown", (event) => {
  if (event.code === "Space" && event.target === document.body) {
    event.preventDefault();
    toggle();
  }
});

function dispose() {
  if (closed) return;
  closed = true;
  cancelAnimationFrame(frame);
  listeners.forEach((remove) => remove());
  delete window.vortex;
}

// 显式时间入口也供截图工具使用；动画和场景逻辑均来自 Calcit。
window.vortex = {
  seek(seconds) {
    if (!Number.isFinite(seconds) || seconds < 0)
      throw new Error("invalid time");
    time = seconds;
    playing = false;
    return render();
  },
  snapshot: () => ({
    time,
    playing,
    generation: model.get(tags.generation),
    seed: model.get(tags.seed),
    segments: model.get(tags.segments).len(),
  }),
  generate,
  inspect: () => to_js_data(model),
  dispose,
};
render();
frame = requestAnimationFrame(tick);
listen(window, "pagehide", dispose);
if (import.meta.hot) {
  import.meta.hot.accept();
  import.meta.hot.dispose(dispose);
}
