---
name: react-component-patterns
description: >
  Guides on how to write React/TypeScript components the way this user prefers.
  Use this skill whenever the user is creating a new component, refactoring an existing one,
  asking how to structure a component, asking about styling conventions, or working inside
  the `src/components/` tree — even for small changes. Also use when the user asks about
  compound components, Tailwind usage, sub-component exports, or the ui/ vs screen styling contract.
---

# Component Patterns

## The compound pattern

All components with meaningful sub-structure use the **compound pattern** via `Object.assign`.
This makes usage self-documenting, prevents orphaned sub-components, and keeps tree-shaking safe
because unused sub-components simply won't appear in consuming code.

### Structure

```tsx
// src/components/ui/badge.tsx

const Badge = ({ children, className }: Props) => { ... };

const Group = ({ children, className }: Props) => { ... };
const Icon = ({ ... }: Props) => { ... };
const Text = ({ children, className }: Props) => { ... };

export default Object.assign(Badge, { Group, Icon, Text });
```

### Index re-export

```ts
// src/components/ui/index.ts
export { default as Badge } from "./badge";
```

Sub-components (`Badge.Group`, `Badge.Icon`, `Badge.Text`) are **never exported individually**.
They are only accessible through the root. This is intentional — it enforces compound usage
and keeps the editor's autocomplete clean.

### When compound applies

Use compound pattern when a component has **at least one meaningful sub-part** that consumers
will compose. Examples: `Card` with `Header/Content/Footer`, `Section` with `Title/Content`,
`Badge` with `Group/Icon/Text`

For truly atomic components with no sub-structure (e.g. a standalone `Spinner`), a simple
default export is fine. Still export through index as a named export.

### Enforcement rule

If a sub-component is no longer used anywhere, **remove it from the `Object.assign` call**.
Because sub-components are not individually exported, removal has no side effects — no orphan
imports to chase down. This is a key benefit of the pattern.

## Styling contract: `ui/` vs screen

This is the most important styling rule:

| Location                                | Purpose                                                    | Example                                         |
| --------------------------------------- | ---------------------------------------------------------- | ----------------------------------------------- |
| Inside `ui/` component definition       | Universal styles — apply everywhere this component is used | `className="flex border px-2 py-1 text-xs"`     |
| Outside `ui/`, when using the component | Screen-specific overrides — apply only in this context     | `<Badge.Group className="pointer-events-none">` |

**`ui/` components define what the component IS. Consumers define what it does in their context.**

```tsx
// CORRECT — universal badge styles live in badge.tsx definition
const Badge = ({ children, className }: Props) => (
  <span className={cn("flex border px-2 py-1 text-xs font-medium", className)}>
    {children}
  </span>
);

// CORRECT — screen-specific concern lives in the consuming component
<Badge.Group className="pointer-events-none">
  <Badge className="pointer-events-none">...</Badge>
</Badge.Group>;
```

Never add screen-specific layout, pointer behaviour, or context-dependent styles inside the `ui/`
definition. The `className` prop + `cn()` merge is how consumers override when needed.

### Structure for UI Components composition

In some rare cases a UI component might end up being used by other UI Components as well as
by the Screen Components, and for that purpose isolate it in a Base Components structure.
Enforce use of Base as a single source of trust from all Base components, following the same
principle described in the sections above.

project-root/
├── src/
│ ├── components/
│ │ └── ui/
│ │ └── base/
│ │ ├── index.ts
│ │ └── title.tsx
│ └── ...
└── ...

```tsx
// Usage inside a Section UI Component, to ensure it is composed with the right title abstraction

// src/components/ui/section.tsx

// --- Import Base components ---
import { Base } from "./base";

// --- Implement abstract section title ---
const Title = ({ children }: { children: React.ReactNode }) => {
  return (
    <Base.Title size="md" className=" mt-5 mb-7 md:mt-6 md:mb-8">
      {children}
    </Base.Title>
  );
};

// --- Export components ---
export default Object.assign(Section, {
  Title,
});
```

```tsx
// Usage of both use cases, abstracted and base, in hero-section

// src/components/hero-section.tsx

// --- Import components ---
import { Base } from "./base";
import { Section } from "./ui";

export function HeroSection() {
  ...
  return (
    <Section>
      <Section.Title>...</Section.Title>
      ...
      <Base.Title size="lg" className="self-center mt-2 mb-3">...</Base.Title>
    </Section>
  )
}
```

## Tailwind usage

- Use Tailwind utility classes as the default styling approach.
- Use `cn()` (from `@/lib/utils`) to merge class names and handle conditional classes.
- Multi-line class strings are fine for readability — use template literals:

```tsx
className={cn(
  `flex
  transition-color
  border-transparent
  bg-secondary
  text-secondary-foreground
  duration-700`,
  className,
)}
```

- Arbitrary values (`[&>svg]:size-3.5`) are acceptable when Tailwind doesn't have a direct utility.
- `motion-reduce:` variants should be used for animated components as an accessibility default.

## Component file anatomy

A typical `ui/` component file:

```tsx
import * as React from "react";
import { cn } from "@/lib/utils";
// other imports

// --- type definitions ---
interface Props {
  children: React.ReactNode;
  className?: string;
}

// --- sub-components (if any) ---
const SubPart = ({ ... }: Props) => { ... };

// --- root component ---
const MyComponent = ({ children, className }: Props) => {
  return ( ... );
};

// --- export (always via Object.assign if compound, default otherwise) ---
export default Object.assign(MyComponent, { SubPart });
```

## Feature components (non-ui)

Components outside `ui/` (e.g. `skills-section.tsx`, `hero-section.tsx`) are screen/feature
components. They:

- Import from `./ui` using named exports: `import { Badge, Card, Section } from "./ui"`
- Apply screen-specific styles at the point of use, not by modifying `ui/` definitions
- Can use hooks from `@/hooks/` or from their co-located feature folder
- Are NOT exported as compound components unless they themselves have meaningful sub-structure
- Are named as plain function exports: `export function SkillsSection() { ... }`

## Naming conventions

| Thing              | Convention                            | Example                                        |
| ------------------ | ------------------------------------- | ---------------------------------------------- |
| Component function | PascalCase                            | `const Badge`, `export function SkillsSection` |
| File name          | kebab-case                            | `badge.tsx`, `skills-section.tsx`              |
| Sub-component      | PascalCase (short, noun)              | `Group`, `Icon`, `Text`, `Header`, `Footer`    |
| Hook               | camelCase with `use` prefix           | `useIsDesktopLike`                             |
| Hook file          | kebab-case                            | `use-is-desktop-like.ts`                       |
| Props interface    | `Props` (local to file, not exported) | `interface Props { ... }`                      |

## Known components libraries that will require refactor

- Shadcn/ui
- React Native Reusable
