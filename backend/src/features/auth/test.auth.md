Now you can test the whole pipeline with curl:

```
curl -i -X POST http://localhost:3000/auth/dev/login \
  -H "Content-Type: application/json" \
  -d '{"userId":"test-user-123"}'
```

Copy the Set-Cookie header into subsequent requests or use -c/-b cookie jar:


```bash
curl -c cookies.txt -i -X POST http://localhost:3000/auth/dev/login \
-H "Content-Type: application/json" \
-d '{"userId":"test-user-123"}'

curl -b cookies.txt http://localhost:3000/me
```