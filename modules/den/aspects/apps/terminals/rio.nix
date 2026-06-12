{ den, lib, ... }:
{
  den.aspects.terminal = {
    includes = [
      den.aspects.terminal.rio
    ];

    rio = {
      homeManager =
        { lib, ... }:
        {
          programs.rio = {
            enable = lib.mkDefault true;
            settings = {
              env-vars = [ "TERM=xterm-256color" ];
              confirm-before-quit = false;
              cursor = {
                shape = "underline";
                blinking = true;
              };
              editor.program = "nvim";
              window.decorations = "Disabled";
              renderer = {
                backend = "Vulkan";
                target-fps = 120;
              };
              keyboard.use-kitty-keyboard-protocol = true;
              fonts = {
                hinting = false;
              };
              navigation = {
                mode = "plain";
                use-split = false;
              };
              shell.program = "/run/current-system/sw/bin/nu";
            };
          };

          xdg = {
            terminal-exec = {
              enable = true;
              settings = {
                default = lib.mkBefore [
                  "rio.desktop"
                ];
              };
            };
            mimeApps = {
              defaultApplications = lib.mkBefore (
                let
                  application = "rio-open.desktop";
                  mimeTypes = [
                    "x-scheme-handler/rio"
                    "x-scheme-handler/ssh"
                  ];
                in
                lib.genAttrs mimeTypes (mimetype: application)
              );
              associations.added =
                let
                  application = "rio-open.desktop";
                  mimeTypes = [
                    "application/x-sh"
                    "application/x-shellscript"
                    "inode/directory"
                    "image/*"
                    "text/*"
                  ];
                in
                lib.genAttrs mimeTypes (mimetype: application);
            };
          };
        };

      persistUserIgnore =
        { hmConfig, ... }:
        {
          directories = [ "${hmConfig.xdg.cacheHome}/rio" ];
        };
    };
  };
}
