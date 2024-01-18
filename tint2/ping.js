const WebSocket = require('ws');

const server = () => {
  const wss = new WebSocket.Server({
    port: 32713,
    maxPayload: 1024
  });
  wss.on('connection', (ws) => {
    ws.on('message', (message) => {
      const response = JSON.stringify({
        message: message.toString()
      });
      console.log(`sending response: ${response}`);
      ws.send(response);
    });
  });
}

server();
