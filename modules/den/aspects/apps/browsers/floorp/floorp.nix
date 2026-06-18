{ den, inputs, ... }:
{
  flake-file.inputs.betterfox = {
    url = "gh:yokoffing/Betterfox";
    flake = false;
  };
  flake-file.inputs.firefox-addons = {
    url = "git+https://gitlab.com/rycee/nur-expressions";
    flake = false;
  };

  den.aspects.browser.floorp = {
    includes = [ den.aspects.tridactyl ];

    homeManager =
      {
        config,
        pkgs,
        lib,
        ...
      }:
      let
        addons = import "${inputs.firefox-addons}/pkgs/firefox-addons" {
          inherit (pkgs) fetchurl lib stdenv;
          buildMozillaXpiAddon =
            (import "${inputs.firefox-addons}/lib/mozilla.nix" { inherit (pkgs) lib; })
              .mkBuildMozillaXpiAddon
              { inherit (pkgs) fetchurl stdenv; };
        };
        forceInstall = slug: {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
        };

        ublockFilterLists = [
          "ublock-filters"
          "ublock-badware"
          "ublock-privacy"
          "ublock-quick-fixes"
          "ublock-unbreak"
          "easylist"
          "adguard-generic"
          "adguard-mobile"
          "easyprivacy"
          "adguard-spyware"
          "adguard-spyware-url"
          "block-lan"
          "urlhaus-1"
          "curben-phishing"
          "plowe-0"
          "dpollock-0"
          "fanboy-cookiemonster"
          "ublock-cookies-easylist"
          "adguard-cookies"
          "ublock-cookies-adguard"
          "fanboy-social"
          "adguard-social"
          "fanboy-thirdparty_social"
          "easylist-chat"
          "easylist-newsletters"
          "easylist-notifications"
          "easylist-annoyances"
          "adguard-mobile-app-banners"
          "adguard-other-annoyances"
          "adguard-popup-overlays"
          "adguard-widgets"
          "ublock-annoyances"
          "DEU-0"
          "FRA-0"
          "NLD-0"
          "RUS-0"
          "https://raw.githubusercontent.com/yokoffing/filterlists/main/privacy_essentials.txt"
          "https://raw.githubusercontent.com/yokoffing/filterlists/main/annoyance_list.txt"
          "https://easylist-downloads.adblockplus.org/antiadblockfilters.txt"
          "https://raw.githubusercontent.com/liamengland1/miscfilters/master/antipaywall.txt"
          "https://raw.githubusercontent.com/iam-py-test/my_filters_001/main/antimalware.txt"
          "user-filters"
        ];

        floorpDesign = {
          globalConfigs = {
            userInterface = "lepton";
            faviconColor = false;
            appliedUserJs = "";
          };
          tabbar = {
            tabbarStyle = "horizontal";
            tabbarPosition = "default";
            multiRowTabBar = {
              maxRowEnabled = false;
              maxRow = 3;
            };
          };
          tab = {
            tabScroll = {
              enabled = false;
              reverse = false;
              wrap = false;
            };
            tabMinHeight = 30;
            tabMinWidth = 76;
            tabPinTitle = false;
            tabDubleClickToClose = false;
            tabOpenPosition = -1;
          };
          uiCustomization = {
            navbar = {
              position = "top";
              searchBarTop = false;
            };
            display = {
              disableFullscreenNotification = false;
              deleteBrowserBorder = false;
            };
            special = {
              optimizeForTreeStyleTab = false;
              hideForwardBackwardButton = false;
              stgLikeWorkspaces = false;
            };
            multirowTab.newtabInsideEnabled = false;
            bookmarkBar = {
              focusExpand = false;
              position = "top";
            };
            qrCode.disableButton = false;
          };
        };

      in
      {
        programs.floorp = {
          enable = true;
          package = pkgs.floorp-bin;
          nativeMessagingHosts = [
            pkgs.tridactyl-native
            pkgs.ff2mpv
          ];

          policies = {
            DisableAppUpdate = true;
            ManualAppUpdateOnly = true;
            DisableTelemetry = true;
            DisablePocket = true;
            ExtensionUpdate = false;
            PasswordManagerEnabled = false;
            OfferToSaveLogins = false;

            ExtensionSettings = {
              "{09acf9ff-55d4-4366-a1a9-c9b3c8877c09}" = forceInstall "sink-it-for-reddit";
              "{3c6bf0cc-3ae2-42fb-9993-0d33104fdcaf}" = forceInstall "youtube-addon";
              "{333f4540-f467-419b-8410-233078ae8813}" = forceInstall "alihelper";
            };

            "3rdparty".Extensions = {
              "{446900e4-71c2-419f-a6a6-df9e8e6ee4d1}".environment = {
                base = "https://ao05.tail0df4ba.ts.net";
              };

              "uBlock0@raymondhill.net".adminSettings = {
                userSettings = {
                  uiTheme = "dark";
                  advancedUserEnabled = true;
                  userFiltersTrusted = true;
                  cloudStorageEnabled = false;
                  popupPanelSections = 31;
                };
                selectedFilterLists = ublockFilterLists;
              };

              "addon@darkreader.org" = {
                enabled = true;
                automation = {
                  enabled = true;
                  behavior = "OnOff";
                  mode = "system";
                };
                detectDarkTheme = true;
                enabledByDefault = true;
                changeBrowserTheme = false;
                enableForProtectedPages = true;
                fetchNews = false;
                syncSitesFixes = true;
                theme = {
                  mode = 1;
                  darkSchemeBackgroundColor = "#000000";
                  darkSchemeTextColor = config.lib.stylix.colors.withHashtag.base05;
                  brightness = 85;
                  contrast = 125;
                  grayscale = 10;
                  sepia = 10;
                };
              };
            };
          };

          profiles.xfo = {
            id = 0;
            isDefault = true;

            search = {
              force = true;
              default = "ddg";
              privateDefault = "ddg";
              order = [
                "ddg"
                "kagi"
                "nixsearch"
                "nix-packages"
                "nix-options"
                "hm-options"
                "noogle"
                "github"
                "wikipedia"
              ];
              engines = {
                nixsearch = {
                  name = "Nix Search";
                  urls = [ { template = "https://nixsearch.thekoppe.com/?q={searchTerms}"; } ];
                  icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                  definedAliases = [ "@nx" ];
                };
                kagi = {
                  name = "Kagi";
                  urls = [ { template = "https://kagi.com/search?q={searchTerms}"; } ];
                  icon = "https://kagi.com/favicon.ico";
                  updateInterval = 7 * 24 * 60 * 60 * 1000;
                  definedAliases = [ "@k" ];
                };
                nix-packages = {
                  name = "Nix Packages";
                  urls = [
                    { template = "https://search.nixos.org/packages?channel=unstable&query={searchTerms}"; }
                  ];
                  icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                  definedAliases = [ "@np" ];
                };
                nix-options = {
                  name = "NixOS Options";
                  urls = [
                    { template = "https://search.nixos.org/options?channel=unstable&query={searchTerms}"; }
                  ];
                  icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                  definedAliases = [ "@no" ];
                };
                hm-options = {
                  name = "Home Manager Options";
                  urls = [
                    { template = "https://home-manager-options.extranix.com/?query={searchTerms}&release=master"; }
                  ];
                  icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                  definedAliases = [ "@hm" ];
                };
                noogle = {
                  name = "Noogle";
                  urls = [ { template = "https://noogle.dev/q?term={searchTerms}"; } ];
                  icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                  definedAliases = [ "@nf" ];
                };
                github = {
                  name = "GitHub";
                  urls = [ { template = "https://github.com/search?q={searchTerms}&type=repositories"; } ];
                  icon = "https://github.com/favicon.ico";
                  updateInterval = 7 * 24 * 60 * 60 * 1000;
                  definedAliases = [ "@gh" ];
                };
                bing.metaData.hidden = true;
                google.metaData.hidden = true;
                amazondotcom-us.metaData.hidden = true;
                ebay.metaData.hidden = true;
              };
            };

            extensions = {
              force = true;
              packages = with addons; [
                ublock-origin
                bitwarden
                consent-o-matic
                ff2mpv
                tridactyl
                sponsorblock
                sidebery
                firenvim
                buster-captcha-solver
                darkreader
                refined-github
                dearrow
                return-youtube-dislikes
                violentmonkey
              ];
              settings."FirefoxColor@mozilla.com".settings.theme.colors = lib.mkForce (
                builtins.fromJSON (builtins.readFile ./set/floorp.colorTheme.json)
              );
            };

            userChrome = ''
              #TabsToolbar { visibility: collapse !important; }
              #search-container,
              #searchbar { display: none !important; }
            '';

            extraConfig = lib.concatMapStringsSep "\n" (f: builtins.readFile "${inputs.betterfox}/${f}") [
              "Fastfox.js"
              "Peskyfox.js"
            ];

            settings = {
              "browser.contentblocking.category" = "strict";
              "privacy.sanitize.sanitizeOnShutdown" = false;
              "privacy.clearOnShutdown.cookies" = false;
              "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
              "browser.startup.homepage" = "chrome://browser/content/blanktab.html";
              "browser.toolbars.bookmarks.visibility" = "never";
              # sideloaded (profile) extensions are auto-disabled by default; 0 = enable on first run
              "extensions.autoDisableScopes" = 0;
              "browser.uiCustomization.state" = builtins.toJSON (
                builtins.fromJSON (builtins.readFile ./set/floorp.uiState.json)
              );

              "ui.key.menuAccessKey" = 0;
              "ui.key.menuAccessKeyFocuses" = false;

              "widget.use-xdg-desktop-portal.file-picker" = 1;

              "floorp.browser.tabs.openNewTabPosition" = -1;
              "floorp.commandPalette.enabled" = true;
              "floorp.workspaces.enabled" = true;
              "floorp.zenmode.enabled" = false;
              # stale-pressedKeys bug fires wrong shortcut on first Ctrl chord
              # after a lost keyup (Floorp#2481); binds ported to tridactylrc
              "floorp.keyboardshortcut.enabled" = false;
              "floorp.mousegesture.enabled" = false;
              "floorp.panelSidebar.enabled" = false;
              "floorp.browser.ssb.enabled" = true;
              "floorp.browser.ssb.config" = builtins.toJSON { showToolbar = true; };
              "floorp.splitView.config" = builtins.toJSON {
                layout = "horizontal";
                maxPanes = 4;
              };
              "floorp.panelSidebar.config" = builtins.toJSON {
                autoUnload = false;
                position_start = true;
                globalWidth = 400;
                displayed = true;
                webExtensionRunningEnabled = false;
              };
              "floorp.workspaces.v4.config" = builtins.toJSON {
                manageOnBms = false;
                showWorkspaceNameOnToolbar = true;
                closePopupAfterClick = false;
                exitOnLastTabClose = false;
              };
              "floorp.design.configs" = builtins.toJSON floorpDesign;
            };
          };
        };

        stylix.targets.floorp = {
          profileNames = [ "xfo" ];
          colorTheme.enable = true;
        };

        home.file.".floorp/xfo/customKeys.json".source = ./set/floorp.customKeys.json;

        xdg.mimeApps.defaultApplications = {
          "text/html" = "floorp.desktop";
          "x-scheme-handler/http" = "floorp.desktop";
          "x-scheme-handler/https" = "floorp.desktop";
        };
        home.sessionVariables.BROWSER = lib.mkDefault "floorp";
      };

    persistUser =
      { hmConfig, ... }:
      {
        directories = [
          {
            directory = ".floorp";
            mode = "0700";
          }
          {
            directory = ".mozilla";
            mode = "0700";
          }
          {
            directory = "${hmConfig.xdg.cacheHome}/floorp";
            mode = "0700";
          }
        ];
      };

    persistUserIgnore =
      { hmConfig, ... }:
      {
        directories = [ "${hmConfig.xdg.cacheHome}/floorp" ];
      };
  };
}
