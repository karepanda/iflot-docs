# ADR-00 — Observability Architecture, Telemetry Model, and Operational Standards for iFlot

**Date:** April 2026

---

## 1. Context

iFlot 2026 is being built as a SaaS platform for fleet operations, access control, and billing-related workflows.

The product will initially run as:

* `iflot-web` — React SPA
* `iflot-api` — Spring Boot backend
* Railway as deployment platform

The platform must support from the beginning:

* end-to-end troubleshooting from frontend to backend
* flow-level reliability visibility
* structured logs for machine analysis
* distributed tracing across layers
* metrics for operational health and SLOs
* readiness for future asynchronous workflows

The system will begin with mostly synchronous flows, but the architecture must be prepared for later evolution toward asynchronous processing, retries, background jobs, and event-driven steps.

Observability must therefore not be treated as an optional add-on or as a set of disconnected tools. It must be designed as a first-class operational capability.

---

## 2. Decision

We adopt a unified observability model for iFlot based on:

* **OpenTelemetry** as the instrumentation standard for frontend and backend
* **Grafana Alloy** as the telemetry collection and forwarding layer in Railway
* **Grafana Cloud** as the primary backend for traces, metrics, logs, dashboards, and SLO management
* **Micrometer** in the backend as the application metrics facade for Spring Boot
* **Structured JSON logging** in frontend and backend with consistent field naming
* **Flow-level SLOs** defined from the user journey perspective, supported by backend and frontend telemetry

Observability is defined across four signals:

* **Logs** — structured diagnostic evidence
* **Traces** — end-to-end execution visibility
* **Metrics** — service health, performance, and business measurements
* **SLOs** — service-level targets for critical product flows

---

## 3. High-level Architecture

### 3.1 Telemetry flow

```text
iflot-web ─────┐
               │
               ├── OTLP / Prometheus-compatible telemetry ──> Grafana Alloy (Railway)
               │                                                  │
iflot-api ─────┘                                                  ├── traces ──> Grafana Cloud Tempo/APM
                                                                  ├── metrics ─> Grafana Cloud Metrics
                                                                  └── logs ────> Grafana Cloud Loki
```

### 3.2 Platform decision

We do **not** self-host Prometheus, Loki, Tempo, or Grafana in Railway in the initial stage.

We use Railway for product deployment and a lightweight telemetry collection layer only.

This avoids introducing early operational burden related to:

* storage sizing and retention tuning
* backup and upgrade management
* Prometheus/Loki/Tempo troubleshooting
* self-hosted observability platform maintenance

---

## 4. Core Principles

### 4.1 User-flow-first observability

Observability is centered on **business flows**, not only on technical components.

Examples of flows:

* Login
* Create Trip
* Close Trip
* Close Guide
* Generate Pre-Invoice

Each critical flow must be observable end-to-end.

### 4.2 Frontend + backend correlation

Frontend and backend telemetry are both required.

* Frontend telemetry captures user-perceived experience
* Backend telemetry captures server-side execution, dependency calls, and failure causes

Neither replaces the other.

### 4.3 Standard before customization

We prefer OpenTelemetry, Micrometer, and standard JSON logging conventions before building custom frameworks.

### 4.4 Logs are not the primary source of truth for SLOs

SLOs are derived from metrics and traces, not from raw log counting.

Logs are a diagnostic signal, not the main measurement signal.

### 4.5 Prepared for async evolution

Even when a flow is currently synchronous, the observability model must support future asynchronous and multi-trace execution.

---

## 5. Telemetry Domains

### 5.1 Logs

Logs provide diagnostic events and operational evidence.

They must be:

* structured
* machine-parsable
* safe for production ingestion
* correlated with traces and business context

### 5.2 Traces

Traces provide request and flow execution visibility across frontend and backend.

Tracing must support:

* browser-to-backend propagation
* internal backend spans
* downstream dependency spans
* future multi-step async flow correlation

### 5.3 Metrics

Metrics provide quantitative measurements for:

* service health
* latency
* throughput
* errors
* resource usage
* business events

### 5.4 SLOs

SLOs measure user-facing reliability for critical flows.

SLOs belong to flows, not to layers.

---

## 6. Correlation Model

### 6.0 Operation ID generation and ownership

The platform defines an explicit rule for `operation_id` generation to avoid inconsistency across teams.

