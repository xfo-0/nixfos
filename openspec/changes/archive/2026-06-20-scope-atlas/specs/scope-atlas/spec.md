## ADDED Requirements

### Requirement: Deterministic isolated trees
The atlas SHALL extract each framework's option/data tree deterministically from
evaluation (not heuristic parsing), so the origins are reproducible ground truth.

#### Scenario: Re-extraction is stable
- **WHEN** the nixos option-tree is extracted twice from the same pin
- **THEN** the two `trees/nixos.json` outputs are identical modulo recorded provenance

#### Scenario: Source edges degrade, trees do not
- **WHEN** graphify's Nix support is unavailable or lossy
- **THEN** option-trees are still produced via eval, and only the source-edge layer is marked reduced-fidelity

### Requirement: Derived relations with an acyclic precedence DAG
The atlas SHALL express cross-tree relations as a graph whose precedence edges form a
DAG that admits a topological linearization into the eval pipeline.

#### Scenario: Precedence linearizes
- **WHEN** the precedence relation (e.g. boot→kernel→nvme→nvme-cli) is computed
- **THEN** it is acyclic and a consistent topological order into the eval/disko pipeline exists

### Requirement: Canonical normalized designations
The atlas SHALL reduce the relations to a normal form: canonical designations (focal
points) with isolating characteristics, plus the distinction-lines between domains.

#### Scenario: A designation is a function of factor and scope
- **WHEN** a designation is derived
- **THEN** it states which factor at which scope it consolidates, and no two designations carry the same (factor, scope) ambiguously

### Requirement: Feed-in allocation to den patterns
The atlas SHALL map each designation to a den pattern × scope and to a v1-now or
v2-leverage path.

#### Scenario: Pattern allocation is explicit
- **WHEN** a designation conditions on a hardware-presence factor
- **THEN** the feed-in map names the carrying pattern (a condition edge) and whether it is expressible in den v1 or needs v2

### Requirement: Traceable, deducible provenance
Every derived relevancy and designation SHALL link back to the source data it was
derived from, so the chain is deducible and expandable.

#### Scenario: A principle is traceable to data
- **WHEN** a designation in `normal-form/` is inspected
- **THEN** `trace/` resolves it to the relations and isolated-tree records that produced it

### Requirement: Generalization without overfitting
Derived principles SHALL be validated across more than one framework, so they reflect
the functional substrate rather than one corpus's accidents.

#### Scenario: Cross-framework hold-out
- **WHEN** a principle is derived from the nixos/den corpus
- **THEN** it is checked against home-manager or hjem, and a principle that fails to transfer is flagged rather than kept
