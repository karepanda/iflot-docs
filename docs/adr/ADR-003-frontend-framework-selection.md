# ADR-002 — Frontend Framework Selection for iFlot 2026

**Status:** Accepted
**Date:** April 2026
**Authors:** Architecture Lead
**Audience:** Core Team (Backend, Frontend, Product)

---

## 1. Context

We evaluated multiple frontend frameworks — React, Svelte, Solid.js, Vue — based on a detailed technical report produced by the frontend team.

That report correctly identifies key trends: the shift toward fine-grained reactivity, performance advantages of signal-based architectures, and the limitations of Virtual DOM approaches at scale.

The decision must also weigh delivery speed, maintainability, hiring and onboarding constraints, team scalability, and junior employability — the explicit goal of this initiative.

This ADR defines the final decision combining technical, operational, and market realities.

---

## 2. Key Observations

### 2.1 Technical direction

Signal-based frameworks (Svelte, Solid) offer cleaner reactivity and better raw performance. React introduces architectural overhead — re-renders, memoization discipline. Vue is evolving toward similar patterns via Vapor Mode, but that runtime is still experimental.

**Conclusion:** The ecosystem is converging toward fine-grained reactivity. React will follow. The gap is narrowing.

---

### 2.2 Benchmark limitations

Microbenchmarks measure isolated DOM operations. They do not reflect real applications with auth, forms, tables, API orchestration, routing, and error handling running together.

**Conclusion:** Benchmarks inform trade-offs. They do not decide architecture.

---

### 2.3 Ecosystem and maturity

React provides a mature UI ecosystem, battle-tested libraries, and broad community support. Alternatives offer fewer options with less production history at scale.

**Conclusion:** Ecosystem maturity directly impacts delivery reliability.

---

### 2.4 Hiring and maintainability

A system must be maintainable by people we can realistically hire.

| Framework | Talent pool |
|---|---|
| React | Large |
| Vue | Moderate |
| Svelte | Small |
| Solid.js | Very limited |

**Conclusion:** Hiring reality is a primary architectural constraint, not a secondary one.

---

### 2.5 Junior employability

**Key principle:**

> A junior developer does not enter the market by using the best framework — but by using the most demanded one.

Active junior frontend listings in Spain and Italy (April 2026):

| Framework | Spain (approx.) | Italy (approx.) | Source |
|---|---|---|---|
| React | ~598 | 720+ | LinkedIn ES / Glassdoor IT |
| Angular | ~360 | ~400 | Derived from global proportions |
| Vue | ~105 | ~100 | Derived from global proportions |
| Svelte | <10 | 6 | Indeed ES / Glassdoor IT |
| Solid.js | <5 | <3 | No direct data |

React dominates junior demand in both target markets by a significant margin.

**Conclusion:** React maximizes employability for Karelys and Julio. The framework with the best DX is not the framework that gets juniors hired.

---

## 3. Impact on Project Execution

### 3.1 Delivery risk

| Framework | Risk |
|---|---|
| React | Low |
| Vue | Low-Medium |
| Svelte | Medium |
| Solid.js | Medium-High |

---

### 3.2 Maintainability

React offers predictable patterns, strong documentation, and a lower onboarding curve for replacements and new team members.

---

### 3.3 Bus factor

| Framework | Risk |
|---|---|
| React | Low |
| Vue | Low-Medium |
| Svelte | Medium |
| Solid.js | High |

---

### 3.4 Conclusion

React provides the lowest overall execution risk across delivery, maintainability, and team continuity.

---

## 4. Decision

### 4.1 Selected stack

| Layer | Tool |
|---|---|
| Framework | React 19 |
| Build | Vite |
| Language | TypeScript |
| Data fetching | TanStack Query |
| Routing | React Router |
| UI components | shadcn/ui |

---

### 4.2 Training strategy

- **Primary stack:** React — full depth, production-grade usage
- **Conceptual exposure:** Svelte 5 and Solid.js — as reference points for understanding fine-grained reactivity, not as deliverable stack

---

### 4.3 Rationale

This stack optimizes for delivery speed, maintainability, hiring flexibility, team scalability, and junior employability simultaneously. No other evaluated option performs as well across all five dimensions.

---

## 5. Testing Strategy

### 5.1 Tools

| Tool | Purpose |
|---|---|
| Vitest | Unit and component testing |
| React Testing Library | Component behavior |
| user-event | User interaction simulation |
| MSW | Network-level mocking |
| Playwright | End-to-end flows |

---

### 5.2 Test levels and distribution

| Level | Scope | Target % |
|---|---|---|
| Unit | Pure logic | 20–30% |
| Component | Primary layer | 60–70% (combined with integration) |
| Integration | Page/system behavior | Included above |
| E2E | Critical flows only | ~10% |

---

### 5.3 Principles

- Test behavior, not implementation details.
- Keep tests fast and deterministic.
- Mock at the network level via MSW, not at the module level.
- Avoid over-engineering the test suite — coverage is a byproduct of good tests, not the goal.

---

## 6. Proposed Frontend Structure

The following structure is a starting point, not a strict constraint. The frontend lead and team can evolve it as the product grows.

```text
src/
  app/
    router/
    providers/
  pages/
  features/
  components/
    ui/
  hooks/
  services/
    api/
  lib/
  styles/
  types/
```

**Structure intent:**

- `app/` — application wiring: routing, global providers, entry point
- `pages/` — route-level screens
- `features/` — self-contained business capabilities
- `components/ui/` — reusable UI primitives (shadcn/ui wrappers and extensions)
- `services/api/` — backend communication layer
- `lib/` — shared utilities with no framework dependency
- `types/` — shared TypeScript types and interfaces

---

## 7. Non-Goals

The following are explicitly out of scope for this decision:

- Evaluating alternative frameworks for initial implementation
- Mixing multiple frameworks in the same codebase
- Adopting experimental runtimes (Vue Vapor, Solid Start in beta)
- Optimizing for theoretical performance over delivery
- Selecting tools based on personal or team preference alone

Reopening this decision requires new evidence — not a re-evaluation of the same data.

---

## 8. Consequences

**Positive:**

- Lower delivery risk across all execution phases
- Easier hiring and onboarding for current and future team members
- Strong alignment with junior job market in Spain and Italy
- Predictable maintenance pattern as the codebase grows

**Negative:**

- Some architectural overhead compared to signal-based frameworks
- Suboptimal theoretical performance relative to Svelte or Solid.js
- Junior developers miss hands-on experience with newer reactivity models (mitigated by conceptual exposure in training)

---

## 9. Final Statement

This decision prioritizes delivery, maintainability, team scalability, and employability over theoretical optimality.

The goal is not to use the most advanced framework. The goal is to maximize the probability of success in real-world conditions — for the product and for the people building it.

---

## 10. Supporting Analysis

Full reasoning, salary data, job market benchmarking, and framework comparison are documented in:

```
/docs/analysis/frontend-framework-evaluation.md
```

The ADR defines the decision. The analysis document provides the evidence.

---

## 11. Future Re-evaluation

This ADR should be revisited if any of the following conditions change:

- Hiring conditions shift materially in the target markets
- Team composition changes in ways that alter the bus factor assumptions
- Product requirements evolve beyond what the selected stack handles well
- Alternative frameworks reach measurable junior demand in the Spanish and Italian job markets
- React's adoption trajectory reverses significantly (tracked via State of JS and Stack Overflow annual surveys)

---

*End of ADR*