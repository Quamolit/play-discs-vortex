import { test, expect } from "@playwright/test";
import * as app from "../target/js/app/app.main.mjs";
import { to_js_data } from "../target/js/app/calcit.core.mjs";

test("默认播放：过期 RAF 首帧不能产生负时间或停止绘制", async ({ page }) => {
  const errors = [];
  page.on("pageerror", (error) => errors.push(error.message));
  await page.addInitScript(() => {
    const original = window.requestAnimationFrame.bind(window);
    let firstFrame = true;
    window.requestAnimationFrame = (callback) =>
      original((timestamp) => {
        if (firstFrame) {
          firstFrame = false;
          callback(timestamp - 10000);
        } else callback(timestamp);
      });
  });
  await page.goto("/?seed=17");
  await expect
    .poll(() => page.evaluate(() => window.vortex?.snapshot().time ?? -1))
    .toBeGreaterThan(0);
  expect(
    await page.evaluate(() => {
      const canvas = document.querySelector("canvas");
      const data = canvas
        .getContext("2d")
        .getImageData(0, 0, canvas.width, canvas.height).data;
      return data.some((value, index) => index % 4 !== 3 && value > 10);
    }),
  ).toBe(true);
  await page.getByRole("button", { name: "暂停", exact: true }).click();
  expect(errors).toEqual([]);
});

test("Calcit：完整圈数、生成规则、乱序采样与历史角速度", () => {
  const model = app.initial(17);
  const data = to_js_data(model);
  expect(new Set(data.segments.map((segment) => segment.ring))).toEqual(
    new Set(Array.from({ length: 38 }, (_, index) => index + 2)),
  );
  expect(to_js_data(app.initial(17))).toEqual(data);
  expect(to_js_data(app.segment_color(0, 1, 0.5))).toEqual({
    r: 1,
    g: 0,
    b: 0,
    a: 1,
  });
  expect(to_js_data(app.segment_color(120, 1, 0.5))).toEqual({
    r: 0,
    g: 1,
    b: 0,
    a: 1,
  });
  expect(to_js_data(app.segment_color(240, 1, 0.5))).toEqual({
    r: 0,
    g: 0,
    b: 1,
    a: 1,
  });
  const before = JSON.stringify(data);
  for (const time of [0, 0.5, 2.5, 0, 1]) {
    const frame = to_js_data(app.sample(model, time, 1100, 1000));
    expect(frame.nodes).toHaveLength(data.segments.length);
    frame.nodes.forEach((node, index) => {
      const segment = data.segments[index];
      const path = node.content[1];
      const angle =
        ((360 * segment.from + (400 * time) / segment.ring) * Math.PI) / 180;
      expect(node.content[0]).toBe("arc");
      expect(path.cx).toBe(550);
      expect(path.cy).toBe(500);
      expect(path.radius).toBe(12 * segment.ring);
      expect(path["start-angle"]).toBe(angle);
      expect(path.counterclockwise).toBe(false);
      expect(path.width).toBe(4);
      expect(path.stroke).toEqual(segment.color);
      const endAngle =
        ((360 * segment.to + (400 * time) / segment.ring) * Math.PI) / 180;
      expect(path["end-angle"]).toBe(endAngle);
    });
  }
  expect(JSON.stringify(to_js_data(model))).toBe(before);
  const regenerated = to_js_data(app.regenerate(model));
  expect(regenerated.generation).toBe(1);
  expect(Math.max(...regenerated.segments.map((segment) => segment.ring))).toBe(
    35,
  );
  expect(regenerated.segments).not.toEqual(data.segments);
  expect(() => app.initial(0)).toThrow();
  expect(() => app.sample(model, -1, 100, 100)).toThrow();
});

