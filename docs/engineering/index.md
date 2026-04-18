# Engineering

This section contains engineering guidelines, technical conventions, and
implementation standards for iFlot.

## Purpose

Engineering documentation exists to make decisions explicit, reduce friction
for new contributors, and ensure consistency across repositories as the team
grows.

Guidelines here are not bureaucracy. Each one exists because the absence of
a clear convention creates ambiguity, slows delivery, or produces inconsistent
results across the product.

## Scope

This section focuses on **how we implement** the system, not on **what we decide
to build**.

- **Architectural decisions** live in ADRs (`docs/adr`)
- **Engineering standards** live here

Typical topics include:

- observability standards
- context propagation
- logging conventions
- metric naming and tagging
- SLO implementation guidance
- cross-repository technical rules

## Repositories

| Repository | Stack | Purpose |
|---|---|---|
| `iflot-api` | Java 21, Spring Boot, PostgreSQL | Backend application |
| `iflot-web` | React 19, Vite, TypeScript | Frontend |
| `iflot-docs` | MkDocs, Material theme | Documentation |

## Backend conventions

**Language and framework.** Java 21 with Spring Boot.

**Architecture.** Architecture is decided per module based on domain complexity.
Support modules may use a simple layered approach. Core domains may use stronger
boundaries when justified. See ADRs for details.

**Database.** PostgreSQL. Schema changes only through migrations. Every table
is tenant-aware from the start.

**Security.** Spring Security with role-based access control and
permission-level authorities.

**State transitions.** State changes are explicit business transitions with
enforced preconditions. Invalid transitions must fail explicitly and must not
leave inconsistent data.

**API versioning.** All endpoints are versioned under `/api/v1/`.

## Frontend conventions

**Stack.** React 19, Vite, TypeScript, TanStack Query, React Router, shadcn/ui.

**State management.** Server state is handled with TanStack Query. Local UI
state remains in components. Global client state is kept minimal.

**Testing.** Vitest, React Testing Library, MSW, and Playwright. Focus on
behavior, not implementation details.

## Observability and operational standards

Observability is part of engineering, not an afterthought.

iFlot uses a unified model across frontend and backend covering structured
logs, distributed tracing, metrics, context propagation, and flow-level SLOs.

Implementation standards are defined across the following documents:

| Document | Scope |
|---|---|
| [Observability index](./observability/index.md) | Overview and principles |
| [Context propagation standard](./observability/context-propagation-standard.md) | `trace_id`, `operation_id`, `X-Correlation-ID` — how they are generated, propagated, and used across frontend, backend, and async boundaries |
| [Log schema](./observability/log-schema.md) | Structured log format, required and recommended fields, MDC mapping, sensitive data policy |
| [Metric catalog](./observability/metric-catalog.md) | Metric types, naming conventions, tagging rules, platform and flow-level metrics, frontend metrics |
| [Flow SLO catalog](./observability/flow-slo-catalog.md) | SLO definitions per business flow, SLI formulas, error budgets, burn rate alerts |

These standards apply to all repositories. Start with the observability index
if you are new to the model.

## Diagram guidelines

Use Mermaid for diagrams that evolve with the documentation.

Use Figma or images for UI and presentation-heavy diagrams.

## Documentation conventions

- American English only
- One topic per page
- Prefer clear prose over excessive bullet lists
- Decisions go in ADRs, not scattered across docs
- Figma is the source of truth for UI

## Current status

Engineering standards will evolve as the system and team mature.

What is documented here reflects current decisions. Missing topics are
intentionally deferred until needed.