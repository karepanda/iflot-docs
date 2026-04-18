# Observability

This section defines how iFlot implements observability across frontend and backend.

Observability is treated as a core engineering capability, not as an optional
or late-stage concern. It enables teams to understand system behavior,
measure reliability, and diagnose issues across the entire user journey.

## Scope

Observability in iFlot is built on four complementary signals:

- **Logs** — structured diagnostic events
- **Traces** — end-to-end execution visibility
- **Metrics** — quantitative system and business measurements
- **SLOs** — reliability targets for critical user flows

All four must work together. No single signal is sufficient on its own.

## Core principle

The primary unit of observability in iFlot is the **business flow**.

Examples:

- `login`
- `create_trip`
- `close_trip`
- `close_guide`
- `generate_preinvoice`

Every critical flow must be observable:

- from the user action in the frontend
- through backend execution
- across future asynchronous steps

## Correlation model

iFlot uses three complementary identifiers:

- **`trace_id`** — technical correlation (OpenTelemetry)
- **`operation_id`** — business flow correlation
- **`X-Correlation-ID`** — request/support correlation

Each serves a different purpose and must not be conflated.

Full definition:

→ [Context Propagation Standard](./context-propagation-standard.md)

## Observability architecture

iFlot uses the following model:

- **OpenTelemetry** for instrumentation (frontend and backend)
- **Grafana Alloy** in Railway as the telemetry collector
- **Grafana Cloud** as the backend for:
  - traces
  - metrics
  - logs
  - dashboards
  - SLOs

Frontend and backend do not send telemetry directly to Grafana Cloud.
All telemetry flows through Alloy.

## Standards in this section

The following documents define implementation standards:

- [Context Propagation Standard](./context-propagation-standard.md)  
  Defines how correlation identifiers are generated and propagated across
  frontend, backend, and async flows.

- `log-schema.md` *(to be created)*  
  Defines the JSON structure for logs and required fields.

- `metric-catalog.md` *(to be created)*  
  Defines metric naming, tagging, and allowed dimensions.

- `flow-slo-catalog.md` *(to be created)*  
  Defines SLOs per business flow.

- `dashboard-baseline.md` *(to be created)*  
  Defines the minimum dashboards required for operation.

- `alerting-baseline.md` *(to be created)*  
  Defines alerting strategy and burn-rate policies.

## Frontend responsibilities

The frontend is responsible for:

- generating `operation_id` for user-initiated flows
- propagating trace context (`traceparent`)
- sending `X-Operation-Id` with API requests
- capturing user-visible latency and failures
- emitting telemetry for flow start, success, and failure

## Backend responsibilities

The backend is responsible for:

- preserving and propagating all correlation identifiers
- generating identifiers when required by the standard
- enriching logs with contextual data (MDC)
- exposing metrics through Micrometer
- creating spans for relevant execution steps
- returning correlation headers in responses

## Logging principles

- Logs must be structured (JSON)
- Logs must include correlation identifiers
- Logs must avoid sensitive data
- Logs must prioritize signal over volume

Logs are used for diagnosis, not for primary measurement.

## Metrics principles

- Metrics must be low-cardinality
- Metrics must be stable over time
- Business metrics are exploratory during discovery
- High-cardinality identifiers (user_id, operation_id) must not be used as labels

## Tracing principles

- Trace context follows W3C Trace Context
- Frontend and backend traces must be connected
- Manual spans are added only where they provide value
- Async flows may create new traces but must preserve `operation_id`

## SLO principles

- SLOs are defined per business flow
- Not per service or endpoint
- At least:
  - availability SLO
  - latency SLO
- Based on real user experience

## Cost awareness

Grafana Cloud free tier is sufficient for development and early stages.

Telemetry volume — especially traces — must be monitored.

If costs grow beyond acceptable limits, alternative deployment models will be evaluated.

## Current status

Observability standards are being defined early to avoid fragmentation later.

Implementation will begin with:

1. context propagation
2. backend structured logging
3. basic tracing
4. baseline metrics
5. initial flow-level SLOs

Additional detail will be added as real usage patterns emerge.