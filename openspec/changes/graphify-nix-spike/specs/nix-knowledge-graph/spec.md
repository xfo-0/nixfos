## ADDED Requirements

### Requirement: Semantic attribute hierarchy
The graph SHALL represent nested Nix attribute paths as distinct hierarchical nodes, not collapse them into a single node per file.

#### Scenario: Nested host settings are distinct nodes
- **WHEN** graphify ingests a host config containing `settings.tailscale.acceptDns` and `settings.services.media.proxy.domain`
- **THEN** each attribute-path segment is a distinct node in the hierarchy, and unrelated modules' attributes do not share one collapsed node

### Requirement: Structural relationship edges
The graph SHALL expose den relationship edges that a grep sweep cannot cheaply answer.

#### Scenario: Quirk emit→collect resolves
- **WHEN** the agent asks which aspects emit the `tailnet-grant` quirk and where it is collected
- **THEN** the graph returns the emitting aspect nodes and the `collectAllHosts` collector node as connected edges, without a manual repo-wide grep

#### Scenario: Transitive include graph for a host
- **WHEN** the agent asks what `core.default` transitively includes for host `grpht`
- **THEN** the graph returns the include closure as a traversable path

### Requirement: Cross-file edges
The graph SHALL link symbols across files, not only within a single file, so the den include/quirk/policy topology is queryable.

#### Scenario: An aspect's emit links to its collector in another file
- **WHEN** an aspect in `aspects/network/tailscale.nix` emits a quirk collected by a policy in `aspects/network/tailnet.nix`
- **THEN** the graph connects the two across files (not two isolated per-file subgraphs)

### Requirement: Defined freshness
The graph artifact SHALL record enough provenance that a consumer can tell whether it reflects the current config and regenerate when stale.

#### Scenario: Stale graph is detectable
- **WHEN** the config changes after a graph was generated
- **THEN** the consumer can determine the graph is stale (e.g. by a recorded source commit/hash) before trusting structural answers

### Requirement: Graceful degradation
Ingestion SHALL degrade to a usable (if lossier) result when `nil` is unavailable, rather than failing.

#### Scenario: nil absent
- **WHEN** graphify runs without `nil` on PATH
- **THEN** it falls back to tree-sitter parsing and reports reduced fidelity instead of erroring out
