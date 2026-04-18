# Metric Catalog

This document defines the metrics used in iFlot.

It establishes:

- which metrics are collected
- how they are named
- how they are tagged
- which are platform vs application vs business
- how they relate to SLOs

---

## 1. Purpose

Metrics are used to:

- measure system health and performance
- support SLOs
- detect anomalies
- provide dashboards and alerts

Metrics are not for debugging individual requests. That is the role of logs and traces.

---

## 2. Sources of Metrics

iFlot uses three sources of metrics:

### 2.1 Platform metrics (automatic)

Provided by:

- Spring Boot Actuator
- Micrometer auto-instrumentation

Examples include:

- JVM
- HTTP server
- database connections
- threads

Micrometer acts as a facade and exports metrics to systems like Prometheus or OTLP.

---

### 2.2 Application metrics (semi-automatic)

Generated from:

- HTTP instrumentation
- framework integrations
- annotated methods (`@Timed`)

---

### 2.3 Custom metrics (manual)

Defined by the application using `MeterRegistry`.

Used for:

- business flows
- domain-specific signals
- SLO support

---

## 3. Metric Types

We use standard Micrometer / OpenTelemetry metric types:

| Type | Usage |
|---|---|
| Counter | monotonic increasing values (events) |
| Timer | duration + count (latency) |
| Gauge | current value (state) |
| Distribution Summary | size distributions |

---

## 4. Platform Metrics (Baseline)

These metrics are **mandatory and must not be renamed**.

### 4.1 JVM Metrics

Prefix: `jvm.*`

Examples:

- `jvm.memory.used`
- `jvm.gc.pause`
- `jvm.threads.live`
- `jvm.classes.loaded`

These are automatically exposed by Micrometer.

---

### 4.2 System Metrics

Prefix:

- `system.*`
- `process.*`

Examples:

- `system.cpu.usage`
- `process.cpu.usage`
- `process.uptime`

---

### 4.3 HTTP Server Metrics

Metric:

- `http.server.requests`

This is the **most important baseline metric**.

Tags (default):

- `method`
- `http.route` — always the route template (e.g. `/api/v1/trips/{id}`), never the raw URI with IDs
- `status`
- `outcome`

> **Note:** Micrometer uses `uri` internally but normalizes it to the route
> template. Always verify that raw URIs (e.g. `/api/v1/trips/1234`) are not
> leaking into this tag — that would produce unbounded cardinality.

These metrics are auto-instrumented for all controllers.

---

### 4.4 HTTP Client Metrics

Metric:

- `http.client.requests`

Used for:

- external calls
- internal service calls

---

### 4.5 Database Metrics

Prefix:

- `jdbc.connections.*`

Examples:

- `jdbc.connections.active`
- `jdbc.connections.idle`

---

### 4.6 Thread / Executor Metrics

Prefix:

- `executor.*`

Examples:

- `executor.active`
- `executor.completed`

---

### 4.7 Cache Metrics (if used)

Prefix:

- `cache.*`

Examples:

- `cache.gets`
- `cache.puts`

---

## 5. Application Metrics

Application metrics describe how the system behaves at runtime.

### 5.1 HTTP Latency

Derived from:

- `http.server.requests` (Timer)

Used for:

- latency SLOs
- P95 / P99

---

### 5.2 HTTP Error Rate

Derived from:

- `http.server.requests{status=5xx}`

Used for:

- availability SLOs

---

### 5.3 Dependency Latency

From:

- `http.client.requests`

Used for:

- downstream dependency analysis
- external failures

---

### 5.4 Task / Job Metrics (future)

Examples:

- `job.execution.time`
- `job.execution.errors`

---

## 6. Business Metrics (Exploratory)

⚠️ These are **NOT stable yet**.

They reflect current understanding of the domain and may evolve as discovery
sessions with legacy customers confirm or refine the domain model.

---

### 6.1 Flow Metrics (Primary Model)

All business metrics are defined at **flow level**.

Flow result is expressed as a **tag**, not as a metric name suffix.
This keeps the metric namespace flat and queryable.

Counters:

- `flow.started`
- `flow.completed`
- `flow.failed`

Tags:

- `flow_name` — see Section 8.2 for allowed values

Examples:

```text
flow.started{flow_name="create_trip"}
flow.completed{flow_name="close_guide"}
flow.failed{flow_name="generate_preinvoice"}
```

> **Why tags instead of name suffixes?**
> `flow.create_trip.started` creates a new metric name per flow.
> `flow.started{flow_name=create_trip}` scales to any number of flows without
> changing the metric schema. It is also more natural to query in Grafana.

---

### 6.2 Flow Duration (Backend)

