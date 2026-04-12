# Frontend Framework Evaluation (2025–2030)
## Technical Assessment + Junior Employability Benchmark (Spain & Italy)

**Author:** Kenny — Solutions Architect  
**Date:** April 2026  
**Purpose:** Complement the frontend team evaluation with project execution constraints and junior employability considerations.

---

## 1. Executive Summary

The frontend team report provides a technically strong evaluation of modern frontend frameworks, correctly identifying key trends such as:

- The shift toward **fine-grained reactivity**
- The performance advantages of **signal-based architectures**
- The structural overhead of Virtual DOM approaches

These conclusions are valid from a purely technical perspective.

However, the report does not sufficiently incorporate critical factors for this initiative:

- Project delivery risk
- Long-term maintainability
- Hiring and onboarding constraints
- Team scalability
- Junior employability (primary objective in this context)

This document extends the analysis by integrating **technical, operational, and market realities**, enabling a decision aligned with real-world execution.

---

## 2. Strengths of the Original Report

### 2.1 Reactivity Model Analysis

The explanation of React’s re-render behavior is accurate:

- Parent state changes cascade into child re-renders
- Memoization requires developer discipline
- Context updates propagate broadly

Signal-based approaches (Svelte, Solid):

- Enable more granular updates
- Reduce unnecessary computation
- Simplify mental models in many cases

This is a real architectural advantage.

---

### 2.2 Benchmark References

The use of **js-framework-benchmark** is appropriate for:

- DOM operation performance
- Memory usage
- Update latency

Solid.js and Svelte consistently lead in these benchmarks.

---

### 2.3 Developer Satisfaction Trends

The report correctly references:

- State of JS
- Stack Overflow surveys

Key signals:

- High satisfaction for Svelte and Solid
- Slight decline in React satisfaction over time

---

## 3. Limitations and Biases in the Report

### 3.1 Microbenchmarks vs Real Applications

Benchmarks do not reflect real applications that include:

- Authentication
- Forms and validation
- Tables and filtering
- API integration
- State orchestration
- Routing and navigation
- Error handling

In practice, performance issues are often driven by:

- Network latency
- Data flow design
- State management patterns

**Conclusion:**  
Benchmarks are informative, but insufficient to drive architectural decisions alone.

---

### 3.2 Bundle Size in Context

While framework size differs:

- HTTP/2
- CDN caching
- Lazy loading

...reduce its real impact.

Most bundle weight comes from domain dependencies.

**Conclusion:**  
Bundle size is not a primary decision driver.

---

### 3.3 Unsupported Productivity Claims

Claims such as:

> “25–40% faster development with Svelte”

are not supported by reproducible evidence.

They should be treated as qualitative, not quantitative.

---

### 3.4 Hiring Risk Underestimated

The original report underestimates:

- Hiring difficulty
- Replacement cost
- Team scaling constraints

**Conclusion:**  
Talent availability is a primary architectural concern.

---

### 3.5 Experimental Risk (Vue Vapor)

Vue Vapor is still experimental.

Using it as a strategic basis introduces instability risk.

---

### 3.6 Ecosystem Maturity Gap

React provides:

- Mature libraries (forms, tables, accessibility)
- Proven patterns
- Extensive documentation

Svelte/Solid require more custom solutions in complex cases.

---

## 4. Impact on Project Execution

This decision directly affects delivery risk.

### 4.1 Delivery Speed

| Framework | Delivery Risk |
|---|---|
| React | Low |
| Vue | Low-Medium |
| Svelte | Medium |
| Solid.js | Medium-High |

---

### 4.2 Maintainability

React offers:

- Standardized patterns
- Large knowledge base
- Faster onboarding

---

### 4.3 Dependency on Specific Profiles (Bus Factor)

| Framework | Dependency Risk |
|---|---|
| React | Low |
| Svelte | Medium |
| Solid.js | High |

---

### 4.4 Hiring and Scaling

A system must be maintainable by people we can realistically hire.

React clearly leads in this dimension.

---

## 5. Junior Job Market Benchmark: Spain and Italy

### 5.1 Active job volume — junior frontend profiles

Since one of the explicit goals of this initiative is to prepare junior developers for the job market, demand must be treated as a primary decision factor.

#### Spain

| Framework | Openings | Source | Relevance |
|---|---:|---|---|
| React | ~598 | LinkedIn ES (Apr 2026) | High |
| Angular | ~360 (est.) | Ratio-based | High |
| Vue | ~105 (est.) | Ratio-based | Medium |
| Svelte | <10 | Indeed ES | Marginal |
| Solid.js | <5 (est.) | — | Marginal |

#### Italy

| Framework | Openings | Source | Relevance |
|---|---:|---|---|
| React | 720+ (all levels) | Glassdoor IT | High |
| React (junior) | 73 | Indeed IT | High |
| Angular | ~400 (est.) | Ratio-based | High |
| Vue | ~100 (est.) | Ratio-based | Medium |
| Svelte | 6 | Glassdoor IT | Marginal |
| Solid.js | <3 (est.) | — | Marginal |

### 5.2 Structural Market Signal

Global analysis (~650K jobs):

- React: ~55%
- Angular: ~32%
- Vue: ~10%
- Others (Svelte, Solid, etc.): ~4%

**Conclusion:**  
The employability gap is structural, not marginal.

---

### 5.3 Why This Matters

**Key statement:**

> A junior developer does not enter the market by using the best framework, but by using the most demanded one.

---

### 5.4 Implication

- React maximizes employability
- Svelte/Solid provide differentiation, not access

---

## 6. Adjusted Evaluation Matrix

| Framework | Original | Adjusted |
|---|---|---|
| Svelte | 8.9 | 8.1 |
| Vue | 8.2 | 8.0 |
| Solid | 8.2 | 7.8 |
| React | 7.2 | 8.0 |

---

## 7. Strategic Interpretation

The original report answers:

> “What is technically superior?”

This document answers:

> “What maximizes success under real-world constraints?”

---

## 8. Final Position

### Production Stack
- React

### Conceptual Exposure
- Svelte 5
- Solid.js

---

## 9. Key Takeaway

The goal is not to use the most advanced framework.

The goal is to:

- Deliver reliably
- Scale the team
- Maintain the system
- Enable junior employability

---

## 10. Relationship with ADR

This document supports:

- `/docs/adr/ADR-002-frontend-framework.md`

The ADR defines the decision.  
This document provides the reasoning.

---

## 11. Final Statement

For this initiative, junior job demand is a primary decision driver.

Because the project also serves as a training platform, the selected stack must maximize both:

- delivery success
- employability

Under current conditions in Spain and Italy, React is the only framework that satisfies both.

---

**End of document**