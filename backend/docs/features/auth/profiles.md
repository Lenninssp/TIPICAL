# Profile API Documentation

These endpoints manage user profiles stored in Firebase Realtime Database.

## Base assumptions

- Base path: `/profiles`
- Auth: session cookie required
- Content type for write operations: `application/json`
- Profiles are stored in Firebase Realtime Database using the authenticated user's UID as the key

Example Realtime DB shape:

```json
{
  "profiles": {
    "test-user-123": {
      "id": "test-user-123",
      "email": "test-user-123@dev.local",
      "username": "test-user-123",
      "firstName": "Dev",
      "lastName": "User",
      "description": "Seeded by dev login",
      "birthDate": null,
      "profilePicture": null,
      "creationDate": 1741460000000,
      "lastLoginDate": 1741460000000
    }
  }
}
```

---

# 1. Get Current Profile

## Endpoint

```http
GET /profiles/me
```

## Description

Returns the authenticated user's profile.

This route resolves `me` to the current session user's ID and reads the profile from:

```txt
profiles/{currentUserId}
```

## Optional Query Parameters

| Parameter | Description |
|----------|-------------|
| `fields` | Comma-separated list of fields to return |

## Examples

```http
GET /profiles/me
GET /profiles/me?fields=email,username,firstName,lastName
GET /profiles/me?fields=description,profilePicture
```

## Success Response

```json
{
  "data": {
    "id": "test-user-123",
    "type": "profiles",
    "attributes": {
      "id": "test-user-123",
      "email": "test-user-123@dev.local",
      "username": "test-user-123",
      "firstName": "Dev",
      "lastName": "User",
      "description": "Seeded by dev login",
      "birthDate": null,
      "profilePicture": null,
      "creationDate": 1741460000000,
      "lastLoginDate": 1741460000000
    },
    "links": {
      "self": "http://localhost:3000/profiles/test-user-123"
    }
  }
}
```

## Success Response with `fields`

Request:

```http
GET /profiles/me?fields=email,username,description
```

Response:

```json
{
  "data": {
    "id": "test-user-123",
    "type": "profiles",
    "attributes": {
      "email": "test-user-123@dev.local",
      "username": "test-user-123",
      "description": "Seeded by dev login"
    },
    "links": {
      "self": "http://localhost:3000/profiles/test-user-123"
    }
  }
}
```

## cURL Example

```bash
curl -b cookies.txt "http://localhost:3000/profiles/me"
```

With selected fields:

```bash
curl -b cookies.txt "http://localhost:3000/profiles/me?fields=email,username,firstName,lastName"
```

## Possible Errors

- `401 Unauthorized` → No active session
- `404 Not Found` → Profile does not exist

---

# 2. Get Profile by ID

## Endpoint

```http
GET /profiles/{id}
```

## Description

Returns a profile by ID.

At the moment, this endpoint only allows users to access **their own profile**.  
If `{id}` is different from the current authenticated user's ID, the request is rejected.

## Path Parameter

| Parameter | Description |
|----------|-------------|
| `id` | Profile ID or `me` |

## Optional Query Parameters

| Parameter | Description |
|----------|-------------|
| `fields` | Comma-separated list of fields to return |

## Examples

```http
GET /profiles/test-user-123
GET /profiles/test-user-123?fields=email,username
GET /profiles/me
```

## Success Response

```json
{
  "data": {
    "id": "test-user-123",
    "type": "profiles",
    "attributes": {
      "id": "test-user-123",
      "email": "test-user-123@dev.local",
      "username": "test-user-123",
      "firstName": "Dev",
      "lastName": "User",
      "description": "Seeded by dev login",
      "birthDate": null,
      "profilePicture": null,
      "creationDate": 1741460000000,
      "lastLoginDate": 1741460000000
    },
    "links": {
      "self": "http://localhost:3000/profiles/test-user-123"
    }
  }
}
```

## cURL Example

```bash
curl -b cookies.txt "http://localhost:3000/profiles/test-user-123"
```

## Possible Errors

