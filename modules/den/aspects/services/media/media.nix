{ lib, ... }:
{
  den.aspects.services.media.base = {
    settings.options.enable = lib.mkEnableOption "media (arr) stack on this host";

    nixos =
      { host, ... }:
      let
        cfg = host.settings.services.media.base or { };
      in
      lib.mkIf (cfg.enable or false) {
        users.groups.media = { };

        systemd.tmpfiles.settings."media-tree" =
          let
            dir = {
              user = "root";
              group = "media";
              mode = "2775";
            };
          in
          {
            "/data/media".d = dir;
            "/data/media/tv".d = dir;
            "/data/media/movies".d = dir;
            "/data/media/music".d = dir;
            "/data/media/books".d = dir;
            "/data/torrents".d = dir;
            "/data/torrents/tv".d = dir;
            "/data/torrents/movies".d = dir;
            "/data/torrents/music".d = dir;
            "/data/torrents/books".d = dir;
          };
      };
  };
}
