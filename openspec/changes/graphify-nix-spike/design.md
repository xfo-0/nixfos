## Context

graphify turns a codebase into a knowledge graph (nodes + edges, community detection, query/path/explain). Nix support is requested in `safishamsi/graphify#1157` (open, unassigned). Two approaches exist:

- **PR #1048** (generic tree-sitter-nix walk). Problem, per the #1157 author: tree-sitter's CST **collapses nested attribute paths into single nodes**, so `config.system.x.y` and context from unrelated modules leak together — it loses the nesting that *is* the semantics in Nix.
- **nil-LSP approach** (proposed in #1157): use the `nil` language server's `textDocument/documentSymbol` to recover the exact attribute hierarchy with no custom parsing; ~12 ms/file; degrades to tree-sitter when `nil` is absent. Author's benchmark: 121 `.nix` files → 0 → 1,333 nix nodes (total graph 300 → 1,631).

`~/nx` is den-based: meaning lives in deep attrsets (`host.settings.<path>`, aspects/quirks/policies). So the tree-sitter approach is near-useless here; the nil-LSP approach is the only one that fits.

## Goals / Non-Goals

**Goals:**
- Decide, **with evidence on `~/nx`**, whether a structural graph materially reduces the rediscovery / reason-from-assumptions friction.
- If yes, pick the adoption path and define the regeneration story.

**Non-Goals:**
- Building or merging the upstream adapter as part of this spike.
- Replacing `nxopt` (values) or the `nixos-den-config` skill (rules) — this adds the structure leg, not a replacement.
- Any change to den config or hosts.

## Decisions

- **Use the nil-LSP approach, not tree-sitter (#1048)**, for the prototype — den's nesting makes tree-sitter lossy by design.
- **Enabler:** expose `nil` on PATH for the prototype (it's already in the nvim closure); do **not** bake it into the config until go.
- **Success is judged on EDGES, not node count.** The graph must answer relationship questions grep/`nxopt` can't, e.g.:
  - "Which aspects emit `tailnet-grant`, and where is it collected?"
  - "What does `core.default` transitively include for `grpht`?"
  - "Which hosts' settings feed the scope-engine cascade for option X?"

## Risks / Trade-offs

- **Drift.** A `graphify-out/` is a snapshot; it goes stale as the config changes and needs regeneration. If the agent must regenerate before trusting it, the win over live grep+`nxopt` shrinks. Open question: regenerate-on-rebuild hook vs on-demand vs accept staleness (structure changes less often than values).
- **Upstream not ready.** #1157 open, #1048 lossy/unmerged. Adoption may mean carrying a fork or contributing the nil-LSP adapter — maintenance cost, and it rides yet another external dep.
- **KEY UNKNOWN — cross-file edges.** Does `nil` documentSymbol (per-file symbol hierarchy) + graphify actually capture den's **cross-file** edges (flake-parts/import-tree indirection, `includes`, quirk emit→collect across files), or only within-file attribute hierarchy? The cross-file edges are the high-value part; if graphify only links per-file symbols, the structure leg may need graphify-level linking that doesn't exist yet. This is the make-or-break the spike must resolve before any go.