* `operation_id` is generated at the start of a business flow
* For user-initiated flows, the **frontend generates `operation_id`**
* For system-initiated flows (jobs, schedulers, internal processes), the **backend generates `operation_id`**
* `operation_id` is propagated via HTTP header: `X-Operation-Id`
* If `X-Operation-Id` is received, it must be preserved
* If absent, the backend must generate one at the entry point
* `operation_id` must remain stable across:

  * retries
  * async steps
  * multiple traces

Domain identifiers (e.g., `trip_id`, `guide_id`) complement but do not replace `operation_id`

---

### 6.1 Mandatory correlation identifiers

The platform adopts the following correlation model:

#### Technical correlation

* `trace_id` — primary technical correlation identifier across frontend, backend, traces, and logs
* `span_id` — identifier for a specific span inside a trace

#### Business / cross-request correlation

* `operation_id` — primary business correlation identifier for flows that may span multiple requests, retries, or asynchronous steps

#### Domain context identifiers

When applicable:

* `tenant_id`
* `user_id`
* `trip_id`
* `guide_id`
* `preinvoice_id`
* `flow_name`

### 6.2 External request correlation header

The platform supports an external request correlation header:

* `X-Correlation-ID`

Rules:

* if present on inbound request, preserve it
* if absent, generate it at the backend entry point
* return it in the response headers
* expose it in logs
* do not treat it as a replacement for `trace_id`

### 6.3 Relationship between identifiers

* `trace_id` answers: **what happened in this execution?**
* `operation_id` answers: **what happened in this business operation across executions?**
* `X-Correlation-ID` answers: **what request identifier can support or external systems use to search?**

---

## 7. Frontend Observability Standard

### 7.0 Telemetry routing

Frontend telemetry must be sent to Grafana Alloy deployed within Railway.

Direct communication from browser clients to Grafana Cloud is not allowed.

This ensures:

* no exposure of credentials
* centralized control of sampling and filtering
* consistent telemetry processing

---

## 7.1 Instrumentation standard

`iflot-web` uses OpenTelemetry browser instrumentation.

It must support:

* document/navigation tracing when relevant
* fetch/XHR instrumentation
* trace context propagation to backend APIs
* frontend exceptions and error reporting where possible
* custom spans for critical user flows when needed

### 7.2 Frontend telemetry responsibilities

The frontend is responsible for emitting telemetry about:

* user-visible flow start
* flow success
* flow failure
* frontend-visible latency
* JavaScript/runtime errors
* API request timing
* navigation and key interaction boundaries

### 7.3 Frontend standard attributes

Every relevant frontend span or structured log should include, when available:

* `service.name=iflot-web`
* `service.version`
* `environment`
* `trace_id`
* `span_id`
* `operation_id`
* `flow_name`
* `tenant_id`
* `user_id` if appropriate and allowed
* `route`
* `ui.action`
* `result`
* `error.code`
* `error.message`

### 7.4 Frontend logging policy

Frontend logs/events must be structured and intentionally limited.

Allowed categories:

* user flow state transitions
* recoverable frontend errors
* API call failures
* rendering/runtime issues that affect the user

Disallowed:

* noisy debug logs in production
* logging secrets, tokens, full payloads, or sensitive form data

---

## 8. Backend Observability Standard

### 8.1 Instrumentation standard

`iflot-api` uses:

* OpenTelemetry for tracing and telemetry correlation
* Micrometer for application and business metrics
* Spring Boot structured logging in JSON format
* MDC enrichment for log correlation fields

### 8.2 Backend tracing scope

Tracing must cover:

* inbound HTTP requests
* controller/use case entry
* relevant domain/application steps when explicit spans add value
* outbound HTTP calls
* database calls
* future async boundaries

### 8.3 Backend metrics scope

Metrics are grouped into three categories:

#### Platform metrics

* JVM memory
* CPU
* threads
* GC
* datasource / connection pool
* HTTP server latency and counts

#### Application metrics

* use case execution count
* use case execution duration
* error counts by flow / category
* retries
* timeouts

#### Business metrics

Examples:

* trips.created
* trips.closed
* guides.closed
* preinvoices.generated
* billing.failures

### 8.4 Backend logging format

Production logs must be emitted as structured JSON to stdout.

File-based logging is not the primary production strategy in Railway.

### 8.5 Backend mandatory log fields

Every backend log entry must include at minimum:

