self.addEventListener('install', (e)=> {
  e.waitUntil(caches.open('ahla-chat-v3.1').then(c=> c.addAll(['/chat/','/chat/manifest.json'])));
});
self.addEventListener('fetch', (e)=> {
  e.respondWith(caches.match(e.request).then(r=> r || fetch(e.request)));
});
self.addEventListener('push', (e)=> {
  const data = e.data ? e.data.json() : {};
  const title = data.title || 'Ahla';
  const body = data.body || 'New message';
  const room = data.room || 'personal';
  const tag  = data.tag || room;
  const badge = data.badge;
  const icon = data.icon;
  e.waitUntil(self.registration.showNotification(title, { body, data:{ room }, tag, badge, icon }));
});
self.addEventListener('notificationclick', (event)=> {
  event.notification.close();
  const room = (event.notification.data && event.notification.data.room) || 'personal';
  const url = '/chat?room=' + encodeURIComponent(room);
  event.waitUntil((async ()=>{
    const allClients = await clients.matchAll({ type:'window', includeUncontrolled:true });
    const existing = allClients.find(c=> c.url.includes('/chat'));
    if(existing){ 
      existing.postMessage({ type:'open-room', room });
      return existing.focus();
    }
    return clients.openWindow(url);
  })());
});