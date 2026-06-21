{ inputs, lib, ... }:
let
  mergeLsColorsFiletypeRules = pkgs: rules: ''
    ${pkgs.python3}/bin/python3 - "$out/flavor.toml" ${rules} <<'PY'
    import pathlib
    import sys

    flavor_path = pathlib.Path(sys.argv[1])
    rules_path = pathlib.Path(sys.argv[2])

    flavor = flavor_path.read_text()
    rules = rules_path.read_text().rstrip()
    filetype = f"[filetype]\nrules = [\n{rules}\n]\n"
    marker = "[filetype]"
    start = flavor.find(marker)
    if start == -1:
        flavor = flavor.rstrip() + "\n\n" + filetype
    else:
        flavor = flavor[:start].rstrip() + "\n\n" + filetype

    flavor_path.write_text(flavor)
    PY
  '';
in
{
  flake-file.inputs.lsColorsToToml = {
    url = "gh:Mellbourn/lsColorsToToml";
    flake = false;
  };

  den.aspects.yazi-flavor = {
    homeManager =
      { config, pkgs, ... }:
      let
        vividEnabled = config.programs.vivid.enable or false;
        vividThemeName = config.programs.vivid.activeTheme or null;
        vividTheme =
          if vividThemeName != null then config.programs.vivid.themes.${vividThemeName} else null;

        staticFlavor = ./yazi/kanso-ink.yazi;

        flavor =
          if vividEnabled && vividThemeName != null && vividTheme != null then
            let
              vividThemeFile = (pkgs.formats.yaml { }).generate "${vividThemeName}.yml" vividTheme;
            in
            pkgs.runCommand "kanso-ink-yazi-stylix-vivid" { } ''
              cp -r ${staticFlavor} "$out"
              chmod -R u+w "$out"

              export XDG_CONFIG_HOME="$TMPDIR/xdg"
              mkdir -p "$XDG_CONFIG_HOME/vivid/themes"
              cp ${vividThemeFile} "$XDG_CONFIG_HOME/vivid/themes/${vividThemeName}.yml"

              ls_colors="$(${pkgs.vivid}/bin/vivid generate ${lib.escapeShellArg vividThemeName})"

              cp -r ${inputs.lsColorsToToml} "$TMPDIR/lsColorsToToml"
              chmod -R u+w "$TMPDIR/lsColorsToToml"
              ${pkgs.esbuild}/bin/esbuild "$TMPDIR/lsColorsToToml/index.ts" --bundle --platform=node --format=cjs --outfile="$TMPDIR/lsColorsToToml/index.js"
              LS_COLORS="$ls_colors" ${pkgs.nodejs}/bin/node "$TMPDIR/lsColorsToToml/index.js" > "$TMPDIR/filetype-rules.toml"

              ${mergeLsColorsFiletypeRules pkgs "$TMPDIR/filetype-rules.toml"}
            ''
          else
            staticFlavor;
      in
      {
        programs.yazi.flavors.kanso-ink = flavor;
      };
  };
}
