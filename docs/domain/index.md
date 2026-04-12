# Domain

This section documents the business domain, core concepts, and shared language
used across iFlot.

## Purpose

Domain documentation exists to create a shared understanding between everyone
working on the project: developers, designers, product leads, and business
stakeholders.

When everyone uses the same terms to mean the same things, conversations are
faster, requirements are clearer, and the system reflects the business more
accurately.

## Ubiquitous language

The following terms have specific meanings in the iFlot domain. They should be
used consistently across code, documentation, and conversation.

**Cargo guide.** The central operational document in iFlot. A guide is not a
document attachment — it drives operations, controls billing eligibility, and
carries lifecycle states that directly block or enable downstream processes.
Every billing failure in the legacy record traces to a guide in the wrong state.

**Trip.** The operational unit connecting vehicle, driver, route, and cargo
guides. A trip has explicit lifecycle states with real downstream effects. The
distinction between a persisted trip and an operationally closed trip is
consequential — an unclosed trip cannot contribute to billing.

**Operational close.** The explicit action that marks a trip as complete and
its associated guides as candidates for billing. Operational close is not
implied by saving a record — it requires defined preconditions to be met.

**Pre-invoice (prefactura).** A billing document generated from cargo guides
that have reached a billable terminal state. A pre-invoice total is
deterministic given its eligible guides. A zero-value result where eligible
guides exist is a domain error, not a valid outcome.

**Billing eligibility.** The condition of a cargo guide that allows it to be
included in a pre-invoice. Eligibility is determined by the guide's lifecycle
state, not by data entry alone. Missing tariff or payment method makes a guide
ineligible.

**Pre-cancellation.** A controlled document that formally initiates the
cancellation of a cargo relationship. It has a unique correlative, is immutable
after emission, and can only be annulled through a formal traceable process.

**Correlative.** A sequential document number with audit significance. In LATAM
logistics, document correlativity carries administrative and potentially fiscal
implications. Gaps in correlatives must be traceable — unexplained gaps are a
domain error.

**Tariff.** The rate applied to a cargo guide that determines its billing value.
Unresolved tariff is a blocking condition — no guide with an unresolved tariff
may be considered billable.

**Payment method.** A required attribute for a guide to be billable. A guide
without a valid payment method must be rejected at creation time, not discovered
as invalid at billing time.

**Freight payable at destination.** A service or billing modality observed
consistently across the legacy system in operational screens, billing reports,
and cancellation flows. Its exact nature — whether it is a guide type, a
billing category, a service modality, or a flow variant — is an open discovery
question. The billing model cannot be finalized until this is resolved.

**Operational expense.** A cost traceable to a specific operational unit, at
minimum to a trip. Trip-level expense traceability is the confirmed minimum
from historical evidence.

**Privileged action.** An action that overrides normal state transitions or
accesses system controls. Privileged actions require elevated authorization
defined within the product and produce an immutable audit record including
actor, timestamp, reason, and prior state.

## Current status

The domain vocabulary above is grounded in historical evidence from the legacy
system. It represents the best current understanding of the domain before
discovery sessions with active operators are completed.

Discovery will validate, refine, or challenge these definitions. Any term whose
meaning changes as a result of discovery must be updated here before it is used
as input to domain modeling or implementation.

## What will be added here

As discovery progresses and the domain model is formalized, this section will
include:

- entity relationships and aggregate boundaries
- lifecycle state diagrams for cargo guides and trips
- business rules and invariants per domain concept
- domain events and their downstream effects
- glossary expansions as new concepts are confirmed