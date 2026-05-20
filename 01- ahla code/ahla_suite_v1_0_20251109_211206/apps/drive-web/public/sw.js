self.addEventListener('install', e=>e.waitUntil(caches.open('ahla-suite-v1').then(c=>c.addAll(['./','./manifest.json']))));
self.addEventListener('fetch', e=>e.respondWith(caches.match(e.request).then(r=>r||fetch(e.request))));
self.addEventListener('push', e=>{
  const d = e.data ? e.data.json() : {};
  const title = d.title || 'Ahla';
  const body  = d.body  || 'New message';
  const url   = d.url   || './';
  e.waitUntil(self.registration.showNotification(title,{ body, data:{url} }));
});
self.addEventListener('notificationclick', ev=>{
  ev.notification.close();
  const url = (ev.notification.data && ev.notification.data.url) || './';
  ev.waitUntil(clients.matchAll({type:'window',includeUncontrolled:true}).then(list=>{
    for(const c of list){ if(c.url.includes(url)) return c.focus(); }
    return clients.openWindow(url);
  }));
});