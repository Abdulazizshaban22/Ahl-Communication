self.addEventListener('install', (e)=> {
  e.waitUntil(caches.open('ahla-chat-v2').then(c=> c.addAll(['/chat/','/chat/manifest.json'])));
});
self.addEventListener('fetch', (e)=> {
  e.respondWith(
    caches.match(e.request).then(res=> res || fetch(e.request))
  );
});
self.addEventListener('push', (e)=> {
  const data = e.data ? e.data.json() : { title:'Ahla', body:'New message' };
  e.waitUntil(self.registration.showNotification(data.title||'Ahla', { body: data.body || 'New message', data }));
});
self.addEventListener('notificationclick', (event)=> {
  event.notification.close();
  event.waitUntil(clients.openWindow('/chat'));
});