# Log Schema Standard

This document defines the structured logging schema for iFlot.

It applies to:

- `iflot-api` (backend)
- `iflot-web` (frontend, where applicable)

All logs must be emitted in **structured JSON format** and must be compatible
with centralized ingestion (Grafana Loki).

---

## 1. Purpose

The goal of structured logging is to:

- enable efficient querying and filtering
- correlate logs with traces
- support debugging across frontend and backend
- provide consistent diagnostic context

Logs are not the primary measurement system. They are a **diagnostic signal**.

---

## 2. Format

All logs must:

- be valid JSON
- use UTC timestamps
- follow consistent field naming
- avoid nested excessive complexity unless necessary

Example:

```json
{
  "timestamp": "2026-04-18T10:15:30.123Z",
  "level": "INFO",
  "message": "Trip created successfully",
  "service.name": "iflot-api",
  "service.version": "1.2.0",
  "environment": "dev",
  "trace_id": "4bf92f3577b34da6a3ce929d0e0e4736",
  "span_id": "00f067aa0ba902b7",
  "operation_id": "8e4f8d6f-88f0-48d4-b7ab-6c6522e4e3c5",
  "flow_name": "create_trip",
  "tenant_id": "tenant-1",
  "trip_id": "TRIP-1001"
}
```

---

## 3. Required Fields

The following fields are mandatory for all backend logs.

| Field | Description |
|---|---|
| `timestamp` | ISO 8601 UTC timestamp |
| `level` | Log level (`INFO`, `WARN`, `ERROR`) |
| `message` | Human-readable message |
| `service.name` | Service identifier (`iflot-api`, `iflot-web`) |
| `service.version` | Deployed version of the service (e.g. `1.2.0`) |
| `environment` | Environment (`dev`, `staging`, `prod`) |
| `trace_id` | OpenTelemetry trace ID |
| `span_id` | OpenTelemetry span ID |
| `operation_id` | Business flow identifier — see Section 3.1 |
| `flow_name` | Logical flow (`create_trip`, `close_guide`, etc.) |

### 3.1 Origin of `operation_id`

`operation_id` is a business-level correlation identifier. It must survive
multiple requests, retries, and future asynchronous steps within the same
logical operation.

Rules:

- **Frontend-initiated flows:** the frontend generates `operation_id` as a UUID
  at flow start and sends it in the `X-Operation-ID` request header.
- **Backend-initiated flows** (background jobs, async steps): the backend
  generates `operation_id` at the entry point of the job or event handler.
- **Once generated, `operation_id` must not change** for the duration of the
  logical operation, regardless of how many requests or retries it spans.
- `operation_id` is **not** the same as `trace_id`. A single `operation_id`
  may correlate multiple `trace_id` values in asynchronous flows.
- `operation_id` is **not** replaced by domain identifiers such as `trip_id`
  or `guide_id`. Those are included alongside it as domain context fields.

> For full propagation rules across frontend, backend, and async boundaries,
> see `context-propagation-standard.md`.

---

## 4. Recommended Fields

These should be included when available:

| Field | Description |
|---|---|
| `tenant_id` | Tenant context |
| `user_id` | User performing the action |
| `correlation_id` | `X-Correlation-ID` from request headers |
| `http.method` | HTTP method |
| `http.route` | API route |
| `http.status_code` | HTTP status |
| `duration_ms` | Execution time |
| `logger` | Logger name |
| `thread.name` | Thread name |

---

## 5. Domain Context Fields

Include domain identifiers when relevant:

- `trip_id`
- `guide_id`
- `preinvoice_id`

These must not replace `operation_id`. They are contextual identifiers that
complement it.

---

## 6. Error Fields

Error logs must include structured error data **and all required correlation
fields**. An error log without `trace_id` and `operation_id` is not diagnosable.

| Field | Description |
|---|---|
| `error.code` | Application-specific error code |
| `error.message` | Error description |
| `exception.type` | Exception class |
| `stack_trace` | See policy below |

### `stack_trace` policy

Include `stack_trace` only for **unexpected exceptions** — errors that
indicate a programming fault or an unhandled condition.

Do **not** include `stack_trace` for known domain errors such as
`GUIDE_INVALID_STATE` or `TARIFF_NOT_RESOLVED`. Those are anticipated
outcomes with a defined error code. A stack trace adds no diagnostic value
and introduces noise.

Rule of thumb: if the error has an explicit `error.code` in the application
error catalog, omit `stack_trace`. If the error is an unhandled exception,
include it.

Example — domain error (no stack trace):

```json
{
  "timestamp": "2026-04-18T10:20:00.456Z",
  "level": "ERROR",
  "message": "Failed to close guide",
  "service.name": "iflot-api",
  "service.version": "1.2.0",
  "environment": "prod",
  "trace_id": "4bf92f3577b34da6a3ce929d0e0e4736",
  "span_id": "00f067aa0ba902b7",
  "operation_id": "8e4f8d6f-88f0-48d4-b7ab-6c6522e4e3c5",
  "flow_name": "close_guide",
  "tenant_id": "tenant-1",
  "guide_id": "GUIDE-1001",
  "error.code": "GUIDE_INVALID_STATE",
  "error.message": "Guide cannot be closed from state PENDING",
  "exception.type": "GuideInvalidStateException"
}
```