* `timestamp`
* `level`
* `message`
* `service.name`
* `service.version`
* `environment`
* `logger`
* `thread.name`
* `trace_id`
* `span_id`
* `operation_id`
* `flow_name`
* `tenant_id` when known

### 8.6 Backend contextual log fields

When applicable, include:

* `user_id`
* `trip_id`
* `guide_id`
* `preinvoice_id`
* `http.method`
* `http.route`
* `http.status_code`
* `duration_ms`
* `error.code`
* `error.message`
* `exception.type`

### 8.7 MDC policy

The backend must use MDC only for stable correlation and contextual fields.

Allowed MDC fields:

* `trace_id`
* `span_id`
* `operation_id`
* `flow_name`
* `tenant_id`
* `correlation_id`

MDC must be cleaned correctly at request completion and async boundaries.

---

## 9. Structured Logging Standard

### 9.1 Format

Structured logging must use JSON.

### 9.2 Naming convention

Field names must be consistent across frontend and backend.

Use snake_case or dotted semantic names consistently. The platform standard is:

* OpenTelemetry semantic names where they already exist and add value
* otherwise snake_case for product-specific fields

Examples:

* `trace_id`
* `span_id`
* `operation_id`
* `flow_name`
* `tenant_id`
* `trip_id`
* `guide_id`

### 9.3 Timestamp

All logs must use UTC and ISO 8601 compatible timestamps.

### 9.4 Sensitive data policy

The following must never be logged:

* passwords
* access tokens
* refresh tokens
* full payment data
* PII beyond what is strictly necessary for operations
* raw credentials
* session secrets

Sensitive values must be masked or omitted.

### 9.5 Volume control

Production logging must avoid noise.

Rules:

* errors: always log
* warnings: log when actionable
* info: key business and lifecycle events only
* debug/trace: disabled by default in production

### 9.6 Logging intent

Logs are used for:

* failures
* key state transitions
* flow milestones
* external dependency issues
* audit-relevant events where applicable

Logs are not used to narrate every line of code execution.

---

## 10. Tracing Standard

### 10.1 Propagation format

Trace context propagation must use W3C Trace Context.

### 10.2 Entry points

Frontend-to-backend requests must propagate trace context headers automatically.

### 10.3 Manual spans

Manual spans are allowed only when they add business or troubleshooting value, such as:

* high-value use case boundaries
* transitions between critical business states
* asynchronous job orchestration steps
* external provider orchestration

### 10.4 Async readiness

When a flow later becomes asynchronous:

* traces may split across multiple executions
* `operation_id` remains the stable business correlation key
* async producers and consumers must propagate `traceparent` where possible and always propagate `operation_id`

---

## 11. Metrics Standard

### 11.1 Backend metrics library

Micrometer is the standard metrics facade for `iflot-api`.

### 11.2 Export model

Metrics are exported through the OpenTelemetry / Alloy pipeline as configured for the platform.

### 11.3 Metric naming

Business metrics are considered **exploratory during the domain discovery phase**.

Initial examples (e.g., trips created, guides closed) are indicative only and subject to change as domain understanding evolves.

Metric definitions must be refined progressively as the domain stabilizes.

Metric names must be:

* descriptive
* stable
* low-cardinality
* tagged carefully

Metric names must be:

* descriptive
* stable
* low-cardinality
* tagged carefully

High-cardinality tags such as raw user IDs must not be used in metrics.

### 11.4 Allowed metric tags

Typical allowed tags:

* `service`
* `environment`
* `flow_name`
* `result`
* `status`
* `http.method`
* `http.route`

### 11.5 Disallowed metric tags

* `user_id`
* `trip_id`
* `guide_id`
* `operation_id`
* any unbounded free-text field

Those belong in logs and traces, not in metrics.

---

## 12. SLO Model

### 12.1 SLO ownership

SLOs are defined per critical business flow.

### 12.2 Initial flow candidates

Initial candidates:

* Login
* Create Trip
* Close Trip
* Close Guide
* Generate Pre-Invoice

### 12.3 SLO types

Each critical flow should define at least:

* **Availability SLO** — percentage of successful flow completions
* **Latency SLO** — percentage of flow executions completed within an acceptable threshold

### 12.4 Measurement model

The SLO belongs to the flow.

Its signals come from:

* frontend telemetry for user-perceived experience
* backend telemetry for execution success and latency
* optional synthetic probes where useful

### 12.5 Alerting model

Burn-rate alerts must use both:

