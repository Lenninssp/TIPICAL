import { type Env } from "hono";
import { notFoundResponse } from "./src/features/shared/responses/notFoundResponse";
import { HTTPException } from "hono/http-exception";
import { bootstrapFeatures } from "./src/features/bootstrap";
import { OpenAPIHono } from "@hono/zod-openapi";
import { zodErrorMiddleware } from "./src/middleware/zodErrorMiddleware";
import { logger } from "hono/logger";
import { secureHeaders } from "hono/secure-headers";
import { isPathMatch } from "./src/utils/path";
import { cors } from "hono/cors";
import { csrf } from "hono/csrf";
import serviceAccount from "./tipical-bd8e7-firebase-adminsdk-fbsvc-b0a76b6eb9.json" with { type: "json" };

// Lennin, when in doubt check this repo, is a great example of what to do: https://github.com/DavidHavl/hono-rest-api-starter/blob/main/src/index.ts

var admin = require("firebase-admin");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://tipical-bd8e7-default-rtdb.firebaseio.com/",
  projectId: process.env.FIREBASE_PROJECT_ID,
});

var db = admin.database();

const app = new OpenAPIHono<Env>({
  defaultHook: zodErrorMiddleware,
});

// MIDDLEWARE //
app.use(logger());

// Helmet like middleware
app.use(secureHeaders());

// Content Type Guard - allow JSON:API compliant content type only //
app.use(async (c, next) => {
  const excludePaths = ["/"];
  if (
    !isPathMatch(c.req.path, excludePaths) &&
    !["GET", "OPTIONS", "DELETE"].includes(c.req.method) &&
    c.req.header("Content-Type") !== "application/json"
  ) {
    return c.json({ error: "Unsupported media type" }, { status: 415 });
  }
  return next();
});

app.use((c, next) => {
  const corsMiddleware = cors({
    origin: process.env.CORS_ORIGIN ? process.env.CORS_ORIGIN.split(",") : "*",
    allowHeaders: [
      "Content-Type",
      "Accept",
      "X-Auth-Return-Redirect",
      "X-Custom-Header",
      "Upgrade-Insecure-Requests",
    ],
    allowMethods: ["POST", "GET", "DELETE", "PATCH", "OPTIONS"],
    exposeHeaders: ["Content-Length"],
    maxAge: 600,
    credentials: true,
  });
  return corsMiddleware(c, next);
});

app.use((c, next) => {
  const csrfMiddleware = csrf({
    origin: process.env.CORS_ORIGIN ? process.env.CORS_ORIGIN.split(",") : "*",
  });
  return csrfMiddleware(c, next);
});

app.use("/api/*", async (c, next) => {
  const authHeader = c.req.header("Authorization");

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return c.json({ message: "Unauthorized" }, 401);
  }

  const idToken = authHeader.split("Bearer ")[1];

  // try {
  //   const decodedToken = await admin.auth().verifyIdToken(idToken)
  //   c.set('user', decodedToken)
  //   await next();
  // }
  // ONLY FOR TESTING - DELETE THIS LATER
  try {

    // Fake a decoded token
    const decodedToken = { email: "lennin@test.com", uid: "test-123" };

    c.set("user", decodedToken);
    await next();
  } catch (error: any) {
    return c.json({ message: "Invalid Token", error: error.message }, 401);
  }
});

// curl -v http://localhost:3000/api/page -H "Content-Type: application/json"
// curl -v -H "Authorization: Bearer LenninCool" -X POST http://localhost:3000/api/page -H "Content-Type: application/json"

bootstrapFeatures(app);

// 404
app.notFound((c) => {
  return notFoundResponse(c, "Route not found");
});

// Error handling
app.onError((err, c) => {
  console.error("app.onError ", err);
  if (err instanceof HTTPException) {
    return err.getResponse();
  }

  return c.json(err, { status: 500 });
});

export default app;