- `401 Unauthorized` → No active session or trying to access another user's profile
- `404 Not Found` → Profile does not exist

---

# 3. Update Current Profile

## Endpoint

```http
PATCH /profiles/me
```

## Description

Updates the authenticated user's profile.

Only the current user can update their own profile.

## Editable Fields

The backend allows updating these fields:

- `firstName`
- `lastName`
- `username`
- `description`
- `birthDate`
- `profilePicture`

## Non-editable Fields

The backend should not allow direct edits to these fields:

- `id`
- `email`
- `creationDate`
- `lastLoginDate`

## Request Body

Any subset of the allowed editable fields:

```json
{
  "firstName": "Lennin",
  "lastName": "Sabogal",
  "username": "lennin",
  "description": "Testing profile patch endpoint",
  "birthDate": 1072915200000,
  "profilePicture": "https://example.com/avatar.jpg"
}
```

You may also send only one field:

```json
{
  "description": "Updated bio"
}
```

## Success Response

```json
{
  "data": {
    "id": "test-user-123",
    "type": "profiles",
    "attributes": {
      "id": "test-user-123",
      "email": "test-user-123@dev.local",
      "username": "lennin",
      "firstName": "Lennin",
      "lastName": "Sabogal",
      "description": "Testing profile patch endpoint",
      "birthDate": 1072915200000,
      "profilePicture": "https://example.com/avatar.jpg",
      "creationDate": 1741460000000,
      "lastLoginDate": 1741460000000
    },
    "links": {
      "self": "http://localhost:3000/profiles/test-user-123"
    }
  }
}
```

## cURL Example

Update description only:

```bash
curl -b cookies.txt -X PATCH "http://localhost:3000/profiles/me" \
  -H "Content-Type: application/json" \
  -d '{"description":"Updated bio"}'
```

Update multiple fields:

```bash
curl -b cookies.txt -X PATCH "http://localhost:3000/profiles/me" \
  -H "Content-Type: application/json" \
  -d '{"firstName":"Lennin","lastName":"Sabogal","username":"lennin"}'
```

## Possible Errors

- `401 Unauthorized` → No active session
- `404 Not Found` → Profile does not exist
- `400 Bad Request` → Invalid request body

---

# 4. Authentication Dependency

## Important Note

The profile endpoints depend on a valid session.

Typical flow:

1. User logs in through Firebase or dev auth
2. Backend creates a session cookie
3. Backend ensures a profile exists in Realtime DB
4. Profile endpoints use the session user ID to read/write under:

```txt
profiles/{userId}
```

If dev login is used, it is recommended that the backend seed a default profile for the test user.

Example seeded profile:

```json
{
  "id": "test-user-123",
  "email": "test-user-123@dev.local",
  "username": "test-user-123",
  "firstName": "Dev",
  "lastName": "User",
  "description": "Seeded by dev login",
  "birthDate": null,
  "profilePicture": null,
  "creationDate": 1741460000000,
  "lastLoginDate": 1741460000000
}
```

---

# Recommended Testing Flow

1. Login using dev auth or Firebase auth
2. Call `GET /me`
3. Call `GET /profiles/me`
4. Call `PATCH /profiles/me`
5. Call `GET /profiles/me` again to verify changes
6. Optionally test `GET /profiles/{id}` using your own user ID

---

# Quick cURL Collection

## Login (dev)

```bash
curl -c cookies.txt -i -X POST "http://localhost:3000/auth/dev/login" \
  -H "Content-Type: application/json" \
  -d '{"userId":"test-user-123"}'
```

## Get current profile

```bash
curl -b cookies.txt "http://localhost:3000/profiles/me"
```

## Get current profile with selected fields

```bash
curl -b cookies.txt "http://localhost:3000/profiles/me?fields=email,username,firstName"
```

## Patch current profile

```bash
curl -b cookies.txt -X PATCH "http://localhost:3000/profiles/me" \
  -H "Content-Type: application/json" \
  -d '{"firstName":"Lennin","description":"Testing profile endpoint"}'
```