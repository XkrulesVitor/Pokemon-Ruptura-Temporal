const fs = require("fs");
const path = require("path");
const { chromium } = require("./node_modules/playwright");

const srcDir = "D:/Excalibur/Downloads/gms (GAMEMAKER)/cities";
const outDir = "D:/GAME-MAKER/PokemonRogueLike/datafiles/sprites/cities";

const maps = [
  ["PALLET.webp", "pallet.png"],
  ["Viridian City.webp", "viridian.png"],
  ["Pewter City.webp", "pewter.png"],
  ["Cerulean City.webp", "cerulean.png"],
  ["Vermilion City.webp", "vermilion.png"],
  ["Cinnabar Island.webp", "cinnabar.png"],
];

function dataUrl(filePath) {
  return `data:image/webp;base64,${fs.readFileSync(filePath).toString("base64")}`;
}

(async () => {
  fs.mkdirSync(outDir, { recursive: true });

  const browser = await chromium.launch({
    headless: true,
    executablePath: "C:/Program Files/Google/Chrome/Application/chrome.exe",
  });
  const page = await browser.newPage({ viewport: { width: 1800, height: 1400 }, deviceScaleFactor: 1 });

  for (const [src, out] of maps) {
    const srcPath = path.join(srcDir, src);

    if (!fs.existsSync(srcPath)) {
      console.log(`missing ${src}`);
      continue;
    }

    await page.setContent(
      `<html><body style="margin:0;background:transparent"><img id="img" src="${dataUrl(srcPath)}"></body></html>`
    );
    await page.waitForLoadState("load");
    await page.waitForFunction(() => {
      const image = document.querySelector("#img");
      return image && image.complete && image.naturalWidth > 0 && image.naturalHeight > 0;
    });

    const image = page.locator("#img");
    const box = await image.boundingBox();
    await image.screenshot({ path: path.join(outDir, out), omitBackground: true });
    console.log(`${out} ${Math.round(box.width)}x${Math.round(box.height)}`);
  }

  await browser.close();
})().catch((error) => {
  console.error(error);
  process.exit(1);
});
