"use client";
import { useState } from "react";

const API = process.env.NEXT_PUBLIC_API_BASE;
export default function Home() {
  const [link, setLink] = useState(API);
  const [output, setOutput] = useState<any>("");

  async function devLogin() {
    setLink(`${API}/auth/dev/login`);
    try {
      const res = await fetch(`${API}/auth/dev/login`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        credentials: "include",
        body: JSON.stringify({ userId: "test-user-123" }),
      });
      const data = await res.json().catch(() => res.text());
      setOutput(data);
    } catch (err: any) {
      setOutput(err.message);
    }
  }

  async function me() {
    setLink(`${API}/me`);
    try {
      const res = await fetch(`${API}/me`, {
        credentials: "include",
      });
      const data = await res.json().catch(() => res.text());
      setOutput(data);
    } catch (err: any) {
      setOutput(err.message);
    }
  }

  async function getPosts() {
    setLink(`${API}/posts?limit=5`);
    try {
      const res = await fetch(`${API}/posts?limit=5`, {
        credentials: "include",
      });
      const data = await res.json().catch(() => res.text());
      setOutput(data);
    } catch (err: any) {
      setOutput(err.message);
    }
  }

  async function createPost() {
    setLink(`${API}/posts`);
    try {
      const res = await fetch(`${API}/posts`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        credentials: "include",
        body: JSON.stringify({
          title: "Next test",
          description: "Created from Next tester",
        }),
      });
      const data = await res.json().catch(() => res.text());
      setOutput(data);
    } catch (err: any) {
      setOutput(err.message);
    }
  }
  async function logout() {
    setLink(`${API}/auth/firebase/logout`);
    try {
      const res = await fetch(`${API}/auth/firebase/logout`, {
        method: "POST",
        credentials: "include",
        headers: {
          "Content-Type": "application/json",
        },
      });
      const data = await res.json().catch(() => res.text());
      setOutput(data);
    } catch (err: any) {
      setOutput(err.message);
    }
  }

  return (
    <div style={{ padding: 40, fontFamily: "monospace" }}>
      <h1>API TESTER</h1>

      <div style={{ display: "flex", gap: 10, flexWrap: "wrap" }}>
        <button
          className="cursor-pointer bg-gray-300 rounded-xl p-3 font-black text-black"
          onClick={devLogin}
        >
          Dev Login
        </button>
        <button
          className="cursor-pointer bg-gray-300 rounded-xl p-3 font-black text-black"
          onClick={me}
        >
          /me
        </button>
        <button
          className="cursor-pointer bg-gray-300 rounded-xl p-3 font-black text-black"
          onClick={getPosts}
        >
          GET /posts
        </button>
        <button
          className="cursor-pointer bg-gray-300 rounded-xl p-3 font-black text-black"
          onClick={createPost}
        >
          POST /posts
        </button>
        <button
          className="cursor-pointer bg-gray-300 rounded-xl p-3 font-black text-black"
          onClick={logout}
        >
          Logout
        </button>
      </div>

      <pre
        style={{
          marginTop: 20,
          background: "#111",
          color: "#0f0",
          padding: 20,
          minHeight: 70,
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
          minHeight: 200,
          whiteSpace: "pre-wrap",
          wordBreak: "break-all",
        }}
        className=""
      >
        <code>{JSON.stringify(output, null, 2)}</code>
      </pre>
    </div>
  );
}
