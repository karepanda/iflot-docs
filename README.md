# iflot-docs

Central documentation repository for iFlot.

## Purpose

This repository is the single source of truth for project-level documentation,
covering product vision, architecture decisions, domain context, engineering
guidelines, and onboarding.

It is intended for both technical and non-technical readers. Product and business
context lives alongside architecture and engineering content.

## Documentation site

The documentation is published via GitHub Pages and deployed automatically on
every push to `main`.

The deployed URL is shown in the workflow summary after each run.

## Structure

```text
docs/
  index.md              # Home
  vision/               # Product intent and direction
  overview/             # Problem, target clients, value proposition, status
  architecture/         # Technical structure and decisions
  adr/                  # Architecture Decision Records
  analysis/             # Supporting analysis documents
  domain/               # Business concepts and language
  design/               # UX context and Figma references
  engineering/          # Standards and implementation guidelines
  discovery/            # Discovery findings and open questions
  onboarding/           # How to get started
```

## Design source of truth

Figma is the single source of truth for UI design.

This repository documents design context, decisions, and links to Figma.
It does not store design assets.

## Run locally

```bash
pip install -r requirements.txt
mkdocs serve
```

## Build

```bash
mkdocs build
```

## Section owners

| Section       | Owner              |
|---------------|--------------------|
| Architecture  | @architecture-lead |
| ADR           | @architecture-lead |
| Engineering   | @tech-lead         |
| Design        | @design-lead       |
| Onboarding    | @team-lead         |

> Update this table and `CODEOWNERS` when ownership changes.