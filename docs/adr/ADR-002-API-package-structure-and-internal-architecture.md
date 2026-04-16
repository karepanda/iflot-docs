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

Authentication is expected to integrate with external identity providers
(e.g., Google). Identity is delegated externally, while authorization
(tenant membership, roles, permissions) is fully managed inside iFlot.

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
```

This is still a 3-layer architecture:

- **Presentation** lives in controllers
- **Application logic** lives in services
- **Persistence** lives in repositories and JPA entities

Authentication integrates with external identity providers, while the Access
module is responsible for resolving internal user context, tenant membership,
roles, and permissions.

---

#### `com.iflot.platform.fleet` — Hexagonal architecture aligned with DDD

Fleet management is the core domain. It contains explicit lifecycle state
machines, business invariants enforced at write time, and precondition-validated
transitions. These characteristics justify hexagonal architecture combined with
DDD principles.

```
com.iflot.platform.fleet
    ├── domain
    │     ├── model
    │     │     ├── trip
    │     │     ├── guide
    │     │     └── preinvoice
    │     ├── port
    │     │     └── out
    │     │           ├── TripRepository
    │     │           ├── GuideRepository
    │     │           └── PreInvoiceRepository
    │     └── service
    ├── application
    │     ├── port
    │     │     └── in
    │     │           ├── CreateTripUseCase
    │     │           ├── CloseTripUseCase
    │     │           └── CloseGuideUseCase
    │     └── service
    └── adapter
          ├── in
          │     └── web
          └── out
                └── persistence
```

#### Layer responsibilities in `fleet`

- `domain/model` — aggregates, entities, value objects, invariants, lifecycle rules  
- `domain/port/out` — repository interfaces defined by the domain  
- `domain/service` — domain services  
- `application/port/in` — use case interfaces  
- `application/service` — orchestration only (no business rules)  
- `adapter/in/web` — REST controllers  
- `adapter/out/persistence` — JPA adapters  

#### Dependency rule

```
adapter  →  application  →  domain
                ↑
         (domain defines port/out)
                ↓
adapter/out implements domain/port/out
```

Dependencies always point inward.

---

### Domain purity rule

The domain layer must not depend on Spring or any framework-specific libraries.

No annotations such as `@Entity`, `@Service`, or `@Component` are allowed in:

```
com.iflot.platform.fleet.domain
```

The domain is pure Java and fully testable without application context.

---

### Module isolation rule

Modules must not depend on each other's internal implementation.

- `access` must not access `fleet` packages directly  
- `fleet` must not access `access` packages directly  

Any interaction must happen through explicit contracts or application-level
orchestration.

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

`shared` must remain minimal.

It is not a convenience location — only truly cross-cutting concerns belong here.

---

### Architectural consistency rule

Architecture style is decided per module based on domain complexity:

- Support subdomains → 3-layer architecture  
- Core domains → hexagonal + DDD  

There is no global rule enforcing a single architecture style.

---

## Rationale

Architecture style is a response to complexity, not a uniform rule.

Access does not justify hexagonal complexity.  
Fleet cannot safely operate without it.

The domain defines persistence contracts (`domain/port/out`), not the application
layer, ensuring true DDD alignment.

`adapter` is used instead of `infrastructure` to reflect hexagonal terminology.

`platform` avoids encoding HTTP or deployment concerns into package naming.

---

## Consequences

- Fast onboarding in `access`
- Strong domain isolation in `fleet`
- Testable domain without Spring
- Clean path to future service extraction
- Clear pattern for adding new modules
- Risk of misuse of `shared` mitigated by strict rules

---

## Alternatives considered

**Uniform 3-layer** — rejected (too weak for domain)  
**Uniform hexagonal** — rejected (overkill for support subdomains)  
**All ports in application (Homberg)** — partially adopted  
**Package-by-layer in access** — rejected  
**Separate deployables** — rejected (premature)
