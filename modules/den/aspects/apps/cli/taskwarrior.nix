{ den, lib, ... }:
{
  den.aspects.taskwarrior = {
    includes = [
      den.aspects.taskwarrior.completions
      den.aspects.taskwarrior.enable
      den.aspects.taskwarrior.persistence
      den.aspects.taskwarrior.theme.kanso
    ];

    enable = {
      homeManager =
        { pkgs, lib, ... }:
        {
          programs.taskwarrior = {
            enable = lib.mkDefault true;
            package = lib.mkDefault pkgs.taskwarrior3;
            config = {
              confirmation = lib.mkDefault false;
              recurrence = lib.mkDefault true;
            };
          };
        };
    };

    theme.kanso = {
      homeManager =
        { config, lib, ... }:
        let
          colors = config.lib.stylix.colors;
          hexVal = {
            "0" = 0;
            "1" = 1;
            "2" = 2;
            "3" = 3;
            "4" = 4;
            "5" = 5;
            "6" = 6;
            "7" = 7;
            "8" = 8;
            "9" = 9;
            "a" = 10;
            "b" = 11;
            "c" = 12;
            "d" = 13;
            "e" = 14;
            "f" = 15;
          };
          byte =
            hex: off:
            hexVal.${builtins.substring off 1 hex} * 16 + hexVal.${builtins.substring (off + 1) 1 hex};
          cubeCh = b: toString ((b * 5 + 127) / 255);
          cube = hex: "rgb${cubeCh (byte hex 0)}${cubeCh (byte hex 2)}${cubeCh (byte hex 4)}";
        in
        {
          programs.taskwarrior.config = {
            "color.active" = lib.mkDefault "${cube colors.base00} on ${cube colors.base0A}";
            "color.alternate" = lib.mkDefault "on ${cube colors.base01}";
            "color.blocked" = lib.mkDefault (cube colors.base04);
            "color.blocking" = lib.mkDefault (cube colors.base0A);
            "color.completed" = lib.mkDefault (cube colors.base04);
            "color.deleted" = lib.mkDefault (cube colors.base08);
            "color.due" = lib.mkDefault (cube colors.base0D);
            "color.due.today" = lib.mkDefault (cube colors.base0A);
            "color.overdue" = lib.mkDefault (cube colors.base08);
            "color.recurring" = lib.mkDefault (cube colors.base0E);
            "color.scheduled" = lib.mkDefault (cube colors.base0C);
            "color.tagged" = lib.mkDefault "${cube colors.base05} on ${cube colors.base01}";
          };
        };
    };

    completions = {
      nushellExternalCompleters.task = ''
        {|spans: list<string>|
          let current = ($spans | last | default "")

          let filter_records = {|rows|
            if ($current == "") {
              $rows
            } else {
              $rows | where {|row| $row.value | str starts-with $current }
            }
          }

          let complete_prefixed = {|prefix: string, values: list<string>, description: string, needle: string|
            $values
            | where {|value| if ($needle == "") { true } else { $value | str starts-with $needle } }
            | each {|value| { value: $"($prefix)($value)", description: $description } }
          }

          let complete_zsh_rows = {|command: string, description_prefix: string|
            task rc.hooks=0 $command
            | lines
            | parse "{value}:{description}"
            | each {|row| { value: $row.value, description: $"($description_prefix): ($row.description)" } }
          }

          let commands = (
            task rc.hooks=0 _zshcommands
            | lines
            | parse "{value}:{kind}:{description}"
            | each {|row| { value: $row.value, description: $"($row.kind): ($row.description)" } }
          )
          let aliases = (task rc.hooks=0 _aliases | lines | each {|value| { value: $value, description: "alias" } })
          let ids = (do $complete_zsh_rows _zshids "task")
          let uuids = (do $complete_zsh_rows _zshuuids "uuid")
          let columns = (task rc.hooks=0 _columns | lines)
          let udas = (task rc.hooks=0 _udas | lines)
          let attributes = (
            $columns
            | append $udas
            | uniq
            | each {|value| { value: $"($value):", description: "attribute" } }
          )

          if ($current | str starts-with "+") {
            do $complete_prefixed "+" (task rc.hooks=0 _tags | lines) "tag" ($current | str replace -r "^[+]" "")
          } else if ($current | str starts-with "-") {
            do $complete_prefixed "-" (task rc.hooks=0 _tags | lines) "tag" ($current | str replace -r "^-" "")
          } else if ($current | str starts-with "project:") {
            do $complete_prefixed "project:" (task rc.hooks=0 _projects | lines) "project" ($current | str replace -r "^project:" "")
          } else if ($current | str starts-with "depends:") {
            do $complete_prefixed "depends:" ($uuids | get value) "dependency" ($current | str replace -r "^depends:" "")
          } else if ($current | str starts-with "rc.") {
            do $complete_prefixed "rc." (task rc.hooks=0 _config | lines) "config" ($current | str replace -r "^rc[.]" "")
          } else {
            do $filter_records ($commands | append $aliases | append $ids | append $attributes)
          }
        }
      '';
    };

    tui = {
      vit = {
        homeManager =
          { config, pkgs, ... }:
          {
            home.packages = [ pkgs.vit ];

            home.file."${config.xdg.configHome}/vit/config.ini".text = ''
              [taskwarrior]
              taskrc = ${config.xdg.configHome}/task/taskrc

              [vit]
              default_keybindings = hatious
              theme = default
              confirmation = False
              wait = False
              mouse = False
              abort_backspace = True
              focus_on_add = True
              pid_dir = /run/user/$UID/vit

              [report]
              default_report = next
              default_filter_only_report = next
              indent_subprojects = True
              row_striping = True
            '';

            home.file."${config.xdg.configHome}/vit/keybinding/hatious.ini".text = ''
              [global]
              <Esc> = {ACTION_GLOBAL_ESCAPE}
              Q,ZZ = {ACTION_QUIT}
              q = {ACTION_QUIT_WITH_CONFIRM}
              S = {ACTION_TASK_SYNC}

              [command]
              <Colon> = {ACTION_COMMAND_BAR_EX}
              t = {ACTION_COMMAND_BAR_EX_TASK_READ_WAIT}
              / = {ACTION_COMMAND_BAR_SEARCH_FORWARD}
              ? = {ACTION_COMMAND_BAR_SEARCH_REVERSE}
              n = {ACTION_COMMAND_BAR_SEARCH_NEXT}
              N = {ACTION_COMMAND_BAR_SEARCH_PREVIOUS}
              c = {ACTION_COMMAND_BAR_TASK_CONTEXT}
              u = {ACTION_TASK_ADD}
              - = {ACTION_TASK_UNDO}
              A = {ACTION_TASK_ANNOTATE}
              D = {ACTION_TASK_DELETE}
              m = {ACTION_TASK_MODIFY}
              <Space> = {ACTION_TASK_START_STOP}
              d = {ACTION_TASK_DONE}
              P = {ACTION_TASK_PRIORITY}
              p = {ACTION_TASK_PROJECT}
              T = {ACTION_TASK_TAGS}
              w = {ACTION_TASK_WAIT}
              r = {ACTION_TASK_EDIT}
              <Enter>,<Equals> = {ACTION_TASK_SHOW}

              [navigation]
              <Up>,n = {ACTION_LIST_UP}
              <Down>,e = {ACTION_LIST_DOWN}
              t = {ACTION_LIST_PAGE_UP}
              a = {ACTION_LIST_PAGE_DOWN}
              ^ = {ACTION_LIST_HOME}
              $ = {ACTION_LIST_END}
              H = {ACTION_LIST_SCREEN_TOP}
              M = {ACTION_LIST_SCREEN_MIDDLE}
              L = {ACTION_LIST_SCREEN_BOTTOM}
              C = {ACTION_LIST_FOCUS_VALIGN_CENTER}

              [report]
              f = {ACTION_REPORT_FILTER}
              <Ctrl> l = {ACTION_REFRESH}
            '';
          };

        persistUser =
          { hmConfig, ... }:
          {
            directories = [
              {
                directory = "${hmConfig.xdg.configHome}/vit";
                how = "symlink";
                createLinkTarget = true;
              }
            ];
          };
      };

      taskwarrior-tui = {
        homeManager =
          { pkgs, lib, ... }:
          {
            home.packages = [ pkgs.taskwarrior-tui ];
            programs.taskwarrior.config = {
              "uda.taskwarrior-tui.keyconfig.quit" = lib.mkDefault "q";
              "uda.taskwarrior-tui.keyconfig.filter" = lib.mkDefault "/";
              "uda.taskwarrior-tui.keyconfig.shell" = lib.mkDefault "!";
              "uda.taskwarrior-tui.keyconfig.help" = lib.mkDefault "?";
              "uda.taskwarrior-tui.keyconfig.zoom" = lib.mkDefault "+";
              "uda.taskwarrior-tui.keyconfig.transpose" = lib.mkDefault "\\";
              "uda.taskwarrior-tui.keyconfig.up" = lib.mkDefault "n";
              "uda.taskwarrior-tui.keyconfig.down" = lib.mkDefault "e";
              "uda.taskwarrior-tui.keyconfig.page-up" = lib.mkDefault "N";
              "uda.taskwarrior-tui.keyconfig.page-down" = lib.mkDefault "E";
              "uda.taskwarrior-tui.keyconfig.go-to-top" = lib.mkDefault "^";
              "uda.taskwarrior-tui.keyconfig.go-to-bottom" = lib.mkDefault "$";
              "uda.taskwarrior-tui.keyconfig.delete" = lib.mkDefault "D";
              "uda.taskwarrior-tui.keyconfig.undo" = lib.mkDefault "-";
              "uda.taskwarrior-tui.keyconfig.refresh" = lib.mkDefault "l";
              "uda.taskwarrior-tui.keyconfig.start-stop" = lib.mkDefault " ";
              "uda.taskwarrior-tui.keyconfig.edit" = lib.mkDefault "m";
              "uda.taskwarrior-tui.keyconfig.modify" = lib.mkDefault "j";
              "uda.taskwarrior-tui.keyconfig.quick-tag" = lib.mkDefault "t";
              "uda.taskwarrior-tui.keyconfig.annotate" = lib.mkDefault "A";
              "uda.taskwarrior-tui.keyconfig.add" = lib.mkDefault "u";
              "uda.taskwarrior-tui.keyconfig.done" = lib.mkDefault "d";
              "uda.taskwarrior-tui.keyconfig.duplicate" = lib.mkDefault "p";
              "uda.taskwarrior-tui.keyconfig.select" = lib.mkDefault "b";
              "uda.taskwarrior-tui.keyconfig.select-all" = lib.mkDefault "%";
              "uda.taskwarrior-tui.keyconfig.previous-tab" = lib.mkDefault "[";
              "uda.taskwarrior-tui.keyconfig.log" = lib.mkDefault "C";
              "uda.taskwarrior-tui.keyconfig.context-menu" = lib.mkDefault "c";
              "uda.taskwarrior-tui.keyconfig.report-menu" = lib.mkDefault "i";
              "uda.taskwarrior-tui.keyconfig.next-tab" = lib.mkDefault "]";
              "uda.taskwarrior-tui.style.context.active" = lib.mkDefault "color16 on color180";
              "uda.taskwarrior-tui.style.report-menu.active" = lib.mkDefault "color16 on color180";
              "uda.taskwarrior-tui.style.calendar.title" = lib.mkDefault "color16 on color180";
              "uda.taskwarrior-tui.style.navbar" = lib.mkDefault "color251 on color235";
              "uda.taskwarrior-tui.style.command" = lib.mkDefault "color251 on color235";
              "uda.taskwarrior-tui.style.report.scrollbar" = lib.mkDefault "color241";
              "uda.taskwarrior-tui.style.report.scrollbar.area" = lib.mkDefault "color235";
              "uda.taskwarrior-tui.task-report.use-alternate-style" = lib.mkDefault true;
            };
          };

        persistUser =
          { hmConfig, ... }:
          {
            directories = [
              {
                directory = "${hmConfig.xdg.dataHome}/taskwarrior-tui";
                how = "symlink";
                createLinkTarget = true;
              }
            ];
          };

        persistUserTmp =
          { hmConfig, ... }:
          {
            "${hmConfig.xdg.dataHome}" = { };
          };
      };
    };

    persistence = {
      persistUser =
        { hmConfig, ... }:
        {
          directories = [
            {
              directory = "${hmConfig.xdg.configHome}/task";
              how = "symlink";
              createLinkTarget = true;
            }
            {
              directory = "${hmConfig.xdg.dataHome}/task";
              how = "symlink";
              createLinkTarget = true;
            }
          ];
        };

      persistUserTmp =
        { hmConfig, ... }:
        {
          ".local" = { };
          "${hmConfig.xdg.configHome}" = { };
          "${hmConfig.xdg.dataHome}" = { };
        };
    };
  };
}
