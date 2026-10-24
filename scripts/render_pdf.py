#!/usr/bin/env python3
import sys, glob
from playwright.sync_api import sync_playwright

html_path = sys.argv[1]
pdf_path = sys.argv[2]

chrome_candidates = glob.glob("/opt/pw-browsers/chromium-*/chrome-linux*/chrome")
if not chrome_candidates:
    raise SystemExit("no bundled chromium found under /opt/pw-browsers")
chrome_path = chrome_candidates[0]

with sync_playwright() as p:
    browser = p.chromium.launch(executable_path=chrome_path)
    page = browser.new_page()
    page.goto(f"file://{html_path}")
    page.pdf(
        path=pdf_path,
        prefer_css_page_size=True,
        print_background=True,
    )
    browser.close()
print(f"wrote {pdf_path}")
