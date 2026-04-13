---
name: react-achitecture
description: >
  Guides on how to structure React TypeScript project the way this user prefers.
  Use this skill whenever the user asks where a file should go, how to organize a new feature,
  where to place a hook, provider, type, style, or any other module — even if they phrase it casually
  like "where do I put this?" or "how should I structure this?". Also use it when creating new files
  or folders, refactoring existing structure, or reviewing whether something is in the right place.
---

# Project Architecture

## Top-level structure

project-root/
├── .github/
├── public/
├── src/
│ ├── components/ # UI and feature components
│ ├── data/ # Static/derived data
│ ├── hooks/ # App-wide custom hooks
│ ├── i18n/ # Internationalisation config and utilities
│ ├── lib/ # Generic utilities and third-party wrappers
│ ├── scripts/ # Build/codegen scripts
│ └── tests/ # App-wide test setup and helpers
├── tailwind.config.\*
├── tsconfig.json
└── ...

## The core principle: contextual placement

The most important rule is **place things as close as possible to where they are exclusively used**.
Only promote to a shared location when genuinely shared. This applies to hooks, providers, types,
styles, tests — everything.

| Situation                                   | Placement                                    |
| ------------------------------------------- | -------------------------------------------- |
| Hook used only inside `i18n/`               | `src/i18n/`                                  |
| Hook used across multiple unrelated modules | `src/hooks/`                                 |
| Provider scoped to one component tree       | alongside that component                     |
| Provider used app-wide                      | `src/app/` or `src/components/providers.tsx` |
| Types for a single component                | co-located in that component file            |
| Types shared across a module                | `types.ts` inside that module folder         |
| Types shared app-wide                       | `src/lib/` or a dedicated `src/types/`       |

When in doubt: **start local, promote when forced to.**

## `src/components/` — Component tree

components/
├── ui/ # Reusable, domain-agnostic UI primitives
│ ├── base/ # Lowest-level structural wrappers (if needed)
│ ├── avatar.tsx
│ ├── badge.tsx
│ ├── button.tsx
│ ├── card.tsx
│ └── index.ts # Public API — explicit named re-exports only
├── aerostat/ # Self-contained feature module
│ ├── aerostat-provider.tsx
│ ├── index.tsx
│ └── use-aerostat-\*.tsx # hooks that ONLY belong to this feature
├── header/
├── switch/
│ ├── locale/
│ │ ├── test/
│ │ └── index.tsx
│ ├── theme/
│ └── index.ts
├── animated-loading-gate.tsx
├── hero-section.tsx
├── providers.tsx # App-wide provider composition
├── skills-section.tsx
└── working-ways-section.tsx

### `ui/` rules

- Contains **definition only** — universal styles that apply everywhere the component is used.
- No screen-specific logic or layout adjustments inside `ui/`.
- Every component exported through `index.ts` as an explicit named export.
- Sub-components (compound pattern members) are NOT individually exported — only the root component with its sub-components attached.

### Non-ui components

- Screen-level sections (`hero-section.tsx`, `skills-section.tsx`) live at `components/` root.
- Feature modules with multiple files get their own subfolder (`aerostat/`, `switch/`).
- Hooks, providers, and tests that belong exclusively to a feature live **inside** that feature folder.

## `src/hooks/` — App-wide hooks

Only hooks that are genuinely shared across multiple unrelated parts of the app:

hooks/
├── use-is-desktop-like.ts
├── use-mouse-over-animation.ts
├── use-stable-random.ts
└── use-uri.ts

Do **not** put here: hooks scoped to a single feature or component. Those live alongside their feature.

## `src/i18n/` — Internationalisation

Everything i18n-specific lives here, including hooks that deal with locale/language concerns
(e.g. a `use-locale-switch` hook belongs here, not in `hooks/`).

## File naming

- All files: **kebab-case** (`hero-section.tsx`, `use-is-desktop-like.ts`)
- No PascalCase filenames, even for components
- Folders: **kebab-case**
- Test folders: `__test__` convention

## Index files

Every folder that exposes a public API has an `index.ts` or `index.tsx`. Rules:

- Export only what consumers should use — the index is a deliberate public contract.
- Use **explicit named exports**, not `export * from`. This controls what editors surface first.
- For compound components, export only the root (which carries sub-components via `Object.assign`).
- For simple modules, `export default` in the component file + named re-export in index is fine.

```ts
// components/ui/index.ts — correct
export { Badge } from "./badge";
export { Card } from "./card";

// NOT this — too implicit
export * from "./badge";
export * from "./card";
```
