# ADR-001 — Architecture for iFlot Access Module

**Status:** Accepted  
**Date:** April 2026  
**Authors:** Architecture Lead  
**Audience:** Development team working on the module

---

## 1. Context

iFlot Access is the user management and access control module of iFlot 2026.

It is a Spring Boot 4 REST API backed by PostgreSQL. It handles users, roles,
permissions, and authentication. It is the first module built for iFlot 2026 and
serves two purposes: it delivers a real, production-ready capability, and it is a
learning environment for junior developers joining the project.

This module uses a 3-layer architecture organized by domain feature. The goal is
to keep the structure simple, clear, and easy to maintain as the team grows.

This ADR records the architecture decision for this module: the style chosen, the
package structure, the rules that govern it, and the reasoning behind each choice.

---

## 2. Decision

### 2.1 Architecture style

This module uses a **3-layer architecture** organized by **feature first**.

The three layers are:

- **Presentation layer** — HTTP entry points (controllers)
- **Service layer** — Application logic and use case coordination
- **Data access layer** — Persistence (repositories and entities)

This is the same 3-layer model described in most Spring Boot tutorials, with one
important difference: the top-level package organization is driven by **domain
feature**, not by technical type.

This means the first thing you see when opening the project is the business domain
— `user`, `role`, `permission`, `auth` — not technical categories like `controller`
or `service`.

### 2.2 Why not package-by-layer (classic)?

The classic approach organizes everything by technical type at the root:

```
com.iflot.access
├── controller/
│   ├── UserController.java
│   ├── RoleController.java
│   └── AuthController.java
├── service/
│   ├── UserService.java
│   └── RoleService.java
├── repository/
├── entity/
└── dto/
```

This works for very small projects. It breaks down quickly because:

- To understand the `user` feature, you must open 5 different folders
- Adding a new feature means touching all folders at once
- The project structure tells you nothing about what the system does
- Services and controllers grow without a natural boundary to stop them

### 2.3 Why feature-first 3 layers?

Feature-first packaging gives junior developers the most important habit early:
**think in domain concepts, not in technical categories**.

When a developer opens the project they should immediately understand what the
system does. When they need to work on users, everything they need is in one place.
When a new feature is added, there is a clear home for every class from the start.

---

## 3. Package structure

### 3.1 Full structure

```
com.iflot.access
├── user/
│   ├── User.java
│   ├── UserController.java
│   ├── UserService.java
│   ├── UserServiceImpl.java
│   ├── UserRepository.java
│   └── dto/
│       ├── CreateUserRequest.java
│       ├── UpdateUserRequest.java
│       └── UserResponse.java
│
├── role/
│   ├── Role.java
│   ├── RoleController.java
│   ├── RoleService.java
│   ├── RoleServiceImpl.java
│   ├── RoleRepository.java
│   └── dto/
│       ├── CreateRoleRequest.java
│       └── RoleResponse.java
│
├── permission/
│   ├── Permission.java
│   ├── PermissionController.java
│   ├── PermissionService.java
│   ├── PermissionServiceImpl.java
│   ├── PermissionRepository.java
│   └── dto/
│       └── PermissionResponse.java
│
├── auth/
│   ├── AuthController.java
│   ├── AuthService.java
│   ├── AuthServiceImpl.java
│   └── dto/
│       ├── LoginRequest.java
│       └── TokenResponse.java
│
└── shared/
    ├── exception/
    │   ├── ApiException.java
    │   ├── ResourceNotFoundException.java
    │   └── GlobalExceptionHandler.java
    ├── security/
    │   ├── JwtFilter.java
    │   ├── JwtUtil.java
    │   └── SecurityConfig.java
    └── config/
        └── OpenApiConfig.java
```

### 3.2 Why the structure is flat inside each feature

Each feature package contains its classes directly, not in sub-packages by layer.

For example, `user/` holds `UserController`, `UserService`, `UserRepository`, and
`User` at the same level, with only `dto/` as a sub-package.

The reason is simple: when a feature has 4 to 6 classes, adding sub-packages
creates navigation overhead without clarity benefit. Sub-packages inside a feature
make sense when the feature grows large — and that growth is exactly the signal
that the feature needs to be redesigned, not subdivided.

### 3.3 The `shared/` package

`shared/` contains code that is genuinely cross-cutting and belongs to no single
feature. It has three sub-packages:

