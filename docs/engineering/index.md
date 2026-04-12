# Engineering

This section contains engineering guidelines, technical conventions, and
implementation standards for iFlot.

## Purpose

Engineering documentation exists to make decisions explicit, reduce friction
for new contributors, and ensure consistency across repositories as the team
grows.

Guidelines here are not bureaucracy. Each one exists because the absence of
a clear convention creates ambiguity that slows delivery or produces
inconsistent results.

## Repositories

| Repository | Stack | Purpose |
|---|---|---|
| `iflot-access` | Java 21, Spring Boot, PostgreSQL | Access control module |
| `iflot-api` | Java 21, Spring Boot, PostgreSQL | Backend core |
| `iflot-web` | React 19, Vite, TypeScript | Frontend |
| `iflot-docs` | MkDocs, Material theme | Documentation |

## Backend conventions

**Language and framework.** Java 21 with Spring Boot. Three-layer architecture:
Controller, Service, Repository. No hexagonal architecture, no additional use
case layers. Keep it simple and maintainable.

**Database.** PostgreSQL. Schema changes through migrations only — never direct
alterations to a running database. Every table is tenant-aware from the start.

**Security.** Spring Security with role-based access control and permission-level
authorities. Roles for coarse grouping, permissions as granted authorities for
fine-grained endpoint and method protection.

**State transitions.** State changes are domain events with enforced
preconditions, not field updates. A transition that cannot complete must leave
the record in its prior valid state and produce an explicit error. Silent invalid
states are not acceptable.

**API versioning.** All endpoints are versioned from day one under `/api/v1/`.

## Frontend conventions

**Stack.** React 19, Vite, TypeScript, TanStack Query, React Router, shadcn/ui.
See [ADR-002](../adr/ADR-002-frontend-framework-selection.md) for the rationale.

**State management.** Server state is managed through TanStack Query. Local UI
state lives in component state. Global client state is kept minimal.

**Testing.** Vitest for unit and integration tests, React Testing Library for
component behavior, MSW for API mocking, Playwright for end-to-end critical
flows. Test behavior, not implementation details.

**Suggested folder structure.** The following is a starting point, not a strict
constraint. The frontend lead and team can evolve it as needed.

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

## Diagram guidelines

Use Mermaid for lightweight technical and functional diagrams that need to
evolve alongside the documentation. Mermaid renders natively in GitHub Markdown,
MkDocs, and most modern documentation tools.

Use Figma or exported images when the diagram requires strong visual
presentation or design-level control.

**When to use Mermaid:**
- flowcharts and process flows
- sequence diagrams
- lifecycle state diagrams
- system context and container diagrams
- simple module relationship maps

**When to use Figma or images:**
- UI mockups and wireframes
- diagrams intended for external or commercial communication
- anything where visual design matters more than editability

## Documentation conventions

- All documentation is written in American English
- Keep pages short and focused on one topic
- Prefer prose over bullet lists for explanations
- Use bullet lists only for enumerable items where order or parallelism matters
- Every section has a named owner in `CODEOWNERS`
- Decisions go in ADRs, not in inline comments or chat
- Figma is the single source of truth for UI design

## Branching and contribution

To be defined as the team workflow stabilizes. This section will be updated
with branching conventions, pull request requirements, and review expectations
once the first delivery increment is underway.

## Current status

Engineering guidelines will grow incrementally as the team starts delivering
and real conventions emerge from practice. What is documented here reflects
decisions already made. What is not yet documented is intentionally deferred
until it is needed.