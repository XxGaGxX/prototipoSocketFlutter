const express = require("express")
const http = require("http")
const socketIo = require("socket.io")

const app = express(); // 
const server = http.createServer(app) // crea un server 
const io = socketIo(server, {
  cors :{
    origin: '*'
  }
});

io.on("connection", socket =>{  //quando avviene la connessione con il client :
  console.log('Client connesso')

  
  socket.on('sendMessage', (data) => { //quando il client manda un messaggio al server
    console.log('Messaggio ripetuto: ' + data)
    io.emit('message', data) //mando un messaggio al client
  })
})

const PORT = process.env.PORT || 3000; // utilizzo la porta 3000 di default, se è occupata usa quella che usava prima
server.listen(PORT, "10.1.0.9", ()=>{ 
  console.log("Server in ascolto alla porta: " + PORT)
})