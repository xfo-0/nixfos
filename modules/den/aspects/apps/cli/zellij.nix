{
  den.aspects.zellij = {
    homeManager =
      { config, lib, ... }:
      {
        programs.zellij = {
          enable = lib.mkDefault true;
          extraConfig = lib.mkDefault ''
            show_startup_tips false
            on_force_close "quit"
            default_shell "nu"
            pane_frames false
            // auto_layout false
            // serialize_pane_viewport true
            scrollback_lines_to_serialize 10000
            // theme "stylix"

            simplified_ui false
            // default_layout "compact"
            // default_mode "locked"
            scroll_buffer_size 10000
            copy_command "wl-copy"                    // wayland
            // copy_clipboard "primary"
            copy_on_select true

            // stacked_resize false
            // show_release_notes false
            // advanced_mouse_actions false
            //mouse_mode false
            // mouse_hover_effects false
            // NOTE: This only applies to web clients at the moment."#;
            // client_async_worker_tasks 4
            // web_client {
            //    font "monospace"
            //}

            plugins {
              nvim-nav location="file:/home/xfo/.local/share/zellij/plugins/zellij-nvim-nav-plugin.wasm"
            }

            keybinds clear-defaults=true {
                shared_except "locked" {
                    bind "Alt Space" { SwitchToMode "Scroll"; }
                    bind "Alt Shift ;" { SwitchToMode "Session"; }
                    bind "Alt Ctrl d" { Quit; }
                    bind "Alt /" { SwitchToMode "EnterSearch"; SearchInput 0; }
                    bind "Alt Shift 5" { ToggleTab; }
                    bind "Alt l" { ToggleFloatingPanes; }
                    bind "Alt o" { TogglePaneEmbedOrFloating; }
                    bind "Alt d" { CloseFocus; }
                    bind "Alt U" { NewPane; }
                    bind "Alt u" { NewTab; }
                    bind "Alt C" { MoveTab "Left"; }
                    bind "Alt c" { MoveFocusOrTab "Left"; }
                    bind "Alt Ctrl n" { MovePane "Up"; }
                    bind "Alt n" { MoveFocus "Up"; }
                    bind "Alt e" { MoveFocus "Down"; }
                    bind "Alt Ctrl n" { MovePane "Down"; }
                    bind "Alt i" { MoveFocusOrTab "Right"; }
                    bind "Alt Ctrl i" { MoveTab "Right"; }
                    bind "Alt -" { Resize "Decrease"; }
                    bind "Alt Shift +" { Resize "Increase"; }
                    bind "Alt Ctrl C" { Resize "Left"; }
                    bind "Alt Ctrl N" { Resize "Up"; }
                    bind "Alt Ctrl E" { Resize "Down"; }
                    bind "Alt Ctrl I" { Resize "Right"; }
                    bind "Alt h" { ToggleFocusFullscreen; }
                    bind "Alt [" { PreviousSwapLayout; }
                    bind "Alt ]" { NextSwapLayout; }
                   // bind "Alt p" { TogglePaneInGroup; }
                   // bind "Alt Shift p" { ToggleGroupMarking; }
                    bind "Alt k" { ToggleActiveSyncTab; SwitchToMode "Normal"; }
                   // bind "b" { BreakPane; SwitchToMode "Normal"; }
                   // bind "]" { BreakPaneRight; SwitchToMode "Normal"; }
                   // bind "[" { BreakPaneLeft; SwitchToMode "Normal"; }
                   // bind "Alt %" { SwitchFocus; }
                    bind "Alt J" { SwitchToMode "RenamePane"; PaneNameInput 0;}
                    bind "Alt j" { SwitchToMode "RenameTab"; PaneNameInput 0;}
                }
                normal {
                    bind "Alt g" { SwitchToMode "Locked"; }
                }
                locked {
                    bind "Alt g" { SwitchToMode "Normal"; }
                }
                scroll {
                    bind "Esc" { SwitchToMode "Normal"; }
                    bind "y" { EditScrollback; SwitchToMode "Normal"; }
                    bind "/" { SwitchToMode "EnterSearch"; SearchInput 0; }
                    bind "$" { ScrollToBottom; SwitchToMode "Normal"; }
                    bind "PageUp" { PageScrollUp; }
                    bind "t" { HalfPageScrollUp; }
                    bind "n" { ScrollUp; }
                    bind "e" { ScrollDown; }
                    bind "a" { HalfPageScrollDown; }
                    bind "PageDown" { PageScrollDown; }
                    // uncomment this and adjust key if using copy_on_select=false
                    // bind "Alt c" { Copy; }
                }
                search {
                    bind "Esc" { SwitchToMode "Normal"; }
                    bind "Ctrl c" { Search "up"; }
                    bind "PageUp" { PageScrollUp; }
                    bind "t" { HalfPageScrollUp; }
                    bind "n" { ScrollUp; }
                    bind "e" { ScrollDown; }
                    bind "a" { HalfPageScrollDown; }
                    bind "PageDown"  { PageScrollDown; }
                    bind "$" { ScrollToBottom; SwitchToMode "Normal"; }
                    bind "Ctrl i" { Search "down"; }
                    // bind "c" { SearchToggleOption "CaseSensitivity"; }
                    // bind "w" { SearchToggleOption "Wrap"; }
                    // bind "o" { SearchToggleOption "WholeWord"; }
                }
                entersearch {
                    bind "Esc" { SwitchToMode "Normal"; }
                    bind "Alt Space" { SwitchToMode "Scroll"; }
                    bind "Enter" { SwitchToMode "Search"; }
                }
                renametab {
                    bind "Enter" { SwitchToMode "Normal"; }
                    bind "Esc" { UndoRenameTab; SwitchToMode "Tab"; }
                }
                renamepane {
                    bind "Enter" { SwitchToMode "Normal"; }
                    bind "Esc" { UndoRenamePane; SwitchToMode "Pane"; }
                }
                session {
                    bind "Esc" { SwitchToMode "Normal"; }
                    bind "v" { Detach; }
                    bind "q" { Quit; }
                    bind "w" {
                        LaunchOrFocusPlugin "session-manager" {
                            floating true
                            move_to_focused_tab true
                        };
                        SwitchToMode "Normal"
                    }
                    bind "c" {
                        LaunchOrFocusPlugin "configuration" {
                            floating true
                            move_to_focused_tab true
                        };
                        SwitchToMode "Normal"
                    }
                    bind "p" {
                        LaunchOrFocusPlugin "plugin-manager" {
                            floating true
                            move_to_focused_tab true
                        };
                        SwitchToMode "Normal"
                    }
                    bind "a" {
                        LaunchOrFocusPlugin "zellij:about" {
                            floating true
                            move_to_focused_tab true
                        };
                        SwitchToMode "Normal"
                    }
                    bind "s" {
                        LaunchOrFocusPlugin "zellij:share" {
                            floating true
                            move_to_focused_tab true
                        };
                        SwitchToMode "Normal"
                    }
                    bind "q" {
                        LaunchPlugin "zellij:sequence" {
                            floating true
                        };
                        SwitchToMode "Normal"
                    }
                    bind "l" {
                        LaunchOrFocusPlugin "zellij:layout-manager" {
                            floating true
                            move_to_focused_tab true
                        };
                        SwitchToMode "Normal"
                    }
                }
            }

            // Plugin aliases - can be used to change the implementation of Zellij
            // changing these requires a restart to take effect
            plugins {
                tab-bar location="zellij:tab-bar"
                status-bar location="zellij:status-bar"
                strider location="zellij:strider"
                compact-bar location="zellij:compact-bar"
                session-manager location="zellij:session-manager"
                filepicker location="zellij:strider" {
                    cwd "/"
                }
                configuration location="zellij:configuration"
                plugin-manager location="zellij:plugin-manager"
                about location="zellij:about"
                sequence location="zellij:sequence"
            }

            // Plugins to load in the background when a new session starts
            load_plugins {
              // "file:/path/to/my-plugin.wasm"
              // "https://example.com/my-plugin.wasm"
            }

          '';

          # themes = {
          #   kanso = ''
          #     themes {
          #     	kanso {
          #     		exit_code_error {
          #     			background "#000000"
          #     			base "#c4746e"
          #     			emphasis_0 "#c4b28a"
          #     			emphasis_1 "#1f1f26"
          #     			emphasis_2 "#b6927b"
          #     			emphasis_3 "#8992a7"
          #     		}
          #     		exit_code_success {
          #     			background "#000000"
          #     			base "#8a9a7b"
          #     			emphasis_0 "#8ea4a2"
          #     			emphasis_1 "#1f1f26"
          #     			emphasis_2 "#a292a3"
          #     			emphasis_3 "#8ba4b0"
          #     		}
          #     		frame_highlight {
          #     			background "#000000"
          #     			base "#c4746e"
          #     			emphasis_0 "#a292a3"
          #     			emphasis_1 "#b6927b"
          #     			emphasis_2 "#b6927b"
          #     			emphasis_3 "#b6927b"
          #     		}
          #     		frame_selected {
          #     			background "#000000"
          #     			base "#909398"
          #     			emphasis_0 "#b6927b"
          #     			emphasis_1 "#8ea4a2"
          #     			emphasis_2 "#a292a3"
          #     			emphasis_3 "#8ba4b0"
          #     		}
          #     		frame_unselected {
          #     			background "#000000"
          #     			base "#4b4e57"
          #     			emphasis_0 "#b6927b"
          #     			emphasis_1 "#8ea4a2"
          #     			emphasis_2 "#a292a3"
          #     			emphasis_3 "#8ba4b0"
          #     		}
          #     		list_selected {
          #     			background "#5c6066"
          #     			base "#c5c9c7"
          #     			emphasis_0 "#b6927b"
          #     			emphasis_1 "#8ea4a2"
          #     			emphasis_2 "#8a9a7b"
          #     			emphasis_3 "#a292a3"
          #     		}
          #     		list_unselected {
          #     			background "#1f1f26"
          #     			base "#c5c9c7"
          #     			emphasis_0 "#b6927b"
          #     			emphasis_1 "#8ea4a2"
          #     			emphasis_2 "#8a9a7b"
          #     			emphasis_3 "#a292a3"
          #     		}
          #     		multiplayer_user_colors {
          #     			player_1 "#a292a3"
          #     			player_2 "#8ba4b0"
          #     			player_3 "#8a9a7b"
          #     			player_4 "#c4b28a"
          #     			player_5 "#8ea4a2"
          #     			player_6 "#b6927b"
          #     			player_7 "#c4746e"
          #     			player_8 "#8992a7"
          #     			player_9 "#75797f"
          #     			player_10 "#A4A7A4"
          #     		}
          #     		ribbon_selected {
          #     			background "#8992a7"
          #     			base "#1f1f26"
          #     			emphasis_0 "#c4746e"
          #     			emphasis_1 "#b6927b"
          #     			emphasis_2 "#a292a3"
          #     			emphasis_3 "#8ba4b0"
          #     		}
          #     		ribbon_unselected {
          #     			background "#c5c9c7"
          #     			base "#1f1f26"
          #     			emphasis_0 "#c4746e"
          #     			emphasis_1 "#c5c9c7"
          #     			emphasis_2 "#8ba4b0"
          #     			emphasis_3 "#a292a3"
          #     		}
          #     		table_cell_selected {
          #     			background "#5c6066"
          #     			base "#c5c9c7"
          #     			emphasis_0 "#b6927b"
          #     			emphasis_1 "#8ea4a2"
          #     			emphasis_2 "#8a9a7b"
          #     			emphasis_3 "#a292a3"
          #     		}
          #     		table_cell_unselected {
          #     			background "#1f1f26"
          #     			base "#c5c9c7"
          #     			emphasis_0 "#b6927b"
          #     			emphasis_1 "#8ea4a2"
          #     			emphasis_2 "#8a9a7b"
          #     			emphasis_3 "#a292a3"
          #     		}
          #     		table_title {
          #     			background "#000000"
          #     			base "#8992a7"
          #     			emphasis_0 "#b6927b"
          #     			emphasis_1 "#8ea4a2"
          #     			emphasis_2 "#8a9a7b"
          #     			emphasis_3 "#a292a3"
          #     		}
          #     		text_selected {
          #     			background "#5c6066"
          #     			base "#c5c9c7"
          #     			emphasis_0 "#b6927b"
          #     			emphasis_1 "#8ea4a2"
          #     			emphasis_2 "#8a9a7b"
          #     			emphasis_3 "#a292a3"
          #     		}
          #     		text_unselected {
          #     			background "#1f1f26"
          #     			base "#c5c9c7"
          #     			emphasis_0 "#b6927b"
          #     			emphasis_1 "#8ea4a2"
          #     			emphasis_2 "#8a9a7b"
          #     			emphasis_3 "#a292a3"
          #     		}
          #     	}
          #     }
          #   '';
          #
          #   stylix = lib.mkForce ''
          #     themes {
          #     	default {
          #     		exit_code_error {
          #     			background "#000000"
          #     			base "#c4746e"
          #     			emphasis_0 "#c4b28a"
          #     			emphasis_1 "#000000"
          #     			emphasis_2 "#000000"
          #     			emphasis_3 "#000000"
          #     		}
          #     		exit_code_success {
          #     			background "#000000"
          #     			base "#8a9a7b"
          #     			emphasis_0 "#c5c9c7"
          #     			emphasis_1 "#1f1f26"
          #     			emphasis_2 "#b6927b"
          #     			emphasis_3 "#8ba4b0"
          #     		}
          #     		frame_highlight {
          #     			background "#000000"
          #     			base "#c4746e"
          #     			emphasis_0 "#b6927b"
          #     			emphasis_1 "#c4b28a"
          #     			emphasis_2 "#c4b28a"
          #     			emphasis_3 "#c4b28a"
          #     		}
          #     		frame_selected {
          #     			background "#000000"
          #     			base "#8992a7"
          #     			emphasis_0 "#c4b28a"
          #     			emphasis_1 "#c5c9c7"
          #     			emphasis_2 "#b6927b"
          #     			emphasis_3 "#000000"
          #     		}
          #     		list_selected {
          #     			background "#75797f"
          #     			base "#c5c9c7"
          #     			emphasis_0 "#c4b28a"
          #     			emphasis_1 "#c5c9c7"
          #     			emphasis_2 "#8a9a7b"
          #     			emphasis_3 "#b6927b"
          #     		}
          #     		list_unselected {
          #     			background "#1f1f26"
          #     			base "#c5c9c7"
          #     			emphasis_0 "#c4b28a"
          #     			emphasis_1 "#c5c9c7"
          #     			emphasis_2 "#8a9a7b"
          #     			emphasis_3 "#b6927b"
          #     		}
          #     		multiplayer_user_colors {
          #     			player_1 "#b6927b"
          #     			player_10 "#000000"
          #     			player_2 "#8ba4b0"
          #     			player_3 "#000000"
          #     			player_4 "#c4b28a"
          #     			player_5 "#c5c9c7"
          #     			player_6 "#000000"
          #     			player_7 "#c4746e"
          #     			player_8 "#000000"
          #     			player_9 "#000000"
          #     		}
          #     		ribbon_selected {
          #     			background "#8992a7"
          #     			base "#1f1f26"
          #     			emphasis_0 "#c4746e"
          #     			emphasis_1 "#c4b28a"
          #     			emphasis_2 "#b6927b"
          #     			emphasis_3 "#8ba4b0"
          #     		}
          #     		ribbon_unselected {
          #     			background "#2a2a35"
          #     			base "#c5c9c7"
          #     			emphasis_0 "#c4746e"
          #     			emphasis_1 "#c5c9c7"
          #     			emphasis_2 "#8ba4b0"
          #     			emphasis_3 "#b6927b"
          #     		}
          #     		table_cell_selected {
          #     			background "#75797f"
          #     			base "#c5c9c7"
          #     			emphasis_0 "#c4b28a"
          #     			emphasis_1 "#c5c9c7"
          #     			emphasis_2 "#8a9a7b"
          #     			emphasis_3 "#b6927b"
          #     		}
          #     		table_cell_unselected {
          #     			background "#1f1f26"
          #     			base "#c5c9c7"
          #     			emphasis_0 "#c4b28a"
          #     			emphasis_1 "#c5c9c7"
          #     			emphasis_2 "#8a9a7b"
          #     			emphasis_3 "#b6927b"
          #     		}
          #     		table_title {
          #     			background "#000000"
          #     			base "#8992a7"
          #     			emphasis_0 "#c4b28a"
          #     			emphasis_1 "#c5c9c7"
          #     			emphasis_2 "#8a9a7b"
          #     			emphasis_3 "#b6927b"
          #     		}
          #     		text_selected {
          #     			background "#75797f"
          #     			base "#c5c9c7"
          #     			emphasis_0 "#c4b28a"
          #     			emphasis_1 "#c5c9c7"
          #     			emphasis_2 "#8a9a7b"
          #     			emphasis_3 "#b6927b"
          #     		}
          #     		text_unselected {
          #     			background "#1f1f26"
          #     			base "#c5c9c7"
          #     			emphasis_0 "#c4b28a"
          #     			emphasis_1 "#c5c9c7"
          #     			emphasis_2 "#8a9a7b"
          #     			emphasis_3 "#b6927b"
          #     		}
          #     	}
          #     }
          #   '';
          # };
        };

        programs.nushell.extraEnv = lib.mkIf config.programs.nushell.enable (
          lib.mkAfter ''
            if $nu.is-interactive and not ("ZELLIJ" in $env) and not ("WAYLAND_DISPLAY" in $env or "DISPLAY" in $env) {
                try { zellij attach --create } catch { }
            }
          ''
        );
      };

    persistUserIgnore =
      { hmConfig, ... }:
      {
        directories = [ "${hmConfig.xdg.cacheHome}/zellij" ];
      };
  };
}
