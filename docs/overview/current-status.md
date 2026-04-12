# Current Status

## Project stage

iFlot is currently in an early-stage phase focused on discovery and building the technical foundation.

There is no production-ready version of the new platform yet. The current work
is centered on understanding the problem in depth and defining the core of the
system before any implementation begins.

## What exists today

The project is not starting from zero.

There is a legacy system that has been used in real production conditions within
the Venezuelan transport market. That system already supported core operational
flows including trip registration, cargo guide management, and basic linkage
between operations and billing.

Although limited, it provides direct evidence of how the problem manifests in
practice and what a solution in this domain must get right from day one.

## What has been validated

The following points are grounded in real operational usage, not assumption:

- billing depends on the lifecycle state of cargo guides
- incorrect or incomplete operational states lead directly to billing failures
- month-end close requires manual reconciliation between systems
- critical processes depend on specific individuals rather than on the system
- the connection between execution and billing is implicit in current tools,
  which makes errors invisible until they surface at billing time

## What is still under validation

The current discovery phase is focused on:

- how consistent these patterns are across different operators
- variations in workflows between companies
- how cargo guides, trips, and billing are actually managed in detail
- which parts of the process can be standardized without breaking real operations

Further validation will come from direct conversations and observation of
additional operators in the target segment.

## Current priorities

The immediate focus of the project is:

- refining the domain understanding based on real-world operations
- defining the core domain model
- establishing access control as the first system capability
- designing the operational flow that connects execution to billing

The goal is to build a solid foundation before expanding scope.

## What has not been defined yet

At this stage, the following are intentionally not finalized:

- a detailed product roadmap
- a full feature set
- final architecture decisions beyond the core domain
- scaling and deployment strategies

These will emerge from validated needs, not from speculative design.

## How decisions are made

Every decision in iFlot is driven by evidence from the legacy system, direct
input from operators, and consistency with the core problem definition. The project prioritizes correctness of the core model over speed of feature delivery.

## Expected direction

As discovery progresses, the project is expected to move toward a minimal
operational core covering cargo guide lifecycle, trip management, and billing
generation. From there, each expansion will be grounded in real operational
feedback rather than speculative design.

No timeline is committed at this stage. The pace is set by the quality of
what is validated, not by a fixed delivery schedule.