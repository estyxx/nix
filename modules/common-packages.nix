{
  inputs,
  pkgs,
  ...
}:
let
  inherit (inputs) nixpkgs nixpkgs-unstable;
in
{
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    ## Build essentials and compilers (added for Python/asdf compilation)
    cmake # Build system generator
    gnumake # GNU Make
    autoconf # Generate configure scripts
    libtool # Generic library support script
    gcc # GNU Compiler Collection
    clang # LLVM Clang compiler
    llvm # LLVM compiler infrastructure

    ## Packages from Brewfile - Core development libraries
    automake # Generate Makefile.in files
    binutils # Binary utilities for development
    pkg-config # Package configuration tool
    readline # Command line editing library
    openssl # Cryptography and SSL/TLS toolkit (OpenSSL 3+)
    zlib # Compression library
    pcre # Perl Compatible Regular Expressions
    xz # LZMA compression utility
    libffi # Foreign Function Interface library
    gettext # Internationalization utilities

    ## Python development dependencies (essential for asdf Python builds)
    python3 # Default Python 3
    python312 # Specific Python 3.12
    python312Packages.pip # Python package installer
    bzip2 # Compression library (needed for Python)
    ncurses # Terminal control library (needed for Python)

    ## Note: memcached and libmemcached may not be available on macOS via Nix
    # memcached # Distributed memory caching system - use Homebrew instead
    # libmemcached # C library for memcached - use Homebrew instead

    ## System libraries from Brewfile
    file # File type identification (provides libmagic functionality)
    libxml2 # XML parsing library
    cairo # 2D graphics library

    ## Command line tools from Brewfile
    sqlite # Lightweight SQL database (sqlite3 in brew)
    wget # Download files from web via command line
    ripgrep # Extremely fast text search tool

    ## Note: oxipng may not be available on macOS via Nix
    # oxipng # PNG optimization tool - use Homebrew instead if needed

    ## Additional packages you had before (known to work on macOS)
    act # Run GitHub Actions locally
    asdf # Version manager for multiple languages
    awscli # AWS command line interface
    biome # Fast formatter and linter
    btop # Modern system monitor with beautiful UI
    diffr # Modern Unix `diff` with syntax highlighting
    difftastic # Modern Unix `diff` that understands code structure
    docker # Container platform
    docker-compose # Multi-container Docker applications
    drill # Clean DNS lookup tool
    du-dust # Modern Unix `du` with visual tree display
    dua # Modern Unix `du` with interactive navigation
    duf # Modern Unix `df` with colors and better formatting
    entr # Modern Unix `watch` - run commands when files change
    fastfetch # System info display tool
    fd # Fast and user-friendly alternative to `find`
    ffmpeg # Swiss army knife for video/audio processing
    figurine # ASCII art text generator
    fzf # Fuzzy finder
    gh # Official GitHub CLI
    git-crypt # Encrypt sensitive files in Git repos
    gnused # GNU version of sed (more features than BSD sed)
    htop # Interactive process viewer
    jq # JSON processor for command line
    mc # Midnight Commander visual file manager
    postgresql # PostgreSQL database
    terraform # Infrastructure as Code tool
    tree # Display directory structure as tree

    ## Modern CLI tools (additional useful ones)
    bat # Better cat with syntax highlighting
    eza # Better ls (successor to exa)
    git # Version control (ensure latest version)
    curl # Transfer data from servers
    vim # Text editor
    neovim # Modern Vim
    which # Locate commands
    lsof # List open files

    ## Compression utilities (additional)
    lz4 # Fast compression algorithm
    zstd # Fast compression with high ratios
    unzip # Extract ZIP archives
    gzip # GNU zip compression

    ## Core libraries for compatibility
    icu # International Components for Unicode
    pcre2 # Perl Compatible Regular Expressions v2

    ## Security and networking
    gnupg # GNU Privacy Guard
    openssh # Secure Shell
    netcat # Network utility

    ## Development utilities
    yq # YAML processor (complement to jq)
    pandoc # Document converter
    git-lfs # Git Large File Storage

    ## GUI Applications
    warp-terminal # Modern terminal
    vscode # Visual Studio Code
    raycast # Productivity app

    ## VS Code extensions (requires allowUnfree = true)
    vscode-extensions.ms-vscode-remote.remote-ssh
    nixfmt-rfc-style
  ];

  # Note: Some packages from your Brewfile should remain in Homebrew:
  # 1. Custom vendored packages (openssl@1.1, libxmlsec1) - these are custom formulas
  # 2. memcached/libmemcached - may not be available or work well on macOS via Nix
  # 3. postgres-unofficial (Postgres.app) - better managed via Homebrew cask
  # 4. PDK/Puppet packages - specialized tools better via Homebrew
}
