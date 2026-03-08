"use client";

import { useState } from "react";

const API = process.env.NEXT_PUBLIC_API_BASE ?? "";

export default function Home() {
  const [link, setLink] = useState(API);
  const [output, setOutput] = useState<any>("");

  const [postId, setPostId] = useState("");
  const [profileFields, setProfileFields] = useState("");

  const [createPostForm, setCreatePostForm] = useState({
    title: "Next test",
    description: "Created from Next tester",
    archived: false,
    userId: "",
    imageUrl: "",
  });

  const [patchProfileForm, setPatchProfileForm] = useState({
    firstName: "",
    lastName: "",
    username: "",
    description: "",
    birthDate: "",
    profilePicture: "",
  });

  const [patchPostForm, setPatchPostForm] = useState({
    title: "",
    description: "",
    archived: "",
    imageUrl: "",
  });

  async function handleResponse(res: Response) {
    const data = await res.json().catch(() => res.text());
    setOutput(data);
  }

  async function runRequest(
    url: string,
    options?: RequestInit,
  ) {
    setLink(url);
    try {
      const res = await fetch(url, {
        credentials: "include",
        ...options,
      });
      await handleResponse(res);
    } catch (err: any) {
      setOutput(err?.message ?? "Unknown error");
    }
  }

  async function devLogin() {
    await runRequest(`${API}/auth/dev/login`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ userId: "test-user-123" }),
    });
  }

  async function me() {
    await runRequest(`${API}/me`);
  }

  async function getProfile() {
    const query = profileFields.trim()
      ? `?fields=${encodeURIComponent(profileFields)}`
      : "";

    await runRequest(`${API}/profiles/me${query}`);
  }

  async function patchProfile() {
    const body: Record<string, any> = {};

    if (patchProfileForm.firstName.trim()) body.firstName = patchProfileForm.firstName.trim();
    if (patchProfileForm.lastName.trim()) body.lastName = patchProfileForm.lastName.trim();
    if (patchProfileForm.username.trim()) body.username = patchProfileForm.username.trim();
    if (patchProfileForm.description.trim()) body.description = patchProfileForm.description.trim();
    if (patchProfileForm.profilePicture.trim()) body.profilePicture = patchProfileForm.profilePicture.trim();

    if (patchProfileForm.birthDate.trim()) {
      const parsed = Number(patchProfileForm.birthDate);
      if (!Number.isNaN(parsed)) {
        body.birthDate = parsed;
      }
    }

    await runRequest(`${API}/profiles/me`, {
      method: "PATCH",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    });
  }

  async function getPosts() {
    await runRequest(`${API}/posts?limit=5`);
  }

  async function createPost() {
    const body: Record<string, any> = {
      title: createPostForm.title,
      description: createPostForm.description,
      archived: createPostForm.archived,
    };

    if (createPostForm.userId.trim()) {
      body.userId = createPostForm.userId.trim();
    }

    if (createPostForm.imageUrl.trim()) {
      body.image = {
        url: createPostForm.imageUrl.trim(),
      };
    }

    await runRequest(`${API}/posts`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    });
  }

  async function patchPost() {
    if (!postId.trim()) {
      setOutput("Missing postId");
      return;
    }

    const body: Record<string, any> = {};

    if (patchPostForm.title.trim()) body.title = patchPostForm.title.trim();
    if (patchPostForm.description.trim()) body.description = patchPostForm.description.trim();

    if (patchPostForm.archived === "true") body.archived = true;
    if (patchPostForm.archived === "false") body.archived = false;

    if (patchPostForm.imageUrl.trim()) {
      body.image = {
        url: patchPostForm.imageUrl.trim(),
      };
    }

    await runRequest(`${API}/posts/${postId}`, {
      method: "PATCH",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    });
  }

  async function deletePost() {
    if (!postId.trim()) {
      setOutput("Missing postId");
      return;
    }

    await runRequest(`${API}/posts/${postId}`, {
      method: "DELETE",
    });
  }

  async function logout() {
    await runRequest(`${API}/auth/firebase/logout`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
    });
  }

  function sectionStyle(title: string) {
    return (
      <h2 style={{ fontSize: 18, fontWeight: 800, marginTop: 24, marginBottom: 12 }}>
        {title}
      </h2>
    );
  }

  return (
    <div style={{ padding: 40, fontFamily: "monospace", maxWidth: 1100, margin: "0 auto" }}>
      <h1 style={{ fontSize: 28, fontWeight: 900, marginBottom: 20 }}>API TESTER</h1>

      {sectionStyle("Auth / Session")}
      <div style={{ display: "flex", gap: 10, flexWrap: "wrap" }}>
        <button className="cursor-pointer bg-gray-300 rounded-xl p-3 font-black text-black" onClick={devLogin}>
          Dev Login
        </button>
        <button className="cursor-pointer bg-gray-300 rounded-xl p-3 font-black text-black" onClick={me}>
          GET /me
        </button>
        <button className="cursor-pointer bg-gray-300 rounded-xl p-3 font-black text-black" onClick={logout}>
          Logout
        </button>
      </div>

      {sectionStyle("Profile")}
      <div style={{ display: "grid", gap: 10 }}>
        <div style={{ display: "flex", gap: 10, alignItems: "center", flexWrap: "wrap" }}>
          <input
            placeholder="fields=email,username,firstName"
            value={profileFields}
            onChange={(e) => setProfileFields(e.target.value)}
            style={inputStyle}
          />
          <button className="cursor-pointer bg-gray-300 rounded-xl p-3 font-black text-black" onClick={getProfile}>
            GET /profiles/me
          </button>
        </div>

        <div style={cardStyle}>
          <div style={grid2Style}>
            <input
              placeholder="firstName"
              value={patchProfileForm.firstName}
              onChange={(e) =>
                setPatchProfileForm((prev) => ({ ...prev, firstName: e.target.value }))
              }
              style={inputStyle}
            />
            <input
              placeholder="lastName"
              value={patchProfileForm.lastName}
              onChange={(e) =>
                setPatchProfileForm((prev) => ({ ...prev, lastName: e.target.value }))
              }
              style={inputStyle}
            />
            <input
              placeholder="username"
              value={patchProfileForm.username}
              onChange={(e) =>
                setPatchProfileForm((prev) => ({ ...prev, username: e.target.value }))
              }
              style={inputStyle}
            />
            <input
              placeholder="birthDate (timestamp)"
              value={patchProfileForm.birthDate}
              onChange={(e) =>
                setPatchProfileForm((prev) => ({ ...prev, birthDate: e.target.value }))
              }
              style={inputStyle}
            />
            <input
              placeholder="profilePicture URL"
              value={patchProfileForm.profilePicture}
              onChange={(e) =>
                setPatchProfileForm((prev) => ({ ...prev, profilePicture: e.target.value }))
              }
              style={inputStyle}
            />
            <input
              placeholder="description"
              value={patchProfileForm.description}
              onChange={(e) =>
                setPatchProfileForm((prev) => ({ ...prev, description: e.target.value }))
              }
              style={inputStyle}
            />
          </div>

          <button className="cursor-pointer bg-gray-300 rounded-xl p-3 font-black text-black" onClick={patchProfile}>
            PATCH /profiles/me
          </button>
        </div>
      </div>

      {sectionStyle("Posts")}
      <div style={cardStyle}>
        <div style={grid2Style}>
          <input
            placeholder="title"
            value={createPostForm.title}
            onChange={(e) =>
              setCreatePostForm((prev) => ({ ...prev, title: e.target.value }))
            }
            style={inputStyle}
          />
          <input
            placeholder="description"
            value={createPostForm.description}
            onChange={(e) =>
              setCreatePostForm((prev) => ({ ...prev, description: e.target.value }))
            }
            style={inputStyle}
          />
          <input
            placeholder="userId (optional)"
            value={createPostForm.userId}
            onChange={(e) =>
              setCreatePostForm((prev) => ({ ...prev, userId: e.target.value }))
            }
            style={inputStyle}
          />
          <input
            placeholder="image url (optional)"
            value={createPostForm.imageUrl}
            onChange={(e) =>
              setCreatePostForm((prev) => ({ ...prev, imageUrl: e.target.value }))
            }
            style={inputStyle}
          />
        </div>

        <label style={{ display: "flex", alignItems: "center", gap: 8 }}>
          <input
            type="checkbox"
            checked={createPostForm.archived}
            onChange={(e) =>
              setCreatePostForm((prev) => ({ ...prev, archived: e.target.checked }))
            }
          />
          archived
        </label>

        <div style={{ display: "flex", gap: 10, flexWrap: "wrap" }}>
          <button className="cursor-pointer bg-gray-300 rounded-xl p-3 font-black text-black" onClick={getPosts}>
            GET /posts
          </button>
          <button className="cursor-pointer bg-gray-300 rounded-xl p-3 font-black text-black" onClick={createPost}>
            POST /posts
          </button>
        </div>
      </div>

      {sectionStyle("Single Post Actions")}
      <div style={cardStyle}>
        <input
          placeholder="post id"
          value={postId}
          onChange={(e) => setPostId(e.target.value)}
          style={inputStyle}
        />

        <div style={grid2Style}>
          <input
            placeholder="new title"
            value={patchPostForm.title}
            onChange={(e) =>
              setPatchPostForm((prev) => ({ ...prev, title: e.target.value }))
            }
            style={inputStyle}
          />
          <input
            placeholder="new description"
            value={patchPostForm.description}
            onChange={(e) =>
              setPatchPostForm((prev) => ({ ...prev, description: e.target.value }))
            }
            style={inputStyle}
          />
          <input
            placeholder='archived: "true" or "false"'
            value={patchPostForm.archived}
            onChange={(e) =>
              setPatchPostForm((prev) => ({ ...prev, archived: e.target.value }))
            }
            style={inputStyle}
          />
          <input
            placeholder="new image url"
            value={patchPostForm.imageUrl}
            onChange={(e) =>
              setPatchPostForm((prev) => ({ ...prev, imageUrl: e.target.value }))
            }
            style={inputStyle}
          />
        </div>

        <div style={{ display: "flex", gap: 10, flexWrap: "wrap" }}>
          <button className="cursor-pointer bg-gray-300 rounded-xl p-3 font-black text-black" onClick={patchPost}>
            PATCH /posts/:id
          </button>
          <button className="cursor-pointer bg-red-300 rounded-xl p-3 font-black text-black" onClick={deletePost}>
            DELETE /posts/:id
          </button>
        </div>
      </div>

      <pre
        style={{
          marginTop: 20,
          background: "#111",
          color: "#0f0",
          padding: 20,
          minHeight: 70,
          whiteSpace: "pre-wrap",
          wordBreak: "break-all",
        }}
      >
        <code>{link}</code>
      </pre>

      <pre
        style={{
          marginTop: 20,
          background: "#111",
          color: "#0f0",
          padding: 20,
          minHeight: 240,
          whiteSpace: "pre-wrap",
          wordBreak: "break-all",
        }}
      >
        <code>{JSON.stringify(output, null, 2)}</code>
      </pre>
    </div>
  );
}

const inputStyle: React.CSSProperties = {
  padding: 12,
  borderRadius: 12,
  border: "1px solid #444",
  background: "#1a1a1a",
  color: "white",
  minWidth: 220,
  width: "100%",
};

const cardStyle: React.CSSProperties = {
  display: "grid",
  gap: 12,
  padding: 16,
  border: "1px solid #333",
  borderRadius: 16,
  background: "#0f0f0f",
};

const grid2Style: React.CSSProperties = {
  display: "grid",
  gridTemplateColumns: "repeat(auto-fit, minmax(220px, 1fr))",
  gap: 10,
};