## Why

Working on the den-based NixOS config at `~/nx` repeatedly incurs a **structural rediscovery cost**: the agent (and the human) reconstruct *relationships* — which aspect includes which, which aspects emit a given quirk and where it's collected, how the scope-engine cascade resolves a host's settings — by grepping and reading, every session. The usage-insights report (2026-06-19) flags the top friction as reasoning from assumptions / "it coheres" rather than from ground truth.

The existing ground-truth tooling covers two of three legs: `nxopt` gives option **values/defaults** (live, eval-based), and the `nixos-den-config` skill gives **invariants/rules** (prose). The missing leg is **structure** — a queryable graph of the config's edges. graphify could fill it, but Nix support isn't upstream yet: issue `safishamsi/graphify#1157` is open, and PR `#1048` uses a generic tree-sitter walk that **collapses nested attribute paths** — exactly the signal den depends on. This spike decides whether graphify-for-nix (the nil-LSP semantic-hierarchy approach proposed in #1157) is worth adopting for `~/nx`, and by what path.

## What Changes

This is a **spike / investigation**, not a build:
- Prototype or run the **nil-LSP**-based graphify ingestion against `~/nx` (187 `.nix` files) and measure the resulting graph (node/edge counts, vs the tree-sitter approach).
- Test whether the graph's **edges** answer real questions that grep/`nxopt` can't cheaply (include graph, quirk emit→collect, scope-engine cascade, host→aspect→option topology).
- Produce a **go/no-go** decision and, if go, the adoption path (contribute the nil-LSP adapter upstream / carry a fork-overlay / defer until #1157 lands) plus the graph-drift/regeneration story.

No application code or den config is changed by this spike beyond throwaway prototype scaffolding and a `graphify-out/` artifact for evaluation.

## Capabilities

### New Capabilities
- `nix-knowledge-graph`: a queryable structural knowledge graph of the den NixOS config — semantic attribute hierarchy plus relationship edges (includes, quirk emit→collect, host/aspect/option topology) — that an agent can query instead of reconstructing structure by grep.

### Modified Capabilities
<!-- none — no existing spec requirements change -->

## Impact

- **Tooling only.** Depends on: graphify (external; Nix support unmerged — #1157 / #1048) and the `nil` LSP (present in the nvim closure, not on PATH).
- **If adopted:** a `graphify-out/` artifact under `~/nx` that must be regenerated on config change (drift cost — a key spike question).
- **Composes** with `nxopt` (values) and the `nixos-den-config` skill (rules); this adds the missing *structure* leg. Directly targets the insights' #1 friction by making config structure cheap ground truth instead of an assumption.
