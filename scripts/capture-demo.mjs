import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { chromium } from "playwright";
import { PNG } from "pngjs";
import GIFEncoder from "gif-encoder-2";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const root = path.resolve(__dirname, "..");
const demoPath = path.join(root, "index.html");
const outDir = path.join(root, "assets", "demo");
const outPath = path.join(outDir, "kabukicho-online-demo.gif");

const width = 800;
const height = 450;
const frameCount = 36;
const frameDelayMs = 90;

fs.mkdirSync(outDir, { recursive: true });

const browser = await chromium.launch();
const page = await browser.newPage({
  viewport: { width, height },
  deviceScaleFactor: 1,
});

await page.goto(`file://${demoPath.replaceAll("\\", "/")}`);
await page.waitForLoadState("load");

const encoder = new GIFEncoder(width, height);
encoder.start();
encoder.setRepeat(0);
encoder.setDelay(frameDelayMs);
encoder.setQuality(12);

for (let i = 0; i < frameCount; i += 1) {
  const screenshot = await page.screenshot({ type: "png" });
  const png = PNG.sync.read(screenshot);
  encoder.addFrame(png.data);
  await page.waitForTimeout(frameDelayMs);
}

encoder.finish();
fs.writeFileSync(outPath, encoder.out.getData());
await browser.close();

console.log(`Wrote ${path.relative(root, outPath)}`);
