{ inputs, ... }:
{
  flake-file.inputs.freecad-mcp = {
    url = "gh:neka-nat/freecad-mcp";
    flake = false;
  };

  den.aspects.freecad =
    { host, ... }:
    {
      homeManager =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        lib.mkIf (host.settings.capabilities.workstation.enable or false) {
          home.packages = [ pkgs.freecad ];

          home.file.".local/share/FreeCAD/Mod/FreeCADMCP".source = "${inputs.freecad-mcp}/addon/FreeCADMCP";

          home.activation.freecadMcpServer = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            ${pkgs.python3}/bin/python3 - <<'PY'
            import json
            from pathlib import Path

            claude_json = Path("${config.home.homeDirectory}/.claude.json")
            state = json.loads(claude_json.read_text()) if claude_json.exists() else {}
            servers = state.setdefault("mcpServers", {})
            servers["freecad"] = {
                "type": "stdio",
                "command": "uvx",
                "args": ["freecad-mcp"],
            }
            claude_json.write_text(json.dumps(state, indent=2) + "\n")
            PY
          '';
        };

      persistUser = {
        directories = [
          {
            directory = ".config/FreeCAD";
            how = "symlink";
          }
          {
            directory = ".local/share/FreeCAD";
            how = "symlink";
          }
        ];
      };
    };
}
