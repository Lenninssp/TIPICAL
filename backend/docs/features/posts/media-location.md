# Post Media & Location Flow

## Overview
This document describes the backend architecture for handling geographic coordinates and image media within the Tipical application.

## 1. Data Model
Posts are stored in Firebase Realtime Database with the following additional optional fields:

| Field | Type | Description |
| :--- | :--- | :--- |
| `latitude` | Number | WGS84 latitude (-90 to 90) |
| `longitude` | Number | WGS84 longitude (-180 to 180) |
| `imageUrl` | String | Publicly accessible URL for the image (signed) |
| `imagePath` | String | Firebase Storage internal path (e.g., `posts/uuid.jpg`) |

### Validation Rules (Zod)
- **Coordinates:** If one is provided, both must be provided (`refine` constraint).
- **Ranges:** Latitude must be between -90 and 90. Longitude must be between -180 and 180.
- **Media:** Both `imageUrl` and `imagePath` are optional strings.

## 2. Firebase Storage Strategy
- **Bucket:** `gs://tipical-bd8e7.firebasestorage.app`
- **Pathing:** All post images are stored under the `posts/` prefix.
- **Naming:** Files are named using `randomUUID()` to prevent collisions.
- **Permissions:** Files are uploaded with private permissions, and the backend generates a long-lived signed URL for retrieval.

## 3. Media Lifecycle Flows

### A. Creation (Two-Step Process)
1. **Upload:** Client calls `POST /posts/upload` with `multipart/form-data`.
   - Backend saves file to Storage.
   - Backend returns `imagePath` and `imageUrl`.
2. **Post Save:** Client calls `POST /posts` with the JSON attributes, including the references received in step 1.

### B. Update & Replacement
When `PATCH /posts/:id` is called with a new `imagePath`:
1. Backend retrieves the existing post record.
2. If the `imagePath` has changed and the old one exists, the backend calls `deletePostImage(oldPath)`.
3. The database record is updated with the new `imagePath` and `imageUrl`.

### C. Deletion (Cascade)
When `DELETE /posts/:id` is called:
1. Backend checks the record for an `imagePath`.
2. If present, it deletes the file from Firebase Storage first.
3. Upon storage success (or 404), the Realtime Database record is removed.

## 4. Distance Calculation Approach
- **Backend Role:** Currently, the backend serves the raw `latitude` and `longitude` in the post attributes.
- **Filtering:** The `GET /posts` endpoint supports basic filtering, but complex proximity-based queries (e.g., "within 5km") are handled on the client side using **MapKit** for performance and lower server load.
- **Future:** If server-side proximity search is required, Geohashing or a specialized Geo-index (like Firestore GeoQueries) would be implemented.

## 5. API Contracts

### POST /posts/upload
- **Request:** `multipart/form-data` with `image` field.
- **Response:**
  ```json
  {
    "data": {
      "id": "upload",
      "type": "upload",
      "attributes": {
        "imageUrl": "https://...",
        "imagePath": "posts/..."
      }
    }
  }
  ```

### DELETE /posts/upload
- **Request:** `application/json` with `{"imagePath": "posts/..."}`.
- **Description:** Manually deletes an orphaned image from storage.
