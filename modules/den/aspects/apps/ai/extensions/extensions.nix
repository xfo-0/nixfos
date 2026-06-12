{ den, ... }:
{
  flake-file.inputs.llm-agents.url = "gh:numtide/llm-agents.nix";

  den.aspects.ai.extensions = {
    homeManager =
      { pkgs, inputs', ... }:
      {
        home.packages = [
          inputs'.llm-agents.packages.beads-rust
          inputs'.llm-agents.packages.gitnexus
          pkgs.playwright-mcp
        ];

        programs.git.ignores = [
          ".gitnexus/"
          ".claude/skills/gitnexus/"
          "/AGENTS.md"
          "/CLAUDE.md"
        ];
      };
  };
}
