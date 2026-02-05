var admin = require('firebase-admin')
var serviceAccount = require('./tipical-bd8e7-firebase-adminsdk-fbsvc-b0a76b6eb9.json')

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
})

const server = Bun.serve({
  port: 3000,
  routes: {
    "/": () => new Response('Hello'),
    "/initialize": () => {
      try {
        const db = admin.firestore();
        return new Response("Firestore initialized ok")
      } catch (err) {
        return new Response(`Firestore did not initialize ok: ${err}`);
      }
    }
  }
})

console.log(`Listening on ${server.url}`)

console.log("Hello via Bun!");