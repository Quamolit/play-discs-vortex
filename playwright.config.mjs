import { defineConfig } from "@playwright/test";

export default defineConfig({
  testDir: "./test",
  use: {
    baseURL: "http://127.0.0.1:5194",
    viewport: { width: 1100, height: 1000 },
  },
  webServer: {
    command: "yarn vite preview --host 127.0.0.1 --port 5194 --strictPort",
    url: "http://127.0.0.1:5194",
    reuseExistingServer: false,
  },
});
