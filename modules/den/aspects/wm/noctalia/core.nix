{ inputs, ... }:
{
  flake-file.inputs.noctalia = {
    url = "gh:noctalia-dev/noctalia-shell/2461f871a602f9a5688b5b01dc19c6309dd0d519";
    inputs.noctalia-qs.follows = "noctalia-qs";
  };
  flake-file.inputs.noctalia-qs.url = "gh:noctalia-dev/noctalia-qs/07398e12b54f194e3a2d47c87e3fd10b8eeaa27d";

  den.aspects.noctalia.core =
    { user, ... }:
    {
      homeManager =
        {
          config,
          options,
          pkgs,
          lib,
          ...
        }:
        let
          noctalia-diff = pkgs.writeShellApplication {
            name = "noctalia-diff";
            runtimeInputs = [
              pkgs.bat-extras.batdiff
              pkgs.jq
            ];
            text = lib.replaceStrings [ "# syntax: bash\n" ] [ "" ] ''
              # syntax: bash
              batdiff <(jq -S . "${config.xdg.configHome}/noctalia/settings.json") \
              <(noctalia-shell ipc call state all | jq -S .settings)
            '';
          };
          d = inputs.self.lib.applyDefaults;
        in
        {
          imports = [ inputs.noctalia.homeModules.default ];
          home.packages = [ noctalia-diff ];
          services.polkit-gnome.enable = lib.mkOverride 900 false;

          programs = lib.optionalAttrs (options.programs ? niri) {
            niri.settings.spawn-at-startup = lib.mkAfter [
              { command = [ "noctalia-shell" ]; }
            ];

            noctalia-shell = {
              enable = lib.mkDefault true;
              package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
                calendarSupport = true;
              };

              plugins = d {
                version = 2;
                states.polkit-agent = {
                  enabled = true;
                  sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
                };
              };

              settings = {
                settingsVersion = lib.mkDefault 59;

                appLauncher = d {
                  enableClipboardHistory = true;
                  autoPasteClipboard = false;
                  enableClipPreview = true;
                  enableClipboardChips = true;
                  enableClipboardSmartIcons = true;
                  clipboardWrapText = true;
                  clipboardWatchTextCommand = "wl-paste --type text --watch cliphist store";
                  clipboardWatchImageCommand = "wl-paste --type image --watch cliphist store";
                  position = "center";
                  pinnedApps = [ ];
                  sortByMostUsed = true;
                  terminalCommand = user.terminal;
                  customLaunchPrefixEnabled = false;
                  customLaunchPrefix = "";
                  viewMode = "list";
                  showCategories = true;
                  iconMode = "tabler";
                  showIconBackground = false;
                  enableSettingsSearch = false;
                  enableWindowsSearch = false;
                  enableSessionSearch = false;
                  ignoreMouseInput = false;
                  screenshotAnnotationTool = "";
                  overviewLayer = false;
                  density = "default";
                };

                bar = d {
                  barType = "simple";
                  position = "top";
                  monitors = [ ];
                  screenOverrides = [ ];
                  density = "default";
                  showOutline = false;
                  showCapsule = false;
                  capsuleOpacity = 1;
                  capsuleColorKey = "none";
                  widgetSpacing = 0;
                  contentPadding = 2;
                  fontScale = 1;
                  useSeparateOpacity = false;
                  floating = false;
                  marginVertical = 4;
                  marginHorizontal = 4;
                  frameThickness = 8;
                  frameRadius = 12;
                  enableExclusionZoneInset = false;
                  outerCorners = true;
                  hideOnOverview = true;
                  displayMode = "always_visible";
                  autoHideDelay = 500;
                  autoShowDelay = 150;
                  showOnWorkspaceSwitch = true;
                  rightClickAction = "controlCenter";
                  rightClickCommand = "";
                  rightClickFollowMouse = true;
                  middleClickAction = "none";
                  middleClickCommand = "";
                  middleClickFollowMouse = true;
                  mouseWheelAction = "none";
                  mouseWheelWrap = true;
                  reverseScroll = false;
                  widgets = {
                    left = [
                      {
                        id = "ActiveWindow";
                        colorizeIcons = false;
                        hideMode = "hidden";
                        maxWidth = 300;
                        scrollingMode = "hover";
                        showIcon = true;
                        textColor = "none";
                        useFixedWidth = false;
                      }
                    ];
                    center = [
                      {
                        id = "Workspace";
                        characterCount = 2;
                        colorizeIcons = false;
                        emptyColor = "secondary";
                        enableScrollWheel = true;
                        focusedColor = "primary";
                        followFocusedScreen = false;
                        groupedBorderOpacity = 1;
                        hideUnoccupied = true;
                        iconScale = 0.8;
                        fontWeight = "bold";
                        labelMode = "index";
                        occupiedColor = "secondary";
                        pillSize = 0.6;
                        showApplications = true;
                        showApplicationsHover = false;
                        showBadge = true;
                        showLabelsOnlyWhenOccupied = true;
                        unfocusedIconsOpacity = 0.8;
                      }
                    ];
                    right = [
                      {
                        id = "MediaMini";
                        compactMode = false;
                        hideMode = "idle";
                        hideWhenIdle = false;
                        maxWidth = 500;
                        panelShowAlbumArt = true;
                        scrollingMode = "hover";
                        showAlbumArt = false;
                        showArtistFirst = true;
                        showProgressRing = true;
                        showVisualizer = false;
                        textColor = "none";
                        useFixedWidth = false;
                        visualizerType = "wave";
                      }
                      {
                        id = "Tray";
                        blacklist = [ ];
                        chevronColor = "none";
                        colorizeIcons = false;
                        drawerEnabled = true;
                        hidePassive = false;
                        pinned = [
                          "Caprine"
                          "steam"
                        ];
                      }
                      {
                        id = "SystemMonitor";
                        compactMode = true;
                        diskPath = "/";
                        iconColor = "none";
                        showCpuUsage = true;
                        showCpuCores = false;
                        showCpuFreq = false;
                        showCpuTemp = false;
                        showDiskAvailable = false;
                        showDiskUsage = false;
                        showDiskUsageAsPercent = false;
                        showGpuTemp = false;
                        showLoadAverage = false;
                        showMemoryAsPercent = true;
                        showMemoryUsage = true;
                        showNetworkStats = false;
                        showSwapUsage = false;
                        textColor = "none";
                        useMonospaceFont = true;
                        usePadding = false;
                      }
                      {
                        id = "Clock";
                        clockColor = "none";
                        customFont = "";
                        formatHorizontal = "h:mm AP";
                        formatVertical = "HH mm";
                        tooltipFormat = "HH:mm ddd, MMM dd";
                        useCustomFont = false;
                      }
                      {
                        id = "Volume";
                        displayMode = "onhover";
                        iconColor = "none";
                        middleClickCommand = "pwvucontrol || pavucontrol";
                        textColor = "none";
                      }
                      {
                        id = "NotificationHistory";
                        hideWhenZero = false;
                        hideWhenZeroUnread = false;
                        iconColor = "none";
                        showUnreadBadge = true;
                        unreadBadgeColor = "primary";
                      }
                    ];
                  };
                };

                dock = d {
                  enabled = false;
                  showDockIndicator = true;
                  launcherIcon = "";
                  launcherUseDistroLogo = false;
                  position = "bottom";
                  displayMode = "auto_hide";
                  dockType = "floating";
                  backgroundOpacity = 1;
                  floatingRatio = 1;
                  size = 1;
                  onlySameOutput = true;
                  monitors = [ ];
                  pinnedApps = [ ];
                  colorizeIcons = false;
                  showLauncherIcon = false;
                  launcherPosition = "end";
                  launcherIconColor = "none";
                  pinnedStatic = false;
                  inactiveIndicators = false;
                  indicatorColor = "primary";
                  indicatorOpacity = 0.6;
                  indicatorThickness = 3;
                  groupApps = false;
                  groupContextMenuMode = "extended";
                  groupClickAction = "cycle";
                  groupIndicatorStyle = "dots";
                  deadOpacity = 0.6;
                  animationSpeed = 1;
                  sitOnFrame = false;
                };

                general = d {
                  avatarImage = "";
                  language = "";
                  telemetryEnabled = false;
                  showChangelogOnStartup = true;
                  dimmerOpacity = 0.2;
                  showScreenCorners = true;
                  forceBlackScreenCorners = true;
                  scaleRatio = 1;
                  radiusRatio = 1;
                  iRadiusRatio = 1;
                  boxRadiusRatio = 1;
                  screenRadiusRatio = 1;
                  animationSpeed = 1;
                  animationDisabled = false;
                  allowPanelsOnScreenWithoutBar = true;
                  reverseScroll = false;
                  compactLockScreen = false;
                  lockScreenAnimations = true;
                  lockOnSuspend = true;
                  showSessionButtonsOnLockScreen = true;
                  showHibernateOnLockScreen = false;
                  enableLockScreenCountdown = true;
                  enableLockScreenMediaControls = true;
                  lockScreenCountdownDuration = 10000;
                  autoStartAuth = false;
                  allowPasswordWithFprintd = false;
                  enableBlurBehind = true;
                  clockStyle = "digital";
                  clockFormat = "hh\\nmm";
                  passwordChars = false;
                  lockScreenMonitors = [ ];
                  lockScreenBlur = 0.6;
                  lockScreenTint = 0;
                  enableShadows = true;
                  shadowDirection = "bottom_right";
                  shadowOffsetX = 2;
                  shadowOffsetY = 3;
                  keybinds = {
                    keyUp = [ "Up" ];
                    keyDown = [ "Down" ];
                    keyLeft = [ "Left" ];
                    keyRight = [ "Right" ];
                    keyEnter = [
                      "Return"
                      "Enter"
                    ];
                    keyEscape = [ "Esc" ];
                    keyRemove = [ "Del" ];
                  };
                };

                idle = d {
                  enabled = true;
                  fadeDuration = 5;
                  screenOffTimeout = 300;
                  screenOffCommand = "";
                  resumeScreenOffCommand = "";
                  lockTimeout = 600;
                  lockCommand = "";
                  resumeLockCommand = "";
                  suspendTimeout = 0;
                  suspendCommand = "";
                  resumeSuspendCommand = "";
                  customCommands = "[]";
                };

                notifications = d {
                  enabled = true;
                  density = "default";
                  location = "top_right";
                  overlayLayer = true;
                  backgroundOpacity = 0.9;
                  monitors = [ ];
                  respectExpireTimeout = false;
                  lowUrgencyDuration = 3;
                  normalUrgencyDuration = 8;
                  criticalUrgencyDuration = 15;
                  clearDismissed = true;
                  enableMarkdown = false;
                  saveToHistory = d {
                    low = true;
                    normal = true;
                    critical = true;
                  };
                  sounds = d {
                    enabled = false;
                    volume = 0.5;
                    separateSounds = false;
                    criticalSoundFile = "";
                    normalSoundFile = "";
                    lowSoundFile = "";
                    excludedApps = "discord,firefox,chrome,chromium,edge";
                  };
                  enableMediaToast = false;
                  enableKeyboardLayoutToast = true;
                  enableBatteryToast = true;
                };

                sessionMenu = d {
                  position = "center";
                  showHeader = true;
                  showKeybinds = true;
                  largeButtonsStyle = true;
                  largeButtonsLayout = "grid";
                  enableCountdown = true;
                  countdownDuration = 10000;
                  powerOptions = [
                    {
                      action = "lock";
                      command = "";
                      countdownEnabled = true;
                      enabled = true;
                      keybind = "1";
                    }
                    {
                      action = "suspend";
                      command = "";
                      countdownEnabled = true;
                      enabled = true;
                      keybind = "2";
                    }
                    {
                      action = "hibernate";
                      command = "";
                      countdownEnabled = true;
                      enabled = true;
                      keybind = "3";
                    }
                    {
                      action = "logout";
                      command = "";
                      countdownEnabled = true;
                      enabled = true;
                      keybind = "4";
                    }
                    {
                      action = "reboot";
                      command = "";
                      countdownEnabled = true;
                      enabled = true;
                      keybind = "5";
                    }
                    {
                      action = "shutdown";
                      command = "";
                      countdownEnabled = true;
                      enabled = true;
                      keybind = "6";
                    }
                    {
                      action = "rebootToUefi";
                      command = "";
                      countdownEnabled = true;
                      enabled = false;
                      keybind = "7";
                    }
                    {
                      action = "userspaceReboot";
                      command = "";
                      countdownEnabled = true;
                      enabled = false;
                      keybind = "";
                    }
                  ];
                };

                network = d {
                  wifiEnabled = true;
                  airplaneModeEnabled = false;
                  bluetoothAutoConnect = false;
                  disableDiscoverability = false;
                  bluetoothRssiPollingEnabled = false;
                  bluetoothRssiPollIntervalMs = 60000;
                  bluetoothHideUnnamedDevices = false;
                  networkPanelView = "wifi";
                  wifiDetailsViewMode = "grid";
                  bluetoothDetailsViewMode = "grid";
                };

                audio = d {
                  volumeStep = 5;
                  volumeOverdrive = true;
                  volumeFeedback = false;
                  volumeFeedbackSoundFile = "";
                  preferredPlayer = "";
                  mprisBlacklist = [ ];
                  spectrumFrameRate = 30;
                  visualizerType = "linear";
                };

                brightness = d {
                  brightnessStep = 5;
                  enforceMinimum = true;
                  enableDdcSupport = false;
                  backlightDeviceMappings = [ ];
                };

                location = d {
                  name = "fresno";
                  weatherEnabled = true;
                  weatherShowEffects = true;
                  useFahrenheit = false;
                  showWeekNumberInCalendar = true;
                  showCalendarEvents = true;
                  showCalendarWeather = true;
                  analogClockInCalendar = false;
                  firstDayOfWeek = 1;
                  use12hourFormat = false;
                  hideWeatherTimezone = false;
                  hideWeatherCityName = false;
                };

                noctaliaPerformance = d {
                  disableWallpaper = true;
                  disableDesktopWidgets = true;
                };

                hooks = d {
                  enabled = false;
                  startup = "";
                  session = "";
                  wallpaperChange = "";
                  darkModeChange = "";
                  colorGeneration = "";
                  screenLock = "";
                  screenUnlock = "";
                  performanceModeEnabled = "";
                  performanceModeDisabled = "";
                };

                systemMonitor = d {
                  useCustomColors = false;
                  warningColor = "";
                  criticalColor = "";
                  cpuWarningThreshold = 80;
                  cpuCriticalThreshold = 90;
                  tempWarningThreshold = 80;
                  tempCriticalThreshold = 90;
                  enableDgpuMonitoring = false;
                  gpuWarningThreshold = 80;
                  gpuCriticalThreshold = 90;
                  memWarningThreshold = 80;
                  memCriticalThreshold = 90;
                  swapWarningThreshold = 80;
                  swapCriticalThreshold = 90;
                  diskWarningThreshold = 80;
                  diskCriticalThreshold = 90;
                  diskAvailWarningThreshold = 20;
                  diskAvailCriticalThreshold = 10;
                  batteryWarningThreshold = 20;
                  batteryCriticalThreshold = 5;
                  externalMonitor = "resources || missioncenter || jdsystemmonitor || corestats || system-monitoring-center || gnome-system-monitor || plasma-systemmonitor || mate-system-monitor || ukui-system-monitor || deepin-system-monitor || pantheon-system-monitor";
                };

                ui = d {
                  tooltipsEnabled = true;
                  boxBorderEnabled = false;
                  translucentWidgets = true;
                  panelBackgroundOpacity = 0.9;
                  scrollbarAlwaysVisible = true;
                  panelsAttachedToBar = true;
                  settingsPanelMode = "attached";
                  settingsPanelSideBarCardStyle = false;
                  fontDefaultScale = 1;
                  fontFixedScale = 1;
                };

                calendar.cards = lib.mkDefault [
                  {
                    enabled = true;
                    id = "calendar-header-card";
                  }
                  {
                    enabled = true;
                    id = "calendar-month-card";
                  }
                  {
                    enabled = true;
                    id = "weather-card";
                  }
                ];

                controlCenter = d {
                  position = "close_to_bar_button";
                  diskPath = "/";
                  shortcuts = {
                    left = [
                      { id = "Network"; }
                      { id = "Bluetooth"; }
                      { id = "WallpaperSelector"; }
                      { id = "NoctaliaPerformance"; }
                    ];
                    right = [
                      { id = "Notifications"; }
                      { id = "PowerProfile"; }
                      { id = "KeepAwake"; }
                      { id = "NightLight"; }
                    ];
                  };
                  cards = [
                    {
                      enabled = true;
                      id = "profile-card";
                    }
                    {
                      enabled = false;
                      id = "shortcuts-card";
                    }
                    {
                      enabled = true;
                      id = "audio-card";
                    }
                    {
                      enabled = false;
                      id = "brightness-card";
                    }
                    {
                      enabled = true;
                      id = "weather-card";
                    }
                    {
                      enabled = true;
                      id = "media-sysmon-card";
                    }
                  ];
                };

                osd = d {
                  enabled = true;
                  location = "top_right";
                  autoHideMs = 2000;
                  overlayLayer = true;
                  backgroundOpacity = 1;
                  enabledTypes = [
                    0
                    1
                    2
                  ];
                  monitors = [ ];
                };

                colorSchemes = d {
                  darkMode = true;
                  schedulingMode = "off";
                  manualSunrise = "06:30";
                  manualSunset = "18:30";
                  useWallpaperColors = false;
                  generationMethod = "tonal-spot";
                  monitorForColors = "";
                };

                nightLight = d {
                  enabled = false;
                  forced = false;
                  autoSchedule = true;
                  nightTemp = "4000";
                  dayTemp = "6500";
                  manualSunrise = "06:30";
                  manualSunset = "18:30";
                };

                desktopWidgets = d {
                  enabled = false;
                  gridSnap = false;
                  gridSnapScale = false;
                  overviewEnabled = true;
                  monitorWidgets = [ ];
                };

                templates = d {
                  enableUserTheming = false;
                  activeTemplates = [ ];
                };

                wallpaper = d {
                  enabled = false;
                  setWallpaperOnAllMonitors = true;
                  skipStartupTransition = false;
                  directory = "${config.xdg.userDirs.pictures}/Wallpapers";
                  showHiddenFiles = false;
                  viewMode = "single";
                  fillMode = "crop";
                  fillColor = "#000000";
                  useSolidColor = false;
                  solidColor = "#1a1a2e";
                  panelPosition = "follow_bar";
                  hideWallpaperFilenames = false;
                  automationEnabled = true;
                  wallpaperChangeMode = "random";
                  randomIntervalSec = 180;
                  transitionDuration = 1500;
                  transitionType = [
                    "honeycomb"
                    "wipe"
                    "stripes"
                    "disc"
                  ];
                  transitionEdgeSmoothness = 0.05;
                  enableMultiMonitorDirectories = false;
                  monitorDirectories = [ ];
                  overviewEnabled = true;
                  overviewBlur = 0.4;
                  overviewTint = 0.6;
                  useWallhaven = false;
                  wallhavenQuery = "";
                  wallhavenSorting = "relevance";
                  wallhavenOrder = "desc";
                  wallhavenCategories = "110";
                  wallhavenPurity = "100";
                  wallhavenRatios = "";
                  wallhavenApiKey = "";
                  wallhavenResolutionMode = "atleast";
                  wallhavenResolutionWidth = "";
                  wallhavenResolutionHeight = "";
                  sortOrder = "name";
                  favorites = [ ];
                };

                plugins = {
                  autoUpdate = lib.mkDefault false;
                  notifyUpdates = lib.mkDefault false;
                };
              };
            };
          };
        };

      persistUser =
        { hmConfig, ... }:
        {
          directories = [
            "${hmConfig.xdg.cacheHome}/noctalia"
            "${hmConfig.xdg.cacheHome}/noctalia-qs"
            {
              directory = "${hmConfig.xdg.cacheHome}/cliphist";
              mode = "0700";
              how = "symlink";
              createLinkTarget = true;
            }
            {
              directory = "${hmConfig.xdg.configHome}/noctalia/colorschemes";
              how = "symlink";
              createLinkTarget = true;
            }
            {
              directory = "${hmConfig.xdg.configHome}/noctalia/plugins/polkit-agent";
              how = "symlink";
              createLinkTarget = true;
            }
          ];
        };

      persistUserTmp =
        { hmConfig, ... }:
        {
          "${hmConfig.xdg.cacheHome}" = { };
          "${hmConfig.xdg.configHome}" = { };
          "${hmConfig.xdg.configHome}/noctalia" = { };
          "${hmConfig.xdg.configHome}/noctalia/plugins" = { };
        };

      persistUserIgnore =
        { hmConfig, ... }:
        {
          files = [ "${hmConfig.xdg.configHome}/noctalia/colors.json" ];
        };
    };
}
