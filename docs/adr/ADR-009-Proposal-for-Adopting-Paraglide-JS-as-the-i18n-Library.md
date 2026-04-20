# ADR-009 - Study and Proposal for Adopting Paraglide JS as the i18n Library

**Date:** April 2026  
**Author:** Frontend Architecture Team  
**Scope:** React SPA, TypeScript, Domain-Driven Constants (DDF)

---

## 1. Executive Summary

This report proposes the adoption of **Paraglide JS** as the standard internationalization (i18n) library for our React Single Page Application. The current codebase already enforces a strict "no hardcoded strings in components" rule (DDF) through domain-based constant files.

Paraglide aligns perfectly with this architecture because it is a **compiler-based, fully typesafe** solution that moves strings out of TypeScript into locale JSON files, while preserving our existing constant files as typed indexes. Migration requires minimal code changes, delivers up to 70% smaller i18n bundles, and shifts translation errors from runtime to compile time.

**Recommendation:** Adopt Paraglide JS for all new features starting Q2 2026, and migrate existing domains incrementally.

---

## 2. Current State: DDF in Practice

Our project avoids hardcoded UI text by centralizing strings per domain:

```ts
// src/domains/tooltip/tooltip.constants.ts
export const TOOLTIP_DEMO = {
  SUCCESS: 'Dispara una notificación de operación exitosa',
  ERROR: 'Dispara una notificación de error de red',
  WARNING: 'Dispara una notificación de advertencia',
  INFO: 'Dispara una notificación informativa',
  SKELETON: 'Muestra un placeholder de carga por 3 segundos',
} as const

export type TooltipDemo = (typeof TOOLTIP_DEMO)[keyof typeof TOOLTIP_DEMO]
```

Usage:
```tsx
<Tooltip content={TOOLTIP_DEMO.SUCCESS} />
```

Strengths:
- Zero literals in JSX
- Clear domain ownership
- Easy to audit

Limitations:
- Strings are locked to Spanish in source code
- No compile-time guarantee that a key exists in all languages
- Adding English requires duplicating objects or manual sync
- Typos in keys are only caught at runtime

---

## 3. Why Runtime Libraries Fall Short

Traditional libraries (react-i18next, React Intl) resolve translations at runtime:

| Characteristic | Runtime Approach |
|----------------|------------------|
| Bundle | Ships entire dictionary and resolver (~9-20kB)【2728455615622195695†L32-L39】 |
| Tree-shaking | No – unused keys remain in bundle |
| Type safety | Partial, requires manual declaration merging【2728455615622195695†L209-L211】 |
| Error detection | Missing key → blank UI in production |
| Performance | Dictionary lookup on every render |

These libraries were designed before React Server Components and modern bundlers. They force us to choose between type safety and flexibility.

---

## 4. How Paraglide Works

Paraglide is not a runtime resolver. It is a compiler.

1. **Source:** You author `messages/es.json`, `messages/en.json`, `messages/fr.json`
2. **Compile:** `npx @inlang/paraglide-js init` generates `./paraglide/messages.js`
3. **Output:** Each message becomes a standalone, typed JavaScript function【3095143372745893057†L26-L29】
4. **Bundle:** Vite/Rollup tree-shakes unused functions automatically【3095143372745893057†L42-L44】

```
Inlang Project → Paraglide Compiler → messages.js + runtime.js
```

The compiler emits zero-runtime overhead functions. Switching locale is a simple `setLocale('en')` call【4808471097296497080†L142-L158】.

---

## 5. Key Advantages

### 5.1 Compile-Time Type Safety
- Autocomplete for every key and parameter
- Typos become TypeScript errors, not production bugs【3095143372745893057†L44-L46】
- Missing parameters are caught before `npm run build`

### 5.2 Up to 70% Smaller Bundles
Paraglide advertises "up to 70% smaller i18n bundle sizes" because unused messages are eliminated【3095143372745893057†L6-L8】. In practice, a page using 5 tooltip strings ships ~1kB instead of a 20kB runtime.

### 5.3 Framework Agnostic, Zero Wrappers
Works identically in React, Vue, or vanilla TS. No `<I18nextProvider>` or `use client` directives needed【3095143372745893057†L46-L48】.

### 5.4 Preserves DDF Exactly
Our domain constants remain the single source of truth for components. We only change their implementation from string literals to function references.

---

## 6. Migration Example: Tooltip Domain

