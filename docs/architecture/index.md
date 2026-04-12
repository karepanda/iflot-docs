# Architecture

This section documents the technical architecture of iFlot, including system
structure, bounded context boundaries, and major technical decisions.

## Relationship with ADRs

Architecture documents describe structure. ADRs capture decisions.

The two are complementary. When a diagram or document here reflects a specific
decision, it links to the corresponding ADR. When an ADR has structural
implications, it links to the relevant architecture document.

## Current phase

The architecture is in its foundation phase. Core domain modeling and bounded
context definition are in progress and depend on discovery findings being
validated with legacy customers.

No final schema, API contract, or service boundary should be considered stable
until the domain model is confirmed through discovery.

See [Discovery](../discovery/index.md) for the open questions that gate deeper
architecture work.

## Foundational constraints

The following constraints are commitments that hold regardless of what discovery
confirms or changes.

**Tenant-aware data model from day one.** Every operational record is associated
with a tenant at the data model level. Cross-tenant access is architecturally
prevented, not enforced only by application logic.

**Wedge strategy — no big-bang rebuild.** The product is deliverable in
increments. No capability is blocked on the completion of all others unless a
direct domain dependency exists. Wedge order: access control → operational core
→ billing → reporting → differentiators.

**Domain clarity before stack decisions.** No schema design or API contract is
finalized before the core domain model is validated through discovery.

## System overview

iFlot occupies the operational and administrative layer between transport
execution and financial close. It does not replace fleet management or
telematics systems. It connects cargo documentation, trip management, billing
generation, and operational reporting in a single traceable flow.

## Diagrams

C4 model diagrams will be added here as the domain model is validated and
bounded context boundaries are confirmed.

Diagrams in this section follow the Mermaid-first approach for documentation
that needs to evolve with the system. Static exports from Figma or external
tools are used only when strong visual presentation is required.

See [Diagram Guidelines](../engineering/index.md) for conventions.

## Bounded contexts

Bounded context definitions are pending discovery validation. The following
are working hypotheses, not confirmed boundaries.

**Access Control.** User identity, authentication, roles, permissions, and
privileged action audit. This is the first delivery increment and is being
implemented in `iflot-access`.

**Transport Operations.** Cargo guide lifecycle, trip creation and close,
tariff resolution, payment method enforcement, and expense registration.
This is the core of the operational model.

**Billing.** Pre-invoice generation from operationally closed guides, receipt
and cancellation management, and pre-cancellation as a controlled document.
Billing depends on operational state and cannot be finalized until the guide
and trip model is confirmed.

**Reporting.** Operational and billing reports with filters, grouping, and
period totals. Treated as domain outputs derived from committed data, not as
queries bolted on after the fact.

**Master Data.** Vehicles, drivers, clients, and routes. No operation can
exist without valid references to these entities.

**Maintenance.** Vehicle service orders and preventive scheduling. Confirmed
as a real business need but not a dependency for the initial delivery increment.

## Repository structure

| Repository | Purpose |
|---|---|
| `iflot-access` | Access control module — first delivery increment |
| `iflot-api` | Backend core — transport operations and billing |
| `iflot-web` | Frontend — React 19 + Vite + TypeScript |
| `iflot-docs` | This documentation repository |