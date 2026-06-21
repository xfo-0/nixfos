## P0. Instrument + repo
- [x] 0.1 Scaffold `~/repos/local/scope-atlas` (README with reproduce-from-scratch; `P0-instrument/ trees/ relations/ normal-form/ feed-in/ trace/`); register with moor (host=local)
- [x] 0.2 Define the record schema: one row per conditioning edge — (node, factor, factor-source, scope/tier, pattern, placement)
- [x] 0.3 Eval extractor: dump the NixOS module option-tree deterministically (`nix eval` of `options`, + `nxopt`) to `trees/`
- [x] 0.4 den introspection extractor: aspect graph + edge primitives (include/route/provide/gather/condition) to `trees/`
- [x] 0.5 Subsume `graphify-nix-spike`: run/decide its nil-LSP vs tree-sitter go/no-go as the source-edge extractor; record maturity + adoption path
- [x] 0.6 Establish `trace/` provenance discipline: every later artifact links data → relevancy → principle

## P1. Distill the isolated trees (origins)
- [x] 1.1 nixpkgs module-system option-tree → `trees/nixos.json`
- [x] 1.2 den data structures (schema/aspects/policies/quirks/edges) → `trees/den.json`
- [x] 1.3 home-manager option-tree → `trees/home-manager.json` (3798 opts; stylix config-dep branch skipped, logged)
- [x] 1.4 hjem (35 opts, feel-co/hjem@89d0bee via extendModules) → `trees/hjem.json`; 3-framework structural test: substrate transfers (nixos/hm/hjem all partition), hm↔hjem share only systemd/xdg → vocab framework-relative
- [x] 1.5 reference-lib lineage notes (grounded in `.tack` pins: flake-parts/flake-file/import-tree/den present; digga/std/hive historical) → `trees/reference-libs.md`

## P2. Relations across trees (rel-algebra + ML)
- [x] 2.1 Relational-algebra backbone (containment, co-declaration, include-graph, type-ref) → `relations/backbone.json`
- [x] 2.2 Anchored heuristics: precedence DAG (bootstrap seed, transitive-reduced) + token-overlap adjacency → `relations/{precedence,adjacency}.json`
- [ ] 2.3 ML suggestion layer (embeddings) — candidates only, confirmed by Stage 1/2 + cross-framework held-out
- [x] 2.4 Regularize → `edges.json` (Stage-1/2 fused; adjacency co-tier/weight confirmed); held-out check PENDING (needs 2nd framework tree)

## P3. Normalize → convergence
- [x] 3.1 Reduce to the functional substrate (monoid of modules); confirm CT is lens-only → `normal-form/substrate.md` + `normalized.json` (20264 opts)
- [x] 3.2 Derive canonical designations (focal points) + isolating characteristics → `designations.json` (scope×tier cells)
- [x] 3.3 Draw the distinction-lines between domains (nixos vs hm; hjem pending P1.4) → `distinction-lines.json`
- [x] 3.4 DAG acyclic ✓ (pipeline-consistency unverified, hand-seeded); held-out (honest): substrate partition transfers, tier-vocab scope-relative (4/13 tiers in hm), 91% is name-coincidence not generalization → `held-out.json`

## P4. Feed-in to den
- [x] 4.1 Allocation map (factor × scope → den pattern) → `feed-in/allocation.json`
- [x] 4.2 v1-now vs v2-lever: **97.9% v1-now**, 2.1% (hardware derive-edge) is the lone v2-lever
- [x] 4.3 Designation layer (scope-primary, tier scope-relative, 3 edge-classes, placement rules) → `feed-in/designation-layer.md`
- [x] 4.4 Follow-up `~/nx` changes identified → `feed-in/followups.md` (lift-hardware-mkIf / recategorize / scope-tier-projection)
