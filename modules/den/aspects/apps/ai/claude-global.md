# Code Style
- NEVER add comments to code unless the user explicitly requests them.
- No explanatory comments, section headers, TODO comments, or inline annotations.
- The code should be self-documenting.
- Exception: only add comments for non-obvious workarounds that can't be expressed in the code itself.

# Nix Option Search
- `nxopt <regex>` (NixOS) / `nxopt -u <regex>` (home-manager) — pin-exact option search evaluated from the local flake, includes repo-defined options. Prefer over web/channel sources, which desync from the local pin.

# Agent Workflows
- Global workflow defaults: @rules/agent-workflows.md
