{
  flake-file.inputs.src-rmux = {
    url = "gh:helvesec/rmux";
    flake = false;
  };

  den.aspects.rmux =
    { user, ... }:
    {
      homeManager =
        { pkgs, lib, ... }:
        let
          shellPkgs = {
            nushell = pkgs.nushell;
            fish = pkgs.fish;
            zsh = pkgs.zsh;
            bash = pkgs.bashInteractive;
          };
          shellPkg = shellPkgs.${user.shell};
        in
        {
          programs.tmux = {
            enable = lib.mkDefault true;
            package = lib.mkDefault pkgs.local.rmux;
            shell = lib.mkDefault (lib.getExe shellPkg);
            prefix = lib.mkDefault "C-a";
            mouse = lib.mkDefault false;
            keyMode = lib.mkDefault "vi";
            baseIndex = lib.mkDefault 1;
            historyLimit = lib.mkDefault 100000;
            extraConfig = lib.mkDefault ''
              unbind C-b
              bind C-a send-prefix

              set -g renumber-windows on
              set -s copy-command 'wl-copy'

              bind T if-shell -F '#{mouse}' 'set -g mouse off ; display-message "mouse OFF: native terminal selection enabled"' 'set -g mouse on ; display-message "mouse ON: pane mouse mode enabled"'

              bind % split-window -h -c "#{pane_current_path}"
              bind '"' split-window -v -c "#{pane_current_path}"
              bind v split-window -h -c "#{pane_current_path}"
              bind b split-window -v -c "#{pane_current_path}"
              bind c new-window -c "#{pane_current_path}"
              bind [ copy-mode
              bind -T copy-mode-vi v send-keys -X begin-selection
              bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel
              bind -T copy-mode-vi C-c send-keys -X copy-pipe-and-cancel
            '';
          };

          xdg.configFile."rmux/rmux.conf".text = ''
            set -g default-shell "${lib.getExe shellPkg}"
          '';
        };
    };
}
