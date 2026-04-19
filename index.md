# iFlot

iFlot is a platform for the operational and administrative layer of land logistics.

It connects daily transport execution with billing and financial close,
ensuring that what is executed operationally is consistently reflected in
what is invoiced.

---

## The problem

Logistics operators in this segment work across fragmented systems,
manual processes, and disconnected data sources.

This creates a structural gap between execution and billing.

→ [Read the full problem statement](overview/problem-statement.md)

---

## The solution

iFlot introduces a unified operational layer that enforces the connection between:

- cargo guide lifecycle
- trip execution
- operational close
- billing eligibility

→ [Read the product overview](overview/product-overview.md)

---

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

---

## Documentation structure

### Product

- [Overview](overview/product-overview.md)
- [Problem Statement](overview/problem-statement.md)
- [Target Clients](overview/target-clients.md)
- [Value Proposition](overview/value-proposition.md)
- [Current Status](overview/current-status.md)

### Architecture

- [Architecture Overview](architecture/index.md)
- [C4 Model](analysis/c4/index.md)

### Engineering

- [Engineering Overview](engineering/index.md)
- [Observability](engineering/observability/index.md)

### Domain

- [Domain Overview](domain/index.md)

### Design

- [Design Overview](design/index.md)
- [Figma Links](design/figma-links.md)

### ADR

- [Architecture Decisions](adr/index.md)

### Onboarding

- [Getting Started](onboarding/index.md)

---

## Current status

iFlot is currently in a **discovery and technical foundation phase**.

→ [See full status](overview/current-status.md)
