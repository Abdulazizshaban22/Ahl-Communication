/* Generate VAPID keys for Web Push (Node)
   Usage: node generate_vapid.js
*/
import webpush from 'web-push'
const keys = webpush.generateVAPIDKeys()
console.log(JSON.stringify(keys,null,2))