Metric:

- `flow.duration`

Type:

- Timer

Tags:

- `flow_name`
- `result` (`success` | `error`)

Example:

```text
flow.duration{flow_name="create_trip", result="success"}
```

---

### 6.3 Domain Counters

⚠️ Provisional — may change as the domain stabilizes.

Examples:

- `trips.created`
- `guides.closed`
- `preinvoices.generated`

---

## 7. Tagging Rules

### 7.1 Allowed Tags

| Tag | Purpose |
|---|---|
| `service.name` | service identifier |
| `environment` | `dev` / `staging` / `prod` |
| `flow_name` | business flow — snake_case from the flow catalog |
| `result` | `success` / `error` |
| `method` | HTTP method |
| `http.route` | route template (never raw URI) |
| `status` | HTTP status code |

---

### 7.2 Forbidden Tags (High Cardinality)

Do **NOT** use as metric tags:

- `operation_id`
- `trace_id`
- `user_id`
- `trip_id`
- `guide_id`

These identifiers have unbounded cardinality and will cause storage and
query performance problems in any metrics backend. They belong in logs and
traces, not in metrics.

---

### 7.3 Common Tags

Configured globally via Micrometer common tags:

- `service.name`
- `environment`

These are applied automatically to all metrics and do not need to be set
per metric.

---

## 8. Naming Conventions

### 8.1 Rules

- use `dot.case` for metric names
- use `snake_case` for tag values (e.g. `flow_name=create_trip`)
- prefix by domain:

| Category | Prefix |
|---|---|
| Platform | `jvm.*`, `system.*`, `http.*` |
| Application | (no prefix — derived from platform metrics) |
| Flow | `flow.*` |
| Domain | `trips.*`, `guides.*` |

Do **not** mix naming styles within a metric name or across tag values.

### 8.2 Flow Name Catalog

`flow_name` tag values must come from the following list.
New flows must be added here before being instrumented.

| `flow_name` | Description |
|---|---|
| `create_trip` | Trip creation flow |
| `close_trip` | Trip operational close |
| `close_guide` | Cargo guide close |
| `generate_preinvoice` | Pre-invoice generation from closed guides |
| `login` | User authentication |

> This catalog will grow as the domain is confirmed through discovery.
> Do not instrument flows not listed here without updating this table.

### 8.3 Examples

Good:

```text
http.server.requests
flow.started{flow_name="create_trip"}
flow.duration{flow_name="close_guide", result="success"}
trips.created
```

Bad:

```text
CreateTripCount
flow.create_trip.started       ← flow name embedded in metric name
tripCreatedMetric
flow.duration{user_id="u-123"} ← high-cardinality tag
```

---

## 9. SLO Mapping

Metrics must support SLOs.

**Availability SLO:**

Based on:

- `flow.failed` / `flow.started` per `flow_name`
- or `http.server.requests{status=5xx}`

**Latency SLO:**

Based on:

- `flow.duration` Timer (backend) — P95 / P99 per `flow_name`
- `ui.flow.duration` Timer (frontend) — user-perceived latency

Both backend and frontend signals are required for a complete latency SLO.
See Section 13 for frontend metrics.

---

## 10. Export Model

Metrics flow:

```text
Application → Micrometer → OTLP → Grafana Alloy → Grafana Cloud
```

Micrometer supports OTLP export natively via `micrometer-registry-otlp`.

---

## 11. Anti-Patterns

### 11.1 Using IDs as tags

Bad:

```text
flow.duration{operation_id="8e4f..."}
```

### 11.2 Creating duplicate metrics

Bad:

```text
custom HTTP latency metric when http.server.requests already exists
```

### 11.3 Mixing naming styles

Bad:

```text
snake_case + camelCase + dot.case in the same catalog
```

### 11.4 Embedding flow name in metric name

Bad:

```text
flow.create_trip.started
flow.close_guide.failed
```

Good:

```text
flow.started{flow_name="create_trip"}
flow.failed{flow_name="close_guide"}
```

### 11.5 Over-instrumentation

Not every method needs a metric.

Only measure:

- flow boundaries
- external calls
- domain-significant events

### 11.6 Using raw URIs as `http.route`

Bad:

```text
http.server.requests{http.route="/api/v1/trips/1234"}
```

Good:

```text
http.server.requests{http.route="/api/v1/trips/{id}"}
```

---

## 12. Frontend Metrics (User Experience)

Frontend metrics measure what the user actually experiences.

These metrics are critical for SLOs and **cannot be derived from backend
metrics alone**.

---

### 12.1 Core Web Vitals

