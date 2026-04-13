---
name: next-achitecture
description: >
  Guides on how to structure a Next.js / React TypeScript project router the way this user prefers.
  Use this skill whenever the user asks where a file should go, how to organize a new layouts, pages
  and folders inside the app folder — even if they phrase it casually like "where do I put this?" or 
  "how should I structure this?". Also use it when creating new files or folders, refactoring existing 
  structure, or reviewing whether something is in the right place.
---

# Project Architecture

## Top-level structure

project-root/
├── src/
│ ├── app/ # Next.js App Router: layouts, pages, global CSS
├── next.config.ts
└── ...

## `src/app/` — Next.js App Router

This folder is exclusively for Next.js routing concerns. Keep it lean.

app/
├── globals.css # Global CSS / Tailwind base
├── layout.tsx # Root layout (providers, fonts, metadata)
├── manifest.json # PWA manifest
└── page.tsx # Root page (single-page app entry)

- Layout files are named generically (`layout.tsx`, `page.tsx`) — the folder name provides context.
- If a route grows sub-layouts or shared concerns, create a subfolder: `app/dashboard/layout.tsx`.
- Global styles live here. Component-level styles belong in `components/ui/`.
