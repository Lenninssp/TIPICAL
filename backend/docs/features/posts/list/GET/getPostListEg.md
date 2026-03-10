# 🧪 curl Test Suite for /posts Endpoint

Assumes:

http://localhost:3000/posts

---

## ✅ BASIC

### No params
```bash
curl http://localhost:3000/posts
```

---

### Limit
```bash
curl "http://localhost:3000/posts?limit=10"
```

---

## 📅 CREATED RANGE

### After timestamp
```bash
curl "http://localhost:3000/posts?createdAfter=1738944000000"
```

---

### Before timestamp
```bash
curl "http://localhost:3000/posts?createdBefore=1739044000000"
```

---

### Between two dates
```bash
curl "http://localhost:3000/posts?createdAfter=1738944000000&createdBefore=1739044000000"
```

---

## 👤 USER FILTER

### By user
```bash
curl "http://localhost:3000/posts?userId=user_abc"
```

---

## 🗄 ARCHIVED

### Archived true
```bash
curl "http://localhost:3000/posts?archived=true"
```

---

### Archived false
```bash
curl "http://localhost:3000/posts?archived=false"
```

---

## 🖼 HAS IMAGE

### With image
```bash
curl "http://localhost:3000/posts?hasImage=true"
```

---

### Without image
```bash
curl "http://localhost:3000/posts?hasImage=false"
```

---

## 🧩 FIELD SELECTION

### Only title + createdAt
```bash
curl "http://localhost:3000/posts?fields=title,createdAt"
```

---

### Only description
```bash
curl "http://localhost:3000/posts?fields=description"
```

---

## 🔀 COMBINED FILTERS

### Limit + archived
```bash
curl "http://localhost:3000/posts?limit=10&archived=false"
```

---

### User + limit
```bash
curl "http://localhost:3000/posts?userId=user_abc&limit=5"
```

---

### Date range + archived
```bash
curl "http://localhost:3000/posts?createdAfter=1738944000000&archived=false"
```

---

### Everything together
```bash
curl "http://localhost:3000/posts?limit=20&archived=false&hasImage=true&fields=title,createdAt"
```

---

## 🧪 DEBUG HEADERS

```bash
curl -i "http://localhost:3000/posts?limit=5"
```

---

## 📐 PRETTY JSON (jq)

```bash
curl "http://localhost:3000/posts?limit=5" | jq .
```

---

## ⚡ STRESS / LIMIT TEST

```bash
curl "http://localhost:3000/posts?limit=1"
curl "http://localhost:3000/posts?limit=50"
curl "http://localhost:3000/posts?limit=100"
```