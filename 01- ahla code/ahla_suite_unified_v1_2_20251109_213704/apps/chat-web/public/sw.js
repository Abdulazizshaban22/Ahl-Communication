self.addEventListener('install',e=>e.waitUntil(caches.open('ahla-v1-2').then(c=>c.addAll(['./','./manifest.json']))));
self.addEventListener('fetch',e=>e.respondWith(caches.match(e.request).then(r=>r||fetch(e.request))));
self.addEventListener('push',e=>{const d=e.data?e.data.json():{};e.waitUntil(self.registration.showNotification(d.title||'Ahla',{body:d.body||'New',data:{url:d.url||'./'}}))});
self.addEventListener('notificationclick',ev=>{ev.notification.close();const url=(ev.notification.data&&ev.notification.data.url)||'./';ev.waitUntil(clients.matchAll({type:'window',includeUncontrolled:true}).then(ls=>{for(const c of ls){if(c.url.includes(url))return c.focus()}return clients.openWindow(url)}))});