- `exception/` — custom exceptions and the global error handler
- `security/` — JWT utilities, the authentication filter, and the security configuration
- `config/` — Spring beans and OpenAPI setup

The rule for placing something in `shared/` is strict: if it belongs to a specific
feature, it lives in that feature. `shared/` is not a dumping ground for things that
do not have an obvious home.

---

## 4. Package responsibilities

### 4.1 Feature packages — `user/`, `role/`, `permission/`, `auth/`

Each feature package owns everything needed to implement that domain capability
from HTTP request to database.

**What lives here:**

- The JPA entity (`User.java`, `Role.java`)
- The Spring Data repository interface (`UserRepository.java`)
- The service interface and its implementation (`UserService.java`, `UserServiceImpl.java`)
- The REST controller (`UserController.java`)
- The `dto/` sub-package with request and response records

**What does not live here:**

- Security configuration (lives in `shared/security/`)
- Global exception handling (lives in `shared/exception/`)
- Cross-feature orchestration logic (belongs in the service of the feature that
  owns the use case)

---

### 4.2 Controller

The controller is the HTTP entry point. It receives requests from outside and
returns responses. It does not make decisions — it delegates.

**Responsible for:**

- Mapping HTTP verbs and paths to methods (`@GetMapping`, `@PostMapping`, etc.)
- Reading request data from the body, path variables, and headers
- Calling `@Valid` for input validation declared in the request DTO
- Calling the service with the validated input
- Returning the appropriate HTTP status and response body

**Not responsible for:**

- Business rules or conditional logic beyond input validation
- Direct access to repositories
- Building domain objects from raw data
- Deciding whether a user is authorized (that belongs in the service or in Spring
  Security configuration)

**Example — what a controller method should look like:**

```java
@PostMapping
@ResponseStatus(HttpStatus.CREATED)
public UserResponse createUser(@Valid @RequestBody CreateUserRequest request) {
    return userService.createUser(request);
}
```

If a controller method is longer than 10 lines, it is doing too much.

---

### 4.3 Service

The service is where the application logic lives. It is the most important layer
and the hardest to keep clean.

**Responsible for:**

- Implementing the use case from start to finish
- Applying business rules (e.g., a username must be unique)
- Coordinating reads and writes through repositories
- Throwing domain exceptions when a business rule is violated
- Mapping between entities and DTOs when the controller or repository cannot

**Not responsible for:**

- HTTP details (`HttpServletRequest`, `ResponseEntity`, status codes)
- Direct database queries beyond what repositories provide
- Knowing about other services unless there is a clear domain dependency

**Interface + implementation — module convention:**

Every service in this module is declared as an interface with a single
implementation class. This is a deliberate convention, not a case-by-case decision.

```java
// Interface — defines the contract
public interface UserService {
    UserResponse createUser(CreateUserRequest request);
    UserResponse findById(UUID id);
    void updateStatus(UUID id, boolean active);
}

// Implementation — owns the logic
@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {
    private final UserRepository userRepository;
    // ...
}
```

The controller always depends on the interface, never on the implementation class
directly. This keeps the contract explicit, reinforces the module-wide convention,
and allows tests to depend on the service contract rather than the concrete
implementation.

This convention applies to all services in this module without exception.
`UserService`, `RoleService`, `PermissionService`, `AuthService` — all follow
the same pattern.

**When a service is getting too large:**

A service method that coordinates multiple repositories should be reviewed
carefully. If it needs more than two repositories, that is a strong signal the
operation may deserve its own class. A service with more than 5 or 6 public
methods is a signal that it is covering more than one concern.

In this module, keep services focused. A `UserService` handles user lifecycle.
It does not also handle role assignment logic — that belongs in a dedicated
operation or in `RoleService`.

---

### 4.4 Repository

The repository is the data access layer. It reads from and writes to the database.
It does not make decisions.

**Responsible for:**

- Extending `JpaRepository<Entity, ID>` or `CrudRepository<Entity, ID>`
- Declaring custom query methods using Spring Data naming conventions
- Declaring `@Query` methods for complex queries that Spring Data cannot infer

**Not responsible for:**

- Business logic of any kind
- Deciding what to do with the data it retrieves
- Calling other repositories or services

**Example:**

```java
public interface UserRepository extends JpaRepository<User, UUID> {
    Optional<User> findByUsername(String username);
    boolean existsByEmail(String email);
}
```

The repository does not know why someone is looking for a user by username. It
just provides the data.

