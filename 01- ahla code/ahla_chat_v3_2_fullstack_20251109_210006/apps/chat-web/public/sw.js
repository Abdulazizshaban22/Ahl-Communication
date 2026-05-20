
self.addEventListener('install', e=>e.waitUntil(caches.open('ahla-v3.2').then(c=>c.addAll(['/chat/','/chat/manifest.json']))));
self.addEventListener('fetch', e=>e.respondWith(caches.match(e.request).then(r=>r||fetch(e.request))));
self.addEventListener('push', e=>{
  const data = e.data ? e.data.json() : {};
  const title = data.title || 'Ahla';
  const body = data.body || 'New message';
  const room = data.room || 'personal';
  const tag = data.tag || room;
  e.waitUntil(self.registration.showNotification(title,{body, data:{room}, tag}));
});
self.addEventListener('notificationclick', event=>{
  event.notification.close();
  const room = event.notification.data && event.notification.data.room || 'personal';
  const url = '/chat?room=' + encodeURIComponent(room);
  event.waitUntil((async ()=>{
    const list = await clients.matchAll({type:'window',includeUncontrolled:true});
    for(const c of list){
      if(c.url.includes('/chat')){ c.postMessage({type:'open-room', room}); return c.focus(); }
    }
    return clients.openWindow(url);
  })());
});