This small example demonstrates the full migration path.

### Before (Current)
```ts
// tooltip.constants.ts
export const TOOLTIP_DEMO = {
  SUCCESS: 'Dispara una notificación de operación exitosa',
  // ...
} as const
```
```tsx
<Tooltip content={TOOLTIP_DEMO.SUCCESS} />
```

### After (Paraglide)

**Step 1 – Create locale files**
```json
// messages/es.json
{
  "tooltip_demo_success": "Dispara una notificación de operación exitosa",
  "tooltip_demo_error": "Dispara una notificación de error de red",
  "tooltip_demo_warning": "Dispara una notificación de advertencia",
  "tooltip_demo_info": "Dispara una notificación informativa",
  "tooltip_demo_skeleton": "Muestra un placeholder de carga por 3 segundos"
}
```
```json
// messages/en.json
{
  "tooltip_demo_success": "Triggers a successful operation notification",
  "tooltip_demo_error": "Triggers a network error notification",
  "tooltip_demo_warning": "Triggers a warning notification",
  "tooltip_demo_info": "Triggers an informational notification",
  "tooltip_demo_skeleton": "Shows a loading placeholder for 3 seconds"
}
```

**Step 2 – Keep constants file (DDF preserved)**
```ts
// tooltip.constants.ts
import * as m from '@/paraglide/messages'

export const TOOLTIP_DEMO = {
  SUCCESS: m.tooltip_demo_success,
  ERROR: m.tooltip_demo_error,
  WARNING: m.tooltip_demo_warning,
  INFO: m.tooltip_demo_info,
  SKELETON: m.tooltip_demo_skeleton,
} as const
```

**Step 3 – Update usage (add parentheses)**
```tsx
<Tooltip content={TOOLTIP_DEMO.SUCCESS()} />
```

**Step 4 – Language switcher**
```tsx
import { setLocale } from '@/paraglide/runtime'

<button onClick={() => setLocale('en')}>EN</button>
```

Changes are minimal: move strings to JSON, import generated functions, add `()`. The component API, folder structure, and DDF philosophy remain untouched.

---

## 7. Error Prevention: Compile vs Runtime

| Error Type | Runtime Library | Paraglide |
|------------|-----------------|-----------|
| Misspelled key | Renders empty string in prod | TypeScript error at build |
| Missing translation | Falls back silently | Build fails if key absent in locale |
| Wrong parameter | `undefined` in UI | Compile error: "Property 'name' missing"【4808471097296497080†L207-L209】 |
| Unused key | Stays in bundle | Tree-shaken out automatically |

This shift-left reduces QA cycles and prevents i18n regressions from reaching users.

---

## 8. Performance Comparison 2026

Data from independent 2026 benchmark【2728455615622195695†L26-L39】:

| Library | Bundle (gz) | Tree-shakable | Type Safety |
|---------|-------------|---------------|-------------|
| Paraglide-JS | ~1kB per locale | Yes | Full |
| LinguiJS | ~3kB | Yes | Excellent |
| react-i18next | ~9kB | No | Good (with setup) |
| React Intl | ~20kB+ | No | Good |

For our SPA, Paraglide offers the best size-to-safety ratio.

---

## 9. Implementation Plan

**Phase 1 (Week 1-2): Pilot**
- Install `@inlang/paraglide-js` and Vite plugin
- Migrate Tooltip domain only
- Add EN locale

**Phase 2 (Week 3-6): Incremental**
- Migrate one domain per sprint (buttons, notifications)
- Keep existing constants files as wrappers

**Phase 3 (Week 7): Tooling**
- Add VS Code Sherlock extension for inline editing
- Connect CI to fail on missing keys

Total estimated effort: <2 days per domain.

---

## 10. Risks and Mitigations

- **Build step added:** Mitigated by Vite plugin auto-regeneration
- **Learning curve:** Minimal – API is just functions
- **Ecosystem maturity:** Actively maintained, used in production by multiple teams【3095143372745893057†L211-L213】

---

## 11. Conclusion

Paraglide JS allows us to keep our DDF architecture exactly as designed, while gaining compile-time safety, smaller bundles, and true multilingual support. The migration is not a rewrite; it is a mechanical move of strings from TypeScript to JSON.

By adopting a compiler-based approach, we eliminate an entire class of runtime i18n errors and align with modern 2026 best practices for React applications.

**Next step:** Approve pilot migration of all components domain.
