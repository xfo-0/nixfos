{
  flake-file.inputs.jjui.url = "gh:idursun/jjui";

  den.aspects.jj = {
    homeManager =
      {
        pkgs,
        inputs',
        lib,
        ...
      }:
      {
        programs.jujutsu = {
          enable = lib.mkDefault true;
          settings = {
            user = {
              name = "xfo-0";
              email = "xfo-0@users.noreply.github.com";
            };

            diff.tool = [
              "difft"
              "--color=always"
              "$left"
              "$right"
            ];

            fsmonitor.backend = "watchman";
            fsmonitor.watchman.register-snapshot-trigger = true;

            git = {
              fetch = [ "origin" ];
              private-commits = "description(glob:'wip:*') | description(glob:'private:*')";
              write-change-id-header = true;
            };

            merge-tools.difft.diff-args = [
              "--color=always"
              "--display=side-by-side"
              "$left"
              "$right"
            ];

            merge-tools.nvim = {
              conflict-marker-style = "snapshot";
              diff-invocation-mode = "file-by-file";
              merge-args = [
                "--cmd"
                "let g:quit_on_write=1"
                "-d"
                "$output"
                "-M"
                "$left"
                "$base"
                "$right"
                "-c"
                "wincmd J"
                "-c"
                "set modifiable"
                "-c"
                "set write"
              ];
              merge-tool-edits-conflict-markers = true;
              program = "nvim";
            };

            revset-aliases = {
              "closest_bookmark(to)" = "heads(::to & bookmarks())";
              "closest_pushable(to)" =
                "heads(::to & mutable() & ~description(exact:\"\") & (~empty() | merges()))";
            };

            snapshot.max-new-file-size = "15M";

            ui = {
              default-command = "log";
              diff-editor = [
                "nvim"
                "-c"
                "DiffEditor $left $right $output"
              ];
              diff-formatter = [
                "difft"
                "--color=always"
                "$left"
                "$right"
              ];
              merge-editor = "diffconflicts";
              show-cryptographic-signatures = true;
              graph.style = "square";
            };
          };
        };

        programs.jjui = {
          enable = lib.mkDefault true;
          package = inputs'.jjui.packages.jjui;
          settings = {
            bindings_profile = "empty-bindings.toml";
            limit = 0;

            graph.batch_size = 50;

            # Colemak: n=up e=down c=left i=right
            # Custom: r=acejump f=preview j=describe u=new d=abandon
            bindings = [
              # ui
              {
                key = "esc";
                action = "ui.cancel";
                scope = "ui";
              }
              {
                key = "q";
                action = "ui.quit";
                scope = "ui";
              }
              {
                key = "?";
                action = "ui.expand_status";
                scope = "ui";
              }
              {
                key = "f1";
                action = "ui.open_help";
                scope = "ui";
              }
              {
                key = "ctrl+l";
                action = "ui.suspend";
                scope = "ui";
              }

              # help
              {
                key = "esc";
                action = "help.cancel";
                scope = "help";
              }
              {
                key = "n";
                action = "help.scroll_up";
                scope = "help";
              }
              {
                key = "e";
                action = "help.scroll_down";
                scope = "help";
              }
              {
                key = "pgup";
                action = "help.page_up";
                scope = "help";
              }
              {
                key = "pgdown";
                action = "help.page_down";
                scope = "help";
              }
              {
                key = "g";
                action = "help.move_top";
                scope = "help";
              }
              {
                key = "G";
                action = "help.move_bottom";
                scope = "help";
              }
              {
                key = "/";
                action = "help.filter";
                scope = "help";
              }
              {
                key = "esc";
                action = "help.cancel";
                scope = "help.filter";
              }
              {
                key = "enter";
                action = "help.apply";
                scope = "help.filter";
              }

              # revset
              {
                key = [
                  "esc"
                  "ctrl+c"
                ];
                action = "revset.cancel";
                scope = "revset";
              }
              {
                key = "enter";
                action = "revset.apply";
                scope = "revset";
              }
              {
                key = "tab";
                action = "revset.autocomplete";
                scope = "revset";
              }
              {
                key = "shift+tab";
                action = "revset.autocomplete_back";
                scope = "revset";
              }
              {
                key = "up";
                action = "revset.move_up";
                scope = "revset";
              }
              {
                key = "down";
                action = "revset.move_down";
                scope = "revset";
              }

              # preview — alt+{c,i,n,e} = Colemak arrows
              {
                key = "alt+c";
                action = "ui.preview_expand";
                scope = "ui.preview";
              }
              {
                key = "alt+i";
                action = "ui.preview_shrink";
                scope = "ui.preview";
              }
              {
                key = "ctrl+p";
                action = "ui.preview_scroll_up";
                scope = "ui.preview";
              }
              {
                key = "ctrl+n";
                action = "ui.preview_scroll_down";
                scope = "ui.preview";
              }
              {
                key = "alt+n";
                action = "ui.preview_half_page_up";
                scope = "ui.preview";
              }
              {
                key = "alt+e";
                action = "ui.preview_half_page_down";
                scope = "ui.preview";
              }

              # revisions
              {
                key = "esc";
                action = "revisions.cancel";
                scope = "revisions";
              }
              {
                key = "n";
                action = "revisions.move_up";
                scope = "revisions";
              }
              {
                key = "e";
                action = "revisions.move_down";
                scope = "revisions";
              }
              {
                key = "ctrl+o";
                action = "revisions.refresh";
                scope = "revisions";
              }
              {
                key = "f";
                action = "ui.preview_toggle";
                scope = "revisions";
              }
              {
                key = "w";
                action = "revset.edit";
                scope = "revisions";
              }
              {
                key = "i";
                action = "revisions.open_details";
                scope = "revisions";
              }
              {
                key = "j";
                action = "revisions.open_inline_describe";
                scope = "revisions";
              }
              {
                key = "a";
                action = "revisions.open_rebase";
                scope = "revisions";
              }
              {
                key = "m";
                action = "revisions.open_evolog";
                scope = "revisions";
              }
              {
                key = "|";
                action = "ui.open_bookmarks";
                scope = "revisions";
              }
              {
                key = ",";
                action = "ui.open_git";
                scope = "revisions";
              }
              {
                key = "M";
                action = "ui.open_oplog";
                scope = "revisions";
              }
              {
                key = "_";
                action = "revisions.open_squash";
                scope = "revisions";
              }
              {
                key = "S";
                action = "revisions.open_set_parents";
                scope = "revisions";
              }
              {
                key = "A";
                action = "revisions.open_revert";
                scope = "revisions";
              }
              {
                key = "h";
                action = "revisions.open_duplicate";
                scope = "revisions";
              }
              {
                key = "#";
                action = "revisions.diff";
                scope = "revisions";
              }
              {
                key = "d";
                action = "revisions.open_abandon";
                scope = "revisions";
              }
              {
                key = "u";
                action = "revisions.new";
                scope = "revisions";
              }
              {
                key = "%";
                action = "revisions.split";
                scope = "revisions";
              }
              {
                key = "alt+s";
                action = "revisions.split_parallel";
                scope = "revisions";
              }
              {
                key = "+";
                action = "revisions.open_set_bookmark";
                scope = "revisions";
              }
              {
                key = "J";
                action = "revisions.describe";
                scope = "revisions";
              }
              {
                key = "enter";
                action = "revisions.edit";
                scope = "revisions";
              }
              {
                key = "ctrl+enter";
                action = "revisions.force_edit";
                scope = "revisions";
              }
              {
                key = "=";
                action = "revisions.commit";
                scope = "revisions";
              }
              {
                key = "ctrl+z";
                action = "revisions.diff_edit";
                scope = "revisions";
              }
              {
                key = "b";
                action = "revisions.open_absorb";
                scope = "revisions";
              }
              {
                key = "-";
                action = "ui.open_undo";
                scope = "revisions";
              }
              {
                key = "shift+u";
                action = "ui.open_redo";
                scope = "revisions";
              }
              {
                key = "space";
                action = "revisions.toggle_select";
                scope = "revisions";
              }
              {
                key = "^";
                action = "revisions.jump_to_parent";
                scope = "revisions";
              }
              {
                key = "$";
                action = "revisions.jump_to_children";
                scope = "revisions";
              }
              {
                key = "@";
                action = "revisions.jump_to_working_copy";
                scope = "revisions";
              }
              {
                key = "r";
                action = "revisions.ace_jump";
                scope = "revisions";
              }
              {
                key = "/";
                action = "ui.quick_search";
                scope = "revisions";
              }
              {
                key = "pgup";
                action = "revisions.page_up";
                scope = "revisions";
              }
              {
                key = "pgdown";
                action = "revisions.page_down";
                scope = "revisions";
              }
              {
                key = "t";
                action = "ui.file_search_toggle";
                scope = "revisions";
              }
              {
                key = ":";
                action = "ui.exec_jj";
                scope = "revisions";
              }
              {
                key = "!";
                action = "ui.exec_shell";
                scope = "revisions";
              }
              {
                key = "shift+w";
                action = "ui.open_command_history";
                scope = "revisions";
              }
              {
                key = "shift+p";
                action = "ui.preview_toggle_bottom";
                scope = "revisions";
              }

              # revisions.quick_search
              {
                key = "ctrl+e";
                action = "revisions.quick_search.next";
                scope = "revisions.quick_search";
              }
              {
                key = "esc";
                action = "revisions.quick_search.clear";
                scope = "revisions.quick_search";
              }

              # revisions.rebase — args omitted (jjui merge bug leaks args)
              # default source keys: r=revision shift+b=branch s=descendants
              # default target keys: b=before a=after o=onto i=insert
              {
                key = "v";
                action = "revisions.rebase.target_picker";
                scope = "revisions.rebase";
              }
              {
                key = "r";
                action = "revisions.rebase.ace_jump";
                scope = "revisions.rebase";
              }
              {
                key = "@";
                action = "revisions.jump_to_working_copy";
                scope = "revisions.rebase";
              }
              {
                key = "n";
                action = "revisions.move_up";
                scope = "revisions.rebase";
              }
              {
                key = "e";
                action = "revisions.move_down";
                scope = "revisions.rebase";
              }
              {
                key = "pgup";
                action = "revisions.page_up";
                scope = "revisions.rebase";
              }
              {
                key = "pgdown";
                action = "revisions.page_down";
                scope = "revisions.rebase";
              }
              {
                key = "enter";
                action = "revisions.rebase.apply";
                scope = "revisions.rebase";
              }
              {
                key = "alt+enter";
                action = "revisions.rebase.force_apply";
                scope = "revisions.rebase";
              }

              # revisions.squash — no args (jjui merge bug)
              # default: alt+enter=force, t=target_picker
              {
                key = "v";
                action = "revisions.squash.target_picker";
                scope = "revisions.squash";
              }
              {
                key = "s";
                action = "revisions.squash.keep_emptied";
                scope = "revisions.squash";
              }
              {
                key = "d";
                action = "revisions.squash.use_destination_msg";
                scope = "revisions.squash";
              }
              {
                key = "h";
                action = "revisions.squash.interactive";
                scope = "revisions.squash";
              }
              {
                key = "r";
                action = "revisions.squash.ace_jump";
                scope = "revisions.squash";
              }
              {
                key = "n";
                action = "revisions.move_up";
                scope = "revisions.squash";
              }
              {
                key = "e";
                action = "revisions.move_down";
                scope = "revisions.squash";
              }
              {
                key = "pgup";
                action = "revisions.page_up";
                scope = "revisions.squash";
              }
              {
                key = "pgdown";
                action = "revisions.page_down";
                scope = "revisions.squash";
              }
              {
                key = "@";
                action = "revisions.jump_to_working_copy";
                scope = "revisions.squash";
              }
              {
                key = "enter";
                action = "revisions.squash.apply";
                scope = "revisions.squash";
              }
              {
                key = "alt+enter";
                action = "revisions.squash.force_apply";
                scope = "revisions.squash";
              }

              # revisions.revert — no args (jjui merge bug)
              # default target keys: b=before a=after o=onto i=insert
              {
                key = "v";
                action = "revisions.revert.target_picker";
                scope = "revisions.revert";
              }
              {
                key = "n";
                action = "revisions.move_up";
                scope = "revisions.revert";
              }
              {
                key = "e";
                action = "revisions.move_down";
                scope = "revisions.revert";
              }
              {
                key = "pgup";
                action = "revisions.page_up";
                scope = "revisions.revert";
              }
              {
                key = "pgdown";
                action = "revisions.page_down";
                scope = "revisions.revert";
              }
              {
                key = "enter";
                action = "revisions.revert.apply";
                scope = "revisions.revert";
              }

              # revisions.duplicate — no args (jjui merge bug)
              # default target keys: a=after b=before o=onto i=insert
              {
                key = "v";
                action = "revisions.duplicate.target_picker";
                scope = "revisions.duplicate";
              }
              {
                key = "r";
                action = "revisions.duplicate.ace_jump";
                scope = "revisions.duplicate";
              }
              {
                key = "n";
                action = "revisions.move_up";
                scope = "revisions.duplicate";
              }
              {
                key = "e";
                action = "revisions.move_down";
                scope = "revisions.duplicate";
              }
              {
                key = "pgup";
                action = "revisions.page_up";
                scope = "revisions.duplicate";
              }
              {
                key = "pgdown";
                action = "revisions.page_down";
                scope = "revisions.duplicate";
              }
              {
                key = "@";
                action = "revisions.jump_to_working_copy";
                scope = "revisions.duplicate";
              }
              {
                key = "enter";
                action = "revisions.duplicate.apply";
                scope = "revisions.duplicate";
              }

              # revisions.details
              {
                key = "n";
                action = "revisions.details.move_up";
                scope = "revisions.details";
              }
              {
                key = "e";
                action = "revisions.details.move_down";
                scope = "revisions.details";
              }
              {
                key = "pgup";
                action = "revisions.details.page_up";
                scope = "revisions.details";
              }
              {
                key = "pgdown";
                action = "revisions.details.page_down";
                scope = "revisions.details";
              }
              {
                key = [
                  "esc"
                  "c"
                ];
                action = "revisions.details.cancel";
                scope = "revisions.details";
              }
              {
                key = "ctrl+o";
                action = "revisions.details.refresh";
                scope = "revisions.details";
              }
              {
                key = "#";
                action = "revisions.details.diff";
                scope = "revisions.details";
              }
              {
                key = "space";
                action = "revisions.details.toggle_select";
                scope = "revisions.details";
              }
              {
                key = "%";
                action = "revisions.details.split";
                scope = "revisions.details";
              }
              {
                key = "alt+s";
                action = "revisions.details.split_parallel";
                scope = "revisions.details";
              }
              {
                key = "_";
                action = "revisions.details.squash";
                scope = "revisions.details";
              }
              {
                key = "-";
                action = "revisions.details.restore";
                scope = "revisions.details";
              }
              {
                key = "k";
                action = "revisions.details.absorb";
                scope = "revisions.details";
              }
              {
                key = "*";
                action = "revisions.details.revisions_changing_file";
                scope = "revisions.details";
              }
              {
                key = "f";
                action = "ui.preview_toggle";
                scope = "revisions.details";
              }
              {
                key = "c";
                action = "revisions.details.confirmation.prev";
                scope = "revisions.details.confirmation";
              }
              {
                key = "i";
                action = "revisions.details.confirmation.next";
                scope = "revisions.details.confirmation";
              }
              {
                key = "enter";
                action = "revisions.details.confirmation.apply";
                scope = "revisions.details.confirmation";
              }
              {
                key = "esc";
                action = "revisions.details.confirmation.cancel";
                scope = "revisions.details.confirmation";
              }

              # revisions.evolog
              {
                key = "n";
                action = "revisions.evolog.move_up";
                scope = "revisions.evolog";
              }
              {
                key = "e";
                action = "revisions.evolog.move_down";
                scope = "revisions.evolog";
              }
              {
                key = "pgup";
                action = "revisions.evolog.page_up";
                scope = "revisions.evolog";
              }
              {
                key = "pgdown";
                action = "revisions.evolog.page_down";
                scope = "revisions.evolog";
              }
              {
                key = "esc";
                action = "revisions.evolog.cancel";
                scope = "revisions.evolog";
              }
              {
                key = "enter";
                action = "revisions.evolog.apply";
                scope = "revisions.evolog";
              }
              {
                key = "d";
                action = "revisions.evolog.diff";
                scope = "revisions.evolog";
              }
              {
                key = "r";
                action = "revisions.evolog.restore";
                scope = "revisions.evolog";
              }
              {
                key = "f";
                action = "ui.preview_toggle";
                scope = "revisions.evolog";
              }
              {
                key = "shift+p";
                action = "ui.preview_toggle_bottom";
                scope = "revisions.evolog";
              }

              # revisions.abandon — default: alt+enter=force
              {
                key = "space";
                action = "revisions.abandon.toggle_select";
                scope = "revisions.abandon";
              }
              {
                key = "esc";
                action = "revisions.abandon.cancel";
                scope = "revisions.abandon";
              }
              {
                key = "s";
                action = "revisions.abandon.select_descendants";
                scope = "revisions.abandon";
              }
              {
                key = "r";
                action = "revisions.abandon.ace_jump";
                scope = "revisions.abandon";
              }
              {
                key = "n";
                action = "revisions.move_up";
                scope = "revisions.abandon";
              }
              {
                key = "e";
                action = "revisions.move_down";
                scope = "revisions.abandon";
              }
              {
                key = "pgup";
                action = "revisions.page_up";
                scope = "revisions.abandon";
              }
              {
                key = "pgdown";
                action = "revisions.page_down";
                scope = "revisions.abandon";
              }
              {
                key = "@";
                action = "revisions.jump_to_working_copy";
                scope = "revisions.abandon";
              }
              {
                key = "enter";
                action = "revisions.abandon.apply";
                scope = "revisions.abandon";
              }
              {
                key = "alt+enter";
                action = "revisions.abandon.force_apply";
                scope = "revisions.abandon";
              }

              # revisions.absorb
              {
                key = "space";
                action = "revisions.absorb.toggle_select";
                scope = "revisions.absorb";
              }
              {
                key = "enter";
                action = "revisions.absorb.apply";
                scope = "revisions.absorb";
              }
              {
                key = "r";
                action = "revisions.absorb.ace_jump";
                scope = "revisions.absorb";
              }
              {
                key = "esc";
                action = "revisions.absorb.cancel";
                scope = "revisions.absorb";
              }
              {
                key = "n";
                action = "revisions.move_up";
                scope = "revisions.absorb";
              }
              {
                key = "e";
                action = "revisions.move_down";
                scope = "revisions.absorb";
              }
              {
                key = "pgup";
                action = "revisions.page_up";
                scope = "revisions.absorb";
              }
              {
                key = "pgdown";
                action = "revisions.page_down";
                scope = "revisions.absorb";
              }
              {
                key = "@";
                action = "revisions.jump_to_working_copy";
                scope = "revisions.absorb";
              }

              # revisions.set_parents
              {
                key = "space";
                action = "revisions.set_parents.toggle_select";
                scope = "revisions.set_parents";
              }
              {
                key = "enter";
                action = "revisions.set_parents.apply";
                scope = "revisions.set_parents";
              }
              {
                key = "r";
                action = "revisions.set_parents.ace_jump";
                scope = "revisions.set_parents";
              }
              {
                key = "esc";
                action = "revisions.set_parents.cancel";
                scope = "revisions.set_parents";
              }
              {
                key = "n";
                action = "revisions.move_up";
                scope = "revisions.set_parents";
              }
              {
                key = "e";
                action = "revisions.move_down";
                scope = "revisions.set_parents";
              }
              {
                key = "pgup";
                action = "revisions.page_up";
                scope = "revisions.set_parents";
              }
              {
                key = "pgdown";
                action = "revisions.page_down";
                scope = "revisions.set_parents";
              }
              {
                key = "@";
                action = "revisions.jump_to_working_copy";
                scope = "revisions.set_parents";
              }

              # revisions.inline_describe
              {
                key = "esc";
                action = "revisions.inline_describe.cancel";
                scope = "revisions.inline_describe";
              }
              {
                key = "alt+e";
                action = "revisions.inline_describe.editor";
                scope = "revisions.inline_describe";
              }
              {
                key = [
                  "alt+enter"
                  "ctrl+s"
                ];
                action = "revisions.inline_describe.accept";
                scope = "revisions.inline_describe";
              }
              {
                key = "alt+shift+enter";
                action = "revisions.inline_describe.force_accept";
                scope = "revisions.inline_describe";
              }
              {
                key = "enter";
                action = "revisions.inline_describe.new_line";
                scope = "revisions.inline_describe";
              }

              # revisions.set_bookmark
              {
                key = "esc";
                action = "revisions.set_bookmark.cancel";
                scope = "revisions.set_bookmark";
              }
              {
                key = "enter";
                action = "revisions.set_bookmark.apply";
                scope = "revisions.set_bookmark";
              }
              {
                key = "tab";
                action = "revisions.set_bookmark.autocomplete";
                scope = "revisions.set_bookmark";
              }
              {
                key = "shift+tab";
                action = "revisions.set_bookmark.autocomplete_back";
                scope = "revisions.set_bookmark";
              }

              # revisions.target_picker
              {
                key = "esc";
                action = "revisions.target_picker.cancel";
                scope = "revisions.target_picker";
              }
              {
                key = "enter";
                action = "revisions.target_picker.apply";
                scope = "revisions.target_picker";
              }
              {
                key = "up";
                action = "revisions.target_picker.move_up";
                scope = "revisions.target_picker";
              }
              {
                key = "down";
                action = "revisions.target_picker.move_down";
                scope = "revisions.target_picker";
              }
              {
                key = "tab";
                action = "revisions.target_picker.autocomplete";
                scope = "revisions.target_picker";
              }
              {
                key = "shift+tab";
                action = "revisions.target_picker.autocomplete_back";
                scope = "revisions.target_picker";
              }

              # revisions.ace_jump / quick_search.input
              {
                key = "esc";
                action = "revisions.ace_jump.cancel";
                scope = "revisions.ace_jump";
              }
              {
                key = "enter";
                action = "revisions.ace_jump.apply";
                scope = "revisions.ace_jump";
              }
              {
                key = "esc";
                action = "revisions.quick_search.input.cancel";
                scope = "revisions.quick_search.input";
              }
              {
                key = "enter";
                action = "revisions.quick_search.input.apply";
                scope = "revisions.quick_search.input";
              }

              # status.input
              {
                key = "esc";
                action = "status.input.cancel";
                scope = "status.input";
              }
              {
                key = "enter";
                action = "status.input.apply";
                scope = "status.input";
              }
              {
                key = "ctrl+r";
                action = "status.input.autocomplete";
                scope = "status.input";
              }
              {
                key = [
                  "up"
                  "ctrl+p"
                ];
                action = "status.input.move_up";
                scope = "status.input";
              }
              {
                key = [
                  "down"
                  "ctrl+n"
                ];
                action = "status.input.move_down";
                scope = "status.input";
              }
              {
                key = [
                  "ctrl+u"
                  "pgup"
                ];
                action = "status.input.page_up";
                scope = "status.input";
              }
              {
                key = [
                  "ctrl+d"
                  "pgdown"
                ];
                action = "status.input.page_down";
                scope = "status.input";
              }

              # file_search
              {
                key = "esc";
                action = "file_search.cancel";
                scope = "file_search";
              }
              {
                key = "enter";
                action = "file_search.apply";
                scope = "file_search";
              }
              {
                key = "t";
                action = "file_search.toggle";
                scope = "file_search";
              }
              {
                key = "alt+e";
                action = "file_search.edit";
                scope = "file_search";
              }
              {
                key = "ctrl+n";
                action = "file_search.move_up";
                scope = "file_search";
              }
              {
                key = "ctrl+e";
                action = "file_search.move_down";
                scope = "file_search";
              }
              {
                key = [
                  "ctrl+u"
                  "pgup"
                ];
                action = "file_search.page_up";
                scope = "file_search";
              }
              {
                key = [
                  "ctrl+d"
                  "pgdown"
                ];
                action = "file_search.page_down";
                scope = "file_search";
              }
              {
                key = "ctrl+b";
                action = "file_search.preview_half_page_up";
                scope = "file_search";
              }
              {
                key = "ctrl+f";
                action = "file_search.preview_half_page_down";
                scope = "file_search";
              }

              # bookmarks
              {
                key = "esc";
                action = "bookmarks.cancel";
                scope = "bookmarks";
              }
              {
                key = "enter";
                action = "bookmarks.apply";
                scope = "bookmarks";
              }
              {
                key = "r";
                action = "bookmarks.bookmark_move";
                scope = "bookmarks";
              }
              {
                key = "d";
                action = "bookmarks.bookmark_delete";
                scope = "bookmarks";
              }
              {
                key = "-";
                action = "bookmarks.bookmark_forget";
                scope = "bookmarks";
              }
              {
                key = "h";
                action = "bookmarks.bookmark_track";
                scope = "bookmarks";
              }
              {
                key = "s";
                action = "bookmarks.bookmark_untrack";
                scope = "bookmarks";
              }
              {
                key = "/";
                action = "bookmarks.filter";
                scope = "bookmarks";
              }
              {
                key = "tab";
                action = "bookmarks.cycle_remotes";
                scope = "bookmarks";
              }
              {
                key = "shift+tab";
                action = "bookmarks.cycle_remotes_back";
                scope = "bookmarks";
              }
              {
                key = "n";
                action = "bookmarks.move_up";
                scope = "bookmarks";
              }
              {
                key = "e";
                action = "bookmarks.move_down";
                scope = "bookmarks";
              }
              {
                key = "pgup";
                action = "bookmarks.page_up";
                scope = "bookmarks";
              }
              {
                key = "pgdown";
                action = "bookmarks.page_down";
                scope = "bookmarks";
              }
              {
                key = "esc";
                action = "bookmarks.cancel";
                scope = "bookmarks.filter";
              }
              {
                key = "enter";
                action = "bookmarks.apply";
                scope = "bookmarks.filter";
              }

              # git
              {
                key = "esc";
                action = "git.cancel";
                scope = "git";
              }
              {
                key = "enter";
                action = "git.apply";
                scope = "git";
              }
              {
                key = "u";
                action = "git.push";
                scope = "git";
              }
              {
                key = "y";
                action = "git.fetch";
                scope = "git";
              }
              {
                key = "/";
                action = "git.filter";
                scope = "git";
              }
              {
                key = "tab";
                action = "git.cycle_remotes";
                scope = "git";
              }
              {
                key = "shift+tab";
                action = "git.cycle_remotes_back";
                scope = "git";
              }
              {
                key = "n";
                action = "git.move_up";
                scope = "git";
              }
              {
                key = "e";
                action = "git.move_down";
                scope = "git";
              }
              {
                key = "pgup";
                action = "git.page_up";
                scope = "git";
              }
              {
                key = "pgdown";
                action = "git.page_down";
                scope = "git";
              }
              {
                key = "esc";
                action = "git.cancel";
                scope = "git.filter";
              }
              {
                key = "enter";
                action = "git.apply";
                scope = "git.filter";
              }

              # oplog
              {
                key = "n";
                action = "oplog.move_up";
                scope = "oplog";
              }
              {
                key = "e";
                action = "oplog.move_down";
                scope = "oplog";
              }
              {
                key = "pgup";
                action = "oplog.page_up";
                scope = "oplog";
              }
              {
                key = "pgdown";
                action = "oplog.page_down";
                scope = "oplog";
              }
              {
                key = "esc";
                action = "oplog.close";
                scope = "oplog";
              }
              {
                key = "d";
                action = "oplog.diff";
                scope = "oplog";
              }
              {
                key = "-";
                action = "oplog.restore";
                scope = "oplog";
              }
              {
                key = "shift+r";
                action = "oplog.revert";
                scope = "oplog";
              }
              {
                key = "f";
                action = "ui.preview_toggle";
                scope = "oplog";
              }
              {
                key = "shift+p";
                action = "ui.preview_toggle_bottom";
                scope = "oplog";
              }
              {
                key = "/";
                action = "ui.quick_search";
                scope = "oplog";
              }
              {
                key = "ctrl+e";
                action = "oplog.quick_search.next";
                scope = "oplog.quick_search";
              }
              {
                key = "esc";
                action = "oplog.quick_search.clear";
                scope = "oplog.quick_search";
              }

              # undo / redo — Colemak left/right
              {
                key = "c";
                action = "undo.prev";
                scope = "undo";
              }
              {
                key = "i";
                action = "undo.next";
                scope = "undo";
              }
              {
                key = "enter";
                action = "undo.apply";
                scope = "undo";
              }
              {
                key = "esc";
                action = "undo.cancel";
                scope = "undo";
              }
              {
                key = "c";
                action = "redo.prev";
                scope = "redo";
              }
              {
                key = "i";
                action = "redo.next";
                scope = "redo";
              }
              {
                key = "enter";
                action = "redo.apply";
                scope = "redo";
              }
              {
                key = "esc";
                action = "redo.cancel";
                scope = "redo";
              }

              # diff
              {
                key = "n";
                action = "diff.scroll_up";
                scope = "diff";
              }
              {
                key = "e";
                action = "diff.scroll_down";
                scope = "diff";
              }
              {
                key = [
                  "pgup"
                  "b"
                ];
                action = "diff.page_up";
                scope = "diff";
              }
              {
                key = [
                  "pgdown"
                  " "
                ];
                action = "diff.page_down";
                scope = "diff";
              }
              {
                key = "ctrl+u";
                action = "diff.half_page_up";
                scope = "diff";
              }
              {
                key = "ctrl+d";
                action = "diff.half_page_down";
                scope = "diff";
              }
              {
                key = "g";
                action = "diff.move_top";
                scope = "diff";
              }
              {
                key = "G";
                action = "diff.move_bottom";
                scope = "diff";
              }
              {
                key = "c";
                action = "diff.left";
                scope = "diff";
              }
              {
                key = "i";
                action = "diff.right";
                scope = "diff";
              }
              {
                key = "w";
                action = "diff.toggle_wrap";
                scope = "diff";
              }
              {
                key = "esc";
                action = "ui.cancel";
                scope = "diff";
              }

              # command_history
              {
                key = "n";
                action = "command_history.move_up";
                scope = "command_history";
              }
              {
                key = "e";
                action = "command_history.move_down";
                scope = "command_history";
              }
              {
                key = "shift+w";
                action = "command_history.close";
                scope = "command_history";
              }
              {
                key = "d";
                action = "command_history.delete_selected";
                scope = "command_history";
              }
              {
                key = "esc";
                action = "command_history.close";
                scope = "command_history";
              }

              # input / password
              {
                key = "esc";
                action = "input.cancel";
                scope = "input";
              }
              {
                key = "enter";
                action = "input.apply";
                scope = "input";
              }
              {
                key = [
                  "esc"
                  "ctrl+c"
                ];
                action = "password.cancel";
                scope = "password";
              }
              {
                key = "enter";
                action = "password.apply";
                scope = "password";
              }

              # choose
              {
                key = "n";
                action = "choose.move_up";
                scope = "choose";
              }
              {
                key = "e";
                action = "choose.move_down";
                scope = "choose";
              }
              {
                key = "enter";
                action = "choose.apply";
                scope = "choose";
              }
              {
                key = "esc";
                action = "choose.cancel";
                scope = "choose";
              }
              {
                key = "up";
                action = "choose.move_up";
                scope = "choose.filter";
              }
              {
                key = "down";
                action = "choose.move_down";
                scope = "choose.filter";
              }
              {
                key = "enter";
                action = "choose.apply";
                scope = "choose.filter";
              }
              {
                key = "esc";
                action = "choose.cancel";
                scope = "choose.filter";
              }
            ];

            custom_commands."resolve mergiraf" = {
              args = [
                "resolve"
                "--tool"
                "mergiraf"
              ];
              key = [ "=" ];
              show = "interactive";
            };

            oplog.limit = 200;

            preview = {
              file_command = [
                "diff"
                "--color"
                "always"
                "-r"
                "$change_id"
                "$file"
              ];
              oplog_command = [
                "op"
                "show"
                "$operation_id"
                "--color"
                "always"
              ];
              revision_command = [
                "show"
                "--color"
                "always"
                "-r"
                "$change_id"
              ];
              show_at_bottom = true;
              show_at_start = false;
              width_increment_percentage = 5.0;
              width_percentage = 60.0;
            };

            revisions = {
              log_batching = true;
              revset = "::";
            };

            ui = {
              auto_refresh_interval = 0;
              tracer.enabled = true;
            };
          };
        };

        home.packages = with pkgs; [
          difftastic
          watchman
        ];

        xdg.configFile."jjui/empty-bindings.toml".text = ''
          bindings = []
        '';

        programs.nushell.extraConfig = ''
          def jjp [] {
            let bookmarks = (jj bookmark list --tracked -T 'name ++ "\n"' | lines | where {|l| $l | is-not-empty } | uniq)
            let leaked = ($bookmarks | each {|b|
              jj file list -r $b
              | lines
              | where {|f| $f =~ '^(\.claude/|\.opencode/|docs/|den-guidelines\.md)' }
              | each {|f| $"($b): ($f)" }
            } | flatten)
            if ($leaked | is-not-empty) {
              error make { msg: $"refusing push: private paths in publishable bookmarks:\n($leaked | str join (char nl))" }
            }
            jj git push
          }
        '';
      };

    persistUser =
      { hmConfig, ... }:
      {
        directories = [
          {
            directory = "${hmConfig.xdg.configHome}/jj/repos";
            how = "symlink";
          }
        ];
      };
  };
}
