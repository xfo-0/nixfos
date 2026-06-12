{ lib, ... }:
{
  flake-file.inputs.yazi.url = "gh:sxyazi/yazi";

  den.aspects.yazi =
    { user, ... }:
    {
      homeManager =
        { pkgs, ... }:
        {
          programs.yazi = {
            enable = lib.mkDefault true;
            enableNushellIntegration = lib.mkDefault true;
            shellWrapperName = "y";

            plugins = with pkgs.yaziPlugins; {
              inherit
                chmod
                git
                kdeconnect-send
                lazygit
                mediainfo
                mount
                ouch
                piper
                restore
                rsync
                starship
                ;
            };

            initLua = builtins.readFile ./yazi/init.lua;
            keymap = fromTOML (builtins.readFile ./yazi/keymap.toml);

            theme = {
              flavor.dark = user.colorscheme;
            };

            settings = {
              confirm.overwrite = true;

              mgr = {
                linemode = "size_and_mtime";
                show_hidden = true;
                sort_by = "natural";
              };

              open.prepend_rules = [
                {
                  mime = "video/*";
                  use = "play";
                }
              ];

              opener = {
                extract = [
                  {
                    desc = "Extract here with ouch";
                    "for" = "unix";
                    run = "ouch d -y \"$@\"";
                  }
                ];
                open = [
                  {
                    desc = "Open";
                    orphan = true;
                    run = "xdg-open \"$@\"";
                  }
                ];
                play = [
                  {
                    desc = "Play";
                    orphan = true;
                    run = "mpv --title='yazi: \${media-title}' \"$@\"";
                  }
                ];
              };

              plugin = {
                prepend_fetchers = [
                  {
                    group = "git";
                    url = "*";
                    run = "git";
                  }
                  {
                    group = "git";
                    url = "*/";
                    run = "git";
                  }
                ];
                prepend_preloaders = [
                  {
                    mime = "{audio,video,image}/*";
                    run = "mediainfo";
                  }
                  {
                    mime = "application/subrip";
                    run = "mediainfo";
                  }
                ];
                prepend_previewers = [
                  {
                    mime = "text/markdown";
                    run = "piper -- CLICOLOR_FORCE=1 glow -w=$w \"$1\"";
                  }
                  {
                    mime = "{audio,video,image}/*";
                    run = "mediainfo";
                  }
                  {
                    mime = "application/subrip";
                    run = "mediainfo";
                  }
                  {
                    mime = "application/*zip";
                    run = "piper -- ouch list -tA \"$1\"";
                  }
                  {
                    mime = "application/*tar";
                    run = "piper -- ouch list -tA \"$1\"";
                  }
                  {
                    mime = "application/*rar";
                    run = "piper -- ouch list -tA \"$1\"";
                  }
                  {
                    mime = "application/x-bzip2";
                    run = "piper -- ouch list -tA \"$1\"";
                  }
                  {
                    mime = "application/x-7z-compressed";
                    run = "piper -- ouch list -tA \"$1\"";
                  }
                  {
                    mime = "application/x-xz";
                    run = "piper -- ouch list -tA \"$1\"";
                  }
                ];
                append_previewers = [
                  {
                    mime = "*";
                    run = "piper -- hexyl --border=none --length=2KiB \"$1\"";
                  }
                ];
              };

              preview = {
                max_height = 1000;
                max_width = 1000;
              };
            };
          };

          home.packages = with pkgs; [
            ffmpeg
            glow
            hexyl
            imagemagick
            jq
            mediainfo
            ouch
            poppler-utils
            trash-cli
          ];
        };

      persistUserIgnore =
        { hmConfig, ... }:
        {
          directories = [ "${hmConfig.xdg.stateHome}/yazi" ];
        };
    };
}
