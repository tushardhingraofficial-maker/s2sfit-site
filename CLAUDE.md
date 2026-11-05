# s2sfit-site - instructions for Claude

This repo is the LIVE source for pages on the S2S Fit HighLevel website (s2sfit.com).
Anything pushed to `main` goes live within ~30 seconds:
GitHub `main` -> Netlify (s2sfit-sections.netlify.app, publishes the `highlevel/` folder)
-> HighLevel pages load it through a loader snippet that is pasted once and never edited.

## Files
| Live file | What it is | HighLevel page |
|---|---|---|
| `highlevel/sections/portal.html` | S2S Transformation Portal (full app, single file) | s2sfit.com main portal page + test page transformation-portal-772077 |
| `highlevel/sections/test.html` | Setup test section | test page only |

`loaders/*.html` are the snippets pasted into HighLevel. Do not change a loader unless the user
explicitly asks - changing it means the user must re-paste it in HighLevel.

## Publishing a change (do this after every change the user approves)
1. `git pull origin main` first (another session may have pushed).
2. Edit / replace the file in `highlevel/sections/`.
3. Bump the portal's version string (e.g. `v2026-08-04pe` -> next letter) so the user can confirm it is live.
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
