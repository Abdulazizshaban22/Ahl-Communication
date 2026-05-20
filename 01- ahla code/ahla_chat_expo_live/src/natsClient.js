import { connect, StringCodec } from "nats.ws";

export async function connectNats(servers, token) {
  const opts = {};
  if (servers && servers.length) opts.servers = servers;
  if (token) opts.token = token;
  return await connect(opts);
}

export async function joinRoom(nc, room, handler) {
  const sc = StringCodec();
  const sub = nc.subscribe(`chat.room.${room}`);
  (async () => {
    for await (const m of sub) {
      try {
        const txt = sc.decode(m.data);
        handler({ text: txt, mine: false });
      } catch (e) {
        handler({ text: "[decode error]", mine: false });
      }
    }
  })();
  return {
    publish: (text) => nc.publish(`chat.room.${room}`, sc.encode(text)),
    close: () => sub.drain()
  }
}
