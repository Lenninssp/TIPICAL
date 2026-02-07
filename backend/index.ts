import { Hono, type Env } from "hono";
import { notFoundResponse } from "./src/features/shared/responses/notFoundResponse";
import { HTTPException } from "hono/http-exception";
import { bootstrapFeatures } from "./src/features/bootstrap";
import { OpenAPIHono } from "@hono/zod-openapi";
import { zodErrorMiddleware } from "./src/middleware/zodErrorMiddleware";


// Lennin, when in doubt check this repo, is a great example of what to do: https://github.com/DavidHavl/hono-rest-api-starter/blob/main/src/index.ts

var admin = require("firebase-admin");
var serviceAccount = require("./tipical-bd8e7-firebase-adminsdk-fbsvc-b0a76b6eb9.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});


const app = new OpenAPIHono<Env>({
  defaultHook: zodErrorMiddleware,
})


bootstrapFeatures(app);

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
