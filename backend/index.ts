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
import { firebaseAuthRouter } from "./src/features/auth/endpoints/firebase-login";
import { authGuard } from "./src/features/auth/auth.guard";
import { getCurrentUserId } from "./src/features/auth/current-user";
import { testUiRouter } from "./src/test-ui";
import { devAuthRouter } from "./src/features/auth/dev/firebase-login";
import serviceAccount from "./tipical-bd8e7-firebase-adminsdk-fbsvc-b0a76b6eb9.json" with { type: "json" };

// Lennin, when in doubt check this repo, is a great example of what to do: https://github.com/DavidHavl/hono-rest-api-starter/blob/main/src/index.ts

// todo: replace this with the better implementation

var admin = require("firebase-admin");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://tipical-bd8e7-default-rtdb.firebaseio.com/",
  projectId: process.env.FIREBASE_PROJECT_ID,
});

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
    origin: [
      "http://localhost:3001",
      "http://localhost:3000",
      "https://lenninsabogal.online",
    ],
    allowHeaders: [
      "Content-Type",
      "Accept",
      "Authorization",
      "X-Auth-Return-Redirect",
      "X-Custom-Header",
      "Upgrade-Insecure-Requests",
    ],
    allowMethods: ["POST", "GET", "DELETE", "PATCH", "OPTIONS"],
    exposeHeaders: ["Content-Length"],
    maxAge: 600,
    credentials: false,
  });
  return corsMiddleware(c, next);
});

// app.use((c, next) => {
//   const csrfMiddleware = csrf({
//     origin: process.env.CORS_ORIGIN ? process.env.CORS_ORIGIN.split(",") : "*",
//   });
//   return csrfMiddleware(c, next);
// });
app.use(
  "/*",
  authGuard({
    excludePaths: [
      "/",
      "/auth/firebase/login",
      "/auth/firebase/logout",
      "/auth/dev/login",
    ],
  }),
);

app.route("/auth/firebase", firebaseAuthRouter());
app.route("/auth/dev", devAuthRouter());
app.get("/me", (c) => {
  const userId = getCurrentUserId(c);
  return c.json({ userId });
});

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
