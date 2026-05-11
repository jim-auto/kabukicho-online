import { chromium } from "playwright";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const root = path.resolve(path.dirname(__filename), "..");
const url = `file://${path.join(root, "index.html").replaceAll("\\", "/")}`;

const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 1280, height: 720 } });
await page.goto(url);
await page.waitForLoadState("load");
await page.locator("#game").waitFor({ state: "visible", timeout: 5000 });
await page.keyboard.press("KeyD");
await page.keyboard.press("Shift");
await page.keyboard.press("KeyF");
await page.keyboard.press("KeyE");
await page.waitForTimeout(500);
const title = await page.title();
const money = await page.locator("#money").textContent();
if (!title.includes("Kabukicho Online") || money === null) {
  throw new Error("Pages smoke test failed");
}
await browser.close();
console.log("GitHub Pages playable demo smoke test passed");
