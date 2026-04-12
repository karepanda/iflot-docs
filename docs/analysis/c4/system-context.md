# System Context

The System Context diagram shows iFlot 2026 as a single platform in relation to
its primary users and external systems.

At this level, the goal is not to describe internal modules or implementation
details. The purpose is to define the system boundary clearly and show which
actors and external dependencies matter for the platform.

## Purpose

iFlot 2026 operates in the administrative and operational layer of terrestrial
fleet and logistics management.

It supports business flows such as:

- trip management
- cargo guide control
- freight and settlement management
- billing-related processes
- tenant-level access administration

The platform does not aim to replace telematics or specialized fleet-tracking
systems. Instead, it connects operational execution, business control, and
financial traceability in a single workflow.

## Primary users

### Dispatcher / Traffic Operator
Uses iFlot to plan trips, assign vehicles and drivers, and monitor transport
operations.

### Billing Operator
Uses iFlot to manage freight-related information, cargo guides, settlements, and
billing processes.

### Tenant Administrator
Uses iFlot to manage tenant-specific configuration, users, roles, and access
policies.

## External systems

### Identity Provider
Provides authentication and identity federation.

### Electronic Invoicing / Tax Authority
Supports invoice validation and electronic invoicing flows.

### ERP / Accounting System
Receives accounting, billing, and reconciliation-related information.

### Notification Service
Sends operational and business notifications.

### Maps / Geolocation Provider
Provides mapping, routing, and geolocation capabilities.

### Observability Platform
Receives telemetry such as logs, metrics, and traces for monitoring and support.

## Interpretation notes

This diagram intentionally treats iFlot as a single software system.

That does not mean the platform will remain technically monolithic forever. It
means that, at the context level, users interact with one coherent business
system, regardless of how its internal implementation evolves.

This view also reflects a key architectural principle of the project:
**domain clarity comes before internal decomposition**.

## Source

Structurizr DSL source:
`diagrams/structurizr/c1-system-context.dsl`