# Flow SLO Catalog

This document defines the Service Level Objectives (SLOs) for iFlot.

SLOs are defined at the **business flow level**, not at the service or endpoint level.

---

## 1. Purpose

SLOs are used to:

- define acceptable reliability for user-facing flows
- measure system performance over time
- detect degradation early
- prioritize engineering work

SLOs are not goals for individual services.
They represent **what the user experiences**.

---

## 2. Core Principle

The primary unit of reliability is the **business flow**.

Flows in scope for this catalog:

- `login`
- `create_trip`
- `close_trip`
- `close_guide`
- `generate_preinvoice`

Each flow must have:

- an availability SLO with an explicit SLI formula
- a latency SLO with an explicit SLI formula and a declared measurement layer

---

## 3. SLO Model

Each flow defines two SLOs.

### 3.1 Availability SLO

> Percentage of successful flow executions over the measurement window.

SLI formula (general):

```text
availability = flow.completed{flow_name=X} / flow.started{flow_name=X}
```

### 3.2 Latency SLO

> Percentage of executions completed within an acceptable time threshold.

SLI formula (general):

```text
latency_SLO = histogram_quantile(0.95, ui.flow.duration{flow_name=X}) < threshold
```

Latency SLOs are measured from the **frontend layer** (`ui.flow.duration`)
unless otherwise stated. Frontend latency is authoritative because it captures
real user-perceived time including network and rendering.

Backend `flow.duration` is used as a **diagnostic signal**, not as the SLO
measurement source.

---

## 4. Measurement Sources

SLOs combine signals from:

| Layer | Metric | Role |
|---|---|---|
| Frontend | `ui.flow.duration`, `ui.fci`, `ui.errors` | Authoritative for SLOs |
| Backend | `flow.duration`, `flow.failed`, `http.server.requests` | Diagnostic |
| System | JVM / infra metrics | Supporting context only |

---

## 5. Error Budget

Error budget represents the allowed unreliability within a measurement window.

**Standard window: 30 days.**

Formula:

```text
error_budget_minutes = (1 - SLO_target) × 30 × 24 × 60
```

Examples:

| SLO Target | Error Budget (30 days) |
|---|---|
| 99.5% | 216 minutes |
| 99% | 432 minutes |
| 98.5% | 648 minutes |

Error budget is consumed by both availability failures and latency violations.
When the budget is exhausted, reliability work takes priority over feature work.

---

## 6. Burn Rate Alerts

Burn rate measures how fast the error budget is being consumed relative to
the allowed rate. A burn rate of 1x means the budget is being consumed at
exactly the pace that would exhaust it at the end of the 30-day window.

Burn rate thresholds depend on the SLO target. The values below are
**reference starting points** and must be validated against real traffic.

### 6.1 Fast Burn (critical)

Detects rapid degradation. Triggers a critical alert.

Reference:

- burn rate > 14x over 5 minutes
- applicable when SLO target ≥ 99%

> At 14x burn rate, 1 hour of degradation consumes ~58% of a monthly budget.

### 6.2 Slow Burn (warning)

Detects sustained degradation that would exhaust the budget before month end.

Reference:

- burn rate > 2x over 1 hour

> **Important:** These multipliers are derived from the Google SRE Workbook
> model for a 99.9% SLO with a 30-day window. At lower SLO targets (99%,
> 98.5%), the same multipliers produce different effective sensitivities.
> Recalibrate after the first month of real traffic.

---

## 7. Flow SLO Definitions

---

### 7.1 Login

**Availability**

SLI:

```text
ui.flow.completed{flow_name="login"} / ui.flow.started{flow_name="login"}
```

Target: **99.5%** — 216 minutes error budget / 30 days

**Latency**

SLI:

```text
histogram_quantile(0.95, ui.flow.duration{flow_name="login"}) < 1.5s
```

Target: **95% of executions < 1.5s** (measured from frontend)

---

### 7.2 Create Trip

**Availability**

SLI:

```text
flow.completed{flow_name="create_trip"} / flow.started{flow_name="create_trip"}
```

> Backend metric used here because trip creation is a multi-step form. The
> frontend flow completion maps directly to the backend commit.

Target: **99%** — 432 minutes error budget / 30 days

**Latency**

SLI:

```text
histogram_quantile(0.95, ui.flow.duration{flow_name="create_trip"}) < 2.5s
```

Target: **95% of executions < 2.5s** (measured from frontend)

Diagnostic reference (backend):

```text
histogram_quantile(0.95, flow.duration{flow_name="create_trip"}) < 1.5s
```

---

### 7.3 Close Trip

**Availability**

SLI:

```text
flow.completed{flow_name="close_trip"} / flow.started{flow_name="close_trip"}
```

Target: **99%** — 432 minutes error budget / 30 days

**Latency**

SLI:

```text
histogram_quantile(0.95, ui.flow.duration{flow_name="close_trip"}) < 2s
```

Target: **95% of executions < 2s** (measured from frontend)

Diagnostic reference (backend):

```text
histogram_quantile(0.95, flow.duration{flow_name="close_trip"}) < 1.2s
```

---

