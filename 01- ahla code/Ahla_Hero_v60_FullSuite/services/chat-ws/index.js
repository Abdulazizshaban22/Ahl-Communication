const { WebSocketServer } = require("ws");
const PORT = process.env.PORT || 8090;
const wss = new WebSocketServer({ port: PORT });

wss.on("connection", (ws) => {
  ws.on("message", (m) => {
    for (const client of wss.clients) {
      if (client.readyState === 1) client.send(m.toString());
    }
  });
});

console.log("Chat WS listening on port", PORT);
