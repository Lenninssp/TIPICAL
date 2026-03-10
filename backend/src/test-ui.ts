import { Hono } from "hono";

export function testUiRouter() {
  const app = new Hono();

  app.get("/test", (c) => {
    return c.html(`<!doctype html>
<html>
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Auth Test</title>
  <style>
    body { font-family: system-ui, -apple-system, sans-serif; max-width: 760px; margin: 40px auto; padding: 0 16px; }
    textarea { width: 100%; min-height: 140px; }
    button { padding: 10px 14px; margin-right: 8px; }
    pre { background: #f6f6f6; padding: 12px; overflow: auto; }
    .row { display: flex; gap: 10px; flex-wrap: wrap; margin: 10px 0; }
  </style>
</head>
<body>
  <h1>Firebase Bearer Auth Test</h1>

  <p>Paste a <b>Firebase ID token</b> below (from your client), then click Login.</p>

  <label for="token">ID Token</label>
  <textarea id="token" placeholder="Paste Firebase ID token here..."></textarea>

  <div class="row">
    <button id="login">Login (POST /auth/firebase/login)</button>
    <button id="me">Call /me</button>
    <button id="logout">Logout</button>
  </div>

  <h3>Response</h3>
  <pre id="out">(nothing yet)</pre>

<script>
  const out = document.getElementById("out");
  const tokenEl = document.getElementById("token");
  let bearerToken = "";

  function show(obj) {
    out.textContent = typeof obj === "string" ? obj : JSON.stringify(obj, null, 2);
  }

  async function call(path, options = {}) {
    const headers = {
      "Content-Type": "application/json",
      ...(options.headers || {})
    };
    if (bearerToken) headers["Authorization"] = "Bearer " + bearerToken;

    const res = await fetch(path, {
      ...options,
      headers
    });
    const text = await res.text();
    let body = text;
    try { body = JSON.parse(text); } catch {}
    return { status: res.status, body };
  }

  document.getElementById("login").onclick = async () => {
    const idToken = tokenEl.value.trim();
    if (!idToken) return show("Paste an ID token first.");
    const result = await call("/auth/firebase/login", {
      method: "POST",
      body: JSON.stringify({ idToken })
    });
    if (result?.body?.token) bearerToken = result.body.token;
    show(result);
  };

  document.getElementById("me").onclick = async () => {
    const result = await call("/me", { method: "GET", headers: {} });
    show(result);
  };

  document.getElementById("logout").onclick = async () => {
    const result = await call("/auth/firebase/logout", { method: "POST" });
    bearerToken = "";
    show(result);
  };
</script>

</body>
</html>`);
  });

  return app;
}
