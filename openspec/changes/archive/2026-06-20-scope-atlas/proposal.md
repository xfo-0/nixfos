## Why

The den aspect structure's organizing principles are **imposed, not derived**. The
directory taxonomy (`system/hardware/`, `apps/cli/tools/`, …) was chosen by hand,
and the *conditioning* logic — which aspect applies, in what shape, where — is
**latent**: scattered as `mkIf` predicates in the NixOS value-layer instead of
expressed as structural edges in the den layer. The real dependency topology is
hidden one fixpoint too low.

The cost is recurring ad-hoc rediscovery of relevancies. Specimens from one working
session: `intel-dgpu` is universally included then `mkIf`-disabled where no Arc card
exists (membership that should be *derived* from a factor); `hd-idle` lives under
`services/media` though it is conditioned by *storage*; disk tools duplicated between
`live.nix` and `cli-tools`; a facter snapshot that cannot even see the host's SATA
HDDs (a factor-source that lies). Each was resolved by hand.

We need a **principled, empirical method** to *derive* den's designations — which
pattern carries which factor at which scope — grounded in the actual structure of
what a NixOS-class system requires, and generalized across config-frameworks
(nixpkgs module system, home-manager, hjem, den itself) so the lines of distinction
are fundamental, not accidental. The work must be recorded, traceable, deducible,
and expandable — the property the den libraries themselves have.

## What Changes

This stands up a **separate analysis repo** — `~/repos/local/scope-atlas` — and a
5-phase program. It does **not** modify `~/nx`; `~/nx` is a reference corpus.

- **P0 — Instrument.** Three complementary, deterministic-where-possible extractors:
  `nix eval`/`nxopt` for option-trees + values (ground truth), graphify for source
  edges (**subsumes `graphify-nix-spike`** as the structure-extractor; consumes its
  go/no-go and maturity caveat), den schema introspection for the aspect graph.
- **P1 — Distill isolated trees.** Per framework, the normalized option/data tree:
  nixpkgs modules, den primitives, home-manager, hjem, reference libs.
- **P2 — Relations.** Cross-tree edges via relational algebra (explicit) + ML
  (fuzzy: correlation, precedence/DAG, semantics), regularized against overfit.
- **P3 — Normalize → convergence.** Reduce apparent convolution to the functional
  substrate (a monoid of modules under merge); derive the canonical designations +
  the distinction-lines between domains.
- **P4 — Feed-in.** Map each designation to a den pattern × scope and to
  v1-expressible-now vs v2-leverage (HOAG demand-driven).

Output is **principles + provenance**, not config edits. Applying them to `~/nx` is
future, separate change(s).

## Capabilities

### New Capabilities
- `scope-atlas`: a reproducible, traceable atlas of nix config-framework scopes
  (nixos / home-manager / hjem / den option-trees and their cross-scope relations)
  and the **normalized designations** derived from it, plus a mapping of how and
  where to feed those designations into den (v1 / v2).

## Impact

- **New repo** `~/repos/local/scope-atlas` (moor `host="local"`). `~/nx` unchanged
  (reference corpus only).
- **Subsumes** `graphify-nix-spike` as P0's structure-extractor; consumes its
  go/no-go.
- **Research/tooling only:** nix eval / nxopt, graphify (maturity-gapped per the
  spike), den introspection, an ML + relational-algebra analysis layer.
- **Deliverable feeds den design**; no `~/nx` switch is affected by this change.
