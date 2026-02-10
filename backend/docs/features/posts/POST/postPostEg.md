# 🧪 curl Test Suite for POST /posts Endpoint

Assumes:

http://localhost:3000/posts

> Tip: If you have `jq`, add `| jq .` to pretty-print responses.

---

## ✅ BASIC CREATE

### Minimal create (title + description)
```bash
curl -X POST "http://localhost:3000/posts" \
  -H "Content-Type: application/json" \
  -d '{"title":"Lennin test","description":"This is a description"}'
```

---

## ✅ CREATE WITH OPTIONAL FIELDS (if your CreatePostSchema allows them)

### Create with userId + archived
```bash
curl -X POST "http://localhost:3000/posts" \
  -H "Content-Type: application/json" \
  -d '{"title":"Post with owner","description":"Has userId + archived","userId":"user_abc","archived":false}'
```

---

## 🧩 FIELD SELECTION IN RESPONSE

Your handler supports `?fields=...` (single field or comma list) to limit returned attributes.

### Return only `id`
```bash
curl -X POST "http://localhost:3000/posts?fields=id" \
  -H "Content-Type: application/json" \
  -d '{"title":"Fields test","description":"Return only id"}'
```

### Return only `title`
```bash
curl -X POST "http://localhost:3000/posts?fields=title" \
  -H "Content-Type: application/json" \
  -d '{"title":"Fields title","description":"Return only title"}'
```

### Return `id,title,createdAt`
```bash
curl -X POST "http://localhost:3000/posts?fields=id,title,createdAt" \
  -H "Content-Type: application/json" \
  -d '{"title":"Fields multi","description":"Return a subset"}'
```

---

## 📐 PRETTY JSON OUTPUT (jq)

```bash
curl -X POST "http://localhost:3000/posts" \
  -H "Content-Type: application/json" \
  -d '{"title":"Pretty print","description":"Using jq"}' | jq .
```

---

## 🧪 DEBUG HEADERS (status, content-type, etc.)

```bash
curl -i -X POST "http://localhost:3000/posts" \
  -H "Content-Type: application/json" \
  -d '{"title":"Header debug","description":"Check headers"}'
```

---

## ❌ INVALID INPUT TESTS (should be 400 if CreatePostSchema rejects)

### Missing required fields (likely fails)
```bash
curl -i -X POST "http://localhost:3000/posts" \
  -H "Content-Type: application/json" \
  -d '{}'
```

### Wrong types (title as number)
```bash
curl -i -X POST "http://localhost:3000/posts" \
  -H "Content-Type: application/json" \
  -d '{"title":123,"description":"bad type"}'
```

### Null title (if not allowed)
```bash
curl -i -X POST "http://localhost:3000/posts" \
  -H "Content-Type: application/json" \
  -d '{"title":null,"description":"bad type"}'
```

---

## ❌ WRONG CONTENT TYPE (should fail or behave differently)

```bash
curl -i -X POST "http://localhost:3000/posts" \
  -H "Content-Type: text/plain" \
  -d '{"title":"Wrong content type","description":"Should fail"}'
```

---

## ✅ QUICK “CREATE THEN FETCH” FLOW (manual)

1) Create:
```bash
curl -X POST "http://localhost:3000/posts" \
  -H "Content-Type: application/json" \
  -d '{"title":"Create then fetch","description":"Step 1"}' | jq -r '.data.id'
```

2) Then GET that id (replace <ID>):
```bash
curl "http://localhost:3000/posts/<ID>" | jq .
```

---

## ✅ POWER TEST: Create multiple posts quickly

```bash
for i in $(seq 1 5); do
  curl -s -X POST "http://localhost:3000/posts" \
    -H "Content-Type: application/json" \
    -d "{\"title\":\"Batch $i\",\"description\":\"Created via loop\"}" \
  | jq -r '.data.id'
done
```