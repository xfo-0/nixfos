## 1. Enable the toolchain
- [ ] 1.1 Expose `nil` on PATH for the prototype (it's in the nvim closure; use `nix shell`/a temp profile — do NOT bake into the config yet)
- [ ] 1.2 Obtain a graphify build with the nil-LSP path (the #1157 author's branch, PR, or a local prototype adapter) — record exactly which and its commit

## 2. Prototype on ~/nx
- [ ] 2.1 Run the nil-LSP ingestion over `~/nx` (187 `.nix` files); record node/edge counts and time
- [ ] 2.2 Run the tree-sitter (#1048) path on the same input; compare — confirm or refute that it collapses the nesting den depends on

## 3. Evaluate the EDGES (the real test)
- [ ] 3.1 Pose 5 real structural questions from recent work (tailnet-grant emit→collect; `core.default` transitive includes for `grpht`; scope-engine cascade for one host setting; persist class resolution; binary-cache record flow) and check whether the graph answers each without grep
- [ ] 3.2 Resolve the KEY UNKNOWN: does nil documentSymbol + graphify capture CROSS-FILE edges (flake-parts/import-tree indirection, `includes`, quirk emit→collect across files), or only within-file hierarchy?

## 4. Decide
- [ ] 4.1 Write a go/no-go: does the structure leg materially beat grep+`nxopt` for these questions, net of drift cost?
- [ ] 4.2 If go: choose adoption path (contribute nil-LSP adapter upstream / carry fork-overlay / defer to #1157) and define the regeneration/drift story (rebuild hook vs on-demand vs accept staleness)
- [ ] 4.3 Capture the decision in `design.md`; if go, open a follow-up implementation change (and, only then, wire `nil` + `graphify-out` into the config)
