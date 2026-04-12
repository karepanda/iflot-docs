# iFlot

iFlot is a platform for the operational and administrative layer of land logistics.
It connects daily transport execution to monthly financial close for mid-market
logistics companies operating in LATAM.

The problem it solves is specific: closing the loop from trip execution to billing
without requiring manual reconciliation outside the system.

## The operational flow

```mermaid
flowchart LR
    Guide[Cargo Guide]
    Trip[Trip Execution]
    Close[Operational Close]
    Billing[Pre-invoice and Billing]
    Settlement[Settlement and Reporting]

    Guide --> Trip --> Close --> Billing --> Settlement
```

## What iFlot replaces

Most logistics companies in this segment manage their operation across legacy
systems, spreadsheets, and manual processes. This creates billing delays, limited
traceability, and no clear audit trail from cargo to invoice.

iFlot is designed to replace that fragmented layer with a single, integrated
platform covering cargo documentation, trip management, pre-billing, and
operational reporting.

## Who it is for

Companies operating 50 to 150 vehicles in ground logistics, where existing
alternatives either cover fleet assets or location tracking — but not cargo
documentation, operational closing, or integrated billing.

## What you will find here

- [Product overview](overview/product-overview.md) — what iFlot does and why
- [Problem statement](overview/problem-statement.md) — the operational gap it addresses
- [Architecture](architecture/index.md) — technical structure and decisions
- [ADR](adr/index.md) — architecture decision records
- [Domain](domain/index.md) — business concepts and language
- [Engineering](engineering/index.md) — standards and implementation guidelines
- [Design](design/index.md) — UX context and Figma references
- [Onboarding](onboarding/index.md) — how to get started

## Current status

Discovery and technical foundation phase. Active work on domain validation,
architecture definition, and access control module.