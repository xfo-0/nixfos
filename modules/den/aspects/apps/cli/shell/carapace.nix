{
  den.aspects.carapace = {
    nushellExternalCompleterFallback =
      { lib, ... }:
      {
        externalCompleterFallback = lib.mkDefault ''
          let fallback_completer = {|spans: list<string>|
              CARAPACE_LENIENT=1 carapace $spans.0 nushell ...$spans | from json
          }
        '';
      };

    homeManager =
      {
        config,
        lib,
        ...
      }:
      {
        programs.carapace = {
          enable = lib.mkDefault true;
          enableNushellIntegration = lib.mkDefault false;
        };

        programs.nushell.extraEnv = lib.mkIf config.programs.nushell.enable (
          lib.mkAfter ''
            $env.CARAPACE_BRIDGES = 'jj,fish,bash,inshellisense,cobra'
          ''
        );
      };
  };
}