* fast-burn alerts for rapid degradation
* slow-burn alerts for sustained degradation

---

## 13. Dashboard Strategy

### 13.1 Core dashboard groups

We maintain dashboards for:

* executive/service overview
* flow reliability
* backend technical health
* frontend user experience
* logs and trace exploration

### 13.2 Initial dashboard set

At minimum:

1. **Service Overview**

   * request rate
   * error rate
   * latency
   * JVM / runtime health

2. **Flow Dashboard**

   * Create Trip success rate
   * Close Guide success rate
   * flow latency percentiles
   * top failure reasons

3. **Trace & Log Correlation Dashboard**

   * recent failed traces
   * logs by trace_id / operation_id

4. **Frontend Experience Dashboard**

   * API failure rate from browser
   * flow completion timing
   * JS/runtime errors

---

## 14. Implementation Standards

### 14.0 Cost awareness

Grafana Cloud free tier is sufficient for development and early-stage environments.

Telemetry volume, especially traces, must be monitored to avoid exceeding free tier limits.

If usage grows beyond acceptable cost thresholds, alternative deployment models (hybrid or self-hosted) will be evaluated.

---

### 14.1 iflot-web

Must implement:

* OTel browser instrumentation
* fetch/XHR propagation
* flow-level custom spans/events where useful
* structured frontend logging/event model
* `operation_id` generation or propagation strategy for critical flows

### 14.2 iflot-api

Must implement:

* OTel Spring instrumentation
* MDC enrichment
* JSON structured logging
* Micrometer metrics
* custom business metrics for key flows
* response header support for `X-Correlation-ID`

### 14.3 Railway

Must host:

* Grafana Alloy service

### 14.4 Grafana Cloud

Must provide:

* traces backend
* logs backend
* metrics backend
* dashboards
* SLO definitions
* alerting

---

## 15. Non-Goals

The following are not part of this ADR for the initial stage:

* self-hosting the full LGTM stack in Railway
* defining every final SLO threshold now
* full audit event design
* long-term log retention policy by compliance tier
* exhaustive synthetic monitoring coverage

These may be addressed in future ADRs or operational documents.

---

## 16. Consequences

### Positive

* iFlot gets a consistent observability model from day one
* frontend and backend become diagnosable as a single execution path
* logs, metrics, and traces can be correlated effectively
* future async evolution does not require redesigning observability identifiers
* SLOs can be defined at the level that users actually experience

### Costs / trade-offs

* more up-front discipline in naming and instrumentation
* need for alignment between frontend and backend teams
* some implementation overhead to propagate and enrich context correctly
* higher learning curve than ad-hoc logging alone

---

## 17. Rejected Alternatives

### Only backend observability

Rejected. It fails to capture user-perceived experience and breaks end-to-end diagnosis.

### Logs-only strategy

Rejected. Logs alone are insufficient for modern flow reliability, latency analysis, and trace correlation.

### Self-hosted observability stack in Railway from day one

Rejected. It introduces premature operational burden.

### Per-service SLOs only

Rejected. SLOs must represent critical user/business flows.

### Correlation via custom IDs only, without OpenTelemetry trace context

Rejected. It ignores the standard technical correlation model and weakens tooling compatibility.

---

## 18. Follow-up Documents Required

The following supporting documents must be created after this ADR is accepted.

**Priority order:**

1. `observability/context-propagation-standard.md` (critical — blocks correct implementation)
2. `observability/log-schema.md`
3. `observability/metric-catalog.md`
4. `observability/flow-slo-catalog.md`
5. `observability/dashboard-baseline.md`
6. `observability/alerting-baseline.md`

The context propagation standard must explicitly define:

* header contracts (`traceparent`, `X-Operation-Id`, `X-Correlation-ID`)
* generation rules
* propagation rules across frontend, backend, and async boundaries

---

The following supporting documents must be created after this ADR is accepted:

1. `observability/log-schema.md`
2. `observability/metric-catalog.md`
3. `observability/flow-slo-catalog.md`
4. `observability/dashboard-baseline.md`
5. `observability/alerting-baseline.md`
6. `observability/context-propagation-standard.md`

---

## 19. Final Rule

In iFlot, observability is designed around the following principle:

**The primary unit of reliability is the business flow.**

Logs, traces, and metrics exist to explain, measure, and troubleshoot that flow across frontend, backend, and future asynchronous boundaries.
