{
  flake-file.inputs.concord.url = "gh:chojs23/concord";

  den.aspects.messaging.discord.concord =
    { host, ... }:
    {
      homeManager =
        {
          lib,
          pkgs,
          inputs',
          ...
        }:
        let
          tomlFormat = pkgs.formats.toml { };
        in
        lib.mkIf (host.settings.capabilities.workstation.enable or false) {
          home.packages = [ inputs'.concord.packages.default ];

          xdg.configFile."concord/config.toml".source = lib.mkDefault (
            tomlFormat.generate "concord-config.toml" {
              display = {
                disable_image_preview = false;
                show_avatars = true;
                show_images = true;
                image_preview_quality = "balanced";
                show_custom_emoji = true;
                circular_avatars = false;
              };

              notifications = {
                desktop_notifications = true;
              };

              voice = {
                self_mute = false;
                self_deaf = false;
                allow_microphone_transmit = false;
                microphone_sensitivity = -30;
                microphone_volume = 100;
                voice_output_volume = 100;
              };
            }
          );

          # Colemak: n=up e=down c=left i=right
          # Custom: x=insert (StartComposer), <leader>e=edit, <leader>c=cast vote
          xdg.configFile."concord/keymap.toml".text = lib.mkDefault ''
            [keymap]
            leader = "space"
            StartComposer = "x"
            OpenPaneFilter = "/"
            FocusGuildPane = "1"
            FocusChannelPane = "2"
            FocusMessagePane = "3"
            FocusMemberPane = "4"
            SelectNext = "e"
            SelectPrevious = "n"
            CycleFocusNext = { keys = ["tab", "i", "right"] }
            CycleFocusPrevious = { keys = ["<S-tab>", "c", "left"] }
            HalfPageDown = "<C-d>"
            HalfPageUp = "<C-u>"
            ScrollMessageViewportDown = "E"
            ScrollMessageViewportUp = "N"
            JumpTop = "g"
            JumpBottom = "G"
            ScrollHorizontalLeft = "C"
            ScrollHorizontalRight = "I"
            ResizePaneLeft = { keys = ["<A-c>", "<A-left>"] }
            ResizePaneRight = { keys = ["<A-i>", "<A-right>"] }
            Quit = "q"
            CopyMessage = "y"
            ReactMessage = "r"
            ReplyMessage = "R"
            DeleteMessage = "d"
            EditMessage = "<leader>e"
            OpenMessageUrl = "o"
            ViewMessageAttachment = "v"
            ShowMessageProfile = "p"
            PinMessage = "P"
            OpenThread = "t"
            ShowReactionUsers = "u"
            OpenPollVotePicker = "<leader>c"
            ToggleGuildPane = "<leader>1"
            ToggleChannelPane = "<leader>2"
            ToggleMemberPane = "<leader>4"
            OpenFocusedPaneAction = "<leader>a"
            OpenOptions = "<leader>o"
            ChannelSwitcher = "<leader><leader>"
            VoiceDeafen = "<leader>vd"
            VoiceMute = "<leader>vm"
            VoiceLeave = "<leader>vl"

            [keymap.groups]
            "<leader>v" = "Voice"

            [keymap.guild_actions]
            MarkAsRead = "m"
            MuteServer = "u"
            LeaveServer = "l"

            [keymap.channel_actions]
            JoinVoice = "j"
            LeaveVoice = "l"
            ShowPinnedMessages = "p"
            ShowThreads = "t"
            MarkAsRead = "m"
            MuteChannel = "u"

            [keymap.member_actions]
            ShowProfile = "p"

            [keymap.composer]
            OpenEditor = "<C-e>"
            PasteClipboard = "<C-v>"
            InsertNewline = { keys = ["<S-enter>", "<C-enter>", "<A-enter>"] }
            Submit = "enter"
            Close = "esc"
            ClearInput = "<C-c>"
            RemoveLastAttachment = "delete"
            DeletePreviousChar = "backspace"
            DeletePreviousWord = { keys = ["<C-backspace>", "<C-w>"] }
            MoveCursorUp = "up"
            MoveCursorDown = "down"
            MoveCursorWordLeft = "<C-left>"
            MoveCursorLeft = "left"
            MoveCursorWordRight = "<C-right>"
            MoveCursorRight = "right"
            MoveCursorHome = "home"
            MoveCursorEnd = "end"
          '';
        };

      persistUser =
        { hmConfig, ... }:
        {
          files = [
            {
              file = "${hmConfig.xdg.configHome}/concord/credential";
              mode = "0600";
            }
          ];
        };

      persistUserTmp =
        { hmConfig, ... }:
        {
          "${hmConfig.xdg.configHome}" = { };
          "${hmConfig.xdg.configHome}/concord" = {
            mode = "0700";
          };
        };

      persistUserIgnore =
        { hmConfig, ... }:
        {
          files = [ "${hmConfig.xdg.configHome}/concord/concord.log" ];
        };
    };
}
