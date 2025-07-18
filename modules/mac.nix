{
  inputs,
  outputs,
  config,
  lib,
  hostname,
  system,
  username,
  pkgs,
  unstablePkgs,
  home,
  ...
}@args:
let
  inherit (inputs) nixpkgs nixpkgs-unstable;
in
{
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      warn-dirty = false;
    };
    channel.enable = false;
  };

  fonts.packages = [
    pkgs.nerd-fonts.fira-code
    pkgs.nerd-fonts.fira-mono
    pkgs.nerd-fonts.hack
    pkgs.nerd-fonts.jetbrains-mono
  ];
  # homebrew = {
  #   enable = true;

  #   onActivation = {
  #     cleanup = "zap";
  #     autoUpdate = true;
  #     upgrade = true;
  #   };
  #   global.autoUpdate = true;
  #   casks = [
  #     "arc"
  #     "nikitabobko/tap/aerospace"
  #     "postgres-unofficial"
  #     "telegram"
  #     "spotify"
  #   ];
  #   taps = [
  #     "homebrew/cask"
  #   ];
  #   brews = [
  #     "defaultbrowser"
  #     "gpg"
  #     "direnv"
  #   ];
  # };

  # Keyboard
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = false;

  # Add ability to used TouchID for sudo authentication
  # security.pam.enableSudotddouchIdAuth = true;

  # macOS configuration
  system.defaults = {
    NSGlobalDomain.AppleShowAllExtensions = true;
    NSGlobalDomain.AppleShowScrollBars = "Always";
    NSGlobalDomain.NSUseAnimatedFocusRing = false;
    NSGlobalDomain.NSNavPanelExpandedStateForSaveMode = true;
    NSGlobalDomain.NSNavPanelExpandedStateForSaveMode2 = true;
    NSGlobalDomain.PMPrintingExpandedStateForPrint = true;
    NSGlobalDomain.PMPrintingExpandedStateForPrint2 = true;
    NSGlobalDomain.NSDocumentSaveNewDocumentsToCloud = false;
    NSGlobalDomain.ApplePressAndHoldEnabled = false;
    NSGlobalDomain.InitialKeyRepeat = 25;
    NSGlobalDomain.KeyRepeat = 2;
    NSGlobalDomain."com.apple.mouse.tapBehavior" = 1;
    NSGlobalDomain."com.apple.swipescrolldirection" = false;
    NSGlobalDomain.NSWindowShouldDragOnGesture = true;
    NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
    LaunchServices.LSQuarantine = false; # disables "Are you sure?" for new apps
    loginwindow.GuestEnabled = false;

    screencapture.location = "~/Pictures/Screenshots";

    finder = {
      # Show hidden files and directories (including those starting with .)
      AppleShowAllFiles = true;

      # Show all filename extensions
      AppleShowAllExtensions = true;

      # Keep folders on top when sorting by name
      _FXSortFoldersFirst = true;

      # Show status bar (displays item count and available space)
      ShowStatusBar = true;

      # Show path bar at bottom of Finder windows
      ShowPathbar = true;

      # Default search scope: search current folder instead of entire Mac
      FXDefaultSearchScope = "SCcf";

      # Preferred view style: list view (others: icon, column, gallery)
      FXPreferredViewStyle = "Nlsv";

      # Show warning before changing file extensions
      FXEnableExtensionChangeWarning = false;
    };
  };

  system.defaults.CustomUserPreferences = {
    "com.apple.finder" = {
      ShowExternalHardDrivesOnDesktop = true;
      ShowHardDrivesOnDesktop = false;
      ShowMountedServersOnDesktop = false;
      ShowRemovableMediaOnDesktop = true;
      _FXSortFoldersFirst = true;
      # When performing a search, search the current folder by default
      FXDefaultSearchScope = "SCcf";
      DisableAllAnimations = true;
      NewWindowTarget = "PfDe";
      NewWindowTargetPath = "file://$\{HOME\}/Desktop/";
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
      ShowStatusBar = true;
      ShowPathbar = true;
      WarnOnEmptyTrash = false;
    };
    "com.apple.desktopservices" = {
      # Avoid creating .DS_Store files on network or USB volumes
      DSDontWriteNetworkStores = true;
      DSDontWriteUSBStores = true;
    };
    "com.apple.dock" = {
      autohide = true;
      launchanim = false;
      static-only = false;
      show-recents = false;
      show-process-indicators = true;
      orientation = "bottom";
      tilesize = 64;
      minimize-to-application = true;
      mineffect = "scale";
      enable-window-tool = false;
    };

    system.defaults.dock = {
      persistent-apps = [
        "/Applications/Arc.app"
        "/Applications/Launchpad.app"
        "/Applications/1Password.app"
        "/Applications/Visual Stddudio Code.app"
        "/Applications/Warp.app"
        "/Applications/Slack.app"
        "/Applications/Spotify.app"
      ];
    };

    "com.apple.ActivityMonitor" = {
      OpenMainWindow = true;
      IconType = 5;
      SortColumn = "CPUUsage";
      SortDirection = 0;
    };
    "com.apple.AdLib" = {
      allowApplePersonalizedAdvertising = false;
    };
    "com.apple.SoftwareUpdate" = {
      AutomaticCheckEnabled = true;
      # Check for software updates daily, not just once per week
      ScheduleFrequency = 1;
      # Download newly available updates in background
      AutomaticDownload = 1;
      # Install System data files & security updates
      CriticalUpdateInstall = 1;
    };
    "com.apple.TimeMachine".DoNotOfferNewDisksForBackup = true;
    # Prevent Photos from opening automatically when devices are plugged in
    "com.apple.ImageCapture".disableHotPlug = true;
    # Turn on app auto-update
    "com.apple.commerce".AutoUpdate = true;
    "com.googlecode.iterm2".PromptOnQuit = false;
    "com.google.Chrome" = {
      AppleEnableSwipeNavigateWithScrolls = true;
      DisablePrintPreview = true;
      PMPrintingExpandedStateForPrint2 = true;
    };
  };
  security.pam.services.sudo_local.touchIdAuth = true;

}
