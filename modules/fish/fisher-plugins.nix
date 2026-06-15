# modules/fish/fisher-plugins.nix - Optional Fisher plugin management
{ pkgs, lib, ... }:

{
  # Use Nix-native Fish plugins instead of Fisher for better reproducibility
  programs.fish.plugins = [
    {
      name = "z";
      src = pkgs.fetchFromGitHub {
        owner = "jethrokuan";
        repo = "z";
        rev = "e0e1b57";
        sha256 = "sha256-+FUBM7CodtZrYKqU542fQD+ZDGrd2438trKM0tIESs0=";
      };
    }
    {
      name = "done";
      src = pkgs.fetchFromGitHub {
        owner = "franciscolourenco";
        repo = "done";
        rev = "eb32ade";
        sha256 = "sha256-DMIRKRAVOn7YEnuAtz4hIxrU93ULxNoQhW6juxCoh4o=";
      };
    }
  ];

  # AeroSpace configuration (this should probably be in a separate module)
  home.file.".aerospace.toml".text = ''
    # AeroSpace Configuration

    # Basic settings
    start-at-login = true
    automatically-unhide-macos-hidden-apps = true
    accordion-padding = 30
    default-root-container-layout = 'tiles'
    default-root-container-orientation = 'auto'

    # Gaps between windows
    gaps.inner.horizontal = 0
    gaps.inner.vertical = 0
    gaps.outer.left = 0
    gaps.outer.bottom = 0
    gaps.outer.top = 0
    gaps.outer.right = 0

    # Define workspaces with meaningful names
    [workspace-to-monitor-force-assignment]
    1 = 'main'  # Browser
    2 = 'main'  # Code
    3 = 'main'  # Dev Tools
    4 = 'main'  # Distractions

    # Key bindings
    [mode.main.binding]
    # Workspace navigation
    ctrl-1 = 'workspace 1'
    ctrl-2 = 'workspace 2'
    ctrl-minus = 'workspace 3'
    ctrl-equal = 'workspace 4'

    # Move window to workspace
    alt-shift-1 = 'move-node-to-workspace 1'
    alt-shift-2 = 'move-node-to-workspace 2'
    alt-shift-3 = 'move-node-to-workspace 3'
    alt-shift-4 = 'move-node-to-workspace 4'

    # Window management
    alt-h = 'focus left'
    alt-j = 'focus down'
    alt-k = 'focus up'
    alt-l = 'focus right'

    cmd-shift-h = 'move left'
    cmd-shift-j = 'move down'
    cmd-shift-k = 'move up'
    cmd-shift-l = 'move right'

    # Layout management
    cmd-shift-space = 'layout floating tiling'
    alt-comma = 'layout accordion horizontal vertical'
    alt-shift-comma = 'layout tiles horizontal vertical'  # Toggle side-by-side / stacked

    # ==========================================
    # WORKSPACE 1: BROWSER
    # ==========================================
    [[on-window-detected]]
    if.app-id = 'company.thebrowser.Browser'  # Arc Browser
    run = 'move-node-to-workspace 1'

    [[on-window-detected]]
    if.app-id = 'com.google.Chrome'  # Chrome
    run = 'move-node-to-workspace 1'

    [[on-window-detected]]
    if.app-id = 'com.apple.Safari'  # Safari
    run = 'move-node-to-workspace 1'

    # ==========================================
    # WORKSPACE 2: CODE EDITOR
    # ==========================================
    [[on-window-detected]]
    if.app-id = 'com.microsoft.VSCode'  # Visual Studio Code
    run = 'move-node-to-workspace 2'

    # ==========================================
    # WORKSPACE 3: DEVELOPMENT TOOLS
    # ==========================================
    [[on-window-detected]]
    if.app-id = 'com.apple.Terminal'  # Terminal
    run = 'move-node-to-workspace 3'

    [[on-window-detected]]
    if.app-id = 'dev.warp.Warp-Stable'  # Warp Terminal
    run = 'move-node-to-workspace 3'

    [[on-window-detected]]
    if.app-id = 'com.postgresapp.Postgres2'  # Postgres.app
    run = 'move-node-to-workspace 3'

    [[on-window-detected]]
    if.app-id = 'com.DanPristupov.Fork'  # Fork Git client (note: removed space)
    run = 'move-node-to-workspace 3'

    [[on-window-detected]]
    if.app-id = 'com.hankinsoft.osx.sqliteprofessional'  # SQLite Pro
    run = 'move-node-to-workspace 3'

    [[on-window-detected]]
    if.app-id = 'com.docker.docker'  # Docker Desktop
    run = 'move-node-to-workspace 3'

    # ==========================================
    # WORKSPACE 4: DISTRACTIONS
    # ==========================================
    [[on-window-detected]]
    if.app-id = 'com.tinyspeck.slackmacgap'  # Slack
    run = 'move-node-to-workspace 4'

    [[on-window-detected]]
    if.app-id = 'ru.keepcoder.Telegram'  # Telegram
    run = 'move-node-to-workspace 4'

    [[on-window-detected]]
    if.app-id = 'net.whatsapp.WhatsApp'  # WhatsApp
    run = 'move-node-to-workspace 4'

    [[on-window-detected]]
    if.app-id = 'com.spotify.client'  # Spotify
    run = 'move-node-to-workspace 4'

    [[on-window-detected]]
    if.app-id = 'com.apple.Music'  # Apple Music
    run = 'move-node-to-workspace 4'

    [[on-window-detected]]
    if.app-id = 'com.apple.mail'  # Mail
    run = 'move-node-to-workspace 4'

  '';
}
