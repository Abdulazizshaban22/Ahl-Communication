// Use in WebRTC clients
export const iceServers = [
  { urls: ['stun:stun.l.google.com:19302'] },
  { urls: ['turns:turn.ahla.com:443?transport=tcp'], username: 'user', credential: 'pass' }
];
