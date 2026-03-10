# Comments API Documentation

These endpoints manage comments stored in Firebase Realtime Database.

## Base assumptions

- Base path: `/comments`
- Auth: session cookie required
- Content type for write operations: `application/json`
- Realtime DB shape:

```json
{
  "comments": {
    "<commentId>": {
      "id": "<commentId>",
      "postId": "<postId>",
      "userId": "<userId>",
      "comment": "Nice post",
      "hidden": false,
      "creationDate": 1741460000000,
      "editionDate": 1741460000000
    }
  }
}
```

---

# 1. Create Comment

## Endpoint

```
POST /comments
```

## Description

Creates a new comment for a post.

The backend automatically sets:

- `id`
- `userId`
- `hidden`
- `creationDate`
- `editionDate`

## Request Body

```json
{
  "postId": "-Opost456",
  "comment": "Nice post"
}
```

## Success Response

```json
{
  "data": {
    "id": "-Ocomment123",
    "type": "comments",
    "attributes": {
      "id": "-Ocomment123",
      "postId": "-Opost456",
      "userId": "test-user-123",
      "comment": "Nice post",
      "hidden": false,
      "creationDate": 1741460000000,
      "editionDate": 1741460000000
    },
    "links": {
      "self": "http://localhost:3000/comments/-Ocomment123"
    }
  }
}
```

## cURL Example

```bash
curl -b cookies.txt -X POST "http://localhost:3000/comments" \
  -H "Content-Type: application/json" \
  -d '{"postId":"-Opost456","comment":"Nice post"}'
```

## Possible Errors

- `401 Unauthorized` → No active session
- `404 Not Found` → Post does not exist
- `400 Bad Request` → Invalid body

---

# 2. Get Comments

## Endpoint

```
GET /comments
```

## Description

Returns a list of comments.

Supports filtering via query parameters.

## Query Parameters

| Parameter | Description |
|----------|-------------|
| `postId` | Filter comments by post |
| `userId` | Filter comments by author |
| `hidden` | `true` or `false` |
| `limit` | Maximum number of results |
| `fields` | Comma-separated list of fields |

## Examples

```
GET /comments
GET /comments?postId=-Opost456
GET /comments?postId=-Opost456&limit=10
GET /comments?fields=comment,creationDate,userId
GET /comments?hidden=false
```

## Success Response

```json
{
  "data": [
    {
      "id": "-Ocomment123",
      "type": "comments",
      "attributes": {
        "id": "-Ocomment123",
        "postId": "-Opost456",
        "userId": "test-user-123",
        "comment": "Nice post",
        "hidden": false,
        "creationDate": 1741460000000,
        "editionDate": 1741460000000
      },
      "links": {
        "self": "http://localhost:3000/comments/-Ocomment123"
      }
    }
  ]
}
```

## cURL Example

```bash
curl -b cookies.txt "http://localhost:3000/comments?postId=-Opost456&limit=10"
```

## Possible Errors

- `401 Unauthorized`

---

# 3. Get Single Comment

## Endpoint

```
GET /comments/{id}
```

## Description

Returns a single comment by its ID.

## Path Parameter

| Parameter | Description |
|----------|-------------|
| `id` | Comment ID |

## Optional Query Parameters

| Parameter | Description |
|----------|-------------|
| `fields` | Select specific fields |

## Examples

```
GET /comments/-Ocomment123
GET /comments/-Ocomment123?fields=comment,editionDate
```

## Success Response

```json
{
  "data": {
    "id": "-Ocomment123",
    "type": "comments",
    "attributes": {
      "id": "-Ocomment123",
      "postId": "-Opost456",
      "userId": "test-user-123",
      "comment": "Nice post",
      "hidden": false,
      "creationDate": 1741460000000,
      "editionDate": 1741460000000
    },
    "links": {
      "self": "http://localhost:3000/comments/-Ocomment123"
    }
  }
}
```

## cURL Example

```bash
curl -b cookies.txt "http://localhost:3000/comments/-Ocomment123"
```

## Possible Errors

- `401 Unauthorized`
- `404 Not Found`

---

# 4. Update Comment

## Endpoint

```
PATCH /comments/{id}
```

## Description

Updates an existing comment.

Only the **owner of the comment** can update it.

The backend automatically updates:

```
editionDate
```

## Path Parameter

| Parameter | Description |
|----------|-------------|
| `id` | Comment ID |

## Request Body

```json
{
  "comment": "Edited comment",
  "hidden": true
}
```

## Notes

The backend **ignores or blocks updates** to:

- `id`
- `postId`
- `userId`
- `creationDate`

## Success Response

```json
{
  "data": {
    "id": "-Ocomment123",
    "type": "comments",
    "attributes": {
      "id": "-Ocomment123",
      "postId": "-Opost456",
      "userId": "test-user-123",
      "comment": "Edited comment",
      "hidden": true,
      "creationDate": 1741460000000,
      "editionDate": 1741460100000
    },
    "links": {
      "self": "http://localhost:3000/comments/-Ocomment123"
    }
  }
}
```

## cURL Example

```bash
curl -b cookies.txt -X PATCH "http://localhost:3000/comments/-Ocomment123" \
  -H "Content-Type: application/json" \
  -d '{"comment":"Edited comment"}'
```

## Possible Errors

- `401 Unauthorized`
- `404 Not Found`
- `400 Bad Request`

---

# 5. Delete Comment

## Endpoint

```
DELETE /comments/{id}
```

## Description

Deletes a comment.

Only the **owner** of the comment can delete it.

## Path Parameter

| Parameter | Description |
|----------|-------------|
| `id` | Comment ID |

## Success Response

```json
{
  "data": {
    "id": "-Ocomment123",
    "type": "comments",
    "attributes": {
      "id": "-Ocomment123"
    },
    "links": {
      "self": "http://localhost:3000/comments/-Ocomment123"
    }
  }
}
```

## cURL Example

```bash
curl -b cookies.txt -X DELETE "http://localhost:3000/comments/-Ocomment123"
```

## Possible Errors

- `401 Unauthorized`
- `404 Not Found`

---

# Recommended Testing Flow

1. Login using dev auth
2. Create a post
3. Create a comment for that post
4. Retrieve comments with `GET /comments?postId=...`
5. Retrieve the comment with `GET /comments/{id}`
6. Update the comment
7. Delete the comment