for (const dpr of [1, 2]) {
  test(`真实圆弧参考、中间帧、交互与全屏 DPR${dpr}`, async ({
    browser,
  }, testInfo) => {
    const context = await browser.newContext({
      viewport: { width: 1100, height: 1000 },
      deviceScaleFactor: dpr,
    });
    const page = await context.newPage();
    const errors = [];
    page.on("pageerror", (error) => errors.push(error.message));
    await page.goto("/?seed=17&t=0");
    await page.waitForFunction(() => window.vortex);
    const original = await page.evaluate(() => window.vortex.snapshot());
    for (const time of [0, 0.5, 2.5, 0]) {
      const metrics = await page.evaluate((seconds) => {
        window.vortex.seek(seconds);
        const canvas = document.querySelector("canvas");
        const model = window.vortex.inspect();
        const reference = document.createElement("canvas");
        reference.width = canvas.width;
        reference.height = canvas.height;
        const native = reference.getContext("2d");
        native.scale(devicePixelRatio, devicePixelRatio);
        native.fillStyle = "black";
        native.fillRect(0, 0, innerWidth, innerHeight);
        native.lineWidth = 4;
        native.lineCap = "round";
        for (const segment of model.segments) {
          const { r, g, b, a } = segment.color;
          native.strokeStyle = `rgba(${255 * r},${255 * g},${255 * b},${a})`;
          const rotation = (seconds * 400) / segment.ring;
          native.beginPath();
          native.arc(
            innerWidth / 2,
            innerHeight / 2,
            12 * segment.ring,
            ((segment.from * 360 + rotation) * Math.PI) / 180,
            ((segment.to * 360 + rotation) * Math.PI) / 180,
          );
          native.stroke();
        }
        const actual = canvas
          .getContext("2d")
          .getImageData(0, 0, canvas.width, canvas.height).data;
        const expected = native.getImageData(
          0,
          0,
          canvas.width,
          canvas.height,
        ).data;
        let difference = 0;
        let blankDifference = 0;
        let lit = 0;
        for (let index = 0; index < actual.length; index += 4) {
          if (expected[index] + expected[index + 1] + expected[index + 2] > 10)
            lit++;
          difference +=
            Math.abs(actual[index] - expected[index]) +
            Math.abs(actual[index + 1] - expected[index + 1]) +
            Math.abs(actual[index + 2] - expected[index + 2]);
          blankDifference +=
            expected[index] + expected[index + 1] + expected[index + 2];
        }
        return {
          errorPerLitChannel: difference / (lit * 3),
          blankError: blankDifference / (lit * 3),
          lit,
          width: canvas.width,
          height: canvas.height,
        };
      }, time);
      expect(metrics.lit).toBeGreaterThan(10000 * dpr * dpr);
      // 原生 Scene arc 已移除离散误差；保留完整帧比较，收紧而不是放宽旧门禁。
      expect(metrics.errorPerLitChannel).toBe(0);
      expect(metrics.blankError).toBeGreaterThan(4);
      console.log(JSON.stringify({ dpr, time, ...metrics }));
      expect(metrics.width).toBe(1100 * dpr);
      await page.screenshot({
        path: testInfo.outputPath(`vortex-t${time}-dpr${dpr}.png`),
      });
    }
    await page.getByRole("button", { name: "重新生成" }).click();
    expect(
      (await page.evaluate(() => window.vortex.snapshot())).generation,
    ).toBe(1);
    await page.getByRole("button", { name: "播放", exact: true }).click();
    await expect
      .poll(() => page.evaluate(() => window.vortex.snapshot().time))
      .toBeGreaterThan(original.time);
    await page.getByRole("button", { name: "暂停", exact: true }).click();
    const paused = await page.evaluate(() => window.vortex.snapshot().time);
    await page.waitForTimeout(100);
    expect(await page.evaluate(() => window.vortex.snapshot().time)).toBe(
      paused,
    );
    await page.getByRole("button", { name: "全屏", exact: true }).click();
    await page.waitForFunction(
      () =>
        document.fullscreenElement ||
        document.querySelector("#status").textContent.startsWith("全屏不可用"),
    );
    await page.evaluate(async () => {
      if (document.fullscreenElement) await document.exitFullscreen();
    });
    await page.setViewportSize({ width: 390, height: 700 });
    await expect(page.locator("canvas")).toHaveCSS("width", "390px");
    await page.evaluate(() => window.vortex.dispose());
    expect(await page.evaluate(() => window.vortex)).toBeUndefined();
    expect(errors).toEqual([]);
    await context.close();
  });
}