---

### 4.5 Entity

The entity is the JPA persistence model. It represents a table in the database.

**Responsible for:**

- Declaring the table mapping with `@Entity`, `@Table`
- Declaring fields and their column mappings
- Declaring relationships (`@ManyToMany`, `@ManyToOne`, etc.)

**Not responsible for:**

- Appearing directly in API responses
- Carrying business logic or behavior
- Knowing about HTTP or presentation concerns

**In Java 21, entities are still regular classes** (not records) because JPA
requires a no-argument constructor and mutable state. This is a known constraint
of the persistence layer, not a design choice.

---

### 4.6 DTO (Data Transfer Object)

DTOs are the public contract of the API. They define what the outside world sends
in and receives back. They are completely separate from entities.

**Responsible for:**

- Representing the shape of a request body
- Representing the shape of a response body
- Carrying validation annotations (`@NotBlank`, `@Email`, `@Size`, etc.)

**Not responsible for:**

- Business logic
- Persistence annotations
- Knowing about entities

**In Java 21, all DTOs must be records:**

```java
public record CreateUserRequest(
    @NotBlank String username,
    @Email @NotBlank String email,
    @NotBlank @Size(min = 8) String password
) {}

public record UserResponse(
    UUID id,
    String username,
    String email,
    boolean active
) {}
```

Records are immutable by design. They eliminate boilerplate constructors, getters,
and `equals`/`hashCode`. They make it clear that a DTO is data — not an object
with behavior. This is not a style preference. It is the standard for all DTOs in
this project.

---

### 4.7 `shared/exception/`

Contains the custom exception classes and the global error handler.

`ApiException` is declared as a **sealed class**. This means the compiler knows
every permitted subtype. If a new exception is added without declaring it in
`permits`, the code does not compile. This protects the `GlobalExceptionHandler`
from silently missing new error cases.

```java
// Base — sealed, all subtypes must be declared here
public sealed class ApiException extends RuntimeException
    permits ResourceNotFoundException,
            DuplicateResourceException,
            UnauthorizedException,
            ForbiddenException {

    public ApiException(String message) {
        super(message);
    }
}

// Each subtype is a final class — no further extension allowed
public final class ResourceNotFoundException extends ApiException { ... }
public final class DuplicateResourceException extends ApiException { ... }
public final class UnauthorizedException extends ApiException { ... }
public final class ForbiddenException extends ApiException { ... }

// The global handler uses pattern matching — exhaustive by design
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(ApiException.class)
    public ResponseEntity<ErrorResponse> handle(ApiException ex) {
        return switch (ex) {
            case ResourceNotFoundException e ->
                ResponseEntity.status(404).body(new ErrorResponse(e.getMessage()));
            case DuplicateResourceException e ->
                ResponseEntity.status(409).body(new ErrorResponse(e.getMessage()));
            case UnauthorizedException e ->
                ResponseEntity.status(401).body(new ErrorResponse(e.getMessage()));
            case ForbiddenException e ->
                ResponseEntity.status(403).body(new ErrorResponse(e.getMessage()));
        };
    }
}
```

The benefit for the team is concrete: when a new exception type is needed, the
developer adds it to `permits` in `ApiException` and the compiler immediately
points to every place that needs to handle it. No case is silently ignored.

All exceptions thrown in services must extend `ApiException` or a declared
subtype. Throwing generic `RuntimeException` directly from a service is not
allowed.

---

### 4.8 `shared/security/`

Contains JWT infrastructure and Spring Security configuration.

**What lives here:**

- `JwtUtil.java` — token generation, validation, and claim extraction
- `JwtFilter.java` — the `OncePerRequestFilter` that validates tokens on each request
- `SecurityConfig.java` — the `SecurityFilterChain` bean and all security rules

**Spring Security 6 model — important for junior developers:**

Spring Boot 4 uses Spring Security 6. This version removed `WebSecurityConfigurerAdapter`.
Many tutorials still show the old model. Do not follow them.

The correct model uses `SecurityFilterChain` as a Spring bean:

```java
@Configuration
@EnableMethodSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        return http
            .csrf(AbstractHttpConfigurer::disable)
            .sessionManagement(s -> s.sessionCreationPolicy(STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/auth/**").permitAll()
                .anyRequest().authenticated()
            )
            .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class)
            .build();
    }
}
```

`@EnableMethodSecurity` enables `@PreAuthorize` annotations on service or
controller methods for fine-grained permission checks:

