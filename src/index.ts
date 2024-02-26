import puppeteer from "puppeteer-extra"

// add stealth plugin and use defaults (all evasion techniques)
import StealthPlugin from "puppeteer-extra-plugin-stealth"
import { Browser, Page } from "puppeteer"
import Xvfb from "xvfb"
;(puppeteer as any).use(StealthPlugin())

let xvfb = new Xvfb({
  silent: true,
  xvfb_args: ["-screen", "0", "1280x720x24", "-ac"],
})
await new Promise((res, rej) => {
  xvfb.start((err: Error) => {
    if (err) {
      rej(err)
      return
    }
    res(null)
  })
})

// puppeteer usage as normal
let browser: Browser
// if (proxy) {
//   browser = await (puppeteer as any).launch({
//     headless: "new",
//     executablePath:
//       process.env.LOCAL === "1" ? undefined : "/usr/bin/google-chrome",
//     args: [
//       "--no-sandbox",
//       "--proxy-bypass-list=<-loopback>",
//       `--proxy-server=${cleanUrl}`,
//     ],
//   })
// } else {
// }
browser = await (puppeteer as any).launch({
  headless: false,
  executablePath: process.env.CHROME_PATH || undefined,
  args: ["--no-sandbox", "--proxy-bypass-list=<-loopback>"],
})
console.log("Running tests..")
const page = await browser.newPage()
await page.goto("https://bot.sannysoft.com")

await page.screenshot({ path: "/out/testresult.png", fullPage: true })
await page.screencast
await browser.close()
console.log(`All done, check the screenshot. ✨`)
