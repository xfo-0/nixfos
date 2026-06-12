{ den, ... }:
{
  den.aspects.opencode = {
    includes = [
      den.aspects.nodejs
      den.aspects.python
      den.aspects.ai.extensions
    ];

    homeManager =
      {
        config,
        inputs',
        lib,
        pkgs,
        ...
      }:
      let
        workflowsPath = "${config.xdg.configHome}/opencode/agent-workflows.md";
      in
      {
        home.packages = [ inputs'.llm-agents.packages.opencode ];

        xdg.configFile."opencode/agent-workflows.md".source = ./agent-workflows.md;

        home.activation.opencodeAgentWorkflows = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          ${pkgs.coreutils}/bin/mkdir -p "${config.xdg.configHome}/opencode"
          ${pkgs.python3}/bin/python3 - <<'PY'
          import json
          import re
          from pathlib import Path

          path = Path("${config.xdg.configHome}/opencode/opencode.json")
          instruction = "${workflowsPath}"

          # opencode reads its config as JSONC; tolerate trailing commas and
          # skip (instead of failing all of HM activation) on anything worse
          data = {"$schema": "https://opencode.ai/config.json"}
          if path.exists():
              text = path.read_text()
              try:
                  data = json.loads(text)
              except json.JSONDecodeError:
                  try:
                      data = json.loads(re.sub(r",(\s*[}\]])", r"\1", text))
                  except json.JSONDecodeError as err:
                      print(f"opencodeAgentWorkflows: leaving unparseable {path} untouched: {err}")
                      raise SystemExit(0)

          instructions = data.get("instructions")
          if not isinstance(instructions, list):
              instructions = []

          instructions = [item for item in instructions if item != instruction]
          instructions.append(instruction)
          data["instructions"] = instructions

          path.write_text(json.dumps(data, indent=2) + "\n")
          PY
        '';
      };

    persistUser =
      { hmConfig, ... }:
      {
        directories = [
          {
            directory = "${hmConfig.xdg.configHome}/opencode";
            how = "symlink";
          }
          {
            directory = "${hmConfig.xdg.dataHome}/opencode";
            how = "symlink";
          }
          {
            directory = "${hmConfig.xdg.cacheHome}/opencode";
            how = "symlink";
          }
          {
            directory = "${hmConfig.xdg.configHome}/lean-ctx";
            how = "symlink";
          }
          {
            directory = ".lean-ctx";
            how = "symlink";
          }
        ];
      };
  };
}