```java
@PreAuthorize("hasAuthority('users.create')")
public UserResponse createUser(CreateUserRequest request) { ... }
```

Security configuration is never scattered. It lives entirely in `shared/security/`
and `shared/config/`.

---

### 4.9 `shared/config/`

Contains Spring bean configuration that is genuinely application-wide.

**What lives here:**

- `OpenApiConfig.java` — Swagger/OpenAPI setup and JWT bearer scheme
- `PasswordEncoderConfig.java` — the `PasswordEncoder` bean
- Any other application-wide infrastructure bean

---

## 5. Dependency rules

The direction of dependencies is fixed. Violations are architecture errors, not
style preferences.

```
Controller  →  Service  →  Repository
                 ↓
              Entity / DTO
```

**Allowed:**

- Controllers depend on services and DTOs
- Services depend on repositories, entities, DTOs, and shared exceptions
- Repositories depend on entities
- Any layer may throw or catch from `shared/exception/`
- Services may use `shared/security/` for principal resolution when needed

**Never allowed:**

- Controllers calling repositories directly
- Services depending on controllers
- Repositories depending on services or controllers
- A feature package accessing another feature's repository directly — cross-feature
  interaction must go through the owning feature's service
- Cyclic dependencies between any packages

---

## 6. Java 21 conventions

This project uses Java 21. The following language features are not optional style
choices — they are project standards.

### Records for all DTOs

All request and response objects are records. No exceptions.

```java
// Correct
public record LoginRequest(
    @NotBlank String username,
    @NotBlank String password
) {}

// Not correct — use records instead of classes for DTOs
public class LoginRequest {
    private String username;
    private String password;
    // ...
}
```

### Constructor injection — no `@Autowired` on fields

```java
// Correct — constructor injection with Lombok
@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {
    private final UserRepository userRepository;
}

// Not correct
@Service
public class UserServiceImpl implements UserService {
    @Autowired
    private UserRepository userRepository;
}
```

Field injection hides dependencies and makes testing harder. Constructor injection
makes dependencies explicit and allows tests without a Spring context.

### Sealed classes for the exception hierarchy

Sealed classes are used **exclusively** for the `ApiException` hierarchy in
`shared/exception/`. They are not used for DTOs, entities, or any other purpose
in this module.

The rule is simple: `ApiException` is sealed, its permitted subtypes are final,
and the `GlobalExceptionHandler` handles them with an exhaustive `switch`.
Adding a new exception type without registering it in `permits` is a compile
error — not a runtime surprise.

This is the one place in this module where sealed classes provide a clear,
immediate benefit: compiler-enforced completeness over a bounded set of error
cases.

---

## 7. Structured logging

This module uses **structured logging** from day one. Plain text logs are not
acceptable in production — they are slow to search, impossible to parse reliably,
and produce no usable signal in observability tools.

### Decision

All log output is emitted as JSON using `logstash-logback-encoder`. Every log
line carries a `traceId` propagated via MDC so that all log entries from a single
request are correlated and searchable together.

### Minimum viable setup

```xml
<!-- pom.xml -->
<dependency>
    <groupId>net.logstash.logback</groupId>
    <artifactId>logstash-logback-encoder</artifactId>
    <version>7.4</version>
</dependency>
```

```xml
<!-- logback-spring.xml -->
<appender name="JSON" class="ch.qos.logback.core.ConsoleAppender">
    <encoder class="net.logstash.logback.encoder.LogstashEncoder"/>
</appender>
```

A `TraceIdFilter` sets `MDC.put("traceId", ...)` at the start of each request
and calls `MDC.clear()` at the end. This gives every log line a correlation ID
with no changes to service or controller code.

### Convention for service logging

```java
private static final Logger log = LoggerFactory.getLogger(UserServiceImpl.class);

log.info("User created",
    StructuredArguments.keyValue("userId", user.getId()),
    StructuredArguments.keyValue("username", user.getUsername()));

log.warn("Duplicate username attempt",
    StructuredArguments.keyValue("username", request.username()));

log.error("Unexpected error creating user",
    StructuredArguments.keyValue("username", request.username()), ex);
```

### Rules

- Use `info` for successful operations with relevant business context
- Use `warn` for expected domain violations — duplicate records, invalid states
- Use `error` for unexpected exceptions only — always include the exception object
- Never log passwords, tokens, or any sensitive field
- Never use `System.out.println` or `printStackTrace`

