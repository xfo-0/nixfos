## Context

This change captures a research program, not a build. Its job is to *derive* the
principles by which den's aspect ontology is organized, from ground truth, rather
than impose a taxonomy. The conceptual foundation below is the recorded basis the
program iterates on; the phases (see `tasks.md`) are how it is carried out.

## The core problem: imposed vs. derived topology

den's pipeline never consults facter (or any factor) during aspect traversal.
Inclusion is either declared (`den.schema.host.includes` = every host) or predicated
on context *name*. Factors enter one layer down, as NixOS config gated by `mkIf`. So
the den structural graph asserts a flat, universal membership and the NixOS
value-fixpoint silently switches aspects off where their (unstated) factor is false.
The true topology — "this aspect exists *because* a factor holds" — is latent. Reform
= lift the latent conditioning up into structural edges, where the factor surface is
the ground the reduction is answerable to.

## Two stacked fixpoints

- **den fixpoint (structural):** `resolve → compile → gate → emit-classes → assemble`.
  Today eager and name-driven; produces the NixOS module set.
- **NixOS fixpoint (values):** module merge — options ⊕ config, `mkIf`/`mkMerge` —
  → `toplevel`.

Empiricism currently lands in the second fixpoint (`mkIf`). The program's target is
to express it in the first.

## Three edge-classes (the canonical basis)

Every relation is exactly one of three kinds; the verbs derive / inherit /
consolidate map one-to-one:

| Verb | Edge-class | Direction | Source of truth | den primitive (v1→v2) | Today |
|------|-----------|-----------|-----------------|-----------------------|-------|
| derive | factor ⊢ node | ground→node | facter / facts / capability / role | (none — in `mkIf`) | **the gap** |
| inherit | eligibility/scope | parent→child | host-type, capability | `includes`→`edge`, `exclude`→`drop` | exists |
| consolidate | contribution | concrete→abstract | leaf aspects | `route`→`reroute`, `provide`→`inject`, `collect`→`gather`, `expose`→`ascend` | exists |

The reform's gap is edge-class #1. #2 and #3 are already first-class in den.

## Factors are multi-source (not facter-only)

The conditioning surface: platform, host-identity, host-type, hardware-presence
(facter), capability, role, user-presence, settings-knob, sub-selection,
cross-entity. Each has a source of truth, a natural scope/tier, and a pattern that
*should* carry it. A **pattern discrepancy** is a factor carried by the wrong
pattern, placed by the wrong axis, duplicated, conflated, or resting on a stale
source. Discrepancies are how **relevancies** (the functional dependencies
factor→placement) are discovered — the analytic instrument is schema normalization:
relevancy = functional dependency, discrepancy = FD violation, design principles =
the normal form, convergence = a design fixpoint (a new principle adds zero new
discrepancies).

## The substrate: why normalization is canonical

Every framework (nixpkgs / home-manager / hjem / den) is a *presentation* over the
same substrate: a (near-)commutative monoid of modules under merge — identity `{}`,
associativity, commutativity via `mkMerge`/priorities. Apparent cross-cutting
complexity (category-theoretic tangles) is presentation, not substance. Category
theory is a valid cross-section (a functor between presentations) but **not
load-bearing**: the functional substrate already guarantees a unique normal form.
This is why "normalization is foremost" is well-posed — the canonical form exists
because the foundation is functional. CT is an optional lens, never a dependency.

## DAG vs. linear resolution

Dependencies like `boot → kernel → nvme → nvme-cli` form a partial order (DAG); Nix
eval and tools like disko impose a topological linearization. The relation is "not
linear on first glance, but must fit the linear resolution pipeline." P2 recovers the
DAG (transitive reduction = minimal edges) and P3 proves it admits a consistent
linearization the pipeline respects (acyclic ⇒ topo-sort exists).

## Determinism without overfitting

Goal: isolate focal points (canonical nodes) specific enough that every config
resolves identically (deterministic) yet general enough to transfer across frameworks
(no memorizing `~/nx` accidents). This is bias–variance for design. "Isolating
characteristics + endpoint interconnections" = define each node by its distinguishing
features and its clean API edges; regularize toward the *minimal* principle set that
explains the data. Cross-framework validation (does a principle derived on nixos hold
for hjem?) is the held-out test against overfit.

