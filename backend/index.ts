import { getAuth } from "firebase-admin/auth";
import createUser from "./src/tests/create-user.html"; 
import { Hono } from "hono";
import { notFoundResponse } from "./src/features/shared/responses/notFoundResponse";
import { HTTPException } from "hono/http-exception";


// Lennin, when in doubt check this repo, is a great example of what to do: https://github.com/DavidHavl/hono-rest-api-starter/blob/main/src/index.ts

var admin = require("firebase-admin");
var serviceAccount = require("./tipical-bd8e7-firebase-adminsdk-fbsvc-b0a76b6eb9.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const app = new Hono()



app.get('/', (c) => {
  return c.text("Hello hono!")
})

app.get('/posts/:id', (c) => {
  const page = c.req.query('page')
  const id = c.req.param('id')
  c.header('X-Message', 'Hi!')
  return c.text(`You want to see ${page} of ${id}`)
})

// 404
app.notFound((c) => {
  return notFoundResponse(c, "Route not found");
})

// Error handling 
app.onError((err, c) => {
  console.error('app.onError ', err);
  if (err instanceof HTTPException) {
    return err.getResponse()
  }

  return c.json(err, { status: 500 });
})


export default app;

// const server = Bun.serve({
//   port: 3000,
//   routes: {
//     "/": () => new Response("Hello"),
//     "/initialize": () => {
//       try {
//         const db = admin.firestore();
//         return new Response("Firestore initialized ok");
//       } catch (err) {
//         return new Response(`Firestore did not initialize: ${err}`);
//       }
//     },
//     "/get-user": () => {
//       try {
//         getAuth()
//           .getUser("0")
//           .then((userRecord) => {
//             return new Response(
//               `Successfully fetched the user data: ${userRecord.toJSON()}`,
//             );
//           })
//           .catch((error) => {
//             return new Response(`Error fetching user data: ${error}`);
//           });
//         return new Response(
//           "If you only see this then it simply dodn't find an user",
//         );
//       } catch (err) {
//         return new Response(`Error getting the user information: ${err}`);
//       }
//     },
//     "/create-user": {
//       POST: async (req) => {
//         const post: 
//         getAuth()
//         .createUser({
//           email: 
//         })
//         const body: any = await req.json();
//         return Response.json({ created: true, message: "you are sexy lennin", ...body });
//       },
//     },
//   },
// // });

// console.log(`Listening on ${server.url}`);

// console.log("Hello via Bun!");
