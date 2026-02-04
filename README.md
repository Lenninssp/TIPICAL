# Typical
> *Bridging social interaction through location-aware content.*

## 1. Project Overview
**Typical** is a social media application designed to capture the core essence of modern platforms: social interaction. The application allows users to engage with Reddit-inspired content featuring text, media, and geographic data, fostering a community built around shared locations and interests.

### Objective
To provide a seamless interface where users can create, preview, and interact with posts while utilizing geographic context via **MapKit** to visualize the distance and location of social activity.

---

## 2. Target Audience
* **Young Adults:** Seeking modern, intuitive social experiences.
* **Explorer-Type Users:** Individuals interested in location-aware content and local social feeds.

---

## 3. Core Features

### 👤 Account System
* **User Authentication:** Secure Sign up, Login, and Logout flows.
* **Account Management:**
  * Forget password recovery.
  * CRUD operations for Profile Picture, Username, and Email.
* **Profiles:** Distinct views for personal profiles and browsing other users' profiles.

### 📝 Posts & Interaction
* **Creation:** Support for text content, image uploads, and optional map tagging.
* **Lifecycle:** Preview mode before publishing, editing existing posts, and deletion.
* **Consumption:** Detailed post views, scrolling feed, and image download capabilities.

### 💬 Engagement
* **Threading:** View organized comment threads per post.
* **Management:** Add, edit, and delete comments.

### 🗺️ Map & Location (MapKit)
* **Geo-Tagging:** Attach specific coordinates to posts.
* **Visualization:** View post locations on an interactive map.
* **Proximity:** Calculate and display the distance between the user’s current location and the post.

---

## 4. Technical Stack

| Component | Technology |
| :--- | :--- |
| **Language** | Swift |
| **Framework** | SwiftUI |
| **Architecture** | MVVM (Model-View-ViewModel) |
| **Backend** | Firebase (Auth, Firestore, Storage) |
| **Local Storage** | CoreData & Local File System |
| **Maps** | MapKit |
| **Version Control** | GitHub |

---

## 5. Screen Overview

### Authentication & Account
* Login, Signup, & Forget Password.
* View Account & Edit Account.
* General Configurations.

### Social Feed & Content
* Main Feed & Post Details.
* Create Post, Preview Post, & Edit Post.
* Comment Section (Add & View).

### Map & Profiles
* Global Map View & Post Location Map.
* User Profile (Personal).
* User Profile (Others).

---

## 6. Project Members
* **Sofia Guerra Quintero**
* **Lennin Sabogal**