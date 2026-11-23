# s2sfit-site - instructions for Claude

This repo is the LIVE source for pages on the S2S Fit HighLevel website (s2sfit.com).
Anything pushed to `main` goes live within ~30 seconds:
GitHub `main` -> Netlify (s2sfit-sections.netlify.app, publishes the `highlevel/` folder)
-> HighLevel pages load it through a loader snippet that is pasted once and never edited.

## Files
| Live file | What it is | HighLevel page |
|---|---|---|
| `highlevel/sections/portal.html` | S2S Transformation Portal (full app, single file) | s2sfit.com main portal page + test page transformation-portal-772077 |
| `highlevel/sections/strategy.html` | Fitness Strategy Call VSL / $500 voucher page (single file; CSS scoped under `#s2sv`). Working copy: `C:Users	aar7DownloadsS2S_Strategy_Call_Page.html`. Version = `data-version` on `<div id="s2sv">` | Strategy Call VSL page (loader `loaders/strategy.html`) |
| `highlevel/sections/price-guide.html` | S2S Price Guide / guided close tool (full single-file app; global CSS, dedicated full-page). Working copy: `C:\Users\taar7\Downloads\s2s-price-guide-site\index.html`. Version = `data-version` on `<html>`. Prices/discount/rewards edit live via in-app admin (Supabase `pricing_config`), no deploy. | Price Guide page (loader `loaders/price-guide.html`) |
| `highlevel/sections/coach-7k9x2m.html` | S2S Coach mobile panel (standalone installable PWA — NOT embedded via a loader; opened directly at its own URL). Working copy: `C:\Users\taar7\Downloads\S2S_Coach_Mobile.html`. Version = `data-version` on `<html>` (shown on the login screen). Unlisted/non-obvious filename on purpose — it unlocks all client data behind the admin password; keep the URL private. | none — direct URL `https://s2sfit-sections.netlify.app/sections/coach-7k9x2m.html`, Add-to-Home-Screen on a phone |
| `highlevel/sections/landing-page.html` | S2S Fit main landing page (full standalone HTML, not a loader-injected section). Working copy: `C:\Users\taar7\Downloads\s2sfit-landing-v1-updated_3.html`. Version = `data-version` on `<html>`. Deploy script: `deploy-landing-page.ps1`. Auto-watcher: `watch-landing-page.ps1` / `START-AUTO-DEPLOY.bat`. | Standalone page at `https://s2sfit-sections.netlify.app/sections/landing-page.html`; loader `loaders/landing-page.html` for GHL. |
| `highlevel/sections/test.html` | Setup test section | test page only |
| `highlevel/sections/fp-b31a1b741624449d.html` | Tushar's PERSONAL Financial Planner (standalone single-file app, NOT loader-embedded). PUBLISH ONLY with `C:Users	aar7DownloadsS2S_Financial_Planner_cloudPublish-Planner.ps1` — it strips the password hash from the working copy `DownloadsS2S_Financial_Planner.html` (never copy the working file here directly: it contains the hash). Data is end-to-end encrypted in the browser; security headers in `highlevel/_headers`. Unlisted URL — never link it anywhere. | s2sfit.com/financial-planning via loader `loaders/financial-planning.html` (div `#s2s-financial-planner`; copies the planner's body classes so it starts locked) — also works at the direct netlify URL |

`loaders/*.html` are the snippets pasted into HighLevel. Do not change a loader unless the user
explicitly asks - changing it means the user must re-paste it in HighLevel.

## Publishing a change (do this after every change the user approves)
1. `git pull origin main` first (another session may have pushed).
2. Edit / replace the file in `highlevel/sections/`.
3. Bump the version string (portal: `APP_VERSION`; strategy page: `data-version` on `#s2sv`; price guide: `data-version` on `<html>`) (e.g. `v2026-08-04pe` -> next letter) so the user can confirm it is live.
   - **PORTAL ONLY: also write the SAME new version into `highlevel/sections/version.txt`** (one line, e.g. `2026-08-04td`) and bump `sw.js` `CACHE`. The portal reads version.txt on boot and auto-clears caches + hard-reloads any client stuck on an older build (self-heal). If version.txt lags APP_VERSION, clients won't be nudged; if it's AHEAD, every client force-reloads once — so keep it exactly equal to APP_VERSION.
4. Commit with a clear message and `git push origin main`.
5. Verify: `https://s2sfit-sections.netlify.app/sections/<file>.html` returns 200 and contains the new version string (allow ~30-60s).
6. Tell the user: "Live - refresh s2sfit.com (Ctrl+Shift+R) and look for version X."

Never tell the user to paste code into HighLevel for these pages - that is no longer needed.
To roll back: `git revert <commit>` and push.

## Rules
- The repo is PUBLIC. Never commit secrets (service-role keys, API secret keys, passwords, customer data).
  The Supabase *publishable* key already in the portal is fine.
- The portal runs inside a HighLevel page via the loader, not as its own document:
  `<title>`/`<meta>` are ignored (HighLevel page settings own them), `window` load /
  DOMContentLoaded handlers are fired by the loader, and scripts run in order.
- Netlify "Visitor access" must stay public, or every section goes blank for visitors.