## Lineage as template — and the deliverable

The abstraction lineage — `path-import → digga/std → hive → imports-list →
import-tree → dendritic → aspects → den` — is a chain where each link refined a
primitive and exposed a cleaner endpoint API, enabling refactor without internal
knowledge. The program's output is the **next link**: the *designation layer* — the
principled API between the option-trees and aspects. The program's *method* must
share that property (idempotent, endpoint-operable, traceable) — enforced by the
`trace/` discipline.

## Dendritic / negative-space discipline

The graph must converge only along the spine; leaves never couple laterally. den's
existing prohibitions enforce this and are adopted as invariants: static topology
(includes on the attrset, not computed in context bodies), never decide includes from
`hasAspect`, one enrichment writer per context key (v2), co-locate with the owner.
Structure is defined by the forbidden lateral edge (the negative space), which
prevents the counter-intuitive tangle.

## Phases (consume → produce)

- **P0 Instrument** — extractors + repo + record schema + trace discipline; subsume
  graphify-nix-spike. → reproducible extraction pipeline.
- **P1 Distill** — per-framework isolated option/data trees as data (`trees/*.json`).
  → the origins.
- **P2 Relations** — DAG + correlation + semantic edges (`relations/`), regularized.
  → the cross-scope relation schema.
- **P3 Normalize** — reduce to substrate; canonical designations + distinction-lines
  (`normal-form/`). → the normal form.
- **P4 Feed-in** — pattern × scope allocation; v1-now / v2-lever map (`feed-in/`).
  → the principle layer + follow-up den change candidates.

## Repo structure (sketch)

```
~/repos/local/scope-atlas/
  README.md          purpose, method, reproduce-from-scratch
  P0-instrument/     extractor scripts (eval dumps, graphify run, den introspection)
  trees/             isolated option-trees as data (nixos/hm/hjem/den .json)
  relations/         P2 learned edges (DAG, correlation, semantics)
  normal-form/       P3 designations + distinction-lines
  feed-in/           P4 pattern×scope allocation, v1-now / v2-lever map
  trace/             provenance: data → relevancy → principle
```

## P2 method (decided 2026-06-20): determinism-ordered hybrid

Relations are recovered in stages ordered by determinism; ML is subordinate and
quarantined to suggestion. Rationale: the substrate is functional, so the relation
structure is *functional dependency*, not statistics — statistics only help *find*
FDs. "Without overfitting" = trust the deterministic layers; let ML propose, never
dispose.

- **Stage 1 — relational algebra (exact, traceable backbone).** Joins/projections
  over the records: option-path containment (parent→child partial order),
  co-declaration (options sharing a `declarations[]` file = same module), the den
  include-graph + closure, type-reference edges (submodule types). Zero overfit;
  every edge cites its records.
- **Stage 2 — anchored heuristics (deterministic, explainable).** Where Stage 1 is
  silent: token-overlap on option paths, and a precedence DAG from declaration
  dependencies + a small hand-seeded bootstrap order, then transitive reduction to
  the minimal edge set. Every edge cites its tokens/seed.
- **Stage 3 — ML, suggestion-only, validated.** Embeddings over option descriptions
  to surface semantically-related-but-lexically-disjoint candidates. An ML edge
  enters `normal-form/` ONLY after confirmation by a Stage-1/2 signal or review, AND
  a cross-framework held-out check. ML proposes; relational algebra disposes — the
  anti-overfit firewall.

Determinism guarantee: the normal form depends only on Stages 1–2; Stage 3 adds
candidates, never authority. Resolution is therefore reproducible.

## Open questions (deferred, not blocking P0)

- **ML method:** relational learning vs embeddings vs plain correlation/clustering
  over extracted tables — choose by P2; bias toward the simplest that generalizes.
- **graphify maturity:** the nil-LSP path is unbuilt; tree-sitter collapses attr
  paths. Option-trees come from eval regardless; graphify is for *source edges* and
  may be deferred or fork-carried per the spike's go/no-go.
- **v1-expressible-now limits:** how much derive-edge can live structurally without
  violating static-topology / no-includes-from-`hasAspect` — likely partial in v1,
  full in v2 (HOAG).
- **host-type:** a derived fact (`facter present ⊢ baremetal`) or its own tier?