Collected using the [`web-vitals`](https://github.com/GoogleChrome/web-vitals)
library. These are **not** captured automatically by the OpenTelemetry browser
SDK — explicit integration is required.

> **Note:** Not all browsers report all Web Vitals. CLS and LCP have broad
> support. INP requires Chromium-based browsers. Plan for partial data.

| Metric | Description |
|---|---|
| `web_vitals.lcp` | Largest Contentful Paint |
| `web_vitals.cls` | Cumulative Layout Shift |
| `web_vitals.inp` | Interaction to Next Paint (replaced FID in 2024) |

---

### 12.2 First Contentful Interaction (FCI)

FCI is a product-level metric — not a standard Web Vital.

**Definition:**

> Time in milliseconds from the user triggering a flow action (button click,
> form submit, navigation) until the resulting UI is interactive and the user
> can take the next action. Measured as the interval between the initiating
> user event and the moment the loading/blocking state resolves and the
> primary interactive element is enabled.

This definition must be implemented consistently per flow. Each flow must
define its own start event and end condition before instrumenting this metric.

Metric:

- `ui.fci`

Type:

- Timer

Tags:

- `flow_name`
- `route`

Example:

```text
ui.fci{flow_name="create_trip", route="/trips/new"}
```

---

### 12.3 User Flow Metrics (Frontend)

Frontend must emit flow-level events for every critical flow.

Counters:

- `ui.flow.started`
- `ui.flow.completed`
- `ui.flow.failed`

Timer:

- `ui.flow.duration`

Tags (all):

- `flow_name`
- `result` (`success` | `error`)
- `route`

---

### 12.4 API Interaction Metrics (Frontend)

These reflect the user's perception of backend calls.

Metrics:

- `ui.api.duration` (Timer)
- `ui.api.errors` (Counter)

Tags:

- `http.route` — route template, not raw URL
- `method`
- `status`

---

### 12.5 JavaScript Errors

Metric:

- `ui.errors` (Counter)

Tags:

- `error.type`
- `route`

---

## 13. Frontend vs Backend Responsibility

| Layer | Measures |
|---|---|
| Frontend | user-perceived latency (`ui.fci`, `ui.flow.duration`), UI errors, perceived API performance |
| Backend | actual execution latency (`flow.duration`), internal errors, system health |

Both layers are required to support SLOs. Neither replaces the other.

---

## 14. Flow-Based Metrics (Unified Model)

iFlot metrics are centered around business flows. A flow represents a complete
user or system operation with a defined start, outcome, and duration.

### 14.1 Flow Lifecycle (Backend)

See Section 6.1. Summary:

- `flow.started{flow_name=...}`
- `flow.completed{flow_name=...}`
- `flow.failed{flow_name=...}`

### 14.2 Flow Duration (Backend)

See Section 6.2.

- `flow.duration{flow_name=..., result=...}`

### 14.3 Flow Lifecycle (Frontend)

See Section 12.3.

- `ui.flow.started{flow_name=...}`
- `ui.flow.completed{flow_name=...}`
- `ui.flow.failed{flow_name=...}`
- `ui.flow.duration{flow_name=..., result=...}`

### 14.4 Derived Metrics

These are calculated in Grafana (recording rules or panel expressions) —
they are not emitted by the application.

**Flow success rate:**

```text
flow.completed / flow.started  (per flow_name)
```

**Flow error rate:**

```text
flow.failed / flow.started  (per flow_name)
```

**Latency SLO signal:**

```text
histogram_quantile(0.95, flow.duration)  (backend)
histogram_quantile(0.95, ui.flow.duration)  (frontend)
```

---

## 15. FCI vs Flow Duration

These are distinct metrics measuring different things. Both are required.

| Metric | What it measures |
|---|---|
| `ui.fci` | Time until the UI is interactive after a user action |
| `ui.flow.duration` | Full flow completion time as experienced by the user |
| `flow.duration` | Backend execution time for the flow |

---

## 16. Observability Model Summary

Each flow must be observable across all three layers.

| Layer | Metrics |
|---|---|
| Frontend | `ui.fci`, `ui.flow.duration`, `ui.errors` |
| Backend | `flow.duration`, `flow.failed`, `http.server.requests` |
| System | JVM, CPU, DB connections |

If any layer is missing, the SLO cannot be computed accurately.

---

## 17. Final Rule

Every metric must answer:

- **what is being measured?**
- **at what level?** (platform / application / flow / business)
- **is it stable or exploratory?**
- **can it support an SLO?**

Every observable flow must answer:

- how long does it take? (frontend + backend)
- how often does it fail?
- what does the user experience?

If a metric cannot answer its question, or a flow cannot answer all three,
the instrumentation is incomplete.