# C4 Model

This section documents the C4 model for iFlot 2026.

The goal of these diagrams is to describe the system progressively, from its
external context to its internal technical structure, while keeping the model
aligned with the current discovery phase.

## Current status

The C4 model is still evolving.

The diagrams published here reflect the current architectural direction, but
some domain boundaries and responsibilities remain subject to validation through
discovery with legacy customers.

This means the diagrams should be read as **directionally correct**, but not yet
as a frozen target-state design.

## Scope of the current diagrams

The following levels are currently documented:

- **System Context (C1)** — shows iFlot as a system, the main user roles, and
  the external systems it interacts with.
- **Container Diagram (C2)** — shows the main deployable building blocks of the
  platform and the high-level responsibilities of the backend.
- **Component view (internal to the Core API)** — currently represented inside
  the container model to show the first internal module split of the backend.

## Architectural interpretation

These diagrams should be interpreted with the following rules in mind:

- Bounded contexts do not imply one repository per context.
- The current backend strategy is a **consolidated backend repository** with
  explicit domain boundaries inside the codebase.
- The backend may evolve into multiple deployable services over time, but that
  is not the starting assumption.
- Tenant isolation is a foundational architectural constraint, not an optional
  implementation detail.
- Access Control is the first delivery increment, but it is part of a broader
  platform direction.

## Relationship with ADRs

The C4 diagrams describe structure. ADRs explain why key decisions were made.

Relevant ADRs include:

- [ADR-001 — Product and System Direction](../../adr/ADR-001-product-and-system-direction.md)
- [ADR-002 — Architecture for iFlot Access](../../adr/ADR-002-architecture-iflot-access.md)
- [ADR-003 — Frontend Framework Selection](../../adr/ADR-003-frontend-framework-selection.md)

## Source files

The Structurizr DSL source files for these diagrams are stored in:

- `diagrams/structurizr/`

## Available diagrams

- [System Context](system-context.md)
- [Container Diagram](container-diagram.md)