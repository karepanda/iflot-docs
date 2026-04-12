# ADR-002 — API Package Structure and Internal Architecture

**Status:** Accepted
**Date:** April 2026
**Authors:** Architecture Lead

---

## Context

`iflot-api` is a single deployable Spring Boot application that covers two
structurally distinct concerns:

- **Access control** — user management, roles, permissions, authentication, and
  audit of privileged actions. This is a support subdomain: necessary
  infrastructure, but not where the main business value lives.
- **Fleet management** — trip lifecycle, cargo guide lifecycle, tariff
  resolution, billing, and reporting. This is the core domain: the
  operational-administrative layer that connects daily transport execution to
  monthly financial close.

These two concerns have fundamentally different complexity profiles. Access
control is CRUD with security rules on top. Fleet management has rich domain
logic, explicit state machines, business invariants, and precondition-enforced
transitions that were the primary source of failure in the legacy system.

A single internal architecture applied uniformly to both concerns would either
over-engineer access control or under-engineer fleet management.

---

## Decision

### Repository naming

| Repo | Purpose |
|---|---|
| `iflot-web` | React SPA — dispatchers, billing operators, tenant administrators |
| `iflot-api` | Spring Boot backend — all server-side logic |

### Package root

```
com.iflot.platform
```

`platform` describes what the system is — not how it is deployed, not the repo
name. This decouples package naming from infrastructure naming and scales cleanly
as modules are added.

---

### Internal architecture by module

#### `com.iflot.platform.access` — 3-layer architecture, feature-first packaging

Access control is a support subdomain. Its complexity is operational, not
domain-driven. A pragmatic 3-layer architecture is appropriate and sufficient.

The module is organized by feature first, not by technical type at the root.
This keeps related code close together and reduces navigation friction for a
module with limited domain complexity.

```
com.iflot.platform.access
    ├── auth
    │     ├── AuthController
    │     ├── AuthService
    │     ├── AuthServiceImpl
    │     ├── AuthMapper
    │     └── dto
    ├── user
    │     ├── UserController
    │     ├── UserService
    │     ├── UserServiceImpl
    │     ├── UserRepository
    │     ├── UserEntity
    │     ├── UserMapper
    │     └── dto
    ├── role
    │     ├── RoleController
    │     ├── RoleService
    │     ├── RoleServiceImpl
    │     ├── RoleRepository
    │     ├── RoleEntity
    │     ├── RoleMapper
    │     └── dto
    ├── permission
    │     ├── PermissionController
    │     ├── PermissionService
    │     ├── PermissionServiceImpl
    │     ├── PermissionRepository
    │     ├── PermissionEntity
    │     ├── PermissionMapper
    │     └── dto
    └── shared
          ├── config
          ├── exception
          ├── logging
          └── security
```

This is still a 3-layer architecture:

- Presentation lives in controllers
- Application logic lives in services
- Persistence lives in repositories and JPA entities

The package organization is feature-first because that is the clearest structure
for this module size and team composition.

---

#### `com.iflot.platform.fleet` — Hexagonal architecture

Fleet management is the core domain. It contains explicit lifecycle state
machines, business invariants enforced at write time, and precondition-validated
transitions. These characteristics justify hexagonal architecture: the domain
must be testable without Spring, and infrastructure must be replaceable without
touching domain logic.

```
com.iflot.platform.fleet
    ├── domain
    │     ├── model
    │     │     ├── trip
    │     │     ├── guide
    │     │     └── preinvoice
    │     ├── port
    │     │     ├── in
    │     │     └── out
    │     └── service
    ├── application
    └── infrastructure
          ├── persistence
          └── web
```

**Layer responsibilities in `fleet`:**

- `domain` — aggregates, entities, value objects, business invariants, domain
  services, lifecycle rules, and domain ports
- `application` — use case orchestration and transaction coordination only
- `infrastructure` — persistence adapters, web adapters, external system
  adapters, and framework-specific implementation details

The application layer must not become a second business layer. Business rules
belong exclusively to domain.

---

#### `com.iflot.platform.shared` — Common primitives

Cross-cutting concerns shared across modules. `shared` is a dependency of both
`access` and `fleet`, never the reverse.

```
com.iflot.platform.shared
    ├── domain
    ├── config
    ├── security
    └── logging
```

`shared` must remain minimal. If a class belongs conceptually to a specific
module, it must not be placed in `shared`.

`shared` is not a convenience location, but a strict boundary for truly
cross-cutting concerns.

---

### Architectural consistency rule

Architecture style is decided per module based on domain complexity:

- Support subdomains may use simpler patterns, such as 3-layer architecture
- Core domains must use architectures that enforce domain boundaries, such as
  hexagonal architecture

There is no global rule enforcing a single architecture style across the entire
system.

---

## Rationale

**Why different architectures in the same deployable?**
Architecture style is a response to complexity, not a project-wide uniform rule.
Applying hexagonal architecture to access control adds indirection without
benefit. Applying 3-layer architecture to fleet management would reproduce the
legacy failure pattern: business rules embedded in services with no enforced
domain boundaries.

**Why feature-first inside `access`?**
Access control has limited domain complexity and a small number of closely
related classes per feature. Organizing the module by feature keeps the structure
clear, reduces navigation overhead, and is easier for junior developers to work
with. A package-by-layer root structure would spread one small feature across too
many technical folders with no real benefit.

**Why `fleet` as a single module and not `operations`/`billing`/`reporting` separately?**
Operations, billing, and reporting are facets of the same business problem —
closing the loop from trip execution to billing. The architecture foundation
states this explicitly as the core value proposition. Splitting them into
separate top-level modules would create artificial boundaries where the domain
has none, and force cross-module coupling for every billing precondition check.

**Why `com.iflot.platform` and not `com.iflot.api`?**
`api` in a Java package name implies the HTTP entry layer, not the full backend.
`platform` describes the system without encoding deployment or infrastructure
assumptions into the package root.

---

## Consequences

- Developers working on `access` use standard Spring patterns with low onboarding
  friction.
- Developers working on `fleet` must understand hexagonal architecture, which
  adds initial learning cost but matches the domain complexity.
- Domain logic in `fleet` is testable without Spring context.
- Adding new modules follows the same principle: assess complexity, choose the
  architecture style intentionally, and place the module under
  `com.iflot.platform`.
- Extracting `fleet` to a separate deployable in the future would require mostly
  infrastructure changes, because domain and application layers are already
  decoupled from Spring.
- `shared` requires discipline; misuse would create hidden coupling and erode
  module boundaries.

---

## Alternatives considered

**Uniform 3-layer across all modules**
Rejected. Insufficient for fleet management domain complexity. Reproduces the
structural failure pattern of the legacy system.

**Uniform hexagonal across all modules**
Rejected. Over-engineers access control. Adds indirection without domain
justification in support subdomains.

**Package-by-layer root structure inside `access`**
Rejected. It spreads small features across too many technical folders and makes
navigation harder for little gain.

**Separate deployables for `access` and `fleet` from day one**
Rejected. Premature decomposition. There is no current driver for it: single
team, early phase, and no operational need that justifies immediate separation.
Extraction remains possible later without structural migration if a real driver
emerges.