Example — unexpected exception (stack trace included):

```json
{
  "timestamp": "2026-04-18T10:21:00.789Z",
  "level": "ERROR",
  "message": "Unexpected error during guide close",
  "service.name": "iflot-api",
  "service.version": "1.2.0",
  "environment": "prod",
  "trace_id": "5cf83a4688c45eb7b4df030e1f1f5847",
  "span_id": "11g178bb1cb013c8",
  "operation_id": "9f5g9e7g-99g1-59e5-c8bc-7d7633f5f4d6",
  "flow_name": "close_guide",
  "tenant_id": "tenant-1",
  "guide_id": "GUIDE-1002",
  "exception.type": "NullPointerException",
  "stack_trace": "..."
}
```

---

## 7. Naming Conventions

### General rules

- use `snake_case` for custom fields
- use dotted notation for semantic fields aligned with OpenTelemetry standards:
  - `service.name`
  - `service.version`
  - `http.method`
  - `http.route`
  - `http.status_code`
  - `error.code`
  - `error.message`
  - `exception.type`
- do not mix styles within the same document or service

Bad:

```json
{
  "traceId": "...",
  "operationId": "..."
}
```

Good:

```json
{
  "trace_id": "...",
  "operation_id": "..."
}
```

---

## 8. Frontend Logging

Frontend logs/events must follow the same schema where applicable.

Minimum fields:

- `timestamp`
- `level`
- `message`
- `service.name` = `iflot-web`
- `service.version`
- `trace_id`
- `operation_id`
- `flow_name`

Frontend logs should be used sparingly and focus on:

- flow start / success / failure
- API failures
- runtime errors

---

## 9. MDC Mapping (Backend)

Backend must map context into MDC:

| MDC Key | Log Field |
|---|---|
| `trace_id` | `trace_id` |
| `span_id` | `span_id` |
| `operation_id` | `operation_id` |
| `correlation_id` | `correlation_id` |
| `flow_name` | `flow_name` |
| `tenant_id` | `tenant_id` |

MDC must be:

- initialized at request entry
- cleared after request completion
- re-initialized at async boundaries

---

## 10. Logging Levels

| Level | Usage |
|---|---|
| `ERROR` | Failures and exceptions |
| `WARN` | Unexpected but recoverable issues |
| `INFO` | Key business events and lifecycle steps |
| `DEBUG` | Disabled in production |

---

## 11. Health Check Logs

Health check endpoints (e.g. `/actuator/health`, `/health`) must not produce
`INFO`-level logs in production.

Rule:

- health check requests must be excluded from access logs entirely, or
  logged at `DEBUG` level
- they must never appear in normal log streams at `INFO` or above

Rationale: health checks in Railway run continuously and produce hundreds of
log entries per hour with zero diagnostic value. Without this rule, they
contaminate Loki queries and inflate ingestion costs.

---

## 12. Sensitive Data Policy

The following must never be logged:

- passwords
- tokens (access/refresh)
- payment data
- full request bodies with sensitive fields
- credentials
- personal identifiable information beyond minimal context

Sensitive fields must be masked or omitted.

---

## 13. Anti-Patterns

**Do not log unstructured text**

Bad:
```
User failed login with id 123
```

**Do not log without correlation context**

Bad:
```json
{
  "message": "Something failed"
}
```

**Do not log high-cardinality data in metrics**

IDs belong in logs and traces, not in metrics.

**Do not include stack traces for known domain errors**

If the error has an explicit `error.code`, the stack trace is noise.
See Section 6 for the full policy.

**Do not log health check endpoints at INFO level**

See Section 11.

---

## 14. Example — Complete Log

```json
{
  "timestamp": "2026-04-18T10:20:00.123Z",
  "level": "INFO",
  "message": "Guide closed successfully",
  "service.name": "iflot-api",
  "service.version": "1.2.0",
  "environment": "dev",
  "trace_id": "4bf92f3577b34da6a3ce929d0e0e4736",
  "span_id": "00f067aa0ba902b7",
  "operation_id": "8e4f8d6f-88f0-48d4-b7ab-6c6522e4e3c5",
  "flow_name": "close_guide",
  "tenant_id": "tenant-1",
  "user_id": "user-42",
  "guide_id": "GUIDE-1001",
  "http.method": "POST",
  "http.route": "/api/v1/guides/{id}/close",
  "http.status_code": 200,
  "duration_ms": 320
}
```

---

## 15. Final Rule

Every log must answer:

- **what happened?** → `message`
- **where?** → `service.name`
- **which version?** → `service.version`
- **when?** → `timestamp`
- **in which flow?** → `flow_name`
- **for which operation?** → `operation_id`
- **in which execution?** → `trace_id`

If any of these is missing, the log is incomplete.