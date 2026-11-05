/* S2S Transformation Portal — service worker
   Makes the portal installable and usable offline. Bump CACHE on each release. */
const CACHE = 's2s-portal-2026-08-04px';
/* served as /sections/portal.html on the standalone origin; icons/manifest are absolute (Supabase bucket). */
const SHELL = ['./portal.html'];
const PUSH_ICON = 'https://iiaqezfiqkonajqqcrcj.supabase.co/storage/v1/object/public/app/icon-192.png';

self.addEventListener('install', (e) => {
  self.skipWaiting();
  e.waitUntil(caches.open(CACHE).then((c) => c.addAll(SHELL).catch(() => {})));
});

self.addEventListener('activate', (e) => {
  e.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(keys.map((k) => (k === CACHE ? null : caches.delete(k)))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', (e) => {
  const req = e.request;
  if (req.method !== 'GET') return;

  let url;
  try { url = new URL(req.url); } catch (_) { return; }

  // Never cache other origins (Supabase API, Google Fonts, the ingredients sheet, YouTube…)
  if (url.origin !== self.location.origin) return;

  // App shell (the HTML page): network-first so updates land fast, fall back to cache offline.
  if (req.mode === 'navigate' || url.pathname.endsWith('.html')) {
    e.respondWith(
      fetch(req)
        .then((res) => { const cp = res.clone(); caches.open(CACHE).then((c) => c.put(req, cp)); return res; })
        .catch(() => caches.match(req).then((m) => m || caches.match('./portal.html')))
    );
    return;
  }

  // Other same-origin assets (icon, manifest): cache-first.
  e.respondWith(
    caches.match(req).then((hit) => hit || fetch(req).then((res) => {
      const cp = res.clone(); caches.open(CACHE).then((c) => c.put(req, cp)); return res;
    }))
  );
});

/* ---- Web Push: show the notification, and focus/open the app on tap ---- */
self.addEventListener('push', (e) => {
  let d = {};
  try { d = e.data ? e.data.json() : {}; } catch (_) { try { d = { body: e.data && e.data.text() }; } catch (__) { d = {}; } }
  const title = d.title || 'S2S Fit';
  const opts = {
    body: d.body || '',
    icon: PUSH_ICON,
    badge: PUSH_ICON,
    tag: d.tag || 's2s',
    renotify: true,
    data: { url: d.url || './' }
  };
  e.waitUntil(self.registration.showNotification(title, opts));
});

self.addEventListener('notificationclick', (e) => {
  e.notification.close();
  e.waitUntil(
    self.clients.matchAll({ type: 'window', includeUncontrolled: true }).then((list) => {
      for (const c of list) { if ('focus' in c) return c.focus(); }   // reuse an open S2S tab
      if (self.clients.openWindow) return self.clients.openWindow(self.registration.scope || './');
    })
  );
});