### 7.4 Close Guide

**Availability**

SLI:

```text
flow.completed{flow_name="close_guide"} / flow.started{flow_name="close_guide"}
```

Target: **99%** — 432 minutes error budget / 30 days

**Latency**

SLI:

```text
histogram_quantile(0.95, ui.flow.duration{flow_name="close_guide"}) < 2s
```

Target: **95% of executions < 2s** (measured from frontend)

Diagnostic reference (backend):

```text
histogram_quantile(0.95, flow.duration{flow_name="close_guide"}) < 1.2s
```

---

### 7.5 Generate Pre-Invoice

**Availability**

SLI:

```text
flow.completed{flow_name="generate_preinvoice"} / flow.started{flow_name="generate_preinvoice"}
```

Target: **98.5%** — 648 minutes error budget / 30 days

> Lower target reflects domain complexity: pre-invoice generation depends on
> guide state validation, tariff resolution, and payment method enforcement.
> Failures are more likely to be domain errors than infrastructure failures.

**Latency**

SLI:

```text
histogram_quantile(0.95, ui.flow.duration{flow_name="generate_preinvoice"}) < 3s
```

Target: **95% of executions < 3s** (measured from frontend)

Diagnostic reference (backend):

```text
histogram_quantile(0.95, flow.duration{flow_name="generate_preinvoice"}) < 2s
```

---

## 8. FCI as a Supporting Indicator

`ui.fci` (First Contentful Interaction) measures the time from a user action
until the resulting UI is interactive. It is an early user experience signal.

**`ui.fci` is not a replacement for `ui.flow.duration`.**

It measures a different thing: when the user can start interacting, not when
the operation has completed. See `metric-catalog.md` Section 15 for the
distinction.

FCI reference targets (not formal SLOs):

| Flow | `ui.fci` target |
|---|---|
| `create_trip` | < 800ms |
| `close_guide` | < 600ms |
| `generate_preinvoice` | < 1s |

These are **indicators**, not SLO commitments. They inform UX decisions and
help identify frontend rendering bottlenecks independent of backend latency.

---

## 9. Frontend vs Backend SLOs

| Dimension | Frontend | Backend |
|---|---|---|
| Role | **Authoritative** for SLOs | **Diagnostic** |
| Captures | User-perceived latency, render time, network | Server execution time |
| When they diverge | Backend healthy, frontend broken | Backend slow, frontend cached |

When frontend and backend metrics diverge, investigate:

- CDN or caching issues
- Network latency between client and server
- Frontend rendering bottlenecks
- Backend-only degradation not visible to the user

---

## 10. SLO Summary Table

| Flow | Availability Target | Latency Target (P95) | Error Budget (30d) |
|---|---|---|---|
| `login` | 99.5% | < 1.5s | 216 min |
| `create_trip` | 99% | < 2.5s | 432 min |
| `close_trip` | 99% | < 2s | 432 min |
| `close_guide` | 99% | < 2s | 432 min |
| `generate_preinvoice` | 98.5% | < 3s | 648 min |

---

## 11. SLO Evolution

SLOs are not static. Initial targets are conservative estimates without real
traffic data. They must be revised.

**Review cadence:**

- after the first 30 days of production traffic: review all targets against
  actual P95 measurements
- quarterly thereafter: adjust targets based on user expectations and system
  maturity
- after any significant architecture change: reassess affected flows

**Rules:**

- do not tighten targets before 30 days of real traffic exist
- do not set targets below what the system can actually sustain
- document the reason for any target change in this file with a date

**Process:**

1. review actual P95 for each flow over the last 30 days
2. compare against current target
3. identify flows consistently within target vs flows burning budget
4. propose adjustments with justification
5. update this document and the corresponding Grafana SLO definitions

---

## 12. Dashboard Requirements

Each flow must have a dashboard panel showing:

- success rate (current window vs target)
- error rate trend
- latency percentiles: P50 / P95 / P99
- error budget remaining (% and minutes)
- recent failures with trace correlation link

---

## 13. Anti-Patterns

### SLO per endpoint instead of per flow

Bad:

```text
POST /api/v1/trips latency SLO
```

Good:

```text
create_trip flow SLO
```

### Using logs as SLI source

Logs are not reliable counters — they can be dropped, sampled, or delayed.
Use metrics (`flow.completed`, `flow.failed`) as SLI sources.

### Backend-only SLOs

Backend healthy does not mean user experience is healthy. Frontend metrics
are required. A backend-only SLO is incomplete by definition.

### Premature tight targets

Setting 99.9% targets before real traffic data exists creates false urgency
and distorts engineering priorities. Start conservative, tighten with data.

### Static SLOs

SLOs that are never revised become meaningless over time. Apply the review
cadence defined in Section 11.

---

## 14. Final Rule

A flow has a valid SLO if and only if you can answer:

- **is this flow healthy right now?** → availability SLI with current data
- **how fast is it for the user?** → latency SLI from frontend layer
- **how much budget remains this month?** → error budget with known window
- **will we know before the budget is exhausted?** → burn rate alerts defined

If any of these cannot be answered, the SLO is incomplete.