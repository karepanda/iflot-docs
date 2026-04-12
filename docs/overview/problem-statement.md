# Problem Statement

## Context

Mid-market logistics companies in LATAM handle significant operational volume daily: trips, cargo guides, freight assignments, and billing cycles.

The systems supporting these activities are typically fragmented, partially manual, or a combination of both.

This is not a perception. It is documented behavior from over a decade of production use of the legacy system that preceded iFlot, including operational emails, bug reports, and direct customer feedback.

## How operations work today

In the segment iFlot targets, the typical pattern is:

- trips are registered in a system or spreadsheet
- cargo guides are managed separately, often in disconnected tools
- billing depends on manual consolidation of operational records
- month-end close requires reconciliation across sources that were never designed to work together

This gap is not just inefficiency. It is a structural disconnect between what happens operationally and what is ultimately invoiced.

## The core problem

Billing eligibility depends on operational state.

A cargo guide must reach a specific lifecycle state before it can be included in a pre-invoice. If that state is not reached, or if the connection between the guide and the trip is not explicit and traceable, the billing process breaks down.

In practice, this results in:

- pre-invoices generated with zero value because guides were in the wrong state
- billing errors discovered at month-end instead of at the time of execution
- manual corrections that require specific people or vendor intervention
- no clear audit trail between what was executed and what was invoiced

The monthly close is not a reporting problem. It is an operational integrity problem.

## Why existing solutions fall short

Existing tools address adjacent problems, not this one:

- fleet management systems handle vehicle and asset administration
- telematics platforms handle location and tracking
- accounting systems handle financial records after the fact

None of these solutions natively connect cargo documentation, operational closing, and billing generation in a single traceable flow.

Companies in this segment are left to bridge that gap manually.

## Problem framing

The problem is not a lack of tracking or data.

The problem is the absence of a unified operational and administrative layer that enforces the connection between:

- cargo guide lifecycle
- trip operational close
- billing eligibility
- financial consistency at period close

Without that layer, companies cannot reliably close the loop between what was executed and what is invoiced.

They compensate with manual work, delayed validation, and high dependency on specific people.

That is the problem iFlot is designed to solve: closing the loop between operational execution and billing with full traceability and consistency.