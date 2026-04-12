# Design

This section documents design principles, UX context, and references to the
iFlot design files.

## Source of truth

Figma is the single source of truth for UI design.

This repository documents design context, decisions, and links to Figma.
It does not store design assets, mockups, or exported images as a primary
source. When a design decision has architectural or product implications, it
is documented here alongside the Figma reference.

## Design files

Figma links will be added here once the design workspace is shared.

See [figma-links.md](figma-links.md) for the current reference list.

## Design principles

These principles guide UI and UX decisions for iFlot and apply regardless
of the specific component or screen being designed.

**Reflect operational reality.** The interface must represent the actual state
of operational records accurately. A trip that is not operationally closed must
not appear as complete. A guide that is not billable must not appear eligible.
The UI inherits the same integrity requirements as the domain.

**Make state visible.** Lifecycle states of cargo guides and trips are
consequential. The interface must surface state explicitly so operators know
what is complete, what is pending, and what is blocked — without having to
attempt an action to find out.

**Surface errors at the right moment.** Errors caused by missing tariff,
missing payment method, or incomplete operational close must appear at the
point of entry, not at billing time. The interface must enforce domain
preconditions, not defer them.

**Optimize for operational efficiency.** The primary users are logistics
operators managing daily workloads. Interfaces must minimize steps for
frequent actions and reduce cognitive load during high-volume periods such
as month-end close.

**Support privileged actions safely.** Actions that override normal state
transitions require elevated authorization. The interface must make these
actions visible, intentional, and auditable — not hidden or easy to trigger
accidentally.

## Current status

Design work is in early stage, aligned with the discovery and technical
foundation phase of the project.

UI design will be developed in Figma by the design lead. Links and context
will be added to this section as screens and flows are produced.