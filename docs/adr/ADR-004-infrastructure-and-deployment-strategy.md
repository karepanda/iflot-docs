# ADR-004 — Infrastructure and Deployment Strategy

**Status:** Accepted
**Date:** April 2026
**Authors:** Architecture Lead

---

## Context

iFlot 2026 is in POC phase. The infrastructure decisions made at this stage must
satisfy three simultaneous goals:

- **Deliver a real, accessible environment** — stakeholders and customers must be
  able to see and interact with the system online without local setup.
- **Provide a realistic learning environment** — junior developers must be exposed
  to production-grade deployment practices, not abstractions that hide how
  software actually runs.
- **Minimize operational overhead** — there is no dedicated infrastructure team.
  The architecture team owns deployment alongside product development.

These goals rule out both ends of the spectrum: a purely local setup (not
accessible to stakeholders) and a full cloud-native Kubernetes setup (too much
operational overhead for a POC phase).

---

## Decision

### Deployment platform

**Railway** is the selected deployment platform for the POC.

Railway provides container-based deployments with git-push workflows, managed
PostgreSQL, per-service environment variables, and a usage-based pricing model
that keeps costs predictable at low traffic volumes.

The Hobby plan ($5/month) covers the full POC stack within its resource limits
and removes the 5-service cap of the free trial.

### Containerization

**Docker** is the selected containerization mechanism for all services.

Every service is deployed as a Docker container built from an explicit
`Dockerfile`. Railway's automatic framework detection is not used. The explicit
`Dockerfile` approach is chosen deliberately:

- Junior developers see exactly how the artifact is built and packaged
- The same `Dockerfile` runs locally and in Railway — no environment-specific
  build logic
- The build process is transparent, reproducible, and transferable to any
  container-based platform

### Services

The POC runs four services on Railway:

| Service | Image | Purpose |
|---|---|---|
| `iflot-web` | Custom `Dockerfile` — React + Nginx | SPA served as static files |
| `iflot-api` | Custom `Dockerfile` — Java 21 + Spring Boot | Backend REST API |
| `postgresql` | Railway managed PostgreSQL 16 | Operational database |
| `otel-lgtm` | `grafana/otel-lgtm` | Full observability stack |

Four services fit within Railway's trial limit and remain well within Hobby plan
resources at POC traffic levels.

### Local development

Local development uses **Docker Compose** with the same images used in Railway.

The `docker-compose.yml` runs all four services locally, including the
observability stack. This gives junior developers a complete environment on their
machines that behaves identically to the Railway deployment.

Environment variables are managed via `.env` files locally and via Railway's
environment variable panel in the deployed environment. The `.env.example` file
documents all required variables without exposing values.

### Environment variable strategy

| Variable scope | Local | Railway |
|---|---|---|
| Database URL | `.env` | Railway environment panel |
| JWT secret | `.env` | Railway environment panel |
| OTLP endpoint | `.env` | Railway environment panel |
| Spring profile | `.env` | Railway environment panel |

No secrets are committed to the repository. The `.env` file is listed in
`.gitignore`. The `.env.example` file is committed and kept current.

---

## Rationale

**Why Railway over alternatives?**
Railway provides a balance of simplicity, real container execution, and cost
predictability that alternatives do not match at this phase. Fly.io requires more
configuration. Render's free tier has cold start limitations. A self-hosted VPS
adds operational overhead that is not justified at POC stage. Heroku's pricing
makes it uncompetitive for small teams.

**Why Docker over Railway's automatic detection?**
Railway can deploy Spring Boot and React applications without a `Dockerfile` using
Nixpacks. This is explicitly rejected for this project. The goal is not the
fastest possible deployment path — it is a deployment path that junior developers
understand and can reproduce, debug, and extend. An explicit `Dockerfile` achieves
that. Nixpacks abstracts it away.

**Why four services and not more?**
The observability stack (`grafana/otel-lgtm`) is a single container that bundles
Grafana Alloy, Loki, Tempo, and Grafana. Splitting these into separate services
would consume Railway service slots without architectural benefit at this scale.
The consolidated image is appropriate for POC and junior learning purposes.

**Why not Kubernetes?**
No operational justification at this phase. A single-team POC with one customer
does not need orchestration, autoscaling, or the operational complexity that
Kubernetes introduces. The selected stack is explicitly designed to be replaceable
— migrating to Kubernetes later requires infrastructure changes only, not
application changes.

**Why keep observability in Railway and not local-only?**
Junior developers must see observability working in a real deployed environment,
not only on their local machines. Dashboards, traces, and logs from live traffic
provide learning value that a local setup cannot replicate. The cost of one
additional Railway service is justified by this pedagogical goal.

---

## Consequences

- Every service has an explicit `Dockerfile` — no magic build detection.
- The local `docker-compose.yml` is the authoritative reference for how services
  connect, what environment variables they need, and what ports they expose.
- Deploying to Railway requires no new knowledge beyond Docker — the same
  container that runs locally is what gets deployed.
- Secrets management is simple but manual at this phase — Railway's environment
  panel is the secrets store. This is acceptable for POC and must be revisited
  before any production deployment.
- The four-service limit means no additional Railway services may be added to
  the Hobby plan without upgrading to Pro ($20/month) or consolidating existing
  services.
- Platform migration (Railway → any container platform) requires only
  infrastructure configuration changes. Application code has no Railway-specific
  dependencies.

---

## Alternatives considered

**Fly.io**
Rejected. More configuration required for networking between services. Railway's
managed PostgreSQL and simpler service linking are better suited for the team's
current capacity.

**Render**
Rejected. Free tier services sleep after inactivity, which produces poor demo
experience. Paid tier pricing is less competitive than Railway for this service
count.

**Self-hosted VPS**
Rejected. Adds server administration overhead with no benefit at POC scale.
Introduces operational risk that the team should not carry at this phase.

**Railway with Nixpacks (no Dockerfile)**
Rejected. Hides the build process from junior developers. The explicit
`Dockerfile` approach is a deliberate pedagogical choice, not a technical
requirement.

**Kubernetes (any provider)**
Rejected. No operational driver at POC scale. Complexity cost is not justified.
Migration path is preserved — application code is container-native and
platform-agnostic.