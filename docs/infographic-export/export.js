const puppeteer = require('puppeteer');
const path = require('path');

// Update this path to the location of your HTML file
const HTML_FILE_PATH = path.resolve('./external-id-graphic.html');

(async () => {
  console.log('Launching browser...');
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  
  console.log('Loading HTML file:', HTML_FILE_PATH);
  await page.goto('file://' + HTML_FILE_PATH, { waitUntil: 'networkidle0' });
  
  // Use page.evaluate to return a promise that resolves after waiting
  // This is compatible with older versions of Puppeteer
  await page.evaluate(() => {
    return new Promise(resolve => {
      setTimeout(resolve, 1000);
    });
  });
  
  // Set viewport with 2x scale for high resolution
  await page.setViewport({
    width: 1000,
    height: 1200,
    deviceScaleFactor: 2
  });
  
  // Take screenshot
  console.log('Taking screenshot...');
  await page.screenshot({
    path: 'entra-infographic.png',
    fullPage: true,
    omitBackground: false
  });
  
  console.log('Screenshot saved as entra-infographic.png');
  await browser.close();
})().catch(err => {
  console.error('An error occurred:', err);
  process.exit(1);
});