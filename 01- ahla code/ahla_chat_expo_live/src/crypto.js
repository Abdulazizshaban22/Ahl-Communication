import nacl from 'tweetnacl';

function hexToBytes(hex) {
  if (!hex) return new Uint8Array();
  const arr = new Uint8Array(hex.length / 2);
  for (let i = 0; i < hex.length; i += 2) {
    arr[i/2] = parseInt(hex.substr(i,2), 16);
  }
  return arr;
}
function bytesToBase64(bytes) {
  return Buffer.from(bytes).toString('base64');
}
function base64ToBytes(b64) {
  return Uint8Array.from(Buffer.from(b64, 'base64'));
}

export function encryptSecretBox(message, keyHex) {
  const key = hexToBytes(keyHex);
  const nonce = nacl.randomBytes(24);
  const msgBytes = new TextEncoder().encode(message);
  const box = nacl.secretbox(msgBytes, nonce, key);
  return {
    b64: bytesToBase64(new Uint8Array([...nonce, ...box])),
    nonce: bytesToBase64(nonce)
  };
}

export function decryptSecretBox(b64, keyHex) {
  const key = hexToBytes(keyHex);
  const all = base64ToBytes(b64);
  if (all.length < 25) return null;
  const nonce = all.slice(0, 24);
  const box = all.slice(24);
  const out = nacl.secretbox.open(box, nonce, key);
  if (!out) return null;
  return new TextDecoder().decode(out);
}
