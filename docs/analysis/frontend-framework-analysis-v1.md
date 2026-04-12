# Frontend Framework Evaluation — Original Analysis (2025–2030)

---

**Document type:** Technical analysis — original input
**Author:** Frontend Lead
**Date:** April 2026
**Status:** Superseded by ADR-002

This document was produced by the frontend lead as the initial framework
evaluation. Its technical analysis on reactivity models, benchmarks, and
ecosystem trends was used as input for the decision process. The framework
recommendation in this document was revised after incorporating additional
constraints around delivery risk, hiring, and junior employability.

See:
- [Architecture Lead evaluation](frontend-framework-evaluation.md)
- [ADR-002 — Frontend Framework Selection](../adr/ADR-002-frontend-framework-selection.md)

---

## Executive Index

This document presents a comprehensive technical analysis for frontend framework
selection, evaluating 12 critical dimensions using data from multiple sources:
official benchmarks (js-framework-benchmark), international surveys (State of JS
2025, Stack Overflow 2025), ecosystem metrics, and in-depth architectural analysis.

---

## 1. Performance Analysis: Objective Benchmarks

### 1.1 js-framework-benchmark Methodology

The official [js-framework-benchmark](https://github.com/krausest/js-framework-benchmark)
measures fundamental operations:

- Create 1,000 rows
- Replace all rows
- Partial update (every 10th row in a table of 10,000)
- Select row
- Swap 2 rows
- Remove row
- Create 10,000 rows
- Append 1,000 to a table of 10,000
- Clear a table with 10,000 rows

**Evaluated metrics include:**
- DOM operation duration
- Memory consumption
- Lighthouse metrics: script startup time, main thread work, total byte weight

> Starting from Chrome 118, a weighted geometric mean is used to calculate the
> overall score, with adjusted CPU throttling factors and refined measurement.

### 1.2 Consolidated Results 2025

#### Absolute Performance Leaders

Solid.js consistently leads speed benchmarks with fine-grained updates that
eliminate Virtual DOM overhead, followed closely by Svelte.

**Vue's Vapor Mode** demonstrated up to **12x faster** performance than vanilla
Vue when creating 1,000 rows, with clear advantages in updates and swaps
touching multiple DOM nodes.

#### Framework-Specific Metrics

| Framework | Bundle Size Gzipped | Memory Overhead | DOM Update Speed | Startup Time |
|-----------|---------------------|-----------------|------------------|--------------|
| Solid.js  | ~1.6kb              | Minimal         | **Leader**       | Excellent    |
| Svelte 5  | ~1.6kb              | **Minimal**     | **Leader**       | Excellent    |
| Vue 3     | ~20kb               | Moderate        | Very good        | Good         |
| React 19  | ~40kb               | High            | Good*            | Average      |

\* *With React Compiler, performance improves but VDOM overhead remains*

### 1.3 Real-World Performance

> **Critical Finding:** In tests with heavy main-thread computation, React and
> Angular saw framerates drop to 30 FPS or 0 FPS causing visible freezing, while
> worker-based architectures maintained a perfect 60 FPS.

Bit.dev research shows that **poor performance can lead to a 30–60% increase in
scripting time**, particularly in applications with deep component trees or
shared context.

---

## 2. Reactivity: Fundamental Architectures

### 2.1 The Re-rendering Problem in React

#### Nature of the Problem

In React, when a parent component's state changes, **all its children re-render
by default**, even if their props have not changed.

> Unnecessary re-renders are not the problem by themselves — React is fast enough
> to handle them without users noticing. However, if re-renders occur very
> frequently or in very heavy components, this can lead to a laggy user
> experience, visible delays on every interaction, or even a completely
> unresponsive app.

#### Documented Causes

1. **State changes in parent components**
2. **Passing non-primitive props** (objects, arrays, functions always create new
   references during re-render)
3. **Updating context** (all components consuming that context re-render)

> Every function is a distinct JavaScript object, so React sees the prop change
> and ensures the component updates. The problem is that the function changes
> every time, even if the counter value it references has not changed.

#### Solutions Require Manual Discipline

Solutions include:

- `React.memo` to wrap functional components
- `useCallback` to memoize callback functions
- `useMemo` to memoize expensive calculations
- Memo usage is at the developer's discretion, based on trial and error

**React Compiler (React 19+)** automatically memoizes components and values,
essentially applying `useMemo` and `useCallback` everywhere it is safe to do so.

⚠️ **Limitation:** It will not save you from architectural problems such as
overly broad context providers or massive component trees.

### 2.2 Fine-Grained Reactivity: The Architectural Solution

#### Definition and Advantages

Fine-grained rendering allows **direct updates without traversing the entire
component tree** — Svelte, Vue, and Solid have adopted this model.

> Well-executed fine-grained rendering has a much higher performance ceiling.

#### Implementations by Framework

##### Solid.js

- **No VDOM, no component re-renders**
- Only the specific DOM nodes that depend on an updated signal are modified
- Solid components are **factory functions** — they run once to establish
  subscriptions, then never run again
- Updates occur at the signal level, directly mutating subscribed DOM nodes

##### Svelte 5 Runes

```javascript
// Svelte 5 with Runes
let count = $state(0)
let doubled = $derived(count * 2)

$effect(() => {
  console.log(`Count is now: ${count}`)
})
```

- `$state`, `$derived`, `$effect` — explicit fine-grained reactivity primitives
- Rivals Solid.js while maintaining Svelte's elegant syntax
- Achieves fine-grained updates by completely skipping the "re-run everything" step

> With fine-grained rendering, all props simply work that way. By default you can
> declare data at the top of your app, pass it through 10 components, and get
> exactly the same results.

##### Vue 3 Composition API + Vapor Mode (experimental beta)

Vue uses Proxies in its reactivity system with read-based auto-tracking,
similar to Solid.js.

### 2.3 Virtual DOM: Quantified Overhead

#### The "VDOM is Faster" Myth

> **The Virtual DOM is not a feature. It is a means to an end**, the end being
> declarative state-based UI development. **Diffing is not free**. You cannot
> apply changes to the real DOM without first comparing the new Virtual DOM with
> the previous snapshot.

**Virtual DOM operations are ADDITIONAL** to the eventual real DOM operations.
Of three steps (enumerate attributes, descend into the element), only the third
has value in most updates since the basic app structure has not changed.

#### Specific Costs

Classic Virtual DOM creates:
- Additional computational effort during DOM diffing
- Additional memory consumption through Virtual Node structures

> With growing requirements for load time, energy efficiency, and interactivity,
> it became clear: **the VDOM is no longer the fastest path to the goal**.

---

## 3. 2025 Modernization: What Frameworks Are Building

### 3.1 Vue Vapor Mode: Complete VDOM Elimination

#### Current State

**Vapor mode is available in Vue 3.6 experimental beta**. It will be more stable
in future versions, and its beta will likely be released once the new version of
Vite is launched.

#### Architecture

Instead of generating a generic render function, the **Vue-Vapor compiler
analyzes the component at build time**, resulting in:

- Reactivity optimized and wired directly into DOM manipulation
- Pre-analyzed conditional rendering paths
- Optimized loops
- Efficient event handlers

```javascript
// Vue Vapor Mode (Direct DOM approach)
<script setup>
import { ref } from 'vue/vapor';
const count = ref(0);
// Vapor Mode knows EXACTLY which DOM node to update
// When count changes: updates ONLY the text node of <h1>
// No Virtual DOM, no diff algorithm, no neighboring component re-renders
</script>

<template>
  <div>
    <h1>Count: {{ count }}</h1>
    <button @click="count++">Increment</button>
    <ExpensiveComponent :data="someData" /> <!-- Does NOT re-render -->
  </div>
</template>
```

#### Preliminary Benchmarks

| Operation | Vapor Improvement |
|-----------|-------------------|
| **Row creation** (1,000) | Up to **12x faster** |
| **Updates & Swaps** | Clear improvements |
| **Large set clearing** | Slight advantage |

#### Interoperability

Applications can benefit from Vapor performance advantages for **specific
sub-trees** while maintaining compatibility with existing virtual DOM components.

**The major challenge is compatibility**: "Because Vapor Mode is a completely new
runtime, making behavior consistent between Vapor Mode and other modes will be a
lot of work" — Evan You

### 3.2 Svelte 5 Runes: Signal Maturity

#### Architectural Evolution

Svelte 5 changed its reactivity architecture from **compiler-based to runtime
signals**.

> Svelte 5 operates without magic, only with explicit and powerful primitives.
> If you loved Svelte for its simplicity, you will love Svelte 5 for its
> predictability. The future of web UI is fine-grained reactivity, and Svelte
> is now a first-class citizen.

#### Documented Advantages

**Signals unlock fine-grained reactivity**, meaning changes to a value within a
large list do not need to invalidate all other members of the list.

**Performance improvements:**
- Bundles **15–30% smaller**
- Better tree-shaking
- **Prevents unnecessary re-renders**
- Smoother runtime performance

#### Unique Features

Official Svelte MCP server for AI and LLM integration — eliminates the need
for copy/pasting docs to generate valid Svelte 5 code.

### 3.3 React Compiler: Optimization Without Architectural Change

React Compiler (React 19+) typically delivers:
- **30–60% reduction** in unnecessary re-renders
- **20–40% improvement** in interaction latency

**Real value:** Prevents performance regressions as teams add features, since
optimization happens automatically.

#### Fundamental Limitation

> React with Compiler closes the performance gap for typical applications — but
> **still has conceptual overhead** (component re-renders, dependency arrays) that
> signal-based frameworks eliminate.

---

## 4. Developer Satisfaction: Statistical Data

### 4.1 State of JavaScript 2025

#### Satisfaction Rankings

**Stack Overflow 2025** (+49,000 developers):

| Framework | Admiration |
|-----------|------------|
| Svelte    | 62.4%      |
| React     | 52.1%      |
| Vue.js    | 50.9%      |
| Angular   | 44.7%      |

**State of JS 2022** (39,472 respondents):

| Framework | Satisfaction |
|-----------|--------------|
| Solid     | 90.87%       |
| Svelte    | 89.62%       |
| React     | 82.95%       |
| Vue       | 77.32%       |
| Angular   | 42.62%       |

> **Solid has maintained the highest satisfaction rating for five consecutive
> years (2021–2025)**, despite only ~10% usage. As the survey editors note:
> "the fact that it has had the highest satisfaction for five consecutive years
> should be enough for us to pay attention to what it is doing."

#### Meta-frameworks

**Astro leads** all meta-frameworks in developer satisfaction, maintaining a
**39 percentage point advantage** over Next.js.

### 4.2 Adoption Trends

**React:** First documented decline — 76.2% (2022) → 69.9% (2024), a **6.3%
decline** in "used and like."

**Svelte:** Sustained growth — **almost 50%** of developers mentioned Svelte as
the framework they **most wanted to learn** in the future.

> In surveys, React continues to dominate in usage, while Svelte dominates in
> love. **Developers get paid to write React — but enjoy writing Svelte**.

---

## 5. Ecosystem and Community: Comparative Analysis

### 5.1 Development Activity

#### Svelte/SvelteKit

Active releases with type safety improvements: type narrowing in `$app/types`,
native WebSockets, SSR-safe ID generation via `$props.id()`, and server-side
route resolution support. Active ecosystem with 5,700+ stars in popular projects.

#### Vue/Nuxt

Official roadmap: Nuxt 4 release around June 30, 2025; Nuxt 3 bug fixes for 6
months post-release; Vitest v3 January 2025; Pinia stable with no breaking changes.

### 5.2 Tools and Libraries

#### Svelte — UI Components

- **shadcn-svelte** (3k+ stars)
- **Skeleton** (design system powered by Tailwind)
- **svelte-ux** (components, actions, stores and utilities)
- **rokkit** (configurable and themeable UI library)

#### Modern Tooling

**Rolldown 1.0 beta** (December 2024): replacement for Rollup and esbuild,
at least 3x faster than other Rust bundlers.

---

## 6. Use Cases and Enterprise Adoption

### 6.1 Verified Production Use

#### Svelte — Enterprise Cases

| Company         | Implementation                         |
|-----------------|----------------------------------------|
| **NY Times**    | Interactive charts                     |
| **IKEA**        | Global site templates in SvelteKit     |
| **Spotify**     | Marketing pages and year-in-review     |
| **Gitpod**      | Collaborative development environments |
| **HuggingChat** | AI chat model interface                |

#### Vue — Verified Adoption

- **Alibaba:** Dynamic interfaces
- **Xiaomi:** Dynamic interfaces

---

## 7. Risk Analysis and Mitigation

### 7.1 Risks by Framework

#### React

| Risk | Description | Severity |
|------|-------------|----------|
| **Accumulated technical debt** | Re-renders, performance, complexity | High |
| **Unnecessary complexity** | Redux vs Zustand vs Context decision overload | Medium |

#### Svelte

| Risk | Description | Mitigation |
|------|-------------|------------|
| **Smaller ecosystem** | ~2.7M downloads/week vs React ~190M | Mature enough for medium apps |
| **Fewer specialized developers** | Steeper hiring curve | Gentle learning curve compensates |

#### Vue Vapor

| Risk | Description | Mitigation |
|------|-------------|------------|
| **Experimental technology** | Not all features fully supported | Interoperability with traditional Vue 3 |

---

## 8. Future Projection 2025–2030

**Fine-grained reactivity** has become the defining technical conversation in
frontend development. All major frameworks are converging toward it:

- **Svelte:** Rethinking reactivity with Runes
- **React:** Evolving toward compilation
- **Vue Vapor:** Eliminating the virtual DOM
- **Angular:** Moving to signals
- **Solid.js:** Pioneer in signals and surgical updates

> For over a decade, React's Virtual DOM was the mental model everyone copied.
> In 2026, that changed: **Solid.js proved that signals with surgical DOM
> updates outperform React's diffing by a significant margin**.

---

## 9. Technical Decision Matrix

### 9.1 Weighted Criteria for a Medium-Sized Application

| Criterion | Weight | Svelte 5 | Solid.js | Vue 3 | React 19 |
|-----------|--------|----------|----------|-------|----------|
| **Runtime Performance** | 20% | 9.5/10 | 10/10 | 8/10 | 6.5/10 |
| **Bundle Size** | 15% | 10/10 | 10/10 | 7/10 | 4/10 |
| **Developer Experience** | 18% | 9.5/10 | 8/10 | 8.5/10 | 6/10 |
| **Ecosystem/Libraries** | 12% | 7/10 | 6/10 | 8/10 | 10/10 |
| **Learning Curve** | 10% | 9/10 | 7/10 | 9/10 | 6/10 |
| **Active Modernization** | 10% | 10/10 | 9/10 | 9/10 | 7/10 |
| **Community/Support** | 8% | 8/10 | 7/10 | 8.5/10 | 10/10 |
| **Enterprise Adoption** | 7% | 7.5/10 | 6/10 | 8/10 | 10/10 |
| **TOTAL SCORE** | 100% | **8.9** | **8.2** | **8.2** | **7.2** |

---

## 10. Final Recommendation

**Primary: Svelte 5 + SvelteKit** — best performance/DX/ecosystem balance,
positive trajectory, verified production cases, superior ROI for medium projects.

**Alternative: Solid.js + SolidStart** — exceptional performance, minimal
learning curve for React developers, ultra-light bundle.

**Not recommended: React (for greenfield)** — architectural overhead, growing
complexity, documented negative trend.

**Viable: Vue 3 + Vapor** — wait for stable release in Q4 2026.

### Projected Impact

#### Svelte 5 vs React:

| Metric | Improvement vs React |
|--------|----------------------|
| Development Speed | 25–40% faster |
| Bundle Size | 60–70% smaller |
| Runtime Performance | 30–50% better |
| Maintenance Cost | Reduced |

#### Solid.js vs React:

| Metric | Improvement vs React |
|--------|----------------------|
| Development Speed | 20–35% faster |
| Bundle Size | 80–85% smaller |
| Runtime Performance | 50–70% better |
| Maintenance Cost | Reduced |

---

## References

- [js-framework-benchmark](https://krausest.github.io/js-framework-benchmark/)
- [State of JavaScript 2025](https://2025.stateofjs.com/)
- Stack Overflow Developer Survey 2025
- [Vue Vapor Mode Documentation](https://github.com/vuejs/vue-vapor)
- [Svelte 5 Runes Documentation](https://svelte.dev/docs/svelte/runes)
- [Solid.js Documentation](https://www.solidjs.com/)
- [React Compiler Documentation](https://react.dev/learn/react-compiler)

---

## Appendix: Glossary

- **Fine-grained reactivity:** Updates only the specific DOM nodes affected by a change
- **Virtual DOM (VDOM):** In-memory representation of the real DOM
- **Signals:** Reactivity primitives that allow automatic dependency tracking
- **Runes:** Svelte 5 reactivity system based on signals
- **Vapor Mode:** Vue compilation mode that eliminates the Virtual DOM
- **SSR:** Server-Side Rendering
- **SSG:** Static Site Generation

---

*This document is an independent technical analysis based on public data,
official benchmarks, and verifiable studies. It is not sponsored by any
framework or company.*