// The 6:15 — HTML -> PDF renderer via headless Chromium (Playwright).
// Usage: node render_pdf.js input.html output.pdf
const path = require('path');
const { chromium } = require('playwright');

(async () => {
  const [,, inputHtml, outputPdf] = process.argv;
  if (!inputHtml || !outputPdf) {
    console.error('Usage: node render_pdf.js input.html output.pdf');
    process.exit(1);
  }
  const browser = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium-1194/chrome-linux/chrome' });
  const page = await browser.newPage();
  await page.goto('file://' + path.resolve(inputHtml));
  await page.pdf({
    path: outputPdf,
    width: '5.5in',
    height: '8.5in',
    margin: { top: '0.5in', right: '0.5in', bottom: '0.55in', left: '0.5in' },
    printBackground: true,
  });
  await browser.close();
  console.log('rendered:', outputPdf);
})();
