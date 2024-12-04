const express = require("express");
const http = require("http");
const socketIo = require("socket.io");

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: "*", // Allow all origins
  },
});

io.on("connection", (socket) => {
  console.log("Client connesso");

  socket.on("sendMessage", (data) => {
    console.log("Messaggio ripetuto: " + data);
    io.emit("message", data); // Send message to all connected clients
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, "0.0.0.0", () => {
  console.log("Server in ascolto alla porta: " + PORT);
});
