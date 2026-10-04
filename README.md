
Discs Vortex
----

全屏多圈彩色圆头弧线，按半径反比持续旋转。重新生成保留旧版圈数规则：初始 `2..39`，Gen 后 `2..35`；半径 `12*r`、宽度 4 CSS px、速度 `400/r` 度/秒。浮层提供生成、播放/暂停和全屏按钮，空格也可暂停。

### 运行与验证

需要 Node.js 24、Calcit 0.28.0 和 caps。使用 node-modules linker。

```sh
yarn install --immutable
yarn compile
yarn dev --port 5193
# 可控时间：/?seed=17&t=0.5
yarn playwright install chromium
yarn test
yarn format:check
```

`calcit.cirru` 是源码，通过 Calcit CLI 修改。随机生成、HSL 转换、绝对时间采样、Scene 与 DPR 投影、Quamolit 绘制调用都由类型化 Calcit 实现；`main.mjs` 只负责浏览器生命周期、RAF、DOM 浮层和输入接线。编译输出放被忽略的 `target/js/app`，不需要手工拷贝或引入 Quamolit 内部 JS。

固定已发布 Quamolit [`0.0.18-alpha.4`](https://github.com/Quamolit/quamolit/releases/tag/0.0.18-alpha.4)（已合并主线 `1fb5d0c`），传递依赖 js-ffi `0.2.1-alpha.11`；[Quamolit #218](https://github.com/Quamolit/quamolit/pull/218) 已合并，圆弧能力不再依赖候选 SHA。Alpha.3 不含此能力，不能降回旧 tag。当前使用 Canvas2D，未验证 WebGPU。

直接声明公共 Calcit `SceneContent :arc / ArcNode`，圆弧、圆头和方向由 Quamolit 引用 js-ffi 的原生 Canvas API 绘制，已删除应用角步长、点采样和三角离散绕过。半径/间隙/颜色/速度不简化；由 [Quamolit #212](https://github.com/Quamolit/quamolit/issues/212) 跟踪新 tag 的最后验收。不是旧随机画面的逐像素复制：随机源改为固定 seed，但原有生成分布、色彩范围与动画规则保留。

测试集中一条链路：Calcit 完整圈数/起止弧度/角速度/不可变乱序采样，构建产物在 Chromium 中与独立原生 `Canvas.arc` 对比 `t=0/0.5/2.5`、DPR1/2；再验证生成、播放/暂停、全屏、窄屏 resize、卸载和 runtime 错误。原折线容差已收紧为整帧 RGB 零差异，不用全屏空白稀释；截图只存到忽略的 `test-results` 与 Actions artifact。

### English

A restored full-screen Calcit/Quamolit animation, not a compile-only bootstrap. Typed Calcit owns seeded generation and absolute-time Scene sampling; JavaScript only wires browser lifecycle and controls. Native `ArcNode` replaces application-side polyline tessellation. Run `yarn compile && yarn dev`; use `?seed=17&t=0.5` for deterministic frames. `yarn test` requires zero full-frame RGB differences against independent native Canvas arcs at DPR 1/2. Quamolit `0.0.18-alpha.4` is pinned and includes merged #218; no candidate SHA or manual host imports are needed. Alpha.3 does not include native arcs; WebGPU is not verified.

### Workflow

https://github.com/Quamolit/quamolit-workflow

### License

MIT
