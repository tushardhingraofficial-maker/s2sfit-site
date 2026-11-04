# s2sfit-site

HTML sections for the S2S Fit HighLevel website.

## How it works
1. Each section lives in `highlevel/sections/<name>.html`.
2. Netlify publishes the `highlevel/` folder automatically on every push to `main`.
3. HighLevel has a small loader (from `loaders/<name>.html`) pasted once per section,
   which fetches the live file - so updates never require editing HighLevel.

## Folders
- `highlevel/` - published to Netlify (sections + `_headers` for CORS/no-cache)
- `loaders/` - snippets to paste into HighLevel Custom Code elements (not published)
- `netlify.toml` - Netlify build settings
