# Tipical Backend

A modern, type-safe API for the **Tipical** social platform, built with **Hono**, **Bun**, and **Firebase**.

## 🚀 Tech Stack

- **Runtime:** [Bun](https://bun.sh/)
- **Web Framework:** [Hono](https://hono.dev/) with [zod-openapi](https://github.com/honojs/middleware/tree/main/packages/zod-openapi)
- **Validation:** [Zod](https://zod.dev/)
- **Database:** Firebase Realtime Database
- **Storage:** Firebase Cloud Storage
- **Auth:** Firebase Authentication (via Hono middleware)
- **Documentation:** Automated OpenAPI (Swagger) support

---

## 🏗️ Project Structure

```text
backend/
├── src/
│   ├── features/          # Domain-driven features (posts, auth, user, comments)
│   │   ├── posts/         # Post management (CRUD, Media, Geo)
│   │   ├── auth/          # Firebase token verification & session logic
│   │   ├── comments/      # Comment threading
│   │   └── user/          # User profiles
│   ├── shared/            # Common models, schemas, and libraries
│   ├── middleware/        # Global error handling & security
│   └── utils/             # Helper functions (object, url, path)
├── docs/                  # Detailed feature documentation
├── index.ts               # App entry point & Firebase init
└── package.json
```

---

## 🛠️ Key Features

### 🔐 Authentication
The backend uses **Firebase Admin SDK** to verify `idToken` from the client. It supports a session-based flow where a Firebase token is exchanged for a JWT managed by the backend.

### 📝 Posts & Media
Supports rich posts with text, geographic coordinates, and images.
- **Two-Step Creation:** Upload binary image first (`/posts/upload`), then create post with JSON metadata.
- **Validation:** Strict coordinate range checks (-90 to 90 for latitude, -180 to 180 for longitude).
- **Storage:** Automatic cascade deletion of images from Firebase Storage when a post is deleted.

### 📍 Location Handling
Posts store optional `latitude` and `longitude`. The API provides raw coordinates for clients to visualize on interactive maps (e.g., Apple MapKit).

---

## 📡 API Endpoints (Post Feature)

| Method | Path | Description |
| :--- | :--- | :--- |
| `GET` | `/posts` | List posts with pagination & filters (`userId`, `hasImage`, `archived`) |
| `POST` | `/posts` | Create a new post |
| `GET` | `/posts/{id}` | Retrieve a single post |
| `PATCH` | `/posts/{id}` | Update a post (with image replacement cleanup) |
| `DELETE` | `/posts/{id}` | Delete post and its associated image |
| `POST` | `/posts/upload` | Upload binary image to storage (returns path/URL) |
| `DELETE` | `/posts/upload` | Manually delete an image by its path |

---

## 📖 Detailed Documentation

- [Media & Location Flow](./docs/features/posts/media-location.md)
- [Auth Flow](./src/features/auth/flow.txt)

---

## 🚦 Getting Started

1.  **Install dependencies:**
    ```bash
    bun install
    ```
2.  **Run in development mode:**
    ```bash
    bun run dev
    ```
3.  **Run Type Check:**
    ```bash
    bun x tsc --noEmit
    ```
