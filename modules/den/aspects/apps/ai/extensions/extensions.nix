{ den, ... }:
{
  flake-file.inputs.llm-agents.url = "gh:numtide/llm-agents.nix";

  den.aspects.ai.extensions = {
    homeManager =
      { pkgs, inputs', ... }:
      {
        home.packages = [
          inputs'.llm-agents.packages.beads-rust
          pkgs.playwright-mcp
        ];

        programs.git.ignores = [
          "/AGENTS.md"
          "/CLAUDE.md"
          "/graphify-out/"
        ];
      };
  };
}
