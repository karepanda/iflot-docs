# ADR-001 — iFlot Product and System Direction

**Date:** 2026-04-11
**Authors:** Architecture Lead

---

## Context

iFlot is being developed to address a structural problem observed in mid-market
logistics operations in LATAM: the lack of a reliable connection between
operational execution and billing.

Existing systems fragment this flow:

- trips are managed separately from cargo guides
- cargo guides are not consistently linked to billing
- billing depends on manual reconciliation across sources
- errors surface late, typically at month-end

The consequence is not just inefficiency, but lack of operational integrity.

A legacy system has been used in real production conditions and provides direct
evidence of how this problem manifests and why it persists.

The project is currently in an early-stage discovery phase, with no committed
roadmap and a strong emphasis on validating the domain before implementing
features.

---

## Decision

iFlot will be designed as a system that enforces the connection between
operational execution and billing as a core invariant.

The system will:

- treat billing eligibility as a direct consequence of operational state
- make the lifecycle of cargo guides explicit and enforceable
- require a consistent linkage between cargo guides and trips
- ensure that financial records derive from operationally valid data
- eliminate the need for external reconciliation as part of normal operation

Rather than building isolated features, iFlot will be structured around a core
operational flow where execution, state, and billing form a continuous and
traceable process.

---

## Architectural Direction

**Domain-driven core.** The core of the system will be defined by the domain
model, not by UI or API requirements. Entities such as cargo guide, trip,
operational state, and billing record will be modeled explicitly and their
relationships enforced by the system.

**State as a first-class concept.** Operational state will not be implicit.
The lifecycle of cargo guides and trips will be explicitly defined, validated
at each transition, and used as the source of truth for billing eligibility.

**Single source of truth for billing.** Billing will not be constructed from
external aggregation. It will be derived directly from operational data that
has already been validated by the system.

**Elimination of reconciliation as a process.** Manual reconciliation is treated
as a symptom of a broken model. The system will be designed so that
reconciliation is not required under normal operation.

**Incremental delivery of the core.** The system will not be built as a
full-featured platform from the start. It will evolve through a minimal
operational core, validation with real users, and iterative expansion based
on observed usage.

---

## Consequences

### Positive

- strong alignment between product and architecture
- reduced risk of building features that do not solve the core problem
- high consistency between operational and financial data
- clear foundation for scaling the system over time
- improved trust in system outputs by operators

### Negative

- slower initial delivery compared to feature-driven approaches
- higher upfront effort in domain modeling
- need for continuous validation with real operators
- potential rework as assumptions are challenged during discovery

---

## Core Invariant

This decision defines the direction of the system, not its final architecture.
Technology choices, infrastructure, and implementation details will follow this
direction and not precede it.

The invariant that must hold across all future decisions is:

> Billing must be a direct consequence of operational state.

Any future decision that contradicts this invariant should be explicitly
challenged before it is accepted.