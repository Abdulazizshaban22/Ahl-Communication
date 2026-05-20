
# Ahla Chat — E2EE (Signal-style scaffold)
- هوية (keypair) تُنشأ محليًا وتُخزن في IndexedDB.
- Safety Number: SHA-256(id_pub_peer + id_pub_self).
- تشفير الرسائل عبر NaCl box (مفتاح مؤقت + nonce) — الخادم يخزن الـcipher فقط.
- نسخ احتياطية مشفرة (ملف JSON لمفاتيح الهوية يمكن حفظه يدويًا).

> ملاحظة: هذا هيكل أولي قابل للترقية إلى **Signal X3DH/Double Ratchet** أو **MLS** لاحقًا.