### Observability roadmap

The structured logging setup in this module is the foundation for full
observability. A dedicated session will extend this with OpenTelemetry,
Micrometer, Prometheus, and Grafana. That configuration will be documented
and linked from this ADR when complete.

---

## 8. ArchUnit enforcement

The following rules will be enforced automatically by ArchUnit tests. Violations
fail the build.

The naming conventions these rules rely on are fixed by this ADR:
controllers end in `Controller`, service interfaces end in `Service`, service
implementations end in `ServiceImpl`, repositories end in `Repository`.
Deviating from these names breaks the ArchUnit rules and is not allowed.

**Rule 1 — Controllers must not depend on repositories**

```java
noClasses().that().haveSimpleNameEndingWith("Controller")
    .should().dependOnClassesThat()
    .haveSimpleNameEndingWith("Repository")
```

**Rule 2 — Service implementations must not depend on controllers**

```java
noClasses().that().haveSimpleNameEndingWith("ServiceImpl")
    .should().dependOnClassesThat()
    .haveSimpleNameEndingWith("Controller")
```

**Rule 3 — Repositories must not depend on controllers or services**

```java
noClasses().that().haveSimpleNameEndingWith("Repository")
    .should().dependOnClassesThat()
    .haveSimpleNameEndingWith("Controller")

noClasses().that().haveSimpleNameEndingWith("Repository")
    .should().dependOnClassesThat()
    .haveSimpleNameEndingWith("ServiceImpl")
```

**Rule 4 — No cyclic dependencies between feature packages**

```java
slices().matching("com.iflot.access.(*)..").should().beFreeOfCycles()
```

**Rule 5 — Entities must not appear in controller method signatures**

Entities must never cross the API boundary. The API contract is defined
exclusively by DTOs. A controller method that receives or returns an entity
is a hard violation — it couples the persistence model directly to the
public interface of the system.

The conceptual rule is approved and enforced by this ADR. The exact ArchUnit
implementation for inspecting method parameter and return types against
`@Entity`-annotated classes requires verification against the ArchUnit version
in use before committing the final test code. The rule will be added to the
ArchUnit test suite once confirmed. Until then, this constraint is enforced
through code review.

The intent in plain terms:

> No method in any class ending in `Controller` may declare a parameter type
> or return type that is annotated with `@Entity`.

---

## 8. What ArchUnit does not enforce — code review responsibility

ArchUnit enforces structure. It cannot enforce judgment. The following must be
reviewed by humans in pull requests:

- Is the DTO well designed? Does it expose the right fields?
- Is the service focused on one concern, or is it growing toward a "god service"?
- Is the exception meaningful, or is it a generic wrapper around nothing?
- Is a shortcut justified and documented, or is it technical debt being hidden?
- Are method names clear enough that a junior developer can understand the
  intent without reading the body?

Good architecture passes ArchUnit. Great architecture also passes code review.

---

## 9. Consequences

### What this decision gives us

- Junior developers can navigate the project by domain concept, not by technical
  category
- Each feature is self-contained enough to be worked on independently
- The 3-layer model is familiar from tutorials and documentation, reducing the
  learning curve
- ArchUnit rules protect the structure automatically as the team grows

### What this decision costs us

- Services will grow over time and will need to be split. Discipline is required.
- The entity and domain model are coupled to JPA. Changing the persistence
  mechanism would require touching both the entity and any service that maps
  from it.
- Testing the service layer requires mocking repositories. This works well but
  requires that tests are written with that constraint in mind from the start.

These are known and accepted trade-offs for this phase of the product.

---

## 10. Alternatives considered

### Option A — Classic package-by-layer

`controller/`, `service/`, `repository/`, `entity/`, `dto/` at the root level.

Rejected because the structure reveals nothing about what the system does, and
it degrades quickly as the number of features grows. Suitable only for throwaway
projects.

### Option B — Feature-first with sub-packages per layer inside each feature

Organizing each feature with sub-packages for each layer:

```
com.iflot.access.user
├── controller/
├── service/
├── repository/
├── entity/
└── dto/
```

Rejected because with 4 to 6 classes per feature, the sub-packages add navigation
overhead without adding clarity. Flat is better at this scale. Sub-packages inside
a feature are a future option if any single feature grows significantly.

---

*This document should be reviewed after the first feature is complete and updated
if team feedback reveals structural problems not anticipated here.*

