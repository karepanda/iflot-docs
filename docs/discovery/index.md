# Discovery

This section captures findings, open questions, and context gathered during
the early phase of the iFlot project.

## Purpose

Discovery exists to validate assumptions before they become architecture.

The legacy system that preceded iFlot was used in real production conditions
for over a decade. That history provides strong domain signals, but it is
evidence of real business needs — not a specification for the new product.

Discovery sessions with active legacy customers are the primary mechanism for
validating, refining, or challenging what the historical record suggests.

## Current phase

Active discovery. Sessions with legacy customers are pending or in progress.

No assumption in this section should be treated as confirmed until it has been
validated through direct operator input.

## What is known

The following signals come from historical evidence: product manuals,
operational emails, bug reports, and change request threads from production use.

**Cargo guides are central to everything.** Guides are not document attachments.
They drive operations, control billing eligibility, and carry lifecycle states
that directly block or enable downstream processes.

**Trip lifecycle is explicit and consequential.** The distinction between a
persisted trip and an operationally complete trip was a recurring failure point
in the legacy system.

**Billing depends on operational state, not just data entry.** A guide in the
wrong state produced a zero-value pre-invoice or was silently excluded. Billing
is downstream of operational closure, not parallel to it.

**Tariff and payment method are blocking data.** Their absence was accepted
silently in the legacy and discovered only at billing time.

**Sensitive actions required vendor intervention.** No in-product elevated
operator role existed, creating an operational dependency on the software vendor
for routine administrative tasks.

**Reporting was operationally load-bearing.** Month-end close depended on
reports that were repeatedly requested and repeatedly broken in the legacy.

## What is still unresolved

The following questions must be answered through discovery before deeper domain
modeling can proceed.

**What triggers the operation?** Does the process begin with a client request,
a freight order, a cargo guide, or a trip? This determines the root aggregate
and the entry point of the transport operations context.

**What is the structural relationship between guide and trip?** Cardinality and
dependency direction between the two most critical entities are not yet confirmed.

**What does freight payable at destination mean operationally?** It appeared
across operational screens, billing reports, and cancellation flows across
multiple years. Whether it is a guide type, a billing category, or a flow
variant is unresolved — and the billing model cannot be finalized without it.

**What are the preconditions for pre-invoice generation?** Whether billing rules
are uniform or parameterized by client, service type, or route is not confirmed.

**What lives outside the system today?** Every workaround in Excel, WhatsApp,
or paper marks a capability gap and a potential differentiator.

**Is route a strong domain entity or a label?** If route carries business rules,
it is an aggregate. If it is an origin-destination label, it is a value object.
The answer determines how tariff resolution is modeled.

## Discovery objectives

The sessions with legacy customers have three named objectives:

1. Validate or challenge the domain signals listed above
2. Resolve the structural question around freight payable at destination
3. Identify what operators manage outside the system today

## Where findings will live

Each discovery session will produce a structured output document in this
section mapping findings to domain implications and open or updated decisions.

Session notes alone are not sufficient. Every finding must connect to a
specific architectural decision it closes or a capability assumption it